import 'package:equatable/equatable.dart';

abstract class CoffeeImage extends Equatable {
  const CoffeeImage(this.imageUrl);

  final String imageUrl;

  @override
  List<Object?> get props => [imageUrl];
}

class RemoteCoffeeImage extends CoffeeImage {
  const RemoteCoffeeImage(super.imageUrl);
}

class LocalCoffeeImage extends CoffeeImage {
  const LocalCoffeeImage(super.imageUrl);
}
