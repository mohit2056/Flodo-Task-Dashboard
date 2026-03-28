import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class StatusFilterChips extends ConsumerWidget {
  const StatusFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(statusFilterProvider);
    final filters = ["All", "To-Do", "In Progress", "Done"];

    return Row(
      children: filters.map((filter) {
        final isSelected = currentFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            // 👇 FIXED: Naya Notifier function call kiya
            onSelected: (val) => ref.read(statusFilterProvider.notifier).setFilter(filter),
            selectedColor: const Color(0xFF8C52FF),
            backgroundColor: Colors.white.withOpacity(0.05),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: BorderSide(color: isSelected ? Colors.transparent : Colors.white12),
          ),
        );
      }).toList(),
    );
  }
}