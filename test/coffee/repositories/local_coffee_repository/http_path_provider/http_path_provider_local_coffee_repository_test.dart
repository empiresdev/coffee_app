import 'dart:io';

import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/local_coffee_repository/http_path_provider/http_path_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../helpers/http_mocks.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  MockPathProviderPlatform(this.tempDir);

  final Directory tempDir;

  @override
  Future<String> getApplicationDocumentsPath() async {
    return tempDir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
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

      final sut = HttpPathProviderLocalCoffeeRepository(mockClient);
      final favorites = await sut.addImage(remoteCoffeeImage);

      expect(favorites, isNotNull);
      expect(favorites.length, 1);
      expect(favorites[0].imageUrl.endsWith('test.png'), true);

      await File(favorites[0].imageUrl).delete();
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

      final sut = HttpPathProviderLocalCoffeeRepository(mockClient);
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

      final sut = HttpPathProviderLocalCoffeeRepository(mockClient);
      final favorites = sut.addImage(remoteCoffeeImage);

      expect(favorites, throwsA(InvalidRemoteCoffeeImageException()));
    });
  });

  group('fetchAllFavorites', () {
    test('returns all saved images', () async {
      final sut = HttpPathProviderLocalCoffeeRepository();
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
