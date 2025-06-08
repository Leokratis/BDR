import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Testing API endpoint structures...\n');
  
  // Different base URL patterns to test
  final baseUrls = [
    'https://service.bdr.gr/blood-donor-registry-web-public/rest',
  ];
  
  // Different endpoint patterns to test
  final endpointPatterns = [
    '/blooddonor/123/donation/history',
    '/blooddonor/123/coverageDonation/history',
    '/blooddonor/123',
    '/captcha',
  ];
  
  final client = HttpClient();
  
  for (String baseUrl in baseUrls) {
    print('Testing base URL: $baseUrl');
    print('=' * 50);
    
    for (String endpoint in endpointPatterns) {
      final fullUrl = '$baseUrl$endpoint';
      print('Testing: $fullUrl');
      
      try {
        final uri = Uri.parse(fullUrl);
        final request = await client.getUrl(uri);
        request.headers.set('Accept', 'application/json');
        request.headers.set('Accept-Language', 'en');
        
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        
        print('  Status: ${response.statusCode}');
        print('  Content-Type: ${response.headers.contentType}');
        
        if (response.statusCode == 200) {
          print('  ✅ SUCCESS - This endpoint works!');
          if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
            print('  Response appears to be JSON');
          }
        } else if (response.statusCode == 401) {
          print('  🔑 UNAUTHORIZED - Endpoint exists but needs authentication');
        } else if (response.statusCode == 404) {
          print('  ❌ NOT FOUND');
        } else {
          print('  ⚠️  Status ${response.statusCode}');
        }
        
        // Show first 100 chars of response for debugging
        if (responseBody.length > 0) {
          final preview = responseBody.length > 100 
              ? '${responseBody.substring(0, 100)}...' 
              : responseBody;
          print('  Preview: $preview');
        }
        
      } catch (e) {
        print('  💥 ERROR: $e');
      }
      
      print('');
    }
    
    print('\n');
  }
  
  client.close();
  print('Testing complete!');
}
