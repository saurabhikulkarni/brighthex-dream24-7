class ShiprocketConfig {
  // Shiprocket API Configuration
  // Official Documentation: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
  // API Docs: https://apidocs.shiprocket.in
  
  // OPTION 1: Use direct API token (RECOMMENDED)
  // If you have a token, set it here to skip authentication
  // Token is valid for 240 hours (10 days) according to Shiprocket docs
  static const String? apiToken = null; 
  // Example: static const String? apiToken = 'your_api_token_here';
  
  // OPTION 2: Use API User credentials for authentication
  // IMPORTANT: These must be API User credentials, NOT your main Shiprocket account!
  // 
  // Steps to create API User:
  // 1. Go to Shiprocket Panel → Settings → API
  // 2. Click "Create an API User"
  // 3. Enter a Valid Email ID (MUST be different from your registered email)
  // 4. Input an appropriate password
  // 5. Use these credentials below (NOT your main account credentials)
  //
  // Reference: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
  static const String email = 'brigthtestShipTest@gmail.com';
  static const String password = 'Xm1ULRgo*I9rC5NvZUW!K#^^Bo&Tx*C8';  
  // Shiprocket API Base URL
  // Base URL: apiv2.shiprocket.in
  // Full base URL: https://apiv2.shiprocket.in/v1/external
  static const String baseUrl = 'https://apiv2.shiprocket.in/v1/external';
  
  // OPTION 3: Backend Proxy URL (for Flutter Web to avoid CORS)
  // If you have a backend proxy server that forwards requests to Shiprocket,
  // set the proxy URL here. This will be used instead of direct API calls on web.
  // Example: 'https://your-backend.com/api/shiprocket'
  // Leave as null to use direct API calls (will fail on web due to CORS)
  static const String? proxyUrl = null;
  // Example: static const String? proxyUrl = 'https://your-backend.com/api/shiprocket';
  
  // Note: For production, use secure storage (flutter_secure_storage)
  // and load tokens from environment variables
}
