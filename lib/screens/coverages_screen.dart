import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../theme/app_theme.dart';

class CoveragesScreen extends StatefulWidget {
  const CoveragesScreen({super.key});

  @override
  State<CoveragesScreen> createState() => _CoveragesScreenState();
}

class _CoveragesScreenState extends State<CoveragesScreen> {
  List<Coverage>? _coverages;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoverages();
  }

  Future<void> _loadCoverages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final coverages = await ApiService.getCoverages();
      setState(() {
        _coverages = coverages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCoverages() async {
    await _loadCoverages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshCoverages,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Blood Coverages',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadCoverages,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'View available blood coverage information',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
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
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoader(width: 150, height: 20),
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
            'Failed to load coverages',
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
    return ListView.separated(
      itemCount: _coverages!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final coverage = _coverages![index];
        return _CoverageCard(coverage: coverage);
      },
    );
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
