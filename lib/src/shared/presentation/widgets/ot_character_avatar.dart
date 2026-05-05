import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/models/character.dart';
import '../../../app/ui_style.dart';

class OTCharacterAvatar extends StatelessWidget {
  const OTCharacterAvatar({
    required this.character,
    required this.radius,
    super.key,
  });

  final Character character;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final imagePath = character.avatarImagePath;
    final imageBase64 = character.avatarImageBase64;
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
          ? Text(
              character.avatar,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
