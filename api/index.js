const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

const JWT_SECRET = 'secret_key_case2_taskmanager'; // Khóa bí mật mã hóa Token

// Kết nối DB (Thay bằng link MongoDB Atlas của bạn nếu có)
const MONGO_URI = "mongodb://localhost:27017/task_manager";
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ Đã kết nối MongoDB thành công'))
  .catch(err => console.error('❌ Lỗi kết nối MongoDB:', err));

// 1. Schema & Model NguoiDung (User)
const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

// Middleware kiểm tra JWT Token
const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ message: 'Không có token, từ chối truy cập!' });

  try {
    const verified = jwt.verify(token, JWT_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(400).json({ message: 'Token không hợp lệ!' });
  }
};

// 2. API Đăng ký (POST /api/auth/register)
app.post('/api/auth/register', async (req, res) => {
  try {
    const { fullName, email, password } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: 'Email này đã tồn tại!' });

    // Băm mật khẩu bằng bcrypt
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({ fullName, email, password: hashedPassword });
    await newUser.save();

    res.status(201).json({ message: 'Đăng ký tài khoản thành công!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ:', error: error.message });
  }
});

// 3. API Đăng nhập (POST /api/auth/login)
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng!' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng!' });

    // Cấp JWT Bearer Token
    const token = jwt.sign({ userId: user._id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: { id: user._id, fullName: user.fullName, email: user.email }
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ:', error: error.message });
  }
});

// 4. API Lấy thông tin cá nhân (GET /api/auth/me)
app.get('/api/auth/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ:', error: error.message });
  }
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
});