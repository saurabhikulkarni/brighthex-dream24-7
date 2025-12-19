# Complete Setup Instructions

## ✅ What's Been Created

### Backend Server (Node.js/Express)
All files are in the `backend/` directory:

- ✅ `server.js` - Main server file
- ✅ `routes/auth.js` - MSG91 OTP endpoints
- ✅ `routes/payments.js` - Razorpay endpoints
- ✅ `services/msg91Service.js` - MSG91 integration
- ✅ `services/razorpayService.js` - Razorpay integration
- ✅ `services/otpService.js` - OTP session management
- ✅ `package.json` - Dependencies
- ✅ `env.example` - Environment variables template
- ✅ `.gitignore` - Git ignore file
- ✅ `README.md` - Backend documentation

### Flutter Integration
- ✅ `lib/config/razorpay_backend_config.dart` - Backend URL config
- ✅ Updated `lib/config/msg91_config.dart` - Backend URL
- ✅ Updated `lib/services/razorpay_service.dart` - Uses backend URLs

---

## 🚀 Setup Steps

### Step 1: Create Separate Backend Directory

**Yes, you need a separate directory/repo for the backend!**

```bash
# Navigate to parent directory
cd C:\Users\91957\OneDrive\Desktop\shopping-app

# Create backend directory
mkdir shopping-app-backend
cd shopping-app-backend
```

### Step 2: Copy Backend Files

Copy all files from `brighthex-dream24-7/backend/` to `shopping-app-backend/`:

**Files to copy:**
- `server.js`
- `package.json`
- `env.example` (rename to `.env.example`)
- `.gitignore`
- `README.md`
- `routes/` folder (with all files)
- `services/` folder (with all files)

### Step 3: Install Dependencies

```bash
cd shopping-app-backend
npm install
```

### Step 4: Configure Environment Variables

```bash
# Copy example file
copy env.example .env

# Edit .env file and add your API keys
```

**Required API Keys:**

1. **MSG91:**
   - Sign up at https://control.msg91.com/
   - Get Auth Key from API section
   - Create OTP template and get Template ID
   - Set Sender ID (6 characters, e.g., "DREAM24")

2. **Razorpay:**
   - Sign up at https://razorpay.com/
   - Go to Dashboard → Settings → API Keys
   - Get Key ID and Key Secret
   - Use Test keys for development

**Example `.env`:**
```env
PORT=3000
NODE_ENV=development

MSG91_AUTH_KEY=1234567890abcdef
MSG91_TEMPLATE_ID=1234567890123456789
MSG91_SENDER_ID=DREAM24

RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxx

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### Step 5: Start Backend Server

```bash
# Development (auto-restart)
npm run dev

# Production
npm start
```

Server runs on `http://localhost:3000`

### Step 6: Update Flutter Config

**File: `lib/config/msg91_config.dart`**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**File: `lib/config/razorpay_backend_config.dart`**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

---

## 🧪 Testing

### Test Backend Endpoints

**1. Health Check:**
```bash
curl http://localhost:3000/health
```

**2. Send OTP:**
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d "{\"mobileNumber\": \"9876543210\"}"
```

**3. Create Razorpay Order:**
```bash
curl -X POST http://localhost:3000/api/payments/create-order \
  -H "Content-Type: application/json" \
  -d "{\"amount\": 1000, \"currency\": \"INR\"}"
```

### Test in Flutter App

1. Run Flutter app
2. Try login/signup (should call MSG91 backend)
3. Try wallet top-up (should call Razorpay backend)

---

## 🌐 Deployment

### Deploy Backend to Railway (Free & Easy)

1. Go to https://railway.app
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your `shopping-app-backend` repo
5. Add environment variables in Railway dashboard:
   - MSG91_AUTH_KEY
   - MSG91_TEMPLATE_ID
   - MSG91_SENDER_ID
   - RAZORPAY_KEY_ID
   - RAZORPAY_KEY_SECRET
   - ALLOWED_ORIGINS (your Flutter app domain)
6. Deploy!

### Update Flutter After Deployment

Update config files with Railway URL:
```dart
static const String baseUrl = 'https://your-app.railway.app/api';
```

---

## 📁 Final Structure

```
shopping-app/
├── brighthex-dream24-7/          # Flutter App
│   ├── lib/
│   │   ├── config/
│   │   │   ├── msg91_config.dart
│   │   │   └── razorpay_backend_config.dart
│   │   └── services/
│   │       ├── msg91_service.dart
│   │       └── razorpay_service.dart
│   └── ...
│
└── shopping-app-backend/          # Node.js Backend (NEW)
    ├── server.js
    ├── package.json
    ├── .env
    ├── routes/
    │   ├── auth.js
    │   └── payments.js
    └── services/
        ├── msg91Service.js
        ├── razorpayService.js
        └── otpService.js
```

---

## ✅ Checklist

- [ ] Created `shopping-app-backend` directory
- [ ] Copied all backend files
- [ ] Ran `npm install`
- [ ] Created `.env` file
- [ ] Added MSG91 API keys to `.env`
- [ ] Added Razorpay API keys to `.env`
- [ ] Started backend server (`npm run dev`)
- [ ] Tested health endpoint
- [ ] Tested send-otp endpoint
- [ ] Tested create-order endpoint
- [ ] Updated Flutter `msg91_config.dart` with backend URL
- [ ] Updated Flutter `razorpay_backend_config.dart` with backend URL
- [ ] Tested OTP flow in Flutter app
- [ ] Tested payment flow in Flutter app

---

## 🐛 Common Issues

### Backend won't start
- Check Node.js is installed: `node --version`
- Check dependencies: `npm install`
- Check `.env` file exists

### MSG91 not sending OTP
- Verify MSG91_AUTH_KEY is correct
- Check Template ID is valid
- Verify Sender ID is 6 characters
- Check MSG91 dashboard for API status

### Razorpay order creation fails
- Verify RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET
- Check keys are from same environment (test/live)
- Verify Razorpay account is activated

### CORS errors in Flutter
- Add Flutter app origin to `ALLOWED_ORIGINS` in `.env`
- Restart backend after changing `.env`

---

## 📚 Documentation Files

- `BACKEND_SERVER_SETUP.md` - Detailed backend setup
- `BACKEND_QUICK_START.md` - Quick start guide
- `MSG91_BACKEND_SETUP.md` - MSG91 specific setup
- `backend/README.md` - Backend API documentation

---

*Everything is ready! Just create the backend directory, copy files, install dependencies, and configure API keys.*
