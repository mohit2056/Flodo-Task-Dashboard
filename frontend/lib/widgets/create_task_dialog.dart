import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_form_components.dart';

// 👇 DRAFT PRESERVATION PROVIDERS (Fixed for Modern Riverpod) 👇
class DraftTitleNotifier extends Notifier<String> {
  @override
  String build() => "";
  void setDraft(String val) => state = val;
}
final draftTitleProvider = NotifierProvider<DraftTitleNotifier, String>(() => DraftTitleNotifier());

class DraftDescNotifier extends Notifier<String> {
  @override
  String build() => "";
  void setDraft(String val) => state = val;
}
final draftDescProvider = NotifierProvider<DraftDescNotifier, String>(() => DraftDescNotifier());


Future<bool?> showCreateTaskDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const CreateTaskDialog(),
  );
}

class CreateTaskDialog extends ConsumerStatefulWidget {
  final Task? existingTask; 
  const CreateTaskDialog({super.key, this.existingTask});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  String _selectedStatus = 'To-Do';
  DateTime _selectedDate = DateTime.now();
  int? _selectedBlockedBy; 
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController = TextEditingController(text: widget.existingTask!.title);
      _descController = TextEditingController(text: widget.existingTask!.description);
      _selectedStatus = widget.existingTask!.status;
      _selectedBlockedBy = widget.existingTask!.blockedBy;
      try {
         _selectedDate = DateTime.parse(widget.existingTask!.dueDate);
      } catch (e) {
         _selectedDate = DateTime.now();
      }
    } else {
      _titleController = TextEditingController(text: ref.read(draftTitleProvider));
      _descController = TextEditingController(text: ref.read(draftDescProvider));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newTask = Task(
      id: widget.existingTask?.id,
      title: _titleController.text,
      description: _descController.text,
      dueDate: "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      status: _selectedStatus,
      blockedBy: _selectedBlockedBy,
    );

    try {
      if (widget.existingTask == null) {
        await ref.read(taskListProvider.notifier).addTask(newTask);
      } else {
        await ref.read(taskListProvider.notifier).updateTask(widget.existingTask!.id!, newTask);
      }
      
      if (widget.existingTask == null) {
        // 👇 FIXED: Naye syntax se state clear karna 👇
        ref.read(draftTitleProvider.notifier).setDraft("");
        ref.read(draftDescProvider.notifier).setDraft("");
      }
      if (mounted) Navigator.of(context).pop(true); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskListProvider).value ?? [];
    final availableTasksToBlock = allTasks.where((t) => t.id != widget.existingTask?.id).toList();

    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 500, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: RadialGradient(
                center: Alignment.topLeft, radius: 2.0,
                colors: [const Color(0xFF8B5CF6).withOpacity(0.3), const Color(0xFF0F172A).withOpacity(0.5)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.existingTask == null ? "Create New Challenge" : "Edit Task", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: _titleController, label: "Task Title", icon: Icons.title, enabled: !_isLoading,
                          onChanged: (val) { if (widget.existingTask == null) ref.read(draftTitleProvider.notifier).setDraft(val); }
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descController, label: "Description", icon: Icons.description_outlined, maxLines: 3, enabled: !_isLoading,
                          onChanged: (val) { if (widget.existingTask == null) ref.read(draftDescProvider.notifier).setDraft(val); }
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(child: StatusDropdown(value: _selectedStatus, enabled: !_isLoading, onChanged: (val) => setState(() => _selectedStatus = val!))),
                            const SizedBox(width: 16),
                            Expanded(child: DatePickerField(selectedDate: _selectedDate, enabled: !_isLoading, onDateSelected: (date) => setState(() => _selectedDate = date))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (availableTasksToBlock.isNotEmpty) 
                          BlockedByDropdown(value: _selectedBlockedBy, tasks: availableTasksToBlock, enabled: !_isLoading, onChanged: (val) => setState(() => _selectedBlockedBy = val)),
                        
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16))),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 48, width: 140,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.shade400, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: _isLoading ? 0 : 4),
                                onPressed: _isLoading ? null : _saveTask,
                                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text("Save Task", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}