import 'dart:async';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../theme/app_colors.dart';
import '../utils/formats.dart';
import 'management_common.dart';
import 'management_config.dart';
import 'management_details_dialog.dart';
import 'management_form_dialog.dart';

/// Generic database backed management screen used by the Education, Food,
/// Medical and Clean Water management systems.
///
/// Provides search, status filtering, add / edit forms with validation,
/// a details view and confirmation protected deletion for one SQLite table.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key, required this.config});

  final ManagementConfig config;

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, Object?>> _rows = const [];
  bool _loading = true;
  String _statusFilter = 'All';
  Timer? _debounce;

  ManagementConfig get _config => widget.config;

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
    final rows = await DbHelper.instance.getManagementRecords(
      _config.table,
      search: _searchController.text,
      status: _statusFilter == 'All' ? null : _statusFilter,
      searchColumns: _config.searchColumns,
    );

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _addRecord() async {
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => ManagementFormDialog(config: _config),
    );
    if (values == null || !mounted) return;

    final id =
        await DbHelper.instance.insertManagementRecord(_config.table, values);
    if (!mounted) return;

    if (id == null) {
      showAppMessage(context, 'Could not save this record. Please try again.');
      return;
    }

    showAppMessage(context, '${_label()} added successfully.');
    _load();
  }

  Future<void> _editRecord(Map<String, Object?> row) async {
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          ManagementFormDialog(config: _config, initial: row),
    );
    if (values == null || !mounted) return;

    final id = row['id'];
    if (id is! int) return;

    final affected = await DbHelper.instance
        .updateManagementRecord(_config.table, id, values);
    if (!mounted) return;

    if (affected == null || affected <= 0) {
      showAppMessage(context, 'Could not update this record. Please try again.');
      return;
    }

    showAppMessage(context, '${_label()} updated successfully.');
    _load();
  }

  Future<void> _deleteRecord(Map<String, Object?> row) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete ${_label()}',
      message: 'Are you sure you want to delete this item?',
    );
    if (!confirmed || !mounted) return;

    final id = row['id'];
    if (id is! int) return;

    final affected =
        await DbHelper.instance.deleteManagementRecord(_config.table, id);
    if (!mounted) return;

    if (affected == null || affected <= 0) {
      showAppMessage(context, 'Could not delete this record. Please try again.');
      return;
    }

    showAppMessage(context, '${_label()} deleted.');
    _load();
  }

  void _showDetails(Map<String, Object?> row) {
    ManagementDetailsDialog.show(
      context,
      config: _config,
      row: row,
      onEdit: () {
        Navigator.pop(context);
        _editRecord(row);
      },
    );
  }

  String _label() {
    final noun = _config.recordNoun;
    return noun.isEmpty ? 'Record' : noun[0].toUpperCase() + noun.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _config.title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add ${_label()}',
            onPressed: _addRecord,
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
            _buildFilters(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH + STATUS FILTER
  // ================================================================

  Widget _buildFilters() {
    final statuses = _config.statuses;
    final searchLabels = [
      for (final field in _config.fields)
        if (field.searchable) field.label.toLowerCase(),
    ];
    final searchHint = searchLabels.isEmpty
        ? 'Search ${_config.recordNoun}s'
        : 'Search ${_config.recordNoun}s by '
            '${searchLabels.take(3).join(', ')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _load();
                      },
                    ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              isDense: true,
            ),
          ),
          if (statuses.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final status in ['All', ...statuses])
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
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ================================================================
  // RECORD LIST
  // ================================================================

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_rows.isEmpty) {
      return _buildEmptyState();
    }

    final summaryCount = _config.summaryFields.length;
    final cardExtent = 150.0 + (summaryCount * 24.0);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
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
                  mainAxisExtent: cardExtent,
                ),
                itemCount: _rows.length,
                itemBuilder: (context, index) => _buildCard(_rows[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, Object?> row) {
    final summary = _config.summaryFields;
    final status = _config.statusOf(row);
    final title = _config.titleOf(row);
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'R';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetails(row),
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
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  statusPill(status),
                ],
              ],
            ),
            const SizedBox(height: 10),
            for (final field in summary)
              _summaryRow(
                field.icon,
                field.label,
                _displayValue(row, field),
              ),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Added ${formatDateTimeLabel(configValue(row, 'created_at'))}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
                _cardAction(
                  tooltip: 'View details',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary,
                  onTap: () => _showDetails(row),
                ),
                _cardAction(
                  tooltip: 'Edit record',
                  icon: Icons.edit_rounded,
                  color: AppColors.primary,
                  onTap: () => _editRecord(row),
                ),
                _cardAction(
                  tooltip: 'Delete record',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  onTap: () => _deleteRecord(row),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String configValue(Map<String, Object?> row, String key) =>
      _config.valueOf(row, key);

  String _displayValue(Map<String, Object?> row, ManagementField field) {
    final value = _config.valueOf(row, field.key);
    if (value.isEmpty) return '-';

    if (field.type == ManagementFieldType.date) {
      return formatDateLabel(value);
    }
    if (field.key == 'estimated_cost') {
      final numeric = double.tryParse(value);
      if (numeric != null) return formatMoneyLabel(value);
    }
    return value;
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardAction({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 19, color: color),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_config.emptyIcon, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              'No ${_config.recordNoun}s found',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your ${_config.recordNoun}s will appear here. '
              'Add the first one to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _addRecord,
              icon: const Icon(Icons.add_rounded),
              label: Text('Add ${_label()}'),
            ),
          ],
        ),
      ),
    );
  }
}
