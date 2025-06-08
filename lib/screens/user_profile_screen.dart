import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'contact_screen.dart'; // Import ContactScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserData? _userData;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _userIdController.text = authProvider.currentUser!.id;
      _loadUserProfile();
    } else if (authProvider.token != null) {
      // If current user is null but token exists, try to derive ID or fetch based on token
      // This part depends on how your user ID is linked to the token.
      // For now, let's assume the token itself might be usable or contains user ID info.
      // This is a placeholder: you might need a way to get user ID after initial login
      // if not immediately available in AuthProvider.currentUser.id
      // Example: decode token if it's a JWT, or make a dedicated endpoint call.
      // If an ID can be reliably obtained, call _loadUserProfile with it.
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      // If user ID is not available, try to get it from AuthProvider's current user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser?.id != null && authProvider.currentUser!.id.isNotEmpty) {
         _userIdController.text = authProvider.currentUser!.id;
      } else {
        setState(() {
            _error = 'User ID not available. Cannot load profile.';
            _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use the ID from controller, which should now be populated
      final userData = await ApiService.getUser(_userIdController.text.trim());
      setState(() {
        _userData = userData;
        // Update AuthProvider's current user if it was null or different
        Provider.of<AuthProvider>(context, listen: false).currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to get user data."; // Simplified error message
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20), // Top padding
            Text(
              'Profile & Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // User ID input and load button section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        hintText: 'Enter your User ID to load profile',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _userIdController.clear(),
                        )
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Profile'),
                      onPressed: _loadUserProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!, // Display the simplified error message
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_userData != null)
              _buildUserDetailsCard(_userData!), // Extracted user details display to a method
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Contact Us Tile
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.contact_support_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Contact Us'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Logout Tile
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500)),
                onTap: () async {
                  // Show confirmation dialog before logging out
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false); // User cancelled
                            },
                          ),
                          TextButton(
                            child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true); // User confirmed
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true) {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Helper widget to display user details
  Widget _buildUserDetailsCard(UserData userData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('User Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            _buildDetailRow('ID', userData.id),
            // Use 'name' field from UserData instead of 'username', 'firstName', 'lastName'
            _buildDetailRow('Name', userData.name ?? 'N/A'), 
            _buildDetailRow('Email', userData.email ?? 'N/A'),
            _buildDetailRow('Phone', userData.phone ?? 'N/A'),
            _buildDetailRow('Blood Type', userData.bloodType ?? 'N/A'),
            _buildDetailRow('Last Donation', userData.lastDonation?.toLocal().toString().split(' ')[0] ?? 'N/A'),
            _buildDetailRow('Total Donations', userData.totalDonations?.toString() ?? 'N/A'),
            // Remove fields not present in UserData model
            // _buildDetailRow('Registered Since', userData.memberSince?.toLocal().toString().split(' ')[0] ?? 'N/A'),
            // _buildDetailRow('Email Verified', userData.emailIsVerified == true ? 'Yes' : 'No'),
            // if (userData.roles != null && userData.roles!.isNotEmpty)
            //   _buildDetailRow('Roles', userData.roles!.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
