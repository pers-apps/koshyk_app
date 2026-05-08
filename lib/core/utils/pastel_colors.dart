import 'package:flutter/material.dart';

/// Canonical pastel palette — deterministic per participant.
/// All screens must use this same list so one participant = one colour everywhere.
const kPastelColors = [
  Color(0xFF90CAF9), // blue-200
  Color(0xFFA5D6A7), // green-200
  Color(0xFFFFCC80), // orange-200
  Color(0xFFB39DDB), // purple-200
  Color(0xFFF48FB1), // pink-200
  Color(0xFF80DEEA), // cyan-200
  Color(0xFFFFD54F), // yellow-300
  Color(0xFF80CBC4), // teal-200
];

/// Returns the pastel colour for [name] given the full sorted name list.
Color pastelForName(String name, List<String> sortedNames) {
  final idx = sortedNames.indexOf(name);
  if (idx < 0) return kPastelColors[0];
  return kPastelColors[idx % kPastelColors.length];
}

/// Builds a [participantId → Color] map from a list of participants.
/// [entries] is a list of (id, name) pairs.
Map<int, Color> buildParticipantColors(List<MapEntry<int, String>> entries) {
  final sorted = entries.map((e) => e.value).toList()..sort();
  return {
    for (final e in entries)
      e.key: pastelForName(e.value, sorted),
  };
}
