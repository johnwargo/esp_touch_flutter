import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static final Config _config = Config._internal();

  factory Config() => _config;

  final saveWifiPasswordKey = 'saveWiFiPassword';
  final wifiPasswordKey = 'wifiPassword';

  bool _saveWifiPassword;
  String _wifiPassword;

  SharedPreferences prefs;

  Config._internal() {
    print('Config constructor');
    loadData();
  }

  void loadData() async {
    // Get the configuration data from persistent storage
    print('Config: loadData()');
    prefs = await SharedPreferences.getInstance();
    _saveWifiPassword = prefs.getBool(saveWifiPasswordKey) ?? false;
    _wifiPassword = prefs.getString(wifiPasswordKey) ?? '';
  }

  void printConfig() {
    String stars;
    print('Config: printConfig()');
    if (_wifiPassword != null) {
      // Make a string with a star for every character in the password
      stars = _wifiPassword.length > 0 ? '*' * _wifiPassword.length : '';
      print('Wi-Fi Password: $stars');
    } else {
      print('Wi-Fi Password: $_wifiPassword');
    }
    print('Save Wi-Fi Password: $_saveWifiPassword');
  }

  bool get saveWiFiPassword {
    print('Config: Getting Save Wi-Fi Password');
    return _saveWifiPassword;
  }

  set saveWiFiPassword(bool value) {
    print('Config: saveWiFiPassword($value)');
    _saveWifiPassword = value;
    _saveBool(saveWifiPasswordKey, value);
  }

  String get wifiPassword {
    print('Config: Getting Wi-Fi Password');
    return _wifiPassword;
  }

  set wifiPassword(String pswd) {
    String printVal;
    printVal = pswd.length > 0 ? '*' * pswd.length : '';
    print('Config: wifiPassword($printVal)');
    _wifiPassword = pswd;
    _saveString(wifiPasswordKey, pswd, printValue: printVal);
  }

  _saveString(String key, String value, {String printValue = ''}) {
    // We showing asterisks or the actual value?
    String printVal = printValue.length > 0 ? printValue : value;
    print('Config: _saveString("$key", "$printVal")');
    prefs.setString(key, value);
  }

  _saveBool(String key, bool value) {
    print('Config: _saveBool("$key", $value)');
    prefs.setBool(key, value);
  }
}
