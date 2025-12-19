# Backend Server Setup Guide

This guide helps you set up a separate Node.js/Express backend server for MSG91 OTP and Razorpay payment processing.

---

## 🎯 Why Separate Backend?

**Security Reasons:**
- MSG91 API key must be kept secret (never in frontend)
- Razorpay Key Secret must be kept secret (never in frontend)
- Payment signature verification requires secret key
- Rate limiting and security controls

**Architecture:**
```
Flutter App (Frontend)
    ↓
Backend Server (Node.js/Express) ← API Keys stored here
    ↓
External APIs (MSG91, Razorpay)
```

---

## 📁 Project Structure

Create a new directory for your backend:

```
shopping-app-backend/
├── package.json
├── .env
├── .env.example
├── .gitignore
├── server.js
├── routes/
│   ├── auth.js          # MSG91 OTP routes
│   └── payments.js      # Razorpay routes
├── services/
│   ├── msg91Service.js
│   ├── razorpayService.js
│   └── otpService.js
├── middleware/
│   ├── auth.js
│   └── rateLimiter.js
└── README.md
```

---

## 🚀 Quick Start

### Step 1: Create Backend Directory

```bash
# Create new directory (outside Flutter project)
mkdir shopping-app-backend
cd shopping-app-backend
```

### Step 2: Initialize Node.js Project

```bash
npm init -y
```

### Step 3: Install Dependencies

```bash
npm install express cors dotenv axios redis crypto express-rate-limit
npm install --save-dev nodemon
```

### Step 4: Create Files

Follow the implementation files provided below.

---

## 📝 Implementation Files

### 1. `package.json`

```json
{
  "name": "shopping-app-backend",
  "version": "1.0.0",
  "description": "Backend API for MSG91 OTP and Razorpay payments",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": ["express", "msg91", "razorpay", "otp"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "axios": "^1.6.0",
    "redis": "^4.6.10",
    "crypto": "^1.0.1",
    "express-rate-limit": "^7.1.3"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

### 2. `.env.example`

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MSG91 Configuration
MSG91_AUTH_KEY=your_msg91_auth_key_here
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_SENDER_ID=your_sender_id_here

# Razorpay Configuration
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Redis Configuration (Optional - for OTP sessions)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. `.gitignore`

```
node_modules/
.env
.DS_Store
*.log
dist/
coverage/
```

---

## 🔧 Complete Implementation

See the following files for complete code:
- `backend/server.js` - Main server file
- `backend/routes/auth.js` - MSG91 OTP routes
- `backend/routes/payments.js` - Razorpay routes
- `backend/services/msg91Service.js` - MSG91 service
- `backend/services/razorpayService.js` - Razorpay service
- `backend/services/otpService.js` - OTP session management

---

## 🔐 Environment Variables Setup

1. Copy `.env.example` to `.env`
2. Fill in your API keys:
   - Get MSG91 Auth Key from [MSG91 Dashboard](https://control.msg91.com/)
   - Get Razorpay keys from [Razorpay Dashboard](https://dashboard.razorpay.com/)

---

## 🚀 Running the Server

### Development Mode:
```bash
npm run dev
```

### Production Mode:
```bash
npm start
```

Server will run on `http://localhost:3000`

---

## 📡 API Endpoints

### MSG91 OTP Endpoints

- `POST /api/auth/send-otp`
  - Body: `{ "mobileNumber": "9876543210" }`
  - Response: `{ "success": true, "sessionId": "..." }`

- `POST /api/auth/verify-otp`
  - Body: `{ "mobileNumber": "9876543210", "otp": "123456", "sessionId": "..." }`
  - Response: `{ "success": true, "verified": true }`

### Razorpay Payment Endpoints

- `POST /api/payments/create-order`
  - Body: `{ "amount": 1000, "currency": "INR", "receipt": "order_123" }`
  - Response: `{ "orderId": "order_...", "amount": 1000, ... }`

- `POST /api/payments/verify-signature`
  - Body: `{ "orderId": "...", "paymentId": "...", "signature": "..." }`
  - Response: `{ "verified": true }`

---

## 🔗 Flutter Integration

After backend is running, update Flutter config:

### Update `lib/config/msg91_config.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api'; // Change to your deployed URL
```

### Update `lib/services/razorpay_service.dart`:
Add backend URLs for order creation and verification.

---

## 🌐 Deployment Options

### Free Options:
1. **Railway** - https://railway.app
2. **Render** - https://render.com
3. **Heroku** (limited free tier)
4. **Vercel** - https://vercel.com

### Paid Options:
1. **AWS EC2**
2. **DigitalOcean**
3. **Google Cloud Run**

---

## ✅ Testing

### Test MSG91 OTP:
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber": "9876543210"}'
```

### Test Razorpay:
```bash
curl -X POST http://localhost:3000/api/payments/create-order \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "currency": "INR"}'
```

---

## 📚 Next Steps

1. Create backend directory
2. Copy implementation files (provided separately)
3. Install dependencies
4. Set up environment variables
5. Test endpoints
6. Deploy backend
7. Update Flutter config with backend URL

---

*See the complete implementation files in the `backend/` directory.*
