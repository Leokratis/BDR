import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

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
    // Auto-load user profile if user ID is available from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _userIdController.text = authProvider.currentUser!.id;
      _loadUserProfile();
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
      setState(() {
        _error = 'Please enter a user ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = await ApiService.getUser(userId);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View user information and details',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // User ID Input
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User ID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter user ID (e.g., 492966250)',
                      prefixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Load Profile',
                      onPressed: _isLoading ? null : _loadUserProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Content
            Expanded(
              child: _buildProfileContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_userData == null) {
      return _buildEmptyState();
    }

    return _buildProfileDetails();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            onPressed: _loadUserProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No profile loaded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a user ID and tap "Load Profile" to view user information',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          CustomCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userData!.name ?? 'User ${_userData!.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_userData!.id}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_userData!.email != null)
                  _ProfileInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _userData!.email!,
                    color: AppTheme.accent,
                  ),
                if (_userData!.phone != null) ...[
                  if (_userData!.email != null) const SizedBox(height: 12),
                  _ProfileInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: _userData!.phone!,
                    color: AppTheme.success,
                  ),
                ],
                if (_userData!.email == null && _userData!.phone == null)
                  Text(
                    'No contact information available',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Medical Information
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_userData!.bloodType != null)
                  _ProfileInfoRow(
                    icon: Icons.bloodtype,
                    label: 'Blood Type',
                    value: _userData!.bloodType!,
                    color: AppTheme.error,
                  ),
                if (_userData!.totalDonations != null) ...[
                  if (_userData!.bloodType != null) const SizedBox(height: 12),
                  _ProfileInfoRow(
                    icon: Icons.favorite,
                    label: 'Total Donations',
                    value: _userData!.totalDonations!.toString(),
                    color: AppTheme.warning,
                  ),
                ],
                if (_userData!.lastDonation != null) ...[
                  if (_userData!.bloodType != null || _userData!.totalDonations != null) 
                    const SizedBox(height: 12),
                  _ProfileInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Last Donation',
                    value: _formatDate(_userData!.lastDonation!),
                    color: AppTheme.success,
                  ),
                ],
                if (_userData!.bloodType == null && 
                    _userData!.totalDonations == null && 
                    _userData!.lastDonation == null)
                  Text(
                    'No medical information available',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
