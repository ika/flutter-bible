import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collections/cache.dart';
import '../database.dart';

class IsarBackup {
  IsarBackup();

  static const String _backupDirKey = 'backup_directory_path';

  // Save the chosen backup directory path
  Future<void> _saveBackupDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupDirKey, path);
    debugPrint('Saved backup directory: $path');
  }

  // Get the previously saved backup directory path
  Future<String?> _getSavedBackupDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_backupDirKey);
    debugPrint('Retrieved saved backup directory: $path');
    return path;
  }

  // Clear the saved backup directory (for user to choose a new one)
  Future<void> clearBackupDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backupDirKey);
    debugPrint('Cleared saved backup directory');
  }

  // Export entire Isar database to a single backup file
  // User chooses where to save using file picker (remembers choice)
  Future<Map<String, dynamic>> exportDatabase({
    bool forceSelectDirectory = false,
  }) async {
    try {
      debugPrint('Starting database export...');

      // Read Cache collection data
      final caches = await isar.caches.where().findAll();
      debugPrint('Read ${caches.length} cache entries');

      // Create backup object
      final backupData = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'collections': {'caches': caches.map((c) => c.toJson()).toList()},
      };

      // Convert to JSON
      final jsonString = jsonEncode(backupData);
      debugPrint('JSON created, size: ${jsonString.length} bytes');

      // Generate filename with timestamp
      final fileName =
          'bible_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      String? directoryPath;

      // Check if we have a saved directory (unless user wants to change it)
      if (!forceSelectDirectory) {
        directoryPath = await _getSavedBackupDirectory();

        // Verify the directory still exists
        if (directoryPath != null) {
          final dir = Directory(directoryPath);
          if (!await dir.exists()) {
            debugPrint(
              'Saved directory no longer exists, will ask user to select new one',
            );
            directoryPath = null;
          }
        }
      }

      // If no saved directory or user wants to change it, ask user to select
      if (directoryPath == null) {
        debugPrint('Asking user to select backup directory...');
        directoryPath = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select folder to save backups',
        );

        if (directoryPath == null) {
          debugPrint('User cancelled directory selection');
          return {'success': false, 'error': 'User cancelled'};
        }

        // Save the selected directory for future use
        await _saveBackupDirectory(directoryPath);
      }

      final filePath = '$directoryPath/$fileName';
      debugPrint('Will save to: $filePath');

      // Write backup file to chosen location
      try {
        final backupFile = File(filePath);
        await backupFile.writeAsString(jsonString);
        debugPrint('File written successfully to: $filePath');
      } catch (writeError) {
        debugPrint('Error writing file: $writeError');
        return {'success': false, 'error': 'Failed to write file: $writeError'};
      }

      debugPrint('Isar database exported to: $filePath');
      debugPrint('Exported ${caches.length} cache entries');

      return {'success': true, 'path': filePath};
    } catch (e, stackTrace) {
      debugPrint('Export error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Restore database from backup file
  // Uses file picker (handles its own permissions)
  Future<bool> restoreDatabase() async {
    try {
      // Pick backup file using file picker
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        dialogTitle: 'Select JSON Backup File',
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('No file selected');
        return false;
      }

      final sourcePath = result.files.single.path!;
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        throw Exception('Backup file not found at: $sourcePath');
      }

      // Read and parse backup file
      final jsonString = await sourceFile.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final collections = backupData['collections'] as Map<String, dynamic>;

      // Clear existing data and restore within a transaction
      await isar.writeTxn(() async {
        // Clear existing collections
        await isar.caches.clear();

        // Restore cache entries
        if (collections.containsKey('caches')) {
          final cachesList = collections['caches'] as List;
          for (var cacheData in cachesList) {
            final cache = Cache()
              ..id = cacheData['id'] ?? Isar.autoIncrement
              ..version = cacheData['version']
              ..book = cacheData['book']
              ..chapter = cacheData['chapter']
              ..verse = cacheData['verse']
              ..text = cacheData['text']
              ..code = cacheData['code']
              ..timestamp = cacheData['timestamp'] != null
                  ? DateTime.parse(cacheData['timestamp'])
                  : DateTime.now();

            await isar.caches.put(cache);
          }
        }
      });

      debugPrint('Database restored from: $sourcePath');
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }
}
