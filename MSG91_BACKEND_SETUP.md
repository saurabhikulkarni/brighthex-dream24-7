# MSG91 Backend API Setup Guide

This document provides instructions for setting up the backend API server for MSG91 OTP verification.

## Overview

The Flutter app uses MSG91 for OTP verification via a backend API. The backend server handles:
1. Sending OTP to user's mobile number using MSG91 API
2. Verifying OTP entered by the user
3. Managing OTP sessions and expiry

**Important**: MSG91 API key should **NEVER** be stored in the Flutter app. It must be kept secure on your backend server.

## Prerequisites

- MSG91 account with API key
- Backend server (Node.js/Express, Python/Flask, etc.)
- Database (MongoDB, PostgreSQL, Redis, etc.) for OTP session storage

## Backend Implementation

### Step 1: Install Dependencies (Node.js Example)

```bash
npm install express dotenv axios redis
# or
yarn add express dotenv axios redis
```

### Step 2: Environment Variables (.env)

Create a `.env` file in your backend project:

```env
# MSG91 Configuration
MSG91_AUTH_KEY=your_msg91_auth_key_here
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_SENDER_ID=YOUR_SENDER_ID

# Server Configuration
PORT=3000
NODE_ENV=development

# Redis Configuration (for OTP session storage)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Database Configuration (if using MongoDB/PostgreSQL)
DATABASE_URL=mongodb://localhost:27017/shopping-app
```

### Step 3: Create MSG91 Service (Backend)

Create `services/msg91Service.js`:

```javascript
const axios = require('axios');

class Msg91Service {
  constructor() {
    this.authKey = process.env.MSG91_AUTH_KEY;
    this.templateId = process.env.MSG91_TEMPLATE_ID;
    this.senderId = process.env.MSG91_SENDER_ID;
    this.baseUrl = 'https://control.msg91.com/api/v5/otp';
  }

  /**
   * Send OTP to mobile number
   * @param {string} mobileNumber - Mobile number (10 digits, no country code)
   * @returns {Promise<Object>} - { success: boolean, message: string, sessionId?: string }
   */
  async sendOtp(mobileNumber) {
    try {
      // MSG91 requires country code, add +91 for India
      const mobileWithCountryCode = `91${mobileNumber}`;

      const response = await axios.post(
        `${this.baseUrl}?authkey=${this.authKey}&template_id=${this.templateId}&mobile=${mobileWithCountryCode}&sender=${this.senderId}`,
        {},
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      // MSG91 returns different response formats, adjust based on your account type
      if (response.data && response.data.type === 'success') {
        return {
          success: true,
          message: 'OTP sent successfully',
          sessionId: response.data.request_id || null,
        };
      }

      return {
        success: false,
        message: response.data?.message || 'Failed to send OTP',
      };
    } catch (error) {
      console.error('MSG91 Send OTP Error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to send OTP. Please try again.',
      };
    }
  }

  /**
   * Verify OTP
   * @param {string} mobileNumber - Mobile number (10 digits)
   * @param {string} otp - OTP entered by user
   * @param {string} sessionId - Optional session ID from sendOtp response
   * @returns {Promise<Object>} - { success: boolean, message: string }
   */
  async verifyOtp(mobileNumber, otp, sessionId = null) {
    try {
      const mobileWithCountryCode = `91${mobileNumber}`;

      let url = `${this.baseUrl}/verify?authkey=${this.authKey}&mobile=${mobileWithCountryCode}&otp=${otp}`;
      if (sessionId) {
        url += `&request_id=${sessionId}`;
      }

      const response = await axios.post(url, {}, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (response.data && response.data.type === 'success') {
        return {
          success: true,
          message: 'OTP verified successfully',
        };
      }

      return {
        success: false,
        message: response.data?.message || 'Invalid OTP',
      };
    } catch (error) {
      console.error('MSG91 Verify OTP Error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Invalid OTP. Please try again.',
      };
    }
  }
}

module.exports = new Msg91Service();
```

### Step 4: OTP Session Storage (Redis Example)

