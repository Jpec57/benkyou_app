import 'package:shared_preferences/shared_preferences.dart';

Future<void> setLastUsedDeckIdFromLocalStorage(int value) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setInt('lastUsedDeckId', value);
}

Future<int> getLastUsedDeckIdFromLocalStorage() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.containsKey('lastUsedDeckId')
      ? sharedPreferences.getInt('lastUsedDeckId')
      : null;
}
