import '../../core/models/resource.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/storage/local_cache.dart';
import '../../core/data/json_asset_loader.dart';
import 'resources_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';

class ResourcesRepositoryImpl implements ResourcesRepository {
  final ConnectivityService _connectivity;
  final JsonAssetLoader _loader;
  final ApiClient _client;
  final LocalCache<List<ResourceItem>> _cache = LocalCache<List<ResourceItem>>();
  static const _key = 'resources';

  ResourcesRepositoryImpl(this._connectivity, this._loader, this._client);

  @override
  Future<List<ResourceItem>> fetchResources() async {
    final online = await _connectivity.check();
    if (online) {
      try {
        final response = await _client.dio.get(ApiEndpoints.resources);
        if (response.data is List) {
          final items = (response.data as List)
              .map((e) => ResourceItem.fromJson(e as Map<String, dynamic>))
              .toList();
          _cache.set(_key, items);
          return items;
        }
        throw ApiError('Unexpected response format');
      } catch (e) {
        final _ = mapDioError(e);
        final raw = await _loader.loadList('assets/data/resources.json');
        final items = raw.map(ResourceItem.fromJson).toList();
        _cache.set(_key, items);
        return items;
      }
    }
    return _cache.get(_key) ?? const [];
  }
}
