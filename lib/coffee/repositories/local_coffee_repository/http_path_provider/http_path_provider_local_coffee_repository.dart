import 'dart:io';

import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const List<String> imageFileExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.tiff',
  '.webp',
  '.svg',
  '.heif',
  '.ico',
  '.raw',
];

class HttpPathProviderLocalCoffeeRepository implements LocalCoffeeRepository {
  HttpPathProviderLocalCoffeeRepository([http.Client? client]) {
    _client = client ?? http.Client();
  }

  late http.Client _client;

  static const _filenameIdentifier = 'image_';
  List<LocalCoffeeImage> _list = [];

  @override
  Future<List<LocalCoffeeImage>> addImage(RemoteCoffeeImage remoteImage) async {
    final imageUrl = remoteImage.imageUrl;
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      throw InvalidRemoteCoffeeImageException();
    }
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw RemoteServerException();
    }
    final fileMetadata = _extractFileNameAndExtension(imageUrl);
    if (!imageFileExtensions.contains(fileMetadata['extension'])) {
      throw InvalidRemoteCoffeeImageException();
    }
    try {
      final imagesDir = await getImagesDirectory();
      final fileName = '$_filenameIdentifier'
          '${DateTime.now().millisecondsSinceEpoch}'
          '_'
          '${fileMetadata['name']}';

      final file = File(path.join(imagesDir.path, fileName));
      await file.writeAsBytes(response.bodyBytes);
      return _list..add(LocalCoffeeImage(file.path));
    } catch (_) {
      throw LocalSavingException();
    }
  }

  @override
  Future<List<LocalCoffeeImage>> fetchAllFavorites() async {
    final imagesDir = await getImagesDirectory();
    final files = imagesDir.listSync().whereType<File>().where(
          (file) => imageFileExtensions.contains(path.extension(file.path)),
        );
    final localCoffeeImages =
        files.map((file) => LocalCoffeeImage(file.path)).toList();
    return _list = localCoffeeImages;
  }

  Future<Directory> getImagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'favorites'));
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Map<String, String> _extractFileNameAndExtension(String url) {
    return {'name': path.basename(url), 'extension': path.extension(url)};
  }
}
