import 'dart:async';
import 'dart:convert';

import 'package:conduit/core/app_failure.dart';
import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/terminal/domain/ssh_terminal_repository.dart';
import 'package:conduit/features/terminal/domain/ssh_terminal_session.dart';
import 'package:conduit/features/terminal/presentation/terminal_keyboard_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

enum TerminalConnectionStatus {
  idle,
  connecting,
  connected,
  disconnected,
  failed,
}

class TerminalSessionController extends ChangeNotifier {
  TerminalSessionController({required this.host, required this.repository})
    : keyboard = TerminalKeyboardController(defaultInputHandler),
      terminal = Terminal(maxLines: 10000) {
    _configureTerminal();
  }

  final SavedHost host;
  final SshTerminalRepository repository;
  final TerminalKeyboardController keyboard;
  final Terminal terminal;

  TerminalConnectionStatus _status = TerminalConnectionStatus.idle;
  SshTerminalSession? _session;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  StreamSubscription<void>? _doneSubscription;
  String _title = '';
  int _pixelWidth = 0;
  int _pixelHeight = 0;
  bool _disconnecting = false;
  bool _disposed = false;
  int _connectionGeneration = 0;

  TerminalConnectionStatus get status => _status;
  String get title => _title.isEmpty ? host.name : _title;
  bool get isConnected => _status == TerminalConnectionStatus.connected;

  bool get shouldConnect =>
      !_disconnecting &&
      (_status == TerminalConnectionStatus.idle ||
          _status == TerminalConnectionStatus.disconnected ||
          _status == TerminalConnectionStatus.failed);

  Future<void> connect() async {
    if (_status == TerminalConnectionStatus.connecting ||
        _status == TerminalConnectionStatus.connected ||
        _disconnecting ||
        _disposed) {
      return;
    }

    final generation = ++_connectionGeneration;
    _status = TerminalConnectionStatus.connecting;
    terminal.write(
      'Connecting to ${host.username}@${host.host}:${host.port}...\r\n',
    );
    notifyListeners();

    try {
      final session = await repository.connect(
        host,
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
      );
      if (_disposed || generation != _connectionGeneration || _disconnecting) {
        unawaited(session.close());
        return;
      }
      _session = session;

      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);
      session.resize(
        terminal.viewWidth,
        terminal.viewHeight,
        _pixelWidth,
        _pixelHeight,
      );

      _stdoutSubscription = session.stdout
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(terminal.write, onError: _handleStreamError);
      _stderrSubscription = session.stderr
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(terminal.write, onError: _handleStreamError);
      _doneSubscription = session.done.asStream().listen((_) {
        if (_status == TerminalConnectionStatus.connected) {
          _status = TerminalConnectionStatus.disconnected;
          terminal.write('\r\nConnection closed.\r\n');
          notifyListeners();
        }
      }, onError: _handleStreamError);

      _status = TerminalConnectionStatus.connected;
      notifyListeners();
    } on AppFailure catch (failure) {
      if (_disposed || generation != _connectionGeneration) {
        return;
      }
      _fail(failure.toString());
    } catch (error) {
      if (_disposed || generation != _connectionGeneration) {
        return;
      }
      _fail('Connection failed: $error');
    }
  }

  Future<void> disconnect() async {
    if (_disconnecting ||
        _status == TerminalConnectionStatus.disconnected ||
        _status == TerminalConnectionStatus.idle) {
      return;
    }
    _disconnecting = true;
    _connectionGeneration += 1;

    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();
    await _doneSubscription?.cancel();
    _stdoutSubscription = null;
    _stderrSubscription = null;
    _doneSubscription = null;

    final session = _session;
    _session = null;
    try {
      await session?.close();
    } finally {
      keyboard.clearModifiers();
      _status = TerminalConnectionStatus.disconnected;
      if (!_disposed) {
        terminal.write('\r\nDisconnected.\r\n');
        notifyListeners();
      }
      _disconnecting = false;
    }
  }

  void sendKey(TerminalKey key) {
    terminal.keyInput(key, ctrl: keyboard.ctrl, alt: keyboard.alt);
    keyboard.clearModifiers();
  }

  void sendText(String text) {
    terminal.textInput(text);
    keyboard.clearModifiers();
  }

  void sendControl(TerminalKey key) {
    terminal.keyInput(key, ctrl: true);
    keyboard.clearModifiers();
  }

  void paste(String text) {
    terminal.paste(text);
    keyboard.clearModifiers();
  }

  void _configureTerminal() {
    terminal.inputHandler = keyboard;
    terminal.onTitleChange = (title) {
      _title = title;
      notifyListeners();
    };
    terminal.onResize = (columns, rows, pixelWidth, pixelHeight) {
      _pixelWidth = pixelWidth;
      _pixelHeight = pixelHeight;
      _session?.resize(columns, rows, pixelWidth, pixelHeight);
    };
    terminal.onOutput = (data) {
      final session = _session;
      if (session == null) {
        return;
      }
      unawaited(session.send(utf8.encode(data)).catchError(_handleStreamError));
    };
  }

  void _handleStreamError(Object error, [StackTrace? stackTrace]) {
    if (_disposed || _status != TerminalConnectionStatus.connected) {
      return;
    }
    terminal.write('\r\n$error\r\n');
    _status = TerminalConnectionStatus.failed;
    notifyListeners();
  }

  void _fail(String message) {
    if (_disposed) {
      return;
    }
    _status = TerminalConnectionStatus.failed;
    terminal.write('\r\n$message\r\n');
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _connectionGeneration += 1;
    unawaited(_stdoutSubscription?.cancel());
    unawaited(_stderrSubscription?.cancel());
    unawaited(_doneSubscription?.cancel());
    final session = _session;
    _session = null;
    if (session != null) {
      unawaited(session.close());
    }
    keyboard.dispose();
    super.dispose();
  }
}
