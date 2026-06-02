import 'package:conduit/core/app_failure.dart';
import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/hosts/domain/saved_hosts_repository.dart';
import 'package:flutter/foundation.dart';

class HostsController extends ChangeNotifier {
  HostsController(this._repository);

  final SavedHostsRepository _repository;

  List<SavedHost> _hosts = const [];
  List<SavedHost>? _recentHostsCache;
  bool _isLoading = true;
  String? _errorMessage;

  List<SavedHost> get hosts => _hosts;
  List<SavedHost> get recentHosts =>
      _recentHostsCache ??= _computeRecentHosts();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _setHosts(await _repository.loadHosts());
    } on AppFailure catch (failure) {
      _errorMessage = failure.toString();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upsert(SavedHost host) async {
    final index = _hosts.indexWhere((currentHost) => currentHost.id == host.id);
    final updatedHosts = [..._hosts];

    if (index == -1) {
      updatedHosts.add(host);
    } else {
      updatedHosts[index] = host;
    }

    await _save(updatedHosts);
  }

  Future<void> remove(SavedHost host) async {
    await _save(
      _hosts.where((currentHost) => currentHost.id != host.id).toList(),
    );
  }

  Future<void> markConnected(SavedHost host) async {
    final current = _hosts.firstWhere(
      (currentHost) => currentHost.id == host.id,
      orElse: () => host,
    );
    await upsert(current.copyWith(lastConnectedAt: DateTime.now()));
  }

  Future<void> _save(List<SavedHost> hosts) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveHosts(hosts);
      _setHosts(hosts);
    } on AppFailure catch (failure) {
      _errorMessage = failure.toString();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  void _setHosts(List<SavedHost> hosts) {
    _hosts = hosts;
    _recentHostsCache = null;
  }

  List<SavedHost> _computeRecentHosts() {
    final sorted = [..._hosts];
    sorted.sort((a, b) {
      final aDate = a.lastConnectedAt;
      final bDate = b.lastConnectedAt;
      if (aDate == null && bDate == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aDate == null) {
        return 1;
      }
      if (bDate == null) {
        return -1;
      }
      return bDate.compareTo(aDate);
    });
    return List.unmodifiable(sorted);
  }
}
