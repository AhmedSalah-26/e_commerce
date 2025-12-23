import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseService {
  SupabaseClient get client;
  GoTrueClient get auth;
  Future<void> initialize();
}

class SupabaseServiceImpl implements SupabaseService {
  static const String supabaseUrl = 'https://jkgnpxpygmychdylaoct.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprZ25weHB5Z215Y2hkeWxhb2N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYyNDY5MzcsImV4cCI6MjA4MTgyMjkzN30.mH2ZfwSioYB8V6TAPrbY3nSIYnYUJvWSXxQ_Zfkt0fo';

  static SupabaseServiceImpl? _instance;
  late final SupabaseClient _client;

  SupabaseServiceImpl._();

  static SupabaseServiceImpl get instance {
    _instance ??= SupabaseServiceImpl._();
    return _instance!;
  }

  @override
  SupabaseClient get client => _client;

  @override
  GoTrueClient get auth => _client.auth;

  @override
  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
    _client = Supabase.instance.client;
  }
}
