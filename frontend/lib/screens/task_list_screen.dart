import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart'; 
import '../providers/task_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/status_filter_chips.dart';
import '../widgets/task_grid_view.dart';
import '../widgets/create_task_dialog.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  late ConfettiController _confettiController;
  // 👇 1. Naya state 'Tick' icon show karne ke liye
  bool _showTick = false; 

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // 👇 Helper function pathake burst karne ke liye
  void _playCelebrationBurst() {
    _confettiController.stop(); 
    _confettiController.play();
    
    // 👇 2. FIXED: Tick Animation Start karo
    setState(() => _showTick = true);
    
    // 1.5 second baad Tick gayab ho jaye (taaki user dashboard dekh sake wapas)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showTick = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtered tasks watch kar rahe hain (real data)
    final filteredTasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tasks Dashboard', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    DashboardSearchBar(),
                  ],
                ),
                const SizedBox(height: 20),
                const StatusFilterChips(),
                const SizedBox(height: 32),
                
                Expanded(
                  child: filteredTasksAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return const Center(child: Text("No tasks found! 🔍", style: TextStyle(color: Colors.white70, fontSize: 18)));
                      }
                      return TaskGridView(
                        tasks: tasks, 
                        onCelebration: _playCelebrationBurst
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // --- CELEBRATION LAYER ---
          // CONFETTI WIDGET (Particles sab taraf futenge center se)
          Align(
            alignment: Alignment.center, 
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, 
              shouldLoop: false,
              colors: const [Colors.cyanAccent, Colors.deepPurpleAccent, Colors.greenAccent, Colors.yellowAccent, Colors.redAccent], 
              numberOfParticles: 60, 
              gravity: 0.1, 
              emissionFrequency: 0.05,
            ),
          ),
          
          // 👇 3. THE MAGIC PREMIUM TICK WIDGET 👇
          // Isko hum AnimatedOpacity mein wrap karenge taaki ye pop-in aur fade-out ho jaye
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              // Agar _showTick true hai toh dikhao (1.0), warna chhupa do (0.0)
              opacity: _showTick ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300), // Pop in/out speed
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Subtle glow matching Cyan particles for premium look
                  boxShadow: [
                    BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline, // Beautiful outlines look premium
                  color: Colors.cyanAccent, // Bold Cyan color
                  size: 120, // Premium "thick" size (Thoda bada rakha hai)
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8C52FF),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Success pe center celebration chalana hai burst ke saath
          final bool? created = await showCreateTaskDialog(context);
          if (created == true) _playCelebrationBurst();
        },
      ),
    );
  }
}