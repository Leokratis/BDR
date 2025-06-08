import 'package:flutter/material.dart';
import 'dart:math' as math; // For min/max
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class CoveragesScreen extends StatefulWidget {
  const CoveragesScreen({super.key});

  @override
  State<CoveragesScreen> createState() => _CoveragesScreenState();
}

class _CoveragesScreenState extends State<CoveragesScreen> with TickerProviderStateMixin { // Added TickerProviderStateMixin
  List<Coverage>? _coverages;
  bool _isLoading = false;
  String? _error;

  // --- Custom Pull-to-Refresh State ---
  double _dragOffset = 0.0;
  final double _refreshTriggerOffset = 100.0;
  final double _maxPullDown = 150.0;
  bool _isRefreshingByPull = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _offsetController;
  late Animation<double> _offsetAnimation;
  // --- End Custom Pull-to-Refresh State ---

  @override
  void initState() {
    super.initState();
    _loadCoverages();

    // --- Initialize Animation Controllers ---
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
            if (!_isRefreshingByPull) {
              setState(() {
                _dragOffset = _offsetAnimation.value;
              });
            }
          });
    // --- End Initialize Animation Controllers ---
  }

  @override
  void dispose() {
    // --- Dispose Animation Controllers ---
    _pulseController.dispose();
    _offsetController.dispose();
    // --- End Dispose Animation Controllers ---
    super.dispose();
  }

  // --- Custom Pull-to-Refresh Logic ---
  Future<void> _handleRefresh() async {
    if (_isRefreshingByPull) return;

    setState(() {
      _isRefreshingByPull = true;
    });

    await _loadCoverages();
  }
  // --- End Custom Pull-to-Refresh Logic ---

  Future<void> _loadCoverages() async {
    final bool wasInitiatedByPull = _isRefreshingByPull;

    if (!wasInitiatedByPull) {
      setState(() {
        _isLoading = true;
        _error = null; 
      });
    } else {
      if (_error != null) {
        setState(() {
          _error = null;
        });
      }
    }    try {
      // Get the current user ID from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      final coverages = await ApiService.getCoverages(userId);
      if (mounted) {
        setState(() {
          _coverages = coverages;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to get coverages.";
        });
      }
    } finally {
      if (mounted) {
        if (wasInitiatedByPull) {
          setState(() {
            _isRefreshingByPull = false;
            _isLoading = false; 
          });
          _offsetAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
              CurvedAnimation(parent: _offsetController, curve: Curves.easeOut));
          _offsetController.forward(from: 0);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Removed _refreshCoverages as it\'s redundant with _handleRefresh

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector( // Added GestureDetector for pull-to-refresh
        behavior: HitTestBehavior.opaque, // Capture gestures across the whole area
        onVerticalDragStart: (_) {
          _offsetController.stop();
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
            _offsetAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
                CurvedAnimation(parent: _offsetController, curve: Curves.easeOut));
            _offsetController.forward(from: 0);
          }
        },
        child: Stack( // Added Stack for layering refresh indicator and content
          children: [
            Positioned( // Blood drop refresh indicator
              top: (_dragOffset * 0.6) - 40,
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
            Transform.translate( // Main content, translated by drag
              offset: Offset(0, _dragOffset),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blood Coverages',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error,
                      ),
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
    // Show shimmer only on initial load or non-pull refresh
    if (_isLoading && !_isRefreshingByPull) { 
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_coverages == null || _coverages!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCoveragesList();
  }

  Widget _buildLoadingState() {
    final listView = ListView.separated(
      physics: (_dragOffset > 0 || _isRefreshingByPull)
                 ? const NeverScrollableScrollPhysics()
                 : null, // Or const AlwaysScrollableScrollPhysics()
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
                  const SkeletonLoader(width: 150, height: 20), // Assuming SkeletonLoader is defined
                  const SkeletonLoader(width: 80, height: 16),
                ],
              ),
              const SizedBox(height: 12),
              const SkeletonLoader(width: 100, height: 16),
              const SizedBox(height: 8),
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
            onPressed: _loadCoverages, 
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
            Icons.local_hospital_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coverages found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Blood coverage information will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoveragesList() {
    final listView = ListView.separated(
      physics: (_dragOffset > 0 || _isRefreshingByPull)
                 ? const NeverScrollableScrollPhysics()
                 : null, // Or const AlwaysScrollableScrollPhysics()
      itemCount: _coverages!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final coverage = _coverages![index];
        return _CoverageCard(coverage: coverage);
      },
    );

    if (_dragOffset > 0 || _isRefreshingByPull) {
      return IgnorePointer(child: listView);
    }
    return listView;
  }
}

class _CoverageCard extends StatelessWidget {
  final Coverage coverage;

  const _CoverageCard({required this.coverage});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  coverage.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusChip(status: coverage.status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.category,
            label: 'Type',
            value: coverage.type,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on,
            label: 'Location',
            value: coverage.location,
            color: AppTheme.success,
          ),
          if (coverage.startDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: _formatDate(coverage.startDate!),
              color: AppTheme.warning,
            ),
          ],
          if (coverage.endDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.event,
              label: 'End Date',
              value: _formatDate(coverage.endDate!),
              color: AppTheme.error,
            ),
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
      case 'active':
      case 'available':
        color = AppTheme.success;
        break;
      case 'pending':
        color = AppTheme.warning;
        break;
      case 'inactive':
      case 'unavailable':
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

// Assuming CustomCard, SkeletonLoader, CustomButton are defined elsewhere (e.g. in a common widgets file)
// or were part of the original coverages_screen.dart.
// If not, they would need to be added here or imported.
// For example, if they were dummy implementations at the end of donations_screen.dart:
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
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: textColor ?? Colors.white)),
    );
  }
}
