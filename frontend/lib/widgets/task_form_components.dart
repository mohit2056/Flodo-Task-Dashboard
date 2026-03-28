import 'package:flutter/material.dart';
import '../models/task_model.dart';

// 1. Custom Text Field
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const CustomTextField({super.key, required this.controller, required this.label, required this.icon, this.maxLines = 1, required this.enabled, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, maxLines: maxLines, enabled: enabled, style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
        filled: true, fillColor: Colors.black.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5))),
      ),
    );
  }
}

// 2. Status Dropdown
class StatusDropdown extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final List<String> options = const ['To-Do', 'In Progress', 'Done'];

  const StatusDropdown({super.key, required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, dropdownColor: const Color(0xFF1E1E2C), style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Status", labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)), prefixIcon: Icon(Icons.flag_outlined, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
        filled: true, fillColor: Colors.black.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      items: options.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}

// 3. Date Picker
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final bool enabled;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerField({super.key, required this.selectedDate, required this.enabled, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () async {
        final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (date != null) onDateSelected(date);
      } : null,
      child: Container(
        height: 60, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// 4. Blocked By Dropdown
class BlockedByDropdown extends StatelessWidget {
  final int? value;
  final List<Task> tasks;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  const BlockedByDropdown({super.key, required this.value, required this.tasks, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      value: value,
      dropdownColor: const Color(0xFF1E1E2C),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Blocked By (Optional)",
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.redAccent.withOpacity(0.7), size: 20),
        filled: true, fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text("None")), 
        ...tasks.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis)))
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}