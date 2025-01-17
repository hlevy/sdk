// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:analysis_server/lsp_protocol/protocol_custom_generated.dart';
import 'package:analysis_server/lsp_protocol/protocol_generated.dart';
import 'package:analysis_server/lsp_protocol/protocol_special.dart';
import 'package:analysis_server/src/analysis_server.dart';
import 'package:analysis_server/src/lsp/constants.dart';
import 'package:analysis_server/src/lsp/lsp_analysis_server.dart';
import 'package:analysis_server/src/lsp/mapping.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:analyzer/src/test_utilities/resource_provider_mixin.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../mocks.dart';

const dartLanguageId = 'dart';

/// Useful for debugging locally, setting this to true will cause all JSON
/// communication to be printed to stdout.
const debugPrintCommunication = false;

final beginningOfDocument = new Range(new Position(0, 0), new Position(0, 0));

abstract class AbstractLspAnalysisServerTest
    with
        ResourceProviderMixin,
        ClientCapabilitiesHelperMixin,
        LspAnalysisServerTestMixin {
  MockLspServerChannel channel;
  LspAnalysisServer server;

  Stream<Message> get serverToClient => channel.serverToClient;

  /// Sends a request to the server and unwraps the result. Throws if the
  /// response was not successful or returned an error.
  Future<T> expectSuccessfulResponseTo<T>(RequestMessage request) async {
    final resp = await sendRequestToServer(request);
    if (resp.error != null) {
      throw resp.error;
    } else {
      return resp.result as T;
    }
  }

  Future sendNotificationToServer(NotificationMessage notification) async {
    channel.sendNotificationToServer(notification);
    await pumpEventQueue();
  }

  Future<ResponseMessage> sendRequestToServer(RequestMessage request) {
    return channel.sendRequestToServer(request);
  }

  void sendResponseToServer(ResponseMessage response) {
    channel.sendResponseToServer(response);
  }

  void setUp() {
    channel = new MockLspServerChannel(debugPrintCommunication);
    // Create an SDK in the mock file system.
    new MockSdk(resourceProvider: resourceProvider);
    server = new LspAnalysisServer(
        channel,
        resourceProvider,
        new AnalysisServerOptions(),
        new DartSdkManager(convertPath('/sdk'), false),
        InstrumentationService.NULL_SERVICE);

    projectFolderPath = convertPath('/home/test');
    projectFolderUri = Uri.file(projectFolderPath);
    newFolder(projectFolderPath);
    newFolder(join(projectFolderPath, 'lib'));
    // Create a folder and file to aid testing that includes imports/completion.
    newFolder(join(projectFolderPath, 'lib', 'folder'));
    newFile(join(projectFolderPath, 'lib', 'file.dart'));
    mainFilePath = join(projectFolderPath, 'lib', 'main.dart');
    mainFileUri = Uri.file(mainFilePath);
    pubspecFilePath = join(projectFolderPath, 'pubspec.yaml');
    pubspecFileUri = Uri.file(pubspecFilePath);
    analysisOptionsPath = join(projectFolderPath, 'analysis_options.yaml');
    analysisOptionsUri = Uri.file(analysisOptionsPath);
  }

  Future tearDown() async {
    channel.close();
    await server.shutdown();
  }
}

