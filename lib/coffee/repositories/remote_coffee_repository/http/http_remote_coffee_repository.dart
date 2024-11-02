import 'dart:convert';

import 'package:coffee_app/coffee/exceptions/exceptions.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:http/http.dart' as http;

class HttpRemoteCoffeeRepository implements RemoteCoffeeRepository {
  HttpRemoteCoffeeRepository([http.Client? client]) {
    _client = client ?? http.Client();
  }

  late http.Client _client;
  final String apiUrl = 'https://coffee.alexflipnote.dev/random.json';

  @override
  Future<RemoteCoffeeImage> fetchRandomImage() async {
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
}

class ApiCoffeeImageModel {
  ApiCoffeeImageModel._({required this.file});

  factory ApiCoffeeImageModel.fromJson(Map<String, dynamic> json) {
    final file = json['file'] as String;
    return ApiCoffeeImageModel._(file: file);
  }

  final String file;

  RemoteCoffeeImage toEntity() => RemoteCoffeeImage(file);
}
