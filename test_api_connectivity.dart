import 'lib/services/api_service.dart';

Future<void> main() async {
  print('Testing API connectivity...');
  
  // Test basic network connectivity
  print('\n1. Testing network connectivity...');
  bool networkResult = await ApiService.testNetworkConnectivity();
  print('Network connectivity: $networkResult');
  
  // Test API endpoint accessibility
  print('\n2. Testing API endpoint accessibility...');
  bool apiResult = await ApiService.testApiEndpoint();
  print('API endpoint accessibility: $apiResult');
  
  // Test a simple API call without authentication
  print('\n3. Testing getCaptcha API call...');
  try {
    final captcha = await ApiService.getCaptcha();
    print('getCaptcha successful: ${captcha.id}');
  } catch (e) {
    print('getCaptcha failed: $e');
  }
  
  print('\nTest completed.');
}
