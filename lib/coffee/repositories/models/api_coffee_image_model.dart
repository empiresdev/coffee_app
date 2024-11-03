import 'package:coffee_app/coffee/models/models.dart';

class ApiCoffeeImageModel {
  ApiCoffeeImageModel._({required this.file});

  factory ApiCoffeeImageModel.fromJson(Map<String, dynamic> json) {
    final file = json['file'] as String;
    return ApiCoffeeImageModel._(file: file);
  }

  final String file;

  RemoteCoffeeImage toEntity() => RemoteCoffeeImage(file);
}
