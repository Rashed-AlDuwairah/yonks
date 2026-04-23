/// API configuration for the Reels backend.
///
/// During development the backend runs locally via `python main.py`.
/// In production, replace [baseUrl] with your VPS address.
///
/// Note: For iOS **simulator** testing, `localhost` works.
/// For a **real device**, use your machine's local IP (e.g. 192.168.x.x).
abstract final class ApiConstants {
  static const baseUrl = 'http://192.168.1.139:8888';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 30);
  static const downloadTimeout = Duration(minutes: 30);
}