Create `services/otpService.js`:

```javascript
const redis = require('redis');
const { promisify } = require('util');

class OtpService {
  constructor() {
    this.client = redis.createClient({
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
    });

    this.getAsync = promisify(this.client.get).bind(this.client);
    this.setAsync = promisify(this.client.set).bind(this.client);
    this.delAsync = promisify(this.client.del).bind(this.client);
  }

  /**
   * Store OTP session
   * @param {string} mobileNumber - Mobile number
   * @param {string} sessionId - Session ID from MSG91
   * @param {number} expiryMinutes - Expiry time in minutes (default: 10)
   */
  async storeOtpSession(mobileNumber, sessionId, expiryMinutes = 10) {
    const key = `otp:${mobileNumber}`;
    const expirySeconds = expiryMinutes * 60;
    await this.setAsync(key, sessionId, 'EX', expirySeconds);
  }

  /**
   * Get OTP session
   * @param {string} mobileNumber - Mobile number
   * @returns {Promise<string|null>} - Session ID or null
   */
  async getOtpSession(mobileNumber) {
    const key = `otp:${mobileNumber}`;
    return await this.getAsync(key);
  }

  /**
   * Delete OTP session
   * @param {string} mobileNumber - Mobile number
   */
  async deleteOtpSession(mobileNumber) {
    const key = `otp:${mobileNumber}`;
    await this.delAsync(key);
  }
}

module.exports = new OtpService();
```

### Step 5: API Routes (Express Example)

Create `routes/auth.js`:

```javascript
const express = require('express');
const router = express.Router();
const msg91Service = require('../services/msg91Service');
const otpService = require('../services/otpService');

/**
 * POST /api/auth/send-otp
 * Request body: { mobileNumber: string }
 */
router.post('/send-otp', async (req, res) => {
  try {
    const { mobileNumber } = req.body;

    // Validate mobile number
    if (!mobileNumber || !/^[6-9]\d{9}$/.test(mobileNumber)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid mobile number format',
      });
    }

    // Send OTP via MSG91
    const result = await msg91Service.sendOtp(mobileNumber);

    if (result.success && result.sessionId) {
      // Store session in Redis (optional, if you want to track sessions)
      await otpService.storeOtpSession(mobileNumber, result.sessionId);
    }

    res.json(result);
  } catch (error) {
    console.error('Send OTP Error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

/**
 * POST /api/auth/verify-otp
 * Request body: { mobileNumber: string, otp: string, sessionId?: string }
 */
router.post('/verify-otp', async (req, res) => {
  try {
    const { mobileNumber, otp, sessionId } = req.body;

    // Validate inputs
    if (!mobileNumber || !/^[6-9]\d{9}$/.test(mobileNumber)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid mobile number format',
      });
    }

    if (!otp || !/^\d{4,6}$/.test(otp)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP format',
      });
    }

    // Get session ID from Redis if not provided (optional)
    const storedSessionId = sessionId || await otpService.getOtpSession(mobileNumber);

    // Verify OTP via MSG91
    const result = await msg91Service.verifyOtp(mobileNumber, otp, storedSessionId);

    if (result.success) {
      // Delete OTP session from Redis after successful verification
      await otpService.deleteOtpSession(mobileNumber);

      // Optional: Generate and return auth token for your app
      // const authToken = generateAuthToken(mobileNumber);
      // result.token = authToken;
    }

    res.json(result);
  } catch (error) {
    console.error('Verify OTP Error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

module.exports = router;
```

### Step 6: Main Server Setup

Create `server.js`:

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## Security Best Practices

### ✅ Rate Limiting

Implement rate limiting to prevent abuse:

```javascript
const rateLimit = require('express-rate-limit');

const otpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  message: 'Too many OTP requests, please try again later',
});

router.post('/send-otp', otpLimiter, async (req, res) => {
  // ... send OTP logic
});
```

### ✅ Input Validation

Always validate and sanitize inputs:

