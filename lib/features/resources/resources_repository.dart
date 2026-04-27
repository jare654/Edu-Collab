import '../../core/models/resource.dart';

abstract class ResourcesRepository {
  Future<List<ResourceItem>> fetchResources();
}
