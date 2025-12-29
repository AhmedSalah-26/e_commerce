import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Abstract interface for auth remote data source
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
  });
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of auth remote data source using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> signIn(String email, String password) async {
    logger.i('🔐 Attempting sign in for: $email');
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        logger.w('⚠️ Sign in failed: No user returned');
        throw AuthException.invalidCredentials();
      }

      logger.i('✅ Sign in successful for user: ${response.user!.id}');

      // Fetch user profile
      final profile = await _fetchUserProfile(response.user!.id);
      return profile;
    } on AuthApiException catch (e) {
      logger.e('❌ Auth API Exception during sign in', error: e);
      throw AuthException.fromSupabaseAuthError(e);
    } catch (e, stackTrace) {
      logger.e('❌ Exception during sign in', error: e, stackTrace: stackTrace);
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
  }) async {
    logger.i(
        '📝 Attempting sign up for: $email, role: ${role.name}, name: $name');
    try {
      // Step 1: Create auth user
      logger.d('Step 1: Creating auth user...');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role.name,
          'name': name,
          'phone': phone,
          'avatar_url': avatarUrl,
          'governorate_id': governorateId,
        },
      );

      if (response.user == null) {
        logger.e('❌ Sign up failed: No user returned from Supabase');
        throw const AuthException('فشل في إنشاء الحساب');
      }

      final userId = response.user!.id;
      logger.i('✅ Auth user created: $userId');

      // Step 2: Check if we have a session (user is auto-confirmed)
      final hasSession = response.session != null;
      logger.d('Has session after signup: $hasSession');

      // Step 3: Wait a bit for any triggers
      logger.d('Step 3: Waiting for database trigger...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // Step 4: Return user model directly from signup data
      // Don't try to fetch profile if RLS blocks it
      logger.i('✅ Sign up complete, returning user data');

      return UserModel(
        id: userId,
        email: email,
        role: role,
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
        governorateId: governorateId,
        createdAt: DateTime.now(),
      );
    } on AuthApiException catch (e, stackTrace) {
      logger.e('❌ Auth API Exception during sign up',
          error: e, stackTrace: stackTrace);
      throw AuthException.fromSupabaseAuthError(e);
    } catch (e, stackTrace) {
      logger.e('❌ Exception during sign up', error: e, stackTrace: stackTrace);
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    logger.i('🚪 Signing out...');
    try {
      await _client.auth.signOut();
      logger.i('✅ Sign out successful');
    } catch (e, stackTrace) {
      logger.e('❌ Exception during sign out', error: e, stackTrace: stackTrace);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    logger.d('Getting current user...');
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        logger.d('No current user found');
        return null;
      }

      logger.d('Current user found: ${user.id}');
      return await _fetchUserProfile(user.id);
    } catch (e, stackTrace) {
      logger.e('❌ Exception getting current user',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      logger.d('Auth state changed: ${event.event}');
      if (event.session?.user == null) {
        logger.d('No session user');
        return null;
      }
      try {
        return await _fetchUserProfile(event.session!.user.id);
      } catch (e, stackTrace) {
        logger.e('❌ Exception in auth state change',
            error: e, stackTrace: stackTrace);
        return null;
      }
    });
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
  }) async {
    logger.i('📝 Updating profile for user: $userId');
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (governorateId != null) updateData['governorate_id'] = governorateId;

      if (updateData.isEmpty) {
        logger.w('⚠️ No data to update');
        return await _fetchUserProfile(userId);
      }

      await _client.from('profiles').update(updateData).eq('id', userId);

      logger.i('✅ Profile updated successfully');
      return await _fetchUserProfile(userId);
    } on PostgrestException catch (e, stackTrace) {
      logger.e('❌ PostgrestException updating profile',
          error: e, stackTrace: stackTrace);
      throw ServerException('فشل في تحديث البيانات: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('❌ Exception updating profile',
          error: e, stackTrace: stackTrace);
      throw ServerException('فشل في تحديث البيانات: ${e.toString()}');
    }
  }

  /// Helper method to fetch user profile from profiles table
  /// If profile doesn't exist, create it automatically
  Future<UserModel> _fetchUserProfile(String userId) async {
    logger.d('Fetching profile for user: $userId');
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        logger.d('✅ Profile found: $response');
        return UserModel.fromJson(response);
      }

      logger.w('⚠️ Profile not found, creating from user metadata...');

      // Profile doesn't exist - get data from current user metadata
      final user = _client.auth.currentUser;
      if (user == null) {
        logger.e('❌ Cannot create profile: No current user');
        throw const AuthException('المستخدم غير موجود');
      }

      final roleFromMeta = user.userMetadata?['role'] as String? ?? 'customer';
      final nameFromMeta = user.userMetadata?['name'] as String?;
      final phoneFromMeta = user.userMetadata?['phone'] as String?;

      // Try to insert profile
      try {
        final newProfile = {
          'id': userId,
          'email': user.email ?? '',
          'role': roleFromMeta,
          'name': nameFromMeta,
          'phone': phoneFromMeta,
        };

        logger.d('Creating new profile: $newProfile');
        await _client.from('profiles').upsert(newProfile);
        logger.i('✅ New profile created');
      } catch (insertError) {
        logger.w('⚠️ Could not insert profile (RLS?), returning from metadata');
      }

      return UserModel(
        id: userId,
        email: user.email ?? '',
        role: UserRole.fromString(roleFromMeta),
        name: nameFromMeta,
        phone: phoneFromMeta,
        createdAt: DateTime.now(),
      );
    } on PostgrestException catch (e, stackTrace) {
      logger.e('❌ PostgrestException fetching profile',
          error: e, stackTrace: stackTrace);

      // If RLS blocks us, try to return from current user metadata
      final user = _client.auth.currentUser;
      if (user != null) {
        logger.w('⚠️ Returning user from metadata due to RLS');
        final roleFromMeta =
            user.userMetadata?['role'] as String? ?? 'customer';
        return UserModel(
          id: userId,
          email: user.email ?? '',
          role: UserRole.fromString(roleFromMeta),
          name: user.userMetadata?['name'] as String?,
          phone: user.userMetadata?['phone'] as String?,
          createdAt: DateTime.now(),
        );
      }

      throw ServerException('فشل في جلب بيانات المستخدم: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('❌ Exception fetching profile',
          error: e, stackTrace: stackTrace);
      if (e is AuthException) rethrow;
      throw ServerException('فشل في جلب بيانات المستخدم: ${e.toString()}');
    }
  }
}
