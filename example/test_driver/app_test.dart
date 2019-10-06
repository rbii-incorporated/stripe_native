import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {

    FlutterDriver driver;

    setUpAll(() async => driver = await FlutterDriver.connect());

    tearDownAll(() async => driver?.close());

   group('Welcome:', () {

      test('Driver', () async {
         // This is an example that uses a widget key to figure out if the menu has opened.
         //final navLabel = find.byValueKey('leadingNav');
         //final navText = await driver.getText(navLabel);
         //expect(navText, 'Menu');
      });


   });

}