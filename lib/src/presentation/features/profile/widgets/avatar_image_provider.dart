import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:takion/src/core/logging/app_logger.dart';

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
    } catch (e) {
      AppLogger.warning('Failed to decode base64 avatar image', error: e);
    }
  }
  final file = File(normalized);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return null;
}
