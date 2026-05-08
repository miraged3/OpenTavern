import 'dart:convert';
import 'dart:io';

import '../models/character.dart';
import 'app_storage.dart';

class CharacterAvatarStore {
  const CharacterAvatarStore();

  Future<Character> persistIfNeeded(Character character) async {
    final base64Image = character.avatarImageBase64;
    if (base64Image == null || base64Image.isEmpty) {
      return character;
    }

    final directory = await _avatarDirectory();
    final file = File(
      '${directory.path}/${character.id}-${character.updatedAt?.microsecondsSinceEpoch ?? DateTime.now().microsecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(base64Decode(base64Image), flush: true);

    return character.copyWith(
      avatarImagePath: file.path,
      clearAvatarImageBase64: true,
    );
  }

  Future<void> deleteIfExists(Character character) async {
    final path = character.avatarImagePath;
    if (path == null || path.isEmpty) {
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _avatarDirectory() async {
    final baseDirectory = await AppStorage.openTavernDirectory();
    final directory = Directory('${baseDirectory.path}/character_avatars');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
