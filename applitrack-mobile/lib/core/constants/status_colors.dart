import 'package:flutter/material.dart';
import 'enums.dart';

const Map<ApplicationStatus, Color> statusColors = {
  ApplicationStatus.wishlist: Color(0xFF9E9E9E),       // grey
  ApplicationStatus.applied: Color(0xFF3B82F6),        // blue
  ApplicationStatus.phoneScreen: Color(0xFF06B6D4),    // cyan
  ApplicationStatus.technicalRound: Color(0xFFF97316), // orange
  ApplicationStatus.onsiteInterview: Color(0xFF8B5CF6), // purple
  ApplicationStatus.offerReceived: Color(0xFF22C55E),  // green
  ApplicationStatus.accepted: Color(0xFF10B981),       // emerald
  ApplicationStatus.rejected: Color(0xFFEF4444),       // red
  ApplicationStatus.withdrawn: Color(0xFF6B7280),      // dark grey
  ApplicationStatus.ghosted: Color(0xFFD97706),        // amber
};

const Map<ApplicationStatus, Color> statusBgColors = {
  ApplicationStatus.wishlist: Color(0xFFF3F4F6),
  ApplicationStatus.applied: Color(0xFFEFF6FF),
  ApplicationStatus.phoneScreen: Color(0xFFECFEFF),
  ApplicationStatus.technicalRound: Color(0xFFFFF7ED),
  ApplicationStatus.onsiteInterview: Color(0xFFF5F3FF),
  ApplicationStatus.offerReceived: Color(0xFFF0FDF4),
  ApplicationStatus.accepted: Color(0xFFECFDF5),
  ApplicationStatus.rejected: Color(0xFFFEF2F2),
  ApplicationStatus.withdrawn: Color(0xFFF9FAFB),
  ApplicationStatus.ghosted: Color(0xFFFFFBEB),
};

Color statusColor(ApplicationStatus s) => statusColors[s] ?? const Color(0xFF9E9E9E);
Color statusBgColor(ApplicationStatus s) => statusBgColors[s] ?? const Color(0xFFF3F4F6);
