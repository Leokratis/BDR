void main() {
  // Test token extraction logic
  final testToken = 'elenii.stpl|BloodDonorUser|v+YkXJM5PDvFFw1XZAudxVOc8zinZ+9c1fWOtAqWm1uYPpwKiSbOzgoo';
  
  print('Original token: $testToken');
  
  // Extract userId from token structure: userId|userType|token
  String? userId;
  try {
    final tokenParts = testToken.split('|');
    if (tokenParts.length >= 3) {
      userId = tokenParts[0]; // First part should be the user ID
      print('Extracted userId: $userId');
      print('User type: ${tokenParts[1]}');
      print('Token part: ${tokenParts[2]}');
    } else {
      print('Token doesn\'t match expected format (userId|userType|token)');
    }
  } catch (e) {
    print('Error extracting userId from token: $e');
  }
  
  if (userId != null && userId.isNotEmpty) {
    print('✓ User ID extraction successful: $userId');
  } else {
    print('✗ User ID extraction failed');
  }
}