```javascript
const { body, validationResult } = require('express-validator');

router.post(
  '/send-otp',
  [
    body('mobileNumber')
      .matches(/^[6-9]\d{9}$/)
      .withMessage('Invalid mobile number format'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    // ... send OTP logic
  }
);
```

### ✅ HTTPS Only

Always use HTTPS in production:

```javascript
if (process.env.NODE_ENV === 'production') {
  app.use((req, res, next) => {
    if (req.header('x-forwarded-proto') !== 'https') {
      res.redirect(`https://${req.header('host')}${req.url}`);
    } else {
      next();
    }
  });
}
```

### ✅ Logging

Log all OTP attempts for security monitoring:

```javascript
const logger = require('./utils/logger');

router.post('/send-otp', async (req, res) => {
  const { mobileNumber } = req.body;
  logger.info('OTP send request', { mobileNumber, ip: req.ip });
  // ... send OTP logic
});
```

## MSG91 API Documentation

- Official Documentation: https://docs.msg91.com/
- OTP API: https://docs.msg91.com/collection/send-otp-v5-api
- Verify OTP: https://docs.msg91.com/collection/verify-otp-v5-api

## Testing

1. Update `lib/config/msg91_config.dart` with your backend URL
2. Test OTP sending: `POST /api/auth/send-otp`
3. Test OTP verification: `POST /api/auth/verify-otp`

## Alternative: Python/Flask Backend

If you prefer Python, here's a minimal Flask example:

```python
from flask import Flask, request, jsonify
import requests
import redis
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    password=os.getenv('REDIS_PASSWORD', None)
)

MSG91_AUTH_KEY = os.getenv('MSG91_AUTH_KEY')
MSG91_BASE_URL = 'https://control.msg91.com/api/v5/otp'

@app.route('/api/auth/send-otp', methods=['POST'])
def send_otp():
    data = request.json
    mobile_number = data.get('mobileNumber')
    
    # Validate mobile number
    if not mobile_number or not re.match(r'^[6-9]\d{9}$', mobile_number):
        return jsonify({'success': False, 'message': 'Invalid mobile number'}), 400
    
    # Send OTP via MSG91
    mobile_with_country = f'91{mobile_number}'
    url = f'{MSG91_BASE_URL}?authkey={MSG91_AUTH_KEY}&mobile={mobile_with_country}'
    
    response = requests.post(url)
    
    if response.json().get('type') == 'success':
        session_id = response.json().get('request_id')
        redis_client.setex(f'otp:{mobile_number}', 600, session_id)  # 10 min expiry
        return jsonify({'success': True, 'message': 'OTP sent', 'sessionId': session_id})
    
    return jsonify({'success': False, 'message': 'Failed to send OTP'}), 400

@app.route('/api/auth/verify-otp', methods=['POST'])
def verify_otp():
    data = request.json
    mobile_number = data.get('mobileNumber')
    otp = data.get('otp')
    session_id = data.get('sessionId') or redis_client.get(f'otp:{mobile_number}')
    
    mobile_with_country = f'91{mobile_number}'
    url = f'{MSG91_BASE_URL}/verify?authkey={MSG91_AUTH_KEY}&mobile={mobile_with_country}&otp={otp}'
    if session_id:
        url += f'&request_id={session_id.decode()}'
    
    response = requests.post(url)
    
    if response.json().get('type') == 'success':
        redis_client.delete(f'otp:{mobile_number}')
        return jsonify({'success': True, 'message': 'OTP verified'})
    
    return jsonify({'success': False, 'message': 'Invalid OTP'}), 400

if __name__ == '__main__':
    app.run(port=3000)
```

## Deployment

1. Deploy backend to cloud (AWS, Heroku, DigitalOcean, etc.)
2. Update `MSG91_CONFIG.baseUrl` in Flutter app with production URL
3. Set environment variables on your hosting platform
4. Enable HTTPS/SSL certificate
5. Configure CORS for your Flutter app domain

## Support

For issues:
- MSG91 Support: https://msg91.com/support
- Check MSG91 dashboard for API usage and credits
