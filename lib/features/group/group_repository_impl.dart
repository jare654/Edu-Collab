import '../../core/models/group.dart';
import '../../core/models/group_member.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/storage/local_cache.dart';
import '../../core/data/json_asset_loader.dart';
import 'group_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import '../../core/network/api_config.dart';
import 'package:dio/dio.dart';

class GroupRepositoryImpl implements GroupRepository {
  final ConnectivityService _connectivity;
  final JsonAssetLoader _loader;
  final ApiClient _client;
  final LocalCache<List<Group>> _cache = LocalCache<List<Group>>();
  static const _key = 'groups';

  GroupRepositoryImpl(this._connectivity, this._loader, this._client);

  @override
  Future<List<Group>> fetchGroups() async {
    final online = await _connectivity.check();
    if (online) {
      try {
        final response = await _client.dio.get(ApiEndpoints.groups);
        if (response.data is List) {
          final items =
              (response.data as List).map((e) => Group.fromJson(e as Map<String, dynamic>)).toList();
          _cache.set(_key, items);
          return items;
        }
        throw ApiError('Unexpected response format');
      } catch (e) {
        final _ = mapDioError(e);
        final raw = await _loader.loadList('assets/data/groups.json');
        final items = raw.map(Group.fromJson).toList();
        _cache.set(_key, items);
        return items;
      }
    }
    return _cache.get(_key) ?? const [];
  }

  @override
  Future<List<String>> fetchGroupMemberEmails(String groupId) async {
    final members = await fetchGroupMembers(groupId);
    return members.map((m) => m.email).where((e) => e.isNotEmpty).toList();
  }

  @override
  Future<List<GroupMember>> fetchGroupMembers(String groupId) async {
    final online = await _connectivity.check();
    if (!online) return const [];
    try {
      final response = await _client.dio.get(
        '${ApiEndpoints.groupMembers}?group_id=eq.$groupId&select=id,group_id,email',
      );
      if (response.data is List) {
        final rows = response.data as List;
        return rows
            .whereType<Map>()
            .map((row) => GroupMember.fromJson(Map<String, dynamic>.from(row)))
            .toList();
      }
    } catch (e) {
      final _ = mapDioError(e);
    }
    return const [];
  }

  @override
  Future<GroupMemberAddResult> addGroupMember(String groupId, String email, {bool sendEmail = true}) async {
    final response = await _client.dio.post(
      ApiEndpoints.groupMembers,
      data: {
        'group_id': groupId,
        'email': email,
      },
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    Map<String, dynamic> payload;
    if (response.data is List && (response.data as List).isNotEmpty) {
      payload = Map<String, dynamic>.from((response.data as List).first as Map);
    } else if (response.data is Map) {
      payload = Map<String, dynamic>.from(response.data as Map);
    } else {
      payload = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'group_id': groupId, 'email': email};
    }
    bool emailSent = false;
    String? message;
    if (sendEmail) {
      try {
        await _sendGroupInviteEmail(groupId: groupId, email: email);
        emailSent = true;
      } catch (e) {
        emailSent = false;
        message = e.toString();
      }
    }
    final member = GroupMember.fromJson(payload);
    return GroupMemberAddResult(member: member, emailSent: emailSent, message: message);
  }

  @override
  Future<void> removeGroupMember(String memberId) async {
    await _client.dio.delete('${ApiEndpoints.groupMembers}?id=eq.$memberId');
  }

  Future<void> _sendGroupInviteEmail({
    required String groupId,
    required String email,
  }) async {
    try {
      await _client.dio.post(
        '${ApiConfig.functionsBaseUrl}/send-group-invite',
        data: {
          'group_id': groupId,
          'email': email,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String courseCode,
    String? description,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.groups,
      data: {
        'name': name,
        'course_code': courseCode,
        if (description != null && description.isNotEmpty) 'description': description,
      },
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    Map<String, dynamic> payload;
    if (response.data is List && (response.data as List).isNotEmpty) {
      payload = Map<String, dynamic>.from((response.data as List).first as Map);
    } else if (response.data is Map) {
      payload = Map<String, dynamic>.from(response.data as Map);
    } else {
      payload = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'course_code': courseCode,
        'members': 0,
      };
    }
    final group = Group.fromJson(payload);
    final current = _cache.get(_key) ?? const [];
    _cache.set(_key, [group, ...current]);
    return group;
  }
}
