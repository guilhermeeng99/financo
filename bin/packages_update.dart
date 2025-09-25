// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final directory = Directory.current;
  final packagesFolder = Directory(p.join(directory.path, 'packages'));
  final listOfPackages = packagesFolder.listSync();
  final totalPackages = listOfPackages.length + 1;
  var currentPackage = 1;
  for (final entity in listOfPackages) {
    if (entity is Directory) {
      final package = entity;
      final pubspec = File(p.join(package.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        await _updatePubspec(
          path: package.path,
          totalPackages: totalPackages,
          currentPackage: currentPackage,
        );
      }
    }
    currentPackage++;
  }
  await _updatePubspec(
    path: directory.path,
    totalPackages: totalPackages,
    currentPackage: currentPackage,
  );
  print('[PackageUpdate] (100%) All packages updated');
}

Future<void> _updatePubspec({
  required String path,
  required int totalPackages,
  required int currentPackage,
}) async {
  final eachPercent = 100.0 / totalPackages;
  final percent = (eachPercent * (currentPackage - 1)).toStringAsFixed(2);
  final donePercent = (eachPercent * currentPackage).toStringAsFixed(2);
  final relativePath = p.relative(path);
  print('[PackageUpdate] ($percent%) Updating pubspec.yaml in $relativePath');
  try {
    final oldFileContent = await _removePubspecNumber(
      path: path,
      content: await File(p.join(path, 'pubspec.yaml')).readAsString(),
    );
    await Process.run(
      'flutter',
      ['pub', 'upgrade', '--major-versions'],
      workingDirectory: path,
      runInShell: true,
    );
    final newFileContent = await _removePubspecNumber(
      path: path,
      content: await File(p.join(path, 'pubspec.yaml')).readAsString(),
    );
    final oldLines = oldFileContent.split('\n');
    final newLines = newFileContent.split('\n');
    for (var i = 0; i < oldLines.length; i++) {
      if (i >= newLines.length) {
        break;
      }
      if (oldLines[i] != newLines[i]) {
        print(
          '($donePercent%) Updated from ${oldLines[i].trim()} to ${newLines[i].trim()}',
        );
      }
    }
  } on Exception catch (e) {
    print('[PackageUpdate] Error updating pubspec.yaml in $path');
    print(e);
  }
}

Future<String> _removePubspecNumber({
  required String path,
  required String content,
}) async {
  final indexOfDependencies = content.indexOf('dependencies:');
  final beforeDependencies = content.substring(0, indexOfDependencies);
  final afterDependencies = content.substring(indexOfDependencies);
  var newContent = afterDependencies.replaceAllMapped(
    RegExp(r'(\s*:\s*)\^(\d)'),
    (match) {
      return '${match.group(1)}${match.group(2)}';
    },
  );
  if (newContent == afterDependencies) {
    return content;
  }
  newContent = '$beforeDependencies$newContent';
  await File(p.join(path, 'pubspec.yaml')).writeAsString(newContent);
  return newContent;
}
