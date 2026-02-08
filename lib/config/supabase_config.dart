/// Supabase configuration for ResearchTech app.

class SupabaseConfig {
  /// Your Supabase project URL
  static const String supabaseUrl = 'https://zqrqudggioohnqrurvwe.supabase.co';

  /// Your Supabase anonymous/public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpxcnF1ZGdnaW9vaG5xcnVydndlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1NDEwMjgsImV4cCI6MjA4NjExNzAyOH0.Olgv0-9d1F-BZj8tMuS7qPWQnVrO3u2WW25yf4IG7e0';

  /// Check if credentials are configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_');
}
