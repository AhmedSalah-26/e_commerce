import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminUsersMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getUsersImpl({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = client.from('profiles').select('*');

      if (role == 'customer') {
        query = query.eq('role', 'customer');
      } else if (role == 'merchant') {
        query = query.eq('role', 'merchant');
      } else if (role == 'admin') {
        query = query.eq('role', 'admin');
      }

      if (search != null && search.isNotEmpty) {
        // Check if search is UUID format
        final isUuidSearch = RegExp(
          r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}$',
        ).hasMatch(search);

        if (isUuidSearch) {
          query = query.or(
              'name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%,id.eq.$search');
        } else {
          query = query.or(
              'name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%');
        }
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get users: $e');
    }
  }

  Future<void> toggleUserStatusImpl(String userId, bool isActive) async {
    try {
      await client
          .from('profiles')
          .update({'is_active': isActive}).eq('id', userId);
    } catch (e) {
      throw ServerException('Failed to toggle user status: $e');
    }
  }

  Future<bool> isAdminImpl(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> banUserImpl(
      String userId, String duration) async {
    try {
      final response = await client.rpc('ban_user', params: {
        'target_user_id': userId,
        'ban_duration': duration,
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException('Failed to ban user: $e');
    }
  }

  Future<Map<String, dynamic>> unbanUserImpl(String userId) async {
    try {
      final response = await client.rpc('ban_user', params: {
        'target_user_id': userId,
        'ban_duration': 'none',
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException('Failed to unban user: $e');
    }
  }
}
