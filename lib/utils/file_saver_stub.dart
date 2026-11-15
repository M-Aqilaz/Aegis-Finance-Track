abstract class FileSaverPlatform {
  static Future<bool> saveOrShareFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    throw UnsupportedError('Platform not supported');
  }
}
