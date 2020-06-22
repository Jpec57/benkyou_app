//TODO https://flutter.dev/docs/cookbook/testing/integration/introduction
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  // Close the connection to the driver after the tests have completed.
  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  Future<void> delay([int milliseconds = 250]) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  test('check flutter driver health', () async {
    final health = await driver.checkHealth();
    await delay(5000);

    expect(health.status, HealthStatus.ok);
  });

}