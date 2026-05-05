String markdownToPreviewText(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  var next = value
      .replaceAllMapped(
        RegExp(r'!\[([^\]]*)\]\([^)]+\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]+\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'^\s{0,3}(#{1,6})\s*', multiLine: true),
        (_) => '',
      )
      .replaceAll('**', '')
      .replaceAll('__', '')
      .replaceAll('*', '')
      .replaceAll('_', '')
      .replaceAll('`', '')
      .replaceAll('~~', '')
      .replaceAll('>', '')
      .replaceAllMapped(RegExp(r'^\s*[-*+]\s+', multiLine: true), (_) => '')
      .replaceAllMapped(RegExp(r'^\s*\d+\.\s+', multiLine: true), (_) => '')
      .replaceAll(RegExp(r'\r\n?'), '\n')
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();

  return next;
}
