import 'package:flutter_test/flutter_test.dart';
import 'package:academic_collab_app/core/models/resource.dart';
import 'package:academic_collab_app/features/resources/resources_repository.dart';
import 'package:academic_collab_app/features/resources/resources_notifier.dart';

class _FakeResourcesRepo implements ResourcesRepository {
  @override
  Future<List<ResourceItem>> fetchResources() async {
    return const [
      ResourceItem(
        id: 'r1',
        title: 'Resource',
        course: 'ARCH-201',
        type: 'PDF',
        availableOffline: true,
      ),
    ];
  }
}

void main() {
  test('ResourcesNotifier loads resources', () async {
    final notifier = ResourcesNotifier(_FakeResourcesRepo());
    await notifier.load();
    expect(notifier.items.length, 1);
    expect(notifier.loading, false);
  });
}
