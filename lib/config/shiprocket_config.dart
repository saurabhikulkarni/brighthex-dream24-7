// Shiprocket API Configuration
// Replace with your actual credentials from https://app.shiprocket.in

class ShiprocketConfig {
  // Your Shiprocket API Key
  static const String apiKey = 'YOUR_SHIPROCKET_API_KEY_HERE';

  // Shiprocket API Base URL
  static const String baseUrl = 'https://apiv2.shiprocket.in/v1/external';

  // Enable/Disable debug mode
  static const bool debugMode = true;

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  // Whether to use mock data for development
  static const bool useMockData = true;

  // Webhook secret for receiving updates
  static const String webhookSecret = 'YOUR_WEBHOOK_SECRET_HERE';

  /// Update API Key
  static void updateApiKey(String newApiKey) {
    // In production, store this securely in device storage
    print('API Key updated. Remember to rebuild the app.');
  }

  /// Get authorization header
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }
}
