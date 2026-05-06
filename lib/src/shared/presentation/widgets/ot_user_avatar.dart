import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/ui_style.dart';
import '../../../core/models/user_persona.dart';

class OTUserAvatar extends StatelessWidget {
  const OTUserAvatar({
    required this.userPersona,
    required this.radius,
    super.key,
  });

  final UserPersona userPersona;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final imagePath = userPersona.avatarImagePath;
    final imageBase64 = userPersona.avatarImageBase64;
    Uint8List? imageBytes;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64);
      } catch (_) {
        imageBytes = null;
      }
    }
    final ImageProvider<Object>? fileImage =
        imagePath == null || imagePath.isEmpty
        ? null
        : FileImage(File(imagePath));
    final ImageProvider<Object>? imageProvider =
        fileImage ?? (imageBytes == null ? null : MemoryImage(imageBytes));

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.mutedFill,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.person_rounded,
              color: colors.tertiaryText,
              size: radius * 1.1,
            )
          : null,
    );
  }
}
