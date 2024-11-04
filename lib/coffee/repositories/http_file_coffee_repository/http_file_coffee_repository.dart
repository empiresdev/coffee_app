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
  Future<List<LocalCoffeeImage>> addImage(CoffeeImage coffeeImage) async {
    late File file;
    if (coffeeImage is RemoteCoffeeImage) {
      final imageUrl = coffeeImage.imageUrl;
      file = await _downloadAndSaveFile(imageUrl);
    } else {
      final tempFile = File(coffeeImage.imageUrl);
      final newDirectory = await getImagesDirectory();
      file = await _moveFile(tempFile, newDirectory);
    }
    return _list..add(LocalCoffeeImage(file.path));
  }

  Future<File> _downloadAndSaveFile(
    String imageUrl, {
    bool isTemp = false,
  }) async {
    final response = await _fetchUrl(imageUrl);
    final file = await _createFileFromUrl(imageUrl, isTemp: isTemp);
    await file.writeAsBytes(response.bodyBytes);
    return file;
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
    final response = await _fetchUrl(apiUrl);
    late RemoteCoffeeImage remoteImage;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      remoteImage = ApiCoffeeImageModel.fromJson(json).toEntity();
    } catch (exc) {
      throw InvalidRemoteCoffeeImageException();
    }
    final file = await _downloadAndSaveFile(remoteImage.imageUrl, isTemp: true);
    return LocalCoffeeImage(file.path);
  }

  Future<Directory> getImagesDirectory({bool isTemp = false}) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir =
        Directory(path.join(directory.path, isTemp ? 'temp' : 'favorites'));
    if (!imagesDir.existsSync()) {
      return imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Future<File> _createFileFromUrl(
    String imageUrl, {
    bool isTemp = false,
  }) async {
    final fileMetadata = _extractFileNameAndExtension(imageUrl);
    if (!imageFileExtensions.contains(fileMetadata['extension'])) {
      throw InvalidRemoteCoffeeImageException();
    }
    final imagesDir = await getImagesDirectory(isTemp: isTemp);
    final fileName = '$_filenameIdentifier'
        '${DateTime.now().millisecondsSinceEpoch}'
        '_'
        '${fileMetadata['name']}';

    final file = File(path.join(imagesDir.path, fileName));
    return file;
  }

  Future<http.Response> _fetchUrl(String imageUrl) async {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      throw InvalidRemoteCoffeeImageException();
    }
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw RemoteServerException();
    }
    return response;
  }

  Map<String, String> _extractFileNameAndExtension(String url) {
    return {'name': path.basename(url), 'extension': path.extension(url)};
  }

  Future<File> _moveFile(File sourceFile, Directory newDirectory) async {
    try {
      // if (!newDirectory.existsSync()) {
      //   await newDirectory.create(recursive: true);
      // }

      final newFilePath = '${newDirectory.path}'
          '${Platform.pathSeparator}'
          '${sourceFile.uri.pathSegments.last}';

      final file = await sourceFile.rename(newFilePath);
      return file;
    } catch (e) {
      throw LocalSavingFileException();
    }
  }
}
