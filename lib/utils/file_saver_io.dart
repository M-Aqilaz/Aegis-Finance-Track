import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileSaverPlatform {
  static Future<bool> saveOrShareFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    final xFile = XFile(file.path, mimeType: mimeType, name: fileName);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: 'Cadangan Financial Track',
        text: 'File Cadangan Financial Track ($fileName)',
      ),
    );
    return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
  }
}
