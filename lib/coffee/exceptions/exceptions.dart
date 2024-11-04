import 'package:equatable/equatable.dart';

abstract class CoffeeException extends Equatable implements Exception {
  @override
  List<Object?> get props => [];
}

class RemoteServerException extends CoffeeException {}

class InvalidRemoteCoffeeImageException extends CoffeeException {}

class LocalSavingFileException extends CoffeeException {}
