// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:migration/src/io.dart';
import 'package:migration/src/test_directories.dart';

/// Rough estimate of how many lines of code someone could migrate per day.
/// Based on rnystrom migrating corelib_2/r-z, lib_2/js, and lib_2/collection
/// in one day (along with some other tasks).
///
/// This is an optimistic estimate since those were particularly easy libraries.
/// But it's also conservative since it didn't take the entire day to migrate
/// them.
// TODO(rnystrom): Update this with numbers from migrating some language tests.
const _linesPerDay = 24607;

void main(List<String> arguments) {
  var totalFiles = 0;
  var totalLines = 0;
  var totalMigratedFiles = 0;
  var totalMigratedLines = 0;

  for (var dir in legacyRootDirs) {
    var files = 0;
    var lines = 0;
    var migratedFiles = 0;
    var migratedLines = 0;

    for (var legacyPath in listFiles(dir)) {
      files++;
      var lineCount = readFileLines(legacyPath).length;
      lines += lineCount;

      var nnbdPath = toNnbdPath(legacyPath);
      // TODO(rnystrom): Look for a marker comment in legacy files that we know
      // are not intended to be migrated and count those as done.
      if (fileExists(nnbdPath)) {
        migratedFiles++;
        migratedLines += lineCount;
      }
    }

    _show(dir, migratedFiles, files, migratedLines, lines);
    totalFiles += files;
    totalLines += lines;
    totalMigratedFiles += migratedFiles;
    totalMigratedLines += migratedLines;
  }

  print("");
  _show(
      "total", totalMigratedFiles, totalFiles, totalMigratedLines, totalLines);
}

void _show(
    String label, int migratedFiles, int files, int migratedLines, int lines) {
  percent(num n, num max) =>
      (100 * migratedFiles / files).toStringAsFixed(1).padLeft(5);
  pad(Object value, int length) => value.toString().padLeft(length);

  var days = lines / _linesPerDay;
  var migratedDays = migratedLines / _linesPerDay;
  var daysLeft = days - migratedDays;

  print("${label.padRight(12)} ${pad(migratedFiles, 4)} / ${pad(files, 4)} "
      "files (${percent(migratedFiles, files)}%), "
      "${pad(migratedLines, 6)}/${pad(lines, 6)} "
      "lines (${percent(migratedLines, lines)}%), "
      "${pad(migratedDays.toStringAsFixed(2), 6)}/"
      "${pad(days.toStringAsFixed(2), 6)} "
      "days (${percent(migratedDays, days)}%), "
      "${pad(daysLeft.toStringAsFixed(2), 6)} "
      "days left (${percent(daysLeft, days)}%)");
}
