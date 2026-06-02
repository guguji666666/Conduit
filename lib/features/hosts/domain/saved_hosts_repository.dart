import 'package:conduit/features/hosts/domain/saved_host.dart';

abstract interface class SavedHostsRepository {
  Future<List<SavedHost>> loadHosts();

  Future<void> saveHosts(List<SavedHost> hosts);
}
