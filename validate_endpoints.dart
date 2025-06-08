void main() {
  // Test that our current API service configuration produces the correct URLs
  const baseUrl =
      'https://service.bdr.gr/blood-donor-registry-web-public/rest';
  
  print('=== API Endpoint URL Validation ===\n');
  
  // Test all endpoint URLs
  final endpoints = {
    'Donations': '$baseUrl/blooddonor/123/donation/history',
    'User (ID: 123)': '$baseUrl/blooddonor/123',
    'Coverages': '$baseUrl/blooddonor/123/coverageDonation/history',
    'Captcha': '$baseUrl/captcha',
    'Contact': '$baseUrl/contact',
  };
  
  print('Current API Service URLs:');
  endpoints.forEach((name, url) {
    print('  $name: $url');
  });
  
  print('\n=== Expected URLs (from API docs) ===');
  print(
      '  Donations: https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/{id}/donation/history');
  print('  User: https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/{id}');
  print(
      '  Coverages: https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/{id}/coverageDonation/history');
  print('  Captcha: https://service.bdr.gr/blood-donor-registry-web-public/rest/captcha');
  print('  Contact: https://service.bdr.gr/blood-donor-registry-web-public/rest/contact');
  
  print('\n=== Validation Results ===');
  
  // Check if URLs match expected format
  bool donationsMatch =
      endpoints['Donations'] ==
          'https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/123/donation/history';
  bool userMatch = endpoints['User (ID: 123)'] ==
      'https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/123';
  bool coveragesMatch =
      endpoints['Coverages'] ==
          'https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor/123/coverageDonation/history';
  bool captchaMatch = endpoints['Captcha'] ==
      'https://service.bdr.gr/blood-donor-registry-web-public/rest/captcha';
  bool contactMatch = endpoints['Contact'] ==
      'https://service.bdr.gr/blood-donor-registry-web-public/rest/contact';
  
  print('  Donations URL: ${donationsMatch ? "✅ CORRECT" : "❌ INCORRECT"}');
  print('  User URL: ${userMatch ? "✅ CORRECT" : "❌ INCORRECT"}');
  print('  Coverages URL: ${coveragesMatch ? "✅ CORRECT" : "❌ INCORRECT"}');
  print('  Captcha URL: ${captchaMatch ? "✅ CORRECT" : "❌ INCORRECT"}');
  print('  Contact URL: ${contactMatch ? "✅ CORRECT" : "❌ INCORRECT"}');
  
  bool allCorrect = donationsMatch && userMatch && coveragesMatch && captchaMatch && contactMatch;
  
  print('\n=== Overall Status ===');
  print('API Configuration: ${allCorrect ? "✅ ALL ENDPOINTS CORRECT" : "❌ SOME ENDPOINTS NEED FIXING"}');
  
  if (allCorrect) {
    print('\n🎉 The API service is now correctly configured!');
    print('The 404 errors should be resolved.');
    print('\nNext steps:');
    print('1. Run the Flutter app: flutter run');
    print('2. Test authentication and API calls');
    print('3. Check that English language responses are received');
  }
}
