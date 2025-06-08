import 'package:http/http.dart' as http;

void main() async {
  print('Testing alternative API base URLs...\n');
  
  // Test different possible API base structures
  final testUrls = [
    'https://service.bdr.gr/blood-donor-registry-web-public/rest',
    'https://service.blooddonorregistry.gr/blood-donor-registry-web-public/rest', 
    'https://service.blooddonorregistry.gr/rest',
    'https://service.blooddonorregistry.gr/api',
    'https://service.blooddonorregistry.gr/v2/v2/donations', // Current failing
    'https://service.blooddonorregistry.gr/v2/donations',
    'https://service.blooddonorregistry.gr/donations',
  ];
  
  for (final url in testUrls) {
    try {
      print('Testing: $url');
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      print('  Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('  ✅ SUCCESS - Endpoint accessible');
      } else if (response.statusCode == 401) {
        print('  🔒 REQUIRES AUTH (This is expected and good!)');
      } else if (response.statusCode == 404) {
        print('  ❌ NOT FOUND');
      } else if (response.statusCode == 405) {
        print('  🔄 METHOD NOT ALLOWED (Try GET instead of HEAD)');
      } else {
        print('  ⚠️ Other status: ${response.statusCode}');
      }
    } catch (e) {
      print('  ❌ ERROR: $e');
    }
    print('');
  }
  
  // Test the old-style endpoint from README
  print('=== Testing old-style endpoint pattern ===');
  final oldStyleUrl = 'https://service.bdr.gr/blood-donor-registry-web-public/rest/blooddonor';
  
  try {
    print('Testing: $oldStyleUrl');
    final response = await http.head(Uri.parse(oldStyleUrl)).timeout(const Duration(seconds: 10));
    print('Status: ${response.statusCode}');
    if (response.statusCode == 405) {
      print('✅ Endpoint exists but HEAD method not allowed - this is promising!');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
