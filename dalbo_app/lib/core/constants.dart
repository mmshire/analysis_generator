// App-wide constants for Dalbo

class AppConstants {
  // Change this to your computer's IP address when testing on a real phone.
  // Keep 'localhost' when testing on an Android emulator.
  // On a physical Android device use your WiFi IP e.g. 'http://192.168.1.100:3000'
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // 1 USD ≈ 570 Somaliland Shilling (update as needed)
  static const double usdToSls = 570.0;

  static String toSls(double usd) {
    final sls = (usd * usdToSls).round();
    return 'SLS ${_formatNumber(sls)}';
  }

  static String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
  }
}
