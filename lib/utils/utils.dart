List<dynamic> decodeJsonFromArray(array, Function function){
  if (array == null){
    return [];
  }
  List entities = [];
  for (var card in array){
    entities.add(function(card));
  }
  return entities;
}

dynamic getFromJson(Map<String, dynamic> json, String key, {defaultValue = ''}){
  if (json.containsKey(key)){
    return json[key];
  }
  return defaultValue;
}