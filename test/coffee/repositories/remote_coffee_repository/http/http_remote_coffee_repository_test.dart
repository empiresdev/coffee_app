import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/repositories/remote_coffee_repository/remote_coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('fetchRandomImage', () {
    test('returns a valid RemoteCoffeeImage', () async {
      final client = generateHttpMockClient(
        statusCode: 200,
        body: '''
{
  "file": "https://coffee.alexflipnote.dev/2GiUIZKXR1s_coffee.jpg"
}
''',
      );
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
      final client = generateHttpMockClient(statusCode: 500, body: '');

      final sut = HttpRemoteCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(RemoteServerException()));
    });

    test(
        'throws a InvalidRemoteCoffeeImageException when '
        'response data is invalid', () async {
      final client =
          generateHttpMockClient(statusCode: 200, body: 'invalid data');

      final sut = HttpRemoteCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(InvalidRemoteCoffeeImageException()));
    });
  });
}
