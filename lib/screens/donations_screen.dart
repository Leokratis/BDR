import 'package:flutter/material.dart';
import 'dart:math' as math; // For min/max
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../theme/app_theme.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> with TickerProviderStateMixin {
  List<Donation>? _donations;
  bool _isLoading = false;
  String? _error;

  double _dragOffset = 0.0;
  final double _refreshTriggerOffset = 100.0; // How far to pull to trigger refresh
  final double _maxPullDown = 150.0; // Max visual pull
  bool _isRefreshingByPull = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _offsetController; // For smooth snap back
  late Animation<double> _offsetAnimation;   // For smooth snap back

  @override
  void initState() {
    super.initState();
    _loadDonations();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _offsetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _offsetAnimation =
        Tween<double>(begin: 0, end: 0).animate(_offsetController)
          ..addListener(() {
            if (!_isRefreshingByPull) { // Only update drag if not actively refreshing via pull
              setState(() {
                _dragOffset = _offsetAnimation.value;
              });
            }
          });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshingByPull) return;

    setState(() {
      _isRefreshingByPull = true;
      // _isLoading should not be set to true here,
      // as we don't want the main shimmer during pull-to-refresh.
      // The blood drop icon serves as the refresh indicator.
    });

    await _loadDonations();
  }

  Future<void> _loadDonations() async {
    final bool wasInitiatedByPull = _isRefreshingByPull; // Capture state at entry

    if (!wasInitiatedByPull) {
      setState(() {
        _isLoading = true; // For shimmer on initial load or "Try Again"
        _error = null; // Clear error on new load attempt
      });
    } else {
      // For pull-to-refresh, we only clear the error, isLoading is handled by the icon
      if (_error != null) {
        setState(() {
          _error = null;
        });
      }
    }

    try {
      final donations = await ApiService.getDonations();
      if (mounted) {
        setState(() {
          _donations = donations;
          // _isLoading will be set to false in the finally block
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to get donations.";
          // _isLoading will be set to false in the finally block
        });
      }
    } finally {
      if (mounted) {
        if (wasInitiatedByPull) {
          // This was a pull-to-refresh cycle
          setState(() {
            _isRefreshingByPull = false; // Mark pull-refresh as complete
            _isLoading = false;          // Ensure general loading is also off
          });
          // Animate snap back
          _offsetAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
              CurvedAnimation(parent: _offsetController, curve: Curves.easeOut));
          _offsetController.forward(from: 0);
        } else {
          // This was a normal load (initial or "Try Again")
          setState(() {
            _isLoading = false; // Turn off shimmer or general loading indicator
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Capture gestures across the whole area
        onVerticalDragStart: (_) {
          _offsetController.stop(); // Stop snap-back animation if user starts dragging again
        },
        onVerticalDragUpdate: (details) {
          if (_isRefreshingByPull) return;
          setState(() {
            _dragOffset = math.max(0, math.min(_dragOffset + details.delta.dy, _maxPullDown));
          });
        },
        onVerticalDragEnd: (details) {
          if (_isRefreshingByPull) return;
          if (_dragOffset >= _refreshTriggerOffset) {
            _handleRefresh();
          } else {
            // Animate snap back
            _offsetAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
                CurvedAnimation(parent: _offsetController, curve: Curves.easeOut));
            _offsetController.forward(from: 0);
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: (_dragOffset * 0.6) - 40, // Adjust positioning for visibility
              left: 0,
              right: 0,
              child: Opacity(
                opacity: math.min(1.0, _dragOffset / _refreshTriggerOffset),
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.bloodtype,
                      color: AppTheme.error,
                      size: 40.0,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Donations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && !_isRefreshingByPull) { // Show shimmer only on initial load or non-pull refresh
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_donations == null || _donations!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDonationsList();
  }

  Widget _buildLoadingState() {
    final listView = ListView.separated(
      physics: (_dragOffset > 0 || _isRefreshingByPull)
                 ? const NeverScrollableScrollPhysics()
                 : null, // Or const AlwaysScrollableScrollPhysics() for consistent scrollability
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return CustomCard( // Assuming CustomCard is defined
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoader(width: 120, height: 20), // Assuming SkeletonLoader is defined
                  const SkeletonLoader(width: 80, height: 16),
                ],
              ),
              const SizedBox(height: 12),
              const SkeletonLoader(width: double.infinity, height: 16),
              const SizedBox(height: 8),
              const SkeletonLoader(width: 200, height: 16),
            ],
          ),
        );
      },
    );

    if (_dragOffset > 0 || _isRefreshingByPull) {
      return IgnorePointer(child: listView);
    }
    return listView;
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
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton( // Assuming CustomButton is defined
            text: 'Try Again',
            onPressed: _loadDonations, // This will now also handle resetting pull-to-refresh state if needed
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
            Icons.bloodtype_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No donations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your donation history will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList() {
    final listView = ListView.separated(
      physics: (_dragOffset > 0 || _isRefreshingByPull)
                 ? const NeverScrollableScrollPhysics()
                 : null, // Or const AlwaysScrollableScrollPhysics()
      itemCount: _donations!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final donation = _donations![index];
        return _DonationCard(donation: donation);
      },
    );

    if (_dragOffset > 0 || _isRefreshingByPull) {
      return IgnorePointer(child: listView);
    }
    return listView;
  }
}

class _DonationCard extends StatelessWidget {
  final Donation donation;

  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(donation.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _StatusChip(status: donation.status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.bloodtype,
            label: 'Blood Type',
            value: donation.bloodType,
            color: AppTheme.error,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on,
            label: 'Location',
            value: donation.location,
            color: AppTheme.accent,
          ),
          if (donation.hemoglobin != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.trending_up,
              label: 'Hemoglobin',
              value: '${donation.hemoglobin!.toStringAsFixed(1)} g/dL',
              color: AppTheme.success,
            ),
          ],
          if (donation.notes != null && donation.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Notes',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(donation.notes!),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        color = AppTheme.success;
        break;
      case 'pending':
        color = AppTheme.warning;
        break;
      case 'cancelled':
      case 'failed':
        color = AppTheme.error;
        break;
      default:
        color = AppTheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Dummy CustomCard, SkeletonLoader, and CustomButton for compilation if not present
// Replace with your actual implementations

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const CustomCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8), child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(12.0), child: child)));
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonLoader({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