mixin ClientCapabilitiesHelperMixin {
  final emptyTextDocumentClientCapabilities =
      new TextDocumentClientCapabilities(
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null);

  final emptyWorkspaceClientCapabilities = new WorkspaceClientCapabilities(
      null, null, null, null, null, null, null, null);

  TextDocumentClientCapabilities extendTextDocumentCapabilities(
    TextDocumentClientCapabilities source,
    Map<String, dynamic> textDocumentCapabilities,
  ) {
    // TODO(dantup): Figure out why we need to do this to get a map...
    // source.toJson() doesn't recursively called toJson() so we end up with
    // objects (instead of maps) in child properties, which means multiple
    // calls to this function do not work correctly. For now, calling jsonEncode
    // then jsonDecode will force recursive serialisation.
    final json = jsonDecode(jsonEncode(source));
    if (textDocumentCapabilities != null) {
      textDocumentCapabilities.keys.forEach((key) {
        json[key] = textDocumentCapabilities[key];
      });
    }
    return TextDocumentClientCapabilities.fromJson(json);
  }

  WorkspaceClientCapabilities extendWorkspaceCapabilities(
    WorkspaceClientCapabilities source,
    Map<String, dynamic> workspaceCapabilities,
  ) {
    // TODO(dantup): As above - it seems like this round trip should be
    // unnecessary.
    final json = jsonDecode(jsonEncode(source));
    if (workspaceCapabilities != null) {
      workspaceCapabilities.keys.forEach((key) {
        json[key] = workspaceCapabilities[key];
      });
    }
    return WorkspaceClientCapabilities.fromJson(json);
  }

  WorkspaceClientCapabilities withApplyEditSupport(
    WorkspaceClientCapabilities source,
  ) {
    return extendWorkspaceCapabilities(source, {'applyEdit': true});
  }

  TextDocumentClientCapabilities withCodeActionKinds(
    TextDocumentClientCapabilities source,
    List<CodeActionKind> kinds,
  ) {
    return extendTextDocumentCapabilities(source, {
      'codeAction': {
        'codeActionLiteralSupport': {
          'codeActionKind': {'valueSet': kinds.map((k) => k.toJson()).toList()}
        }
      }
    });
  }

  TextDocumentClientCapabilities withCompletionItemDeprecatedSupport(
    TextDocumentClientCapabilities source,
  ) {
    return extendTextDocumentCapabilities(source, {
      'completion': {
        'completionItem': {'deprecatedSupport': true}
      }
    });
  }

  TextDocumentClientCapabilities withCompletionItemKinds(
    TextDocumentClientCapabilities source,
    List<CompletionItemKind> kinds,
  ) {
    return extendTextDocumentCapabilities(source, {
      'completion': {
        'completionItemKind': {
          'valueSet': kinds.map((k) => k.toJson()).toList()
        }
      }
    });
  }

  TextDocumentClientCapabilities withCompletionItemSnippetSupport(
    TextDocumentClientCapabilities source,
  ) {
    return extendTextDocumentCapabilities(source, {
      'completion': {
        'completionItem': {'snippetSupport': true}
      }
    });
  }

  WorkspaceClientCapabilities withDocumentChangesSupport(
    WorkspaceClientCapabilities source,
  ) {
    return extendWorkspaceCapabilities(source, {
      'workspaceEdit': {'documentChanges': true}
    });
  }

  TextDocumentClientCapabilities withHierarchicalDocumentSymbolSupport(
    TextDocumentClientCapabilities source,
  ) {
    return extendTextDocumentCapabilities(source, {
      'documentSymbol': {'hierarchicalDocumentSymbolSupport': true}
    });
  }

  TextDocumentClientCapabilities withHoverContentFormat(
    TextDocumentClientCapabilities source,
    List<MarkupKind> formats,
  ) {
    return extendTextDocumentCapabilities(source, {
      'hover': {'contentFormat': formats.map((k) => k.toJson()).toList()}
    });
  }

  TextDocumentClientCapabilities withHoverDynamicRegistration(
    TextDocumentClientCapabilities source,
  ) {
    return extendTextDocumentCapabilities(source, {
      'hover': {'dynamicRegistration': true}
    });
  }

  TextDocumentClientCapabilities withSignatureHelpContentFormat(
    TextDocumentClientCapabilities source,
    List<MarkupKind> formats,
  ) {
    return extendTextDocumentCapabilities(source, {
      'signatureHelp': {
        'signatureInformation': {
          'documentationFormat': formats.map((k) => k.toJson()).toList()
        }
      }
    });
  }

  TextDocumentClientCapabilities withTextSyncDynamicRegistration(
    TextDocumentClientCapabilities source,
  ) {
    return extendTextDocumentCapabilities(source, {
      'synchronization': {'dynamicRegistration': true}
    });
  }
}

