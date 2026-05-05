import '../models/character.dart';

abstract class SiteAdapter {
  const SiteAdapter();

  String get name;

  Future<List<Character>> search(String query);

  Future<Character> getDetail(String id);

  Future<Character> download(String id);
}
