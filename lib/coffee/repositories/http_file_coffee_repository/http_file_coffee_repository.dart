import 'dart:convert';
import 'dart:io';

import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/repositories/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:coffee_app/core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final class HttpFileCoffeeRepository implements CoffeeRepository {
  HttpFileCoffeeRepository([http.Client? client]) {
    _client = client ?? http.Client();
  }

  late http.Client _client;
  final String apiUrl = 'https://coffee.alexflipnote.dev/random.json';

  static const _filenameIdentifier = 'image_';
  List<LocalCoffeeImage> _list = [];

  @override
  Future<List<LocalCoffeeImage>> addImage(CoffeeImage remoteImage) async {
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
    final imagesDir = await getImagesDirectory();
    final fileName = '$_filenameIdentifier'
        '${DateTime.now().millisecondsSinceEpoch}'
        '_'
        '${fileMetadata['name']}';

    final file = File(path.join(imagesDir.path, fileName));
    await file.writeAsBytes(response.bodyBytes);
    return _list..add(LocalCoffeeImage(file.path));
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

  @override
  Future<CoffeeImage> fetchRandomImage() async {
    final uri = Uri.parse(apiUrl);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw RemoteServerException();
    }
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiCoffeeImageModel.fromJson(json).toEntity();
    } catch (exc) {
      throw InvalidRemoteCoffeeImageException();
    }
  }

  Future<Directory> getImagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'favorites'));
    if (!imagesDir.existsSync()) {
      return imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Map<String, String> _extractFileNameAndExtension(String url) {
    return {'name': path.basename(url), 'extension': path.extension(url)};
  }
}
