// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analysis_server/src/plugin/plugin_locator.dart';
import 'package:analysis_server/src/plugin/plugin_manager.dart';
import 'package:analysis_server/src/plugin/plugin_watcher.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/context/context_root.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/session.dart';
import 'package:analyzer/src/generated/engine.dart' show AnalysisOptionsImpl;
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/source/package_map_resolver.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:analyzer/src/test_utilities/resource_provider_mixin.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PluginWatcherTest);
  });
}

@reflectiveTest
class PluginWatcherTest with ResourceProviderMixin {
  TestPluginManager manager;
  PluginWatcher watcher;

  void setUp() {
    manager = new TestPluginManager();
    watcher = new PluginWatcher(resourceProvider, manager);
  }

  test_addedDriver() async {
    String pkg1Path = newFolder('/pkg1').path;
    newFile('/pkg1/lib/test1.dart');
    newFile('/pkg2/lib/pkg2.dart');
    newFile('/pkg2/pubspec.yaml', content: 'name: pkg2');
    newFile(
        '/pkg2/${PluginLocator.toolsFolderName}/${PluginLocator.defaultPluginFolderName}/bin/plugin.dart');

    ContextRoot contextRoot = new ContextRoot(pkg1Path, [],
        pathContext: resourceProvider.pathContext);
    TestDriver driver = new TestDriver(resourceProvider, contextRoot);
    driver.analysisOptions.enabledPluginNames = ['pkg2'];
    expect(manager.addedContextRoots, isEmpty);
    watcher.addedDriver(driver, contextRoot);
    //
    // Test to see whether the listener was configured correctly.
    //
    // Use a file in the package being analyzed.
    //
//    await driver.computeResult('package:pkg1/test1.dart');
//    expect(manager.addedContextRoots, isEmpty);
    //
    // Use a file that imports a package with a plugin.
    //
//    await driver.computeResult('package:pkg2/pk2.dart');
    //
    // Wait until the timer associated with the driver's FileSystemState is
    // guaranteed to have expired and the list of changed files will have been
    // delivered.
    //
    await new Future.delayed(new Duration(seconds: 1));
    expect(manager.addedContextRoots, hasLength(1));
  }

  test_addedDriver_missingPackage() async {
    String pkg1Path = newFolder('/pkg1').path;
    newFile('/pkg1/lib/test1.dart');

    ContextRoot contextRoot = new ContextRoot(pkg1Path, [],
        pathContext: resourceProvider.pathContext);
    TestDriver driver = new TestDriver(resourceProvider, contextRoot);
    driver.analysisOptions.enabledPluginNames = ['pkg3'];
    watcher.addedDriver(driver, contextRoot);
    expect(manager.addedContextRoots, isEmpty);
    //
    // Wait until the timer associated with the driver's FileSystemState is
    // guaranteed to have expired and the list of changed files will have been
    // delivered.
    //
    await new Future.delayed(new Duration(seconds: 1));
    expect(manager.addedContextRoots, isEmpty);
  }

  void test_creation() {
    expect(watcher.resourceProvider, resourceProvider);
    expect(watcher.manager, manager);
  }

  test_removedDriver() {
    String pkg1Path = newFolder('/pkg1').path;
    ContextRoot contextRoot = new ContextRoot(pkg1Path, [],
        pathContext: resourceProvider.pathContext);
    TestDriver driver = new TestDriver(resourceProvider, contextRoot);
    watcher.addedDriver(driver, contextRoot);
    watcher.removedDriver(driver);
    expect(manager.removedContextRoots, equals([contextRoot]));
  }
}

class TestDriver implements AnalysisDriver {
  final MemoryResourceProvider resourceProvider;

  SourceFactory sourceFactory;
  AnalysisSession currentSession;
  AnalysisOptionsImpl analysisOptions = new AnalysisOptionsImpl();

  final _resultController = new StreamController<ResolvedUnitResult>();

  TestDriver(this.resourceProvider, ContextRoot contextRoot) {
    path.Context pathContext = resourceProvider.pathContext;
    MockSdk sdk = new MockSdk(resourceProvider: resourceProvider);
    String packageName = pathContext.basename(contextRoot.root);
    String libPath = pathContext.join(contextRoot.root, 'lib');
    sourceFactory = new SourceFactory([
      new DartUriResolver(sdk),
      new PackageMapUriResolver(resourceProvider, {
        packageName: [resourceProvider.getFolder(libPath)],
        'pkg2': [
          resourceProvider.getFolder(resourceProvider.convertPath('/pkg2/lib'))
        ]
      })
    ]);
    currentSession = new AnalysisSessionImpl(this);
  }

  Stream<ResolvedUnitResult> get results => _resultController.stream;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestPluginManager implements PluginManager {
  List<ContextRoot> addedContextRoots = <ContextRoot>[];

  List<ContextRoot> removedContextRoots = <ContextRoot>[];

  @override
  Future<void> addPluginToContextRoot(
      ContextRoot contextRoot, String path) async {
    addedContextRoots.add(contextRoot);
    return null;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  void recordPluginFailure(String hostPackageName, String message) {}

  @override
  void removedContextRoot(ContextRoot contextRoot) {
    removedContextRoots.add(contextRoot);
  }
}
