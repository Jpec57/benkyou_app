import 'dart:math';

int generateRandomIndex(List list) {
  Random random = new Random();
  return random.nextInt(list.length);
}