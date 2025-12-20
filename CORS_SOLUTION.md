# CORS Issue Resolution Guide

## What is CORS?
CORS (Cross-Origin Resource Sharing) errors occur when your Flutter web app (running on `localhost:xxxx`) tries to make requests to your backend API (on Vercel), and the backend doesn't explicitly allow requests from your web app's origin.

## Solution 1: Backend Configuration (Recommended) ⭐

### For Vercel Backend:

Update your backend server to properly configure CORS headers. Here's how:

#### Option A: Allow All Origins (Development Only)
```javascript
const cors = require('cors');

// Simple - allows all origins (NOT for production)
app.use(cors());
```

#### Option B: Specific Origins (Recommended for Production)
```javascript
const cors = require('cors');

// Configure CORS to allow specific origins
const corsOptions = {
  origin: function (origin, callback) {
    // List of allowed origins
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:8080',
      'http://localhost:5000',
      'http://localhost:9999', // Flutter web default
      'https://your-flutter-web-app.vercel.app', // Your deployed Flutter app
      'https://your-flutter-web-app.web.app',    // Firebase hosting
      // Add more origins as needed
    ];

    // Allow requests with no origin (like mobile apps, Postman, etc.)
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true, // Allow cookies/auth headers
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(corsOptions));
```

#### Option C: Environment-Based Configuration (Best Practice)
```javascript
const cors = require('cors');

const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? [
        'https://your-flutter-web-app.vercel.app',
        'https://your-flutter-web-app.web.app',
      ]
    : [
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:5000',
        'http://localhost:9999',
        /^http:\/\/localhost:\d+$/, // Allow any localhost port
      ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(corsOptions));
```

#### Option D: Using Environment Variables
```javascript
const cors = require('cors');

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['http://localhost:3000', 'http://localhost:8080'];

const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(corsOptions));
```

### Update Your `.env` File:
```env
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5000,http://localhost:9999,https://your-flutter-app.vercel.app
```

### For Vercel Serverless Functions:
If you're using Vercel serverless functions, add CORS headers in each function:

```javascript
// api/auth/send-otp.js (example)
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*'); // Or specific origin
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Your API logic here
  // ...
}
```

---

## Solution 2: Flutter Web Workaround (Development Only) ⚠️

### Option A: Run Chrome with Disabled Web Security

**⚠️ WARNING: This is ONLY for development. Never use this in production!**

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

Or manually:
1. Close all Chrome instances
2. Run Chrome with flags:
   ```bash
   chrome.exe --user-data-dir="C:/chrome_dev" --disable-web-security --disable-features=VizDisplayCompositor
   ```
3. Then run: `flutter run -d chrome`

### Option B: Use a Proxy Server

Create a simple proxy to forward requests and avoid CORS:

1. Install `http-proxy-middleware`:
   ```bash
   npm install -g http-proxy-middleware
   ```

2. Create a `proxy.js` file:
   ```javascript
   const { createProxyMiddleware } = require('http-proxy-middleware');
   const express = require('express');
   const app = express();

   app.use('/api', createProxyMiddleware({
     target: 'https://brighthex-dream-24-7-backend-psi.vercel.app',
     changeOrigin: true,
     pathRewrite: {
       '^/api': '/api', // Keep /api prefix
     },
   }));

   app.listen(3001, () => {
     console.log('Proxy server running on http://localhost:3001');
   });
   ```

3. Update Flutter config to use `http://localhost:3001/api`
4. Run proxy: `node proxy.js`
5. Run Flutter app: `flutter run -d chrome`

---

## Solution 3: Vercel Configuration File

Create a `vercel.json` in your backend project root:

```json
{
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, PUT, DELETE, OPTIONS"
        },
        {
          "key": "Access-Control-Allow-Headers",
          "value": "Content-Type, Authorization"
        }
      ]
    }
  ]
}
```

**Note:** Using `*` allows all origins. For production, replace with your specific Flutter web app URL.

---

## Quick Check: Which Port is Flutter Web Using?

When you run `flutter run -d chrome`, check the terminal output. It will show something like:
```
The Flutter DevTools debugger and profiler on Chrome is available at: 
http://127.0.0.1:57744/...
```

The port (e.g., `57744`) is your Flutter web origin. Make sure this is in your backend's allowed origins list.

---

## Recommended Approach

1. **For Development**: Use Solution 1, Option C or D (environment-based) allowing localhost with any port
2. **For Production**: Use Solution 1, Option B with specific production URLs only
3. **For Quick Testing**: Use Solution 2, Option A (Chrome with disabled security) - **remember this is insecure**

---

## Testing CORS Configuration

After updating your backend:

1. Deploy to Vercel
2. Check browser console - CORS errors should be gone
3. Verify requests work in Network tab

---

## Additional Resources

- [MDN CORS Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Express CORS Middleware](https://expressjs.com/en/resources/middleware/cors.html)
- [Vercel Headers Configuration](https://vercel.com/docs/concepts/projects/project-configuration#headers)

