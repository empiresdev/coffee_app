import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/repositories/remote_coffee_repository/remote_coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;

void main() {
  group('fetchRandomImage', () {
    test('returns a valid RemoteCoffeeImage', () async {
      final client = http.MockClient((request) async {
        const body = '''
{
  "file": "https://coffee.alexflipnote.dev/2GiUIZKXR1s_coffee.jpg"
}
''';
        return http.Response(body, 200);
      });
      final sut = HttpRemoteCoffeeRepository(client);

      final result = await sut.fetchRandomImage();
      expect(
        result.imageUrl,
        'https://coffee.alexflipnote.dev/2GiUIZKXR1s_coffee.jpg',
      );
    });

    test(
        'throws a RemoteServerException when response code '
        'is different from 200', () async {
      final client = http.MockClient((request) async {
        return http.Response('', 500);
      });

      final sut = HttpRemoteCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(RemoteServerException()));
    });

    test(
        'throws a InvalidRemoteCoffeeImageException when '
        'response data is invalid', () async {
      final client = http.MockClient((request) async {
        return http.Response('invalid data', 200);
      });

      final sut = HttpRemoteCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(InvalidRemoteCoffeeImageException()));
    });
  });
}
