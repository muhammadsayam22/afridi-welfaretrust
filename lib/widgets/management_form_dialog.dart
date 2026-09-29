import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formats.dart';
import 'management_config.dart';

/// Add / edit dialog used by every management screen.
///
/// Renders one input per [ManagementConfig.fields] entry, validates
/// required / numeric / date values and returns the finished column values
/// (`Map<column, value>`) when the user saves. Cancelling returns `null`
/// and never touches the database.
class ManagementFormDialog extends StatefulWidget {
  const ManagementFormDialog({
    super.key,
    required this.config,
    this.initial,
  });

  final ManagementConfig config;

  /// Existing row when editing, `null` when creating a new record.
  final Map<String, Object?>? initial;

  @override
  State<ManagementFormDialog> createState() => _ManagementFormDialogState();
}

class _ManagementFormDialogState extends State<ManagementFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String?> _choices;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _choices = {};

    for (final field in widget.config.fields) {
      final value = widget.config.valueOf(widget.initial ?? const {}, field.key);

      if (field.type == ManagementFieldType.date &&
          value.isEmpty &&
          !_isEditing) {
        _controllers[field.key] = TextEditingController(text: todayDateKey());
      } else {
        _controllers[field.key] = TextEditingController(text: value);
      }

      if (field.type == ManagementFieldType.choice) {
        final options = widget.config.optionsFor(field);
        _choices[field.key] =
            value.isEmpty && !_isEditing && options.isNotEmpty
                ? options.first
                : value;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(ManagementField field) async {
    final controller = _controllers[field.key]!;
    final initialDate = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      controller.text = dateKeyOf(picked);
    }
  }

  String? _validate(ManagementField field, String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      if (!field.required) return null;
      switch (field.type) {
        case ManagementFieldType.choice:
          return 'Please select ${field.label.toLowerCase()}';
        case ManagementFieldType.date:
          return 'Please select ${field.label.toLowerCase()}';
        case ManagementFieldType.multiline:
          return 'Please enter ${field.label.toLowerCase()}';
        default:
          return 'Please enter ${field.label.toLowerCase()}';
      }
    }

    if (field.type == ManagementFieldType.number &&
        double.tryParse(text) == null) {
      return 'Please enter a valid number for ${field.label.toLowerCase()}';
    }

    if (field.type == ManagementFieldType.date && !isDateKey(text)) {
      return 'Please use the YYYY-MM-DD format';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final values = <String, String>{};
    for (final field in widget.config.fields) {
      if (field.type == ManagementFieldType.choice) {
        values[field.key] = (_choices[field.key] ?? '').trim();
      } else {
        values[field.key] = _controllers[field.key]!.text.trim();
      }
    }

    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit_rounded : widget.config.icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_isEditing ? 'Edit Record' : 'Add Record'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final field in widget.config.fields) ...[
                  _buildInput(field),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(
            _isEditing ? 'Save Changes' : 'Save Record',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(ManagementField field) {
    switch (field.type) {
      case ManagementFieldType.choice:
        return _buildDropdown(field);
      case ManagementFieldType.multiline:
        return _buildMultiline(field);
      case ManagementFieldType.date:
        return _buildDate(field);
      case ManagementFieldType.text:
      case ManagementFieldType.number:
        return _buildTextField(field);
    }
  }

  InputDecoration _decoration(ManagementField field) {
    return InputDecoration(
      labelText: field.required ? '${field.label} *' : field.label,
      hintText: field.hint.isEmpty ? 'Enter ${field.label.toLowerCase()}' : field.hint,
      prefixIcon: Icon(field.icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildTextField(ManagementField field) {
    return TextFormField(
      controller: _controllers[field.key],
      keyboardType: field.keyboardType ??
          (field.type == ManagementFieldType.number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text),
      textInputAction: TextInputAction.next,
      decoration: _decoration(field),
      validator: (value) => _validate(field, value),
    );
  }

  Widget _buildMultiline(ManagementField field) {
    return TextFormField(
      controller: _controllers[field.key],
      maxLines: 4,
      minLines: 2,
      textInputAction: TextInputAction.newline,
      decoration: _decoration(field).copyWith(
        alignLabelWithHint: true,
        hintText: field.hint.isEmpty ? 'Enter ${field.label.toLowerCase()}' : field.hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 46),
          child: Icon(field.icon, color: AppColors.primary),
        ),
      ),
      validator: (value) => _validate(field, value),
    );
  }

  Widget _buildDate(ManagementField field) {
    return TextFormField(
      controller: _controllers[field.key],
      readOnly: true,
      onTap: () => _pickDate(field),
      decoration: _decoration(field).copyWith(
        hintText: 'YYYY-MM-DD',
        suffixIcon: IconButton(
          tooltip: 'Pick date',
          icon: const Icon(Icons.calendar_month_rounded,
              color: AppColors.primary),
          onPressed: () => _pickDate(field),
        ),
      ),
      validator: (value) => _validate(field, value),
    );
  }

  Widget _buildDropdown(ManagementField field) {
    final current = _choices[field.key];
    final options =
        widget.config.selectableOptionsFor(field, current);

    return DropdownButtonFormField<String>(
      initialValue: current != null && options.contains(current) ? current : null,
      decoration: _decoration(field).copyWith(
        hintText: 'Select ${field.label.toLowerCase()}',
      ),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: (value) => setState(() => _choices[field.key] = value),
      validator: (value) => _validate(field, value ?? ''),
    );
  }
}
