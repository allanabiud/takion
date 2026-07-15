import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object>? avatarImageProvider(String avatarUrl) {
  final normalized = avatarUrl.trim();
  if (normalized.isEmpty) return null;
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return NetworkImage(normalized);
  }
  if (normalized.startsWith('data:image/') && normalized.contains(';base64,')) {
    try {
      final base64Str = normalized.split(';base64,').last;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {}
  }
  final file = File(normalized);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return null;
}
