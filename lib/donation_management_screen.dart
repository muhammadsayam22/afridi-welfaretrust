import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/donation_model.dart';
import 'theme/app_colors.dart';
import 'utils/app_routes.dart';

/// Professional donation management screen.
///
/// Includes a live statistics dashboard (calculated from the database), a
/// search box that matches donor name / phone / receipt number /
/// transaction ID, plus status, category and date filters. Tapping a record
/// opens the full details screen where status changes can be applied.
class DonationManagementScreen extends StatefulWidget {
  const DonationManagementScreen({super.key});

  @override
  State<DonationManagementScreen> createState() =>
      _DonationManagementScreenState();
}

class _DonationManagementScreenState extends State<DonationManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Donation> _donations = const [];
  DonationStats _stats = const DonationStats.empty();
  bool _loading = true;

  String _statusFilter = 'All';
  String _categoryFilter = 'All';
  String _dateFilter = 'All Time';
  Timer? _debounce;

  static const List<String> _dateFilters = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    var dateFrom = '';
    var dateTo = '';

    switch (_dateFilter) {
      case 'Today':
        final today = _dateKey(now);
        dateFrom = today;
        dateTo = today;
        break;
      case 'This Week':
        dateFrom = _dateKey(now.subtract(const Duration(days: 6)));
        dateTo = _dateKey(now);
        break;
      case 'This Month':
        dateFrom = _dateKey(now.subtract(const Duration(days: 29)));
        dateTo = _dateKey(now);
        break;
      case 'This Year':
        dateFrom = _dateKey(now.subtract(const Duration(days: 364)));
        dateTo = _dateKey(now);
        break;
    }

    final results = await Future.wait<Object>([
      DbHelper.instance.getDonations(
        search: _searchController.text,
        status: _statusFilter == 'All' ? null : _statusFilter,
        category: _categoryFilter == 'All' ? null : _categoryFilter,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
      DbHelper.instance.donationStats(),
    ]);

    if (!mounted) return;
    setState(() {
      _donations = (results[0] as List<Donation>);
      _stats = (results[1] as DonationStats);
      _loading = false;
    });
  }

  String _dateKey(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _openForm() async {
    final changed = await Get.toNamed<Object?>(AppRoutes.donationForm);
    if (changed == true) _load();
  }

  Future<void> _openDetails(Donation donation) async {
    final changed = await Get.toNamed<Object?>(
      AppRoutes.donationDetails,
      arguments: donation,
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Donation Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Donation',
            onPressed: _openForm,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsSection(),
            _buildFilterSection(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // STATS DASHBOARD
  // ================================================================

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 5
              : (constraints.maxWidth >= 600 ? 3 : 2);
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _statCard(
                Icons.receipt_long_rounded,
                'Total Donations',
                '${_stats.totalDonations}',
                AppColors.primary,
              ),
              _statCard(
                Icons.payments_rounded,
                'Total Amount',
                _formatMoney(_stats.totalAmount),
                AppColors.gold,
              ),
              _statCard(
                Icons.pending_actions_rounded,
                'Pending',
                '${_stats.pendingCount}',
                const Color(0xFFEF6C00),
              ),
              _statCard(
                Icons.verified_rounded,
                'Verified',
                '${_stats.verifiedCount}',
                const Color(0xFF2E7D32),
              ),
              _statCard(
                Icons.cancel_outlined,
                'Rejected',
                '${_stats.rejectedCount}',
                const Color(0xFFC62828),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SEARCH + FILTERS
  // ================================================================

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, receipt or transaction ID',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon:
                          const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _load();
                      },
                    ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              isDense: true,
            ),
            /* The search field uses the theme's default InputDecoration
               shape which keeps the look consistent across the app. */
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final status in ['All', ...DonationConstants.statuses])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: _statusFilter == status,
                      onSelected: (_) {
                        setState(() => _statusFilter = status);
                        _load();
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _statusFilter == status
                            ? Colors.white
                            : AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(
                        color: _statusFilter == status
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  value: _categoryFilter,
                  icon: Icons.category_outlined,
                  items: ['All', ...DonationConstants.categories],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _categoryFilter = v);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _filterDropdown(
                  value: _dateFilter,
                  icon: Icons.date_range_rounded,
                  items: _dateFilters,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _dateFilter = v);
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          hint: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(value)),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ================================================================
  // DONATION LIST
  // ================================================================

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_donations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900 ? 2 : 1;
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(15),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 212,
            ),
            itemCount: _donations.length,
            itemBuilder: (context, index) =>
                _buildDonationCard(_donations[index]),
          );
        },
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    final initial = donation.donorName.isNotEmpty
        ? donation.donorName[0].toUpperCase()
        : 'D';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDetails(donation),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    donation.receiptNumber.isEmpty
                        ? 'Receipt Number'
                        : donation.receiptNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                _statusChip(donation.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.lightGreen,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.donorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _field(donation.phone),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _field(donation.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.payment_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _field(donation.paymentMethod),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.currency_rupee_rounded,
                    size: 15, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatMoney(donation.amount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_rounded,
                    size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _field(donation.donationDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.isEmpty ? DonationConstants.statusPending : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'No donations found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Donations matching your filters will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Donation'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case DonationConstants.statusVerified:
        return const Color(0xFF2E7D32);
      case DonationConstants.statusRejected:
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFEF6C00);
    }
  }

  String _field(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _formatMoney(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return 'Rs. $buffer';
  }
}