mixin LspAnalysisServerTestMixin implements ClientCapabilitiesHelperMixin {
  static const positionMarker = '^';
  static const rangeMarkerStart = '[[';
  static const rangeMarkerEnd = ']]';
  static const allMarkers = [positionMarker, rangeMarkerStart, rangeMarkerEnd];
  static final allMarkersPattern =
      new RegExp(allMarkers.map(RegExp.escape).join('|'));

  int _id = 0;
  String projectFolderPath, mainFilePath, pubspecFilePath, analysisOptionsPath;
  Uri projectFolderUri, mainFileUri, pubspecFileUri, analysisOptionsUri;
  final String simplePubspecContent = 'name: my_project';
  final startOfDocPos = new Position(0, 0);
  final startOfDocRange = new Range(new Position(0, 0), new Position(0, 0));

  /**
   * A stream of [NotificationMessage]s from the server that may be errors.
   */
  Stream<NotificationMessage> get errorNotificationsFromServer {
    return notificationsFromServer.where(_isErrorNotification);
  }

  /**
   * A stream of [NotificationMessage]s from the server.
   */
  Stream<NotificationMessage> get notificationsFromServer {
    return serverToClient
        .where((m) => m is NotificationMessage)
        .cast<NotificationMessage>();
  }

  /**
   * A stream of [RequestMessage]s from the server.
   */
  Stream<RequestMessage> get requestsFromServer {
    return serverToClient
        .where((m) => m is RequestMessage)
        .cast<RequestMessage>();
  }

  Stream<Message> get serverToClient;

  void applyChanges(
    Map<String, String> fileContents,
    Map<String, List<TextEdit>> changes,
  ) {
    changes.forEach((fileUri, edits) {
      final path = Uri.parse(fileUri).toFilePath();
      fileContents[path] = applyTextEdits(fileContents[path], edits);
    });
  }

  void applyDocumentChanges(
    Map<String, String> fileContents,
    Either2<List<TextDocumentEdit>,
            List<Either4<TextDocumentEdit, CreateFile, RenameFile, DeleteFile>>>
        documentChanges, {
    Map<String, int> expectedVersions,
  }) {
    // If we were supplied with expected versions, ensure that all returned
    // edits match the versions.
    if (expectedVersions != null) {
      expectDocumentVersions(documentChanges, expectedVersions);
    }
    documentChanges.map(
      (edits) => applyTextDocumentEdits(fileContents, edits),
      (changes) => applyResourceChanges(fileContents, changes),
    );
  }

  void applyResourceChanges(
    Map<String, String> oldFileContent,
    List<Either4<TextDocumentEdit, CreateFile, RenameFile, DeleteFile>> changes,
  ) {
    // TODO(dantup): Implement handling of resource changes (not currently used).
    throw 'Test helper applyResourceChanges not currently supported';
  }

  String applyTextDocumentEdit(String content, TextDocumentEdit edit) {
    return edit.edits.fold(content, applyTextEdit);
  }

  void applyTextDocumentEdits(
      Map<String, String> oldFileContent, List<TextDocumentEdit> edits) {
    edits.forEach((edit) {
      final path = Uri.parse(edit.textDocument.uri).toFilePath();
      if (!oldFileContent.containsKey(path)) {
        throw 'Recieved edits for $path which was not provided as a file to be edited';
      }
      oldFileContent[path] = applyTextDocumentEdit(oldFileContent[path], edit);
    });
  }

  String applyTextEdit(String content, TextEdit change) {
    final startPos = change.range.start;
    final endPos = change.range.end;
    final lineInfo = LineInfo.fromContent(content);
    final start = lineInfo.getOffsetOfLine(startPos.line) + startPos.character;
    final end = lineInfo.getOffsetOfLine(endPos.line) + endPos.character;
    return content.replaceRange(start, end, change.newText);
  }

  String applyTextEdits(String oldContent, List<TextEdit> changes) {
    String newContent = oldContent;
    // Complex text manipulations are described with an array of TextEdit's,
    // representing a single change to the document.
    //
    // All text edits ranges refer to positions in the original document. Text
    // edits ranges must never overlap, that means no part of the original
    // document must be manipulated by more than one edit. It is possible
    // that multiple edits have the same start position (eg. multiple inserts in
    // reverse order), however since that involves complicated tracking and we
    // only apply edits here sequentially, we don't supported them. We do sort
    // edits to ensure we apply the later ones first, so we can assume the locations
    // in the edit are still valid against the new string as each edit is applied.

    /// Ensures changes are simple enough to apply easily without any complicated
    /// logic.
    void validateChangesCanBeApplied() {
      /// Check if a position is before (but not equal) to another position.
      bool isBefore(Position p, Position other) =>
          p.line < other.line ||
          (p.line == other.line && p.character < other.character);

      /// Check if a position is after (but not equal) to another position.
      bool isAfter(Position p, Position other) =>
          p.line > other.line ||
          (p.line == other.line && p.character > other.character);
      // Check if two ranges intersect or touch.
      bool rangesIntersect(Range r1, Range r2) {
        bool endsBefore = isBefore(r1.end, r2.start);
        bool startsAfter = isAfter(r1.start, r2.end);
        return !(endsBefore || startsAfter);
      }

      for (final change1 in changes) {
        for (final change2 in changes) {
          if (change1 != change2 &&
              rangesIntersect(change1.range, change2.range)) {
            throw 'Test helper applyTextEdits does not support applying multiple edits '
                'where the edits are not in reverse order.';
          }
        }
      }
    }

    validateChangesCanBeApplied();
    changes.sort(
      (c1, c2) =>
          positionCompare(c1.range.start, c2.range.start) *
          -1, // Multiply by -1 to get descending sort.
    );
    for (final change in changes) {
      newContent = applyTextEdit(newContent, change);
    }

    return newContent;
  }

  Future changeFile(
    int newVersion,
    Uri uri,
    List<TextDocumentContentChangeEvent> changes,
  ) async {
    var notification = makeNotification(
      Method.textDocument_didChange,
      new DidChangeTextDocumentParams(
        new VersionedTextDocumentIdentifier(newVersion, uri.toString()),
        changes,
      ),
    );
    await sendNotificationToServer(notification);
  }

  Future changeWorkspaceFolders({List<Uri> add, List<Uri> remove}) async {
    var notification = makeNotification(
      Method.workspace_didChangeWorkspaceFolders,
      new DidChangeWorkspaceFoldersParams(
        new WorkspaceFoldersChangeEvent(
          add?.map(toWorkspaceFolder)?.toList() ?? const [],
          remove?.map(toWorkspaceFolder)?.toList() ?? const [],
        ),
      ),
    );
    await sendNotificationToServer(notification);
  }

  Future closeFile(Uri uri) async {
    var notification = makeNotification(
      Method.textDocument_didClose,
      new DidCloseTextDocumentParams(
          new TextDocumentIdentifier(uri.toString())),
    );
    await sendNotificationToServer(notification);
  }

  Future<Object> executeCommand(Command command) async {
    final request = makeRequest(
      Method.workspace_executeCommand,
      new ExecuteCommandParams(
        command.command,
        command.arguments,
      ),
    );
    return expectSuccessfulResponseTo(request);
  }

  void expectDocumentVersion(
    TextDocumentEdit edit,
    Map<String, int> expectedVersions,
  ) {
    final path = Uri.parse(edit.textDocument.uri).toFilePath();
    final expectedVersion = expectedVersions[path];

    if (edit.textDocument is VersionedTextDocumentIdentifier) {
      expect(edit.textDocument.version, equals(expectedVersion));
    } else {
      throw 'Document identifier for $path was not versioned (expected version $expectedVersion)';
    }
  }

  /// Validates the document versions for a set of edits match the versions in
  /// the supplied map.
  void expectDocumentVersions(
    Either2<List<TextDocumentEdit>,
            List<Either4<TextDocumentEdit, CreateFile, RenameFile, DeleteFile>>>
        documentChanges,
    Map<String, int> expectedVersions,
  ) {
    documentChanges.map(
      // Validate versions on simple doc edits
      (edits) => edits
          .forEach((edit) => expectDocumentVersion(edit, expectedVersions)),
      // For resource changes, we only need to validate changes since
      // creates/renames/deletes do not supply versions.
      (changes) => changes.forEach((change) {
        change.map(
          (edit) => expectDocumentVersion(edit, expectedVersions),
          (create) => {},
          (rename) {},
          (delete) {},
        );
      }),
    );
  }

  Future<T> expectErrorNotification<T>(
    FutureOr<void> f(), {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final firstError = errorNotificationsFromServer.first;
    await f();

    final notificationFromServer = await firstError.timeout(timeout);

    expect(notificationFromServer, isNotNull);
    return notificationFromServer.params as T;
  }

  Future<T> expectNotification<T>(
    bool Function(NotificationMessage) test,
    FutureOr<void> f(), {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final firstError = notificationsFromServer.firstWhere(test);
    await f();

    final notificationFromServer = await firstError.timeout(timeout);

    expect(notificationFromServer, isNotNull);
    return notificationFromServer.params as T;
  }

  /// Expects a [method] request from the server after executing [f].
  Future<RequestMessage> expectRequest(
    Method method,
    FutureOr<void> f(), {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final firstRequest =
        requestsFromServer.firstWhere((n) => n.method == method);
    await f();

    final requestFromServer = await firstRequest.timeout(timeout);

    expect(requestFromServer, isNotNull);
    return requestFromServer;
  }

  Future<T> expectSuccessfulResponseTo<T>(RequestMessage request);

  Future<List<TextEdit>> formatDocument(String fileUri) {
    final request = makeRequest(
      Method.textDocument_formatting,
      new DocumentFormattingParams(
        new TextDocumentIdentifier(fileUri),
        new FormattingOptions(2, true), // These currently don't do anything
      ),
    );
    return expectSuccessfulResponseTo(request);
  }

  Future<List<TextEdit>> formatOnType(
      String fileUri, Position pos, String character) {
    final request = makeRequest(
      Method.textDocument_onTypeFormatting,
      new DocumentOnTypeFormattingParams(
        new TextDocumentIdentifier(fileUri),
        pos,
        character,
        new FormattingOptions(2, true), // These currently don't do anything
      ),
    );
    return expectSuccessfulResponseTo(request);
  }

  Future<List<Either2<Command, CodeAction>>> getCodeActions(
    String fileUri, {
    Range range,
    List<CodeActionKind> kinds,
  }) {
    final request = makeRequest(
      Method.textDocument_codeAction,
      new CodeActionParams(
          new TextDocumentIdentifier(fileUri),
          range ?? beginningOfDocument,
          // TODO(dantup): We may need to revise the tests/implementation when
          // it's clear how we're supposed to handle diagnostics:
          // https://github.com/Microsoft/language-server-protocol/issues/583
          new CodeActionContext([], kinds)),
    );
    return expectSuccessfulResponseTo(request);
  }

  Future<List<CompletionItem>> getCompletion(Uri uri, Position pos,
      {CompletionContext context}) {
    final request = makeRequest(
      Method.textDocument_completion,
      new CompletionParams(
        context,
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<List<CompletionItem>>(request);
  }

  Future<List<Location>> getDefinition(Uri uri, Position pos) {
    final request = makeRequest(
      Method.textDocument_definition,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<List<Location>>(request);
  }

  Future<DartDiagnosticServer> getDiagnosticServer() {
    final request = makeRequest(
      CustomMethods.DiagnosticServer,
      null,
    );
    return expectSuccessfulResponseTo(request);
  }

  Future<List<DocumentHighlight>> getDocumentHighlights(Uri uri, Position pos) {
    final request = makeRequest(
      Method.textDocument_documentHighlight,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<List<DocumentHighlight>>(request);
  }

  Future<Either2<List<DocumentSymbol>, List<SymbolInformation>>>
      getDocumentSymbols(String fileUri) {
    final request = makeRequest(
      Method.textDocument_documentSymbol,
      new DocumentSymbolParams(
        new TextDocumentIdentifier(fileUri),
      ),
    );
    return expectSuccessfulResponseTo(request);
  }

  Future<List<FoldingRange>> getFoldingRegions(Uri uri) {
    final request = makeRequest(
      Method.textDocument_foldingRange,
      new FoldingRangeParams(new TextDocumentIdentifier(uri.toString())),
    );
    return expectSuccessfulResponseTo<List<FoldingRange>>(request);
  }

  Future<Hover> getHover(Uri uri, Position pos) {
    final request = makeRequest(
      Method.textDocument_hover,
      new TextDocumentPositionParams(
          new TextDocumentIdentifier(uri.toString()), pos),
    );
    return expectSuccessfulResponseTo<Hover>(request);
  }

  Future<List<Location>> getImplementations(
    Uri uri,
    Position pos, {
    includeDeclarations = false,
  }) {
    final request = makeRequest(
      Method.textDocument_implementation,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<List<Location>>(request);
  }

  Future<List<Location>> getReferences(
    Uri uri,
    Position pos, {
    includeDeclarations = false,
  }) {
    final request = makeRequest(
      Method.textDocument_references,
      new ReferenceParams(
        new ReferenceContext(includeDeclarations),
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<List<Location>>(request);
  }

  Future<SignatureHelp> getSignatureHelp(Uri uri, Position pos) {
    final request = makeRequest(
      Method.textDocument_signatureHelp,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<SignatureHelp>(request);
  }

  Future<Location> getSuper(
    Uri uri,
    Position pos,
  ) {
    final request = makeRequest(
      CustomMethods.Super,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<Location>(request);
  }

  Future<List<SymbolInformation>> getWorkspaceSymbols(String query) {
    final request = makeRequest(
      Method.workspace_symbol,
      new WorkspaceSymbolParams(query),
    );
    return expectSuccessfulResponseTo(request);
  }

  /// Executes [f] then waits for a request of type [method] from the server which
  /// is passed to [handler] to process, then waits for (and returns) the
  /// response to the original request.
  ///
  /// This is used for testing things like code actions, where the client initiates
  /// a request but the server does not respond to it until it's sent its own
  /// request to the client and it recieved a response.
  ///
  ///     Client                                 Server
  ///     1. |- Req: textDocument/codeAction      ->
  ///     1. <- Resp: textDocument/codeAction     -|
  ///
  ///     2. |- Req: workspace/executeCommand  ->
  ///           3. <- Req: textDocument/applyEdits  -|
  ///           3. |- Resp: textDocument/applyEdits ->
  ///     2. <- Resp: workspace/executeCommand -|
  ///
  /// Request 2 from the client is not responded to until the server has its own
  /// response to the request it sends (3).
  Future<T> handleExpectedRequest<T, R, RR>(
    Method method,
    Future<T> f(), {
    @required FutureOr<RR> handler(R params),
    Duration timeout = const Duration(seconds: 5),
  }) async {
    FutureOr<T> outboundRequest;

    // Run [f] and wait for the incoming request from the server.
    final incomingRequest = await expectRequest(method, () {
      // Don't return/await the response yet, as this may not complete until
      // after we have handled the request that comes from the server.
      outboundRequest = f();
    });

    // Handle the request from the server and send the response back.
    final clientsResponse = await handler(incomingRequest.params as R);
    respondTo(incomingRequest, clientsResponse);

    // Return a future that completes when the response to the original request
    // (from [f]) returns.
    return outboundRequest;
  }

  /// A helper that initializes the server with common values, since the server
  /// will reject any other requests until it is initialized.
  /// Capabilities are overridden by providing JSON to avoid having to construct
  /// full objects just to change one value (the types are immutable) so must
  /// match the spec exactly and are not verified.
  Future<ResponseMessage> initialize({
    String rootPath,
    Uri rootUri,
    List<Uri> workspaceFolders,
    TextDocumentClientCapabilities textDocumentCapabilities,
    WorkspaceClientCapabilities workspaceCapabilities,
    Map<String, Object> initializationOptions,
    bool throwOnFailure = true,
  }) async {
    // Assume if none of the project options were set, that we want to default to
    // opening the test project folder.
    if (rootPath == null && rootUri == null && workspaceFolders == null) {
      rootUri = Uri.file(projectFolderPath);
    }
    final request = makeRequest(
        Method.initialize,
        new InitializeParams(
            null,
            rootPath,
            rootUri?.toString(),
            initializationOptions,
            new ClientCapabilities(
              workspaceCapabilities,
              textDocumentCapabilities,
              null,
            ),
            null,
            workspaceFolders?.map(toWorkspaceFolder)?.toList()));
    final response = await sendRequestToServer(request);
    expect(response.id, equals(request.id));

    if (response.error == null) {
      final notification =
          makeNotification(Method.initialized, new InitializedParams());
      await sendNotificationToServer(notification);
      await pumpEventQueue();
    } else if (throwOnFailure) {
      throw 'Error during initialize request: '
          '${response.error.code}: ${response.error.message}';
    }

    return response;
  }

  NotificationMessage makeNotification(Method method, ToJsonable params) {
    return new NotificationMessage(method, params, jsonRpcVersion);
  }

  RequestMessage makeRenameRequest(
      int version, Uri uri, Position pos, String newName) {
    final docIdentifier = version != null
        ? new VersionedTextDocumentIdentifier(version, uri.toString())
        : new TextDocumentIdentifier(uri.toString());
    final request = makeRequest(
      Method.textDocument_rename,
      new RenameParams(docIdentifier, pos, newName),
    );
    return request;
  }

  RequestMessage makeRequest(Method method, ToJsonable params) {
    final id = Either2<num, String>.t1(_id++);
    return new RequestMessage(id, method, params, jsonRpcVersion);
  }

  Future openFile(Uri uri, String content, {num version = 1}) async {
    var notification = makeNotification(
      Method.textDocument_didOpen,
      new DidOpenTextDocumentParams(new TextDocumentItem(
          uri.toString(), dartLanguageId, version, content)),
    );
    await sendNotificationToServer(notification);
    await pumpEventQueue();
  }

  int positionCompare(Position p1, Position p2) {
    if (p1.line < p2.line) return -1;
    if (p1.line > p2.line) return 1;

    if (p1.character < p2.character) return -1;
    if (p1.character > p2.character) return -1;

    return 0;
  }

  Position positionFromMarker(String contents) =>
      positionFromOffset(withoutRangeMarkers(contents).indexOf('^'), contents);

  Position positionFromOffset(int offset, String contents) {
    final lineInfo = LineInfo.fromContent(withoutMarkers(contents));
    return toPosition(lineInfo.getLocation(offset));
  }

  Future<RangeAndPlaceholder> prepareRename(Uri uri, Position pos) {
    final request = makeRequest(
      Method.textDocument_prepareRename,
      new TextDocumentPositionParams(
        new TextDocumentIdentifier(uri.toString()),
        pos,
      ),
    );
    return expectSuccessfulResponseTo<RangeAndPlaceholder>(request);
  }

  /// Returns the range surrounded by `[[markers]]` in the provided string,
  /// excluding the markers themselves (as well as position markers `^` from
  /// the offsets).
  Range rangeFromMarkers(String contents) {
    final ranges = rangesFromMarkers(contents);
    if (ranges.length == 1) {
      return ranges.first;
    } else if (ranges.isEmpty) {
      throw 'Contents did not include a marked range';
    } else {
      throw 'Contents contained multiple ranges but only one was expected';
    }
  }

  /// Returns all ranges surrounded by `[[markers]]` in the provided string,
  /// excluding the markers themselves (as well as position markers `^` from
  /// the offsets).
  List<Range> rangesFromMarkers(String content) {
    Iterable<Range> rangesFromMarkersImpl(String content) sync* {
      content = content.replaceAll(positionMarker, '');
      final contentsWithoutMarkers = withoutMarkers(content);
      var searchStartIndex = 0;
      var offsetForEarlierMarkers = 0;
      while (true) {
        final startMarker = content.indexOf(rangeMarkerStart, searchStartIndex);
        if (startMarker == -1) {
          return; // Exit if we didn't find any more.
        }
        final endMarker = content.indexOf(rangeMarkerEnd, startMarker);
        if (endMarker == -1) {
          throw 'Found unclosed range starting at offset $startMarker';
        }
        yield new Range(
          positionFromOffset(
              startMarker + offsetForEarlierMarkers, contentsWithoutMarkers),
          positionFromOffset(
              endMarker + offsetForEarlierMarkers - rangeMarkerStart.length,
              contentsWithoutMarkers),
        );
        // Start the next search after this one, but remember to offset the future
        // results by the lengths of these markers since they shouldn't affect the
        // offsets.
        searchStartIndex = endMarker;
        offsetForEarlierMarkers -=
            rangeMarkerStart.length + rangeMarkerEnd.length;
      }
    }

    return rangesFromMarkersImpl(content).toList();
  }

  Future<WorkspaceEdit> rename(
    Uri uri,
    int version,
    Position pos,
    String newName,
  ) {
    final request = makeRenameRequest(version, uri, pos, newName);
    return expectSuccessfulResponseTo<WorkspaceEdit>(request);
  }

  Future<ResponseMessage> renameRaw(
    Uri uri,
    int version,
    Position pos,
    String newName,
  ) {
    final request = makeRenameRequest(version, uri, pos, newName);
    return sendRequestToServer(request);
  }

  Future replaceFile(int newVersion, Uri uri, String content) {
    return changeFile(
      newVersion,
      uri,
      [new TextDocumentContentChangeEvent(null, null, content)],
    );
  }

  Future<CompletionItem> resolveCompletion(CompletionItem item) {
    final request = makeRequest(
      Method.completionItem_resolve,
      item,
    );
    return expectSuccessfulResponseTo<CompletionItem>(request);
  }

  /// Sends [responseParams] to the server as a successful response to
  /// a server-initiated [request].
  void respondTo<T>(RequestMessage request, T responseParams) {
    sendResponseToServer(
        new ResponseMessage(request.id, responseParams, null, jsonRpcVersion));
  }

  void sendExit() {
    final request = makeRequest(Method.exit, null);
    sendRequestToServer(request);
  }

  FutureOr<void> sendNotificationToServer(NotificationMessage notification);

  Future<ResponseMessage> sendRequestToServer(RequestMessage request);

  void sendResponseToServer(ResponseMessage response);

  Future<Null> sendShutdown() {
    final request = makeRequest(Method.shutdown, null);
    return expectSuccessfulResponseTo(request);
  }

  WorkspaceFolder toWorkspaceFolder(Uri uri) {
    return WorkspaceFolder(uri.toString(), path.basename(uri.toFilePath()));
  }

  Future<AnalyzerStatusParams> waitForAnalysisComplete() =>
      waitForAnalysisStatus(false);

  Future<AnalyzerStatusParams> waitForAnalysisStart() =>
      waitForAnalysisStatus(true);

  Future<AnalyzerStatusParams> waitForAnalysisStatus(bool analyzing) async {
    AnalyzerStatusParams params;
    await serverToClient.firstWhere((message) {
      if (message is NotificationMessage &&
          message.method == CustomMethods.AnalyzerStatus) {
        params = _convertParams(message, AnalyzerStatusParams.fromJson);
        return params.isAnalyzing == analyzing;
      }
      return false;
    });
    return params;
  }

  Future<List<ClosingLabel>> waitForClosingLabels(Uri uri) async {
    PublishClosingLabelsParams closingLabelsParams;
    await serverToClient.firstWhere((message) {
      if (message is NotificationMessage &&
          message.method == CustomMethods.PublishClosingLabels) {
        closingLabelsParams =
            _convertParams(message, PublishClosingLabelsParams.fromJson);

        return closingLabelsParams.uri == uri.toString();
      }
      return false;
    });
    return closingLabelsParams.labels;
  }

  Future<List<Diagnostic>> waitForDiagnostics(Uri uri) async {
    PublishDiagnosticsParams diagnosticParams;
    await serverToClient.firstWhere((message) {
      if (message is NotificationMessage &&
          message.method == Method.textDocument_publishDiagnostics) {
        diagnosticParams =
            _convertParams(message, PublishDiagnosticsParams.fromJson);
        return diagnosticParams.uri == uri.toString();
      }
      return false;
    });
    return diagnosticParams.diagnostics;
  }

  Future<Outline> waitForOutline(Uri uri) async {
    PublishOutlineParams outlineParams;
    await serverToClient.firstWhere((message) {
      if (message is NotificationMessage &&
          message.method == CustomMethods.PublishOutline) {
        outlineParams = _convertParams(message, PublishOutlineParams.fromJson);

        return outlineParams.uri == uri.toString();
      }
      return false;
    });
    return outlineParams.outline;
  }

  /// Removes markers like `[[` and `]]` and `^` that are used for marking
  /// positions/ranges in strings to avoid hard-coding positions in tests.
  String withoutMarkers(String contents) =>
      contents.replaceAll(allMarkersPattern, '');

  /// Removes range markers from strings to give accurate position offsets.
  String withoutRangeMarkers(String contents) =>
      contents.replaceAll(rangeMarkerStart, '').replaceAll(rangeMarkerEnd, '');

  /// A helper to simplify processing of results for both in-process tests (where
  /// we'll get the real type back), and out-of-process integration tests (where
  /// params is `Map<String, dynamic>` and needs to be fromJson'd).
  T _convertParams<T>(
    IncomingMessage message,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return message.params is T ? message.params : fromJson(message.params);
  }

  /// Checks whether a notification is likely an error from the server (for
  /// example a window/showMessage). This is useful for tests that want to
  /// ensure no errors come from the server in response to notifications (which
  /// don't have their own responses).
  bool _isErrorNotification(NotificationMessage notification) {
    return notification.method == Method.window_logMessage ||
        notification.method == Method.window_showMessage;
  }
}
