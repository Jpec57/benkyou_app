import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  // TODO https://flutter.dev/docs/cookbook/testing/unit/mocking
//  group('getPublicDecks', () {
//    test('returns a list of public Decks if the http call completes successfully', () async {
//      final client = MockClient();
//
//      // Use Mockito to return a successful response when it calls the
//      // provided http.Client.
//      when(client.get('https://jpec.be/deck'))
//          .thenAnswer((_) async => http.Response('{"title": "Test"}', 200));
//
//      expect(await getPublicDecks(), isA<List<Deck>>());
//    });

//    test('throws an exception if the http call completes with an error', () {
//      final client = MockClient();
//
//      // Use Mockito to return an unsuccessful response when it calls the
//      // provided http.Client.
//      when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
//          .thenAnswer((_) async => http.Response('Not Found', 404));
//
//      expect(getPublicDecks(), throwsException);
//    });
//  });
}