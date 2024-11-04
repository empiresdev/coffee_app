import 'dart:io';

import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/http_file_coffee_repository/http_file_coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/helpers.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  MockPathProviderPlatform({
    required this.applicationDocuments,
    required this.temporary,
  });

  final Directory temporary;
  final Directory applicationDocuments;

  @override
  Future<String> getApplicationDocumentsPath() async {
    return applicationDocuments.path;
  }

  @override
  Future<String> getTemporaryPath() async {
    return temporary.path;
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = MockPathProviderPlatform(
      temporary: tempDir,
      applicationDocuments: tempDir,
    );
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('fetchRandomImage', () {
    test('returns a valid CoffeeImage', () async {
      final client = generateHttpMockClient(
        statusCode: 200,
        body: '''
{
  "file": "https://coffee.alexflipnote.dev/2GiUIZKXR1s_coffee.jpg"
}
''',
      );
      final sut = HttpFileCoffeeRepository(client);

      final result = await sut.fetchRandomImage();
      expect(result, isA<LocalCoffeeImage>());
      expect(result.imageUrl.endsWith('2GiUIZKXR1s_coffee.jpg'), isTrue);
    });

    test(
        'throws a RemoteServerException when response code '
        'is different from 200', () async {
      final client = generateHttpMockClient(statusCode: 500, body: '');

      final sut = HttpFileCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(RemoteServerException()));
    });

    test(
        'throws a InvalidRemoteCoffeeImageException when '
        'response data is invalid', () async {
      final client =
          generateHttpMockClient(statusCode: 200, body: 'invalid data');

      final sut = HttpFileCoffeeRepository(client);

      final result = sut.fetchRandomImage();
      expect(result, throwsA(InvalidRemoteCoffeeImageException()));
    });
  });

  group('addImage', () {
    test('returns a valid list of favorites when it gets a remote image',
        () async {
      const remoteCoffeeImage = RemoteCoffeeImage('https://test.com/test.png');
      final mockImageBytes = List<int>.generate(1024, (index) => index % 256);
      final mockClient = generateHttpMockClient(
        statusCode: 200,
        bytes: mockImageBytes,
        body: '',
      );

      final sut = HttpFileCoffeeRepository(mockClient);
      final favorites = await sut.addImage(remoteCoffeeImage);

      expect(favorites, isNotNull);
      expect(favorites.length, 1);
      expect(favorites[0].imageUrl.endsWith('test.png'), true);

      await File(favorites[0].imageUrl).delete();
    });

    test('returns a valid list of favorites when it gets a local image',
        () async {
      final sut = HttpFileCoffeeRepository();
      const localCoffeeImage = LocalCoffeeImage('test.png');

      expect(
        () => sut.addImage(localCoffeeImage),
        throwsA(
          LocalSavingFileException(),
        ),
      );
    });

    test('throws a RemoteServerException when the image download fails',
        () async {
      const remoteCoffeeImage = RemoteCoffeeImage('https://test.com/test.png');
      final mockImageBytes = List<int>.generate(1024, (index) => index % 256);
      final mockClient = generateHttpMockClient(
        statusCode: 500,
        bytes: mockImageBytes,
        body: '',
      );

      final sut = HttpFileCoffeeRepository(mockClient);
      final favorites = sut.addImage(remoteCoffeeImage);

      expect(favorites, throwsA(RemoteServerException()));
    });

    test('throws a InvalidRemoteCoffeeImageException when the url is invalid',
        () async {
      const remoteCoffeeImage = RemoteCoffeeImage('::Not valid URI::');
      final mockImageBytes = List<int>.generate(1024, (index) => index % 256);
      final mockClient = generateHttpMockClient(
        statusCode: 200,
        bytes: mockImageBytes,
        body: '',
      );

      final sut = HttpFileCoffeeRepository(mockClient);
      final favorites = sut.addImage(remoteCoffeeImage);

      expect(favorites, throwsA(InvalidRemoteCoffeeImageException()));
    });
    test(
        'throws a InvalidRemoteCoffeeImageException when '
        'url does not have any file extension', () async {
      const remoteCoffeeImage = RemoteCoffeeImage('https://test.com/test');
      final mockImageBytes = List<int>.generate(1024, (index) => index % 256);
      final mockClient = generateHttpMockClient(
        statusCode: 200,
        bytes: mockImageBytes,
        body: '',
      );

      final sut = HttpFileCoffeeRepository(mockClient);
      final favorites = sut.addImage(remoteCoffeeImage);

      expect(favorites, throwsA(InvalidRemoteCoffeeImageException()));
    });

    test(
        'throws a InvalidRemoteCoffeeImageException when '
        'file extension is not an image', () async {
      const remoteCoffeeImage = RemoteCoffeeImage('https://test.com/test.pdf');
      final mockImageBytes = List<int>.generate(1024, (index) => index % 256);
      final mockClient = generateHttpMockClient(
        statusCode: 200,
        bytes: mockImageBytes,
        body: '',
      );

      final sut = HttpFileCoffeeRepository(mockClient);
      final favorites = sut.addImage(remoteCoffeeImage);

      expect(favorites, throwsA(InvalidRemoteCoffeeImageException()));
    });
  });

  group('fetchAllFavorites', () {
    test('returns all saved images', () async {
      final sut = HttpFileCoffeeRepository();
      final imagesDir = await sut.getImagesDirectory();
      final filePaths = [
        path.join(imagesDir.path, 'image_1.png'),
        path.join(imagesDir.path, 'image_2.jpg'),
        path.join(imagesDir.path, 'image_3.png'),
      ];
      for (final filePath in filePaths) {
        final file = File(filePath);
        await file.writeAsBytes(
          List<int>.generate(1024, (index) => index % 256),
        );
      }

      final favorites = await sut.fetchAllFavorites();

      expect(favorites.length, filePaths.length);
      for (final filePath in filePaths) {
        expect(favorites.any((file) => file.imageUrl == filePath), isTrue);
      }

      for (final filePath in filePaths) {
        await File(filePath).delete();
      }
    });
  });
}
