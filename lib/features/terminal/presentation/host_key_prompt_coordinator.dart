import 'dart:async';
import 'dart:collection';

import 'package:conduit/features/terminal/domain/host_key_prompt.dart';
import 'package:flutter/foundation.dart';

class HostKeyPromptCoordinator extends ChangeNotifier implements HostKeyPrompt {
  final Queue<_PendingPrompt> _queue = Queue<_PendingPrompt>();

  HostKeyPromptRequest? get current =>
      _queue.isEmpty ? null : _queue.first.request;

  @override
  Future<HostKeyDecision> request(HostKeyPromptRequest request) {
    final completer = Completer<HostKeyDecision>();
    _queue.add(_PendingPrompt(request, completer));
    notifyListeners();
    return completer.future;
  }

  void resolve(HostKeyPromptRequest request, HostKeyDecision decision) {
    if (_queue.isEmpty || _queue.first.request != request) {
      return;
    }
    final pending = _queue.removeFirst();
    pending.completer.complete(decision);
    notifyListeners();
  }

  void rejectAll() {
    if (_queue.isEmpty) {
      return;
    }
    while (_queue.isNotEmpty) {
      _queue.removeFirst().completer.complete(HostKeyDecision.reject);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    rejectAll();
    super.dispose();
  }
}

class _PendingPrompt {
  const _PendingPrompt(this.request, this.completer);

  final HostKeyPromptRequest request;
  final Completer<HostKeyDecision> completer;
}
