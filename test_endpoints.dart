import 'package:http/http.dart' as http;

void main() async {
  // Test the correct API endpoints according to documentation
  final testEndpoints = [
    'https://service.blooddonorregistry.gr/v2/captcha',
    'https://service.blooddonorregistry.gr/v2/donations',
    'https://service.blooddonorregistry.gr/v2/coverages',
    'https://service.blooddonorregistry.gr/v2/contact',
  ];

  print('Testing API endpoints according to official documentation...\n');

  for (final endpoint in testEndpoints) {
    try {
      print('Testing: $endpoint');
      final response = await http.head(Uri.parse(endpoint)).timeout(const Duration(seconds: 10));
      print('Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS');
      } else if (response.statusCode == 401) {
        print('🔒 REQUIRES AUTH (Expected for authenticated endpoints)');
      } else if (response.statusCode == 405) {
        print('🔄 METHOD NOT ALLOWED (Try GET instead of HEAD)');
      } else {
        print('❌ FAILED');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }

  // Test with actual GET request for captcha (no auth needed)
  print('Testing captcha with GET request...');
  try {
    final response = await http.get(
      Uri.parse('https://service.blooddonorregistry.gr/v2/captcha'),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': 'en',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('Captcha GET Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Captcha endpoint works!');
      print('Response length: ${response.body.length} characters');
    } else {
      print('❌ Captcha failed: ${response.body}');
    }
  } catch (e) {
    print('❌ Captcha error: $e');
  }
}
