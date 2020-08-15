import 'package:get/get.dart';

List<dynamic> decodeJsonFromArray(array, Function function) {
  if (array == null) {
    return [];
  }
  List entities = [];
  for (var card in array) {
    entities.add(function(card));
  }
  return entities;
}

dynamic getFromJson(Map<String, dynamic> json, String key,
    {defaultValue = ''}) {
  if (json.containsKey(key)) {
    return json[key];
  }
  return defaultValue;
}

void showNotImplementedSnack() {
  Get.snackbar("Not implemented yet.",
      "This feature is not yet implemented. Please try later.",
      snackPosition: SnackPosition.TOP);
}
