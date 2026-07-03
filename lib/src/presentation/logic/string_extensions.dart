String initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';

  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
    return trimmed.substring(0, trimmed.length.clamp(1, 2));
  }

  final parts = trimmed.split(RegExp(r'[\s\-\/]+'));
  final valid = parts.where((p) => p.isNotEmpty && RegExp(r'^[a-zA-Z0-9]').hasMatch(p)).toList();
  if (valid.isEmpty) return '?';
  if (valid.length >= 2) {
    return '${valid[0][0]}${valid[1][0]}'.toUpperCase();
  }
  return valid[0][0].toUpperCase();
}
