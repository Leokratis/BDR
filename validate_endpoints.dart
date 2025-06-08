void main() {
  // Test that our current API service configuration produces the correct URLs
  const baseUrl =
      'https://service.bdr.gr/blood-donor-registry-web-public/rest';
  
  print('=== API Endpoint URL Validation ===\n');
  
  // Test all endpoint URLs
  final endpoints = {
    'Donations': '$baseUrl/donations',
    'User (ID: 123)': '$baseUrl/user/123',
    'Coverages': '$baseUrl/coverages',
    'Captcha': 'https://service.blooddonorregistry.gr/v2/captcha',
    'Contact': 'https://service.blooddonorregistry.gr/v2/contact',
  };
  
  print('Current API Service URLs:');
  endpoints.forEach((name, url) {
    print('  $name: $url');
  });
  
  print('\n=== Expected URLs (from API docs) ===');
  print('  Donations: https://service.blooddonorregistry.gr/v2/donations');
  print('  User: https://service.blooddonorregistry.gr/v2/user/{id}');
  print('  Coverages: https://service.blooddonorregistry.gr/v2/coverages');
  print('  Captcha: https://service.blooddonorregistry.gr/v2/captcha');
  print('  Contact: https://service.blooddonorregistry.gr/v2/contact');
  
  print('\n=== Validation Results ===');
  
  // Check if URLs match expected format
  bool donationsMatch = endpoints['Donations'] == 'https://service.blooddonorregistry.gr/v2/donations';
  bool userMatch = endpoints['User (ID: 123)'] == 'https://service.blooddonorregistry.gr/v2/user/123';
  bool coveragesMatch = endpoints['Coverages'] == 'https://service.blooddonorregistry.gr/v2/coverages';
  bool captchaMatch = endpoints['Captcha'] == 'https://service.blooddonorregistry.gr/v2/captcha';
  bool contactMatch = endpoints['Contact'] == 'https://service.blooddonorregistry.gr/v2/contact';
  
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
