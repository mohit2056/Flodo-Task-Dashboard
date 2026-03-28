import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/search_provider.dart'; // 👇 1. Search text lane ka jugaad
import 'create_task_dialog.dart';
import 'ui_components.dart'; 

// ==========================================
// MAIN TASK CARD
// ==========================================
class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback? onCelebration; 

  const TaskCard({super.key, required this.task, this.onCelebration});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskListProvider).value ?? [];
    
    // 👇 2. ASLI JADOO: Search bar ka text yahan watch kar rahe hain 👇
    final searchQuery = ref.watch(searchQueryProvider); 

    bool isBlocked = false;
    String blockingTaskName = "";

    if (widget.task.blockedBy != null) {
      try {
        final parentTask = allTasks.firstWhere((t) => t.id == widget.task.blockedBy);
        if (parentTask.status != 'Done') {
          isBlocked = true;
          blockingTaskName = parentTask.title;
        }
      } catch (e) {
        // Ignore
      }
    }

    return MouseRegion(
      cursor: isBlocked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isBlocked ? 0.4 : 1.0,
        child: GlassCardWrapper(
          isHovered: _isHovered && !isBlocked, 
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskHeader(
                    status: widget.task.status,
                    onEdit: isBlocked ? () {} : _onEditPressed,
                    onDelete: isBlocked ? () {} : _onDeletePressed,
                  ),
                  const SizedBox(height: 20),
                  
                  // 👇 3. Yahan TaskBody ko search text diya 👇
                  TaskBody(
                    title: widget.task.title,
                    description: widget.task.description,
                    dueDate: widget.task.dueDate,
                    searchQuery: searchQuery, // <-- YE MISSING THA!
                  ),
                  
                  const Spacer(),
                  TaskFooter(
                    status: widget.task.status,
                    avatarInitials: const ['MS', 'AP'], 
                  ),
                ],
              ),

              if (isBlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            "Blocked by:\n$blockingTaskName",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _onEditPressed() {
    showDialog(context: context, builder: (context) => CreateTaskDialog(existingTask: widget.task));
  }

  void _onDeletePressed() async {
    if (widget.task.id == null) return;

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Text('Delete Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${widget.task.title}"? This action cannot be undone.', 
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), 
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.shade200),
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await ref.read(taskListProvider.notifier).removeTask(widget.task.id!);
        if (mounted && widget.onCelebration != null) {
          widget.onCelebration!();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }
}

// ==========================================
// TASK SPECIFIC COMPONENTS
// ==========================================
class TaskHeader extends StatelessWidget {
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskHeader({super.key, required this.status, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status); 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.assignment_ind_outlined, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded( 
                child: Text("Project Task", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassIconButton(icon: Icons.edit_outlined, iconColor: Colors.white70, onPressed: onEdit),
            const SizedBox(width: 8),
            GlassIconButton(icon: Icons.delete_outline_rounded, iconColor: Colors.redAccent.shade200, onPressed: onDelete),
          ],
        ),
      ],
    );
  }
}

class TaskBody extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final String searchQuery;

  const TaskBody({super.key, required this.title, required this.description, required this.dueDate, this.searchQuery = ""});

  List<TextSpan> _getHighlightedText(String text, String query) {
    String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [TextSpan(text: text)];

    final lowerText = text.toLowerCase();
    final lowerQuery = cleanQuery.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      
      // CYAN HIGHLIGHT
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + cleanQuery.length),
        style: const TextStyle(backgroundColor: Colors.cyanAccent, color: Colors.black, fontWeight: FontWeight.bold),
      ));
      start = indexOfMatch + cleanQuery.length;
    }

    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            children: _getHighlightedText(title, searchQuery),
          ),
        ),
        const SizedBox(height: 8),
        Text(description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text("Due: $dueDate", style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class TaskFooter extends StatelessWidget {
  final String status;
  final List<String> avatarInitials;

  const TaskFooter({super.key, required this.status, required this.avatarInitials});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StackedAvatars(initialsList: avatarInitials),
        StatusPill(status: status),
      ],
    );
  }
}