
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

void main() {
  // Define the paths
  final apkPath = 'build/app/outputs/flutter-apk/app-release.apk';
  final zipPath = 'web/downloads/app-release.zip';

  // Create a new archive
  final archive = Archive();

  // Read the APK file
  final apkFile = File(apkPath);
  if (!apkFile.existsSync()) {
    print('Error: APK file not found at $apkPath');
    return;
  }
  final apkBytes = apkFile.readAsBytesSync();

  // Create an archive file from the bytes
  final archiveFile = ArchiveFile(apkFile.path.split('/').last, apkBytes.length, apkBytes);

  // Add the file to the archive
  archive.addFile(archiveFile);

  // Encode the archive as a zip
  final zipEncoder = ZipEncoder();
  final zipBytes = zipEncoder.encode(archive);

  // Write the zip file to disk
  final zipFile = File(zipPath);
  zipFile.writeAsBytesSync(zipBytes);

  print('Successfully created $zipPath');
}
