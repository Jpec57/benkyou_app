import 'dart:math';

int generateRandomIndex(List list) {
  int length = list.length;
  if (length == 0) {
    return -1;
  }
  if (length == 1) {
    return 0;
  }
  Random random = new Random();
  return random.nextInt(length);
}
