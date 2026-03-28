import 'package:flutter/material.dart';
import 'dart:ui';

// ==========================================
// REUSABLE GLASS WRAPPER
// ==========================================
class GlassCardWrapper extends StatelessWidget {
  final bool isHovered;
  final Widget child;

  const GlassCardWrapper({super.key, required this.isHovered, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isHovered ? 1.02 : 1.0, 
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.zero,
        transform: Matrix4.identity()..translate(0.0, isHovered ? -6.0 : 0.0), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.25), 
              const Color(0xFF0F172A).withOpacity(0.4),  
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(isHovered ? 0.2 : 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B21A8).withOpacity(isHovered ? 0.3 : 0.1),
              blurRadius: isHovered ? 25 : 15,
              spreadRadius: 0,
              offset: Offset(0, isHovered ? 10 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), 
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: IntrinsicHeight(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// REUSABLE UI HELPERS (Buttons, Avatars, Pills)
// ==========================================

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const GlassIconButton({super.key, required this.icon, required this.iconColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: iconColor, size: 18), onPressed: onPressed),
    );
  }
}

class StackedAvatars extends StatelessWidget {
  final List<String> initialsList;

  const StackedAvatars({super.key, required this.initialsList});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.deepPurpleAccent, Colors.orangeAccent, Colors.pinkAccent];
    return SizedBox(
      width: 32.0 + (initialsList.length > 1 ? (initialsList.length - 1) * 18 : 0), 
      height: 32,
      child: Stack(
        children: List.generate(initialsList.length, (index) {
          return Positioned(
            left: index * 18.0,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F172A), width: 2), 
              ),
              child: Center(child: Text(initialsList[index], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          );
        }),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Global Color Helper (Kahin bhi use karne ke liye)
Color getStatusColor(String status) {
  switch (status) {
    case 'Done':
    case 'Completed': return Colors.greenAccent;
    case 'In Progress': return Colors.cyanAccent;
    case 'To-Do': default: return Colors.orangeAccent;
  }
}