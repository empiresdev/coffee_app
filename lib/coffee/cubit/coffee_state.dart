part of 'coffee_cubit.dart';

enum CoffeeStatus { initial, loading, success, failure }

final class CoffeeState extends Equatable{
  const CoffeeState({
    required this.status,
    this.image,
    this.message,
    this.favorites,
  });

  final CoffeeStatus status;
  final CoffeeImage? image;
  final String? message;
  final List<LocalCoffeeImage>? favorites;
  
  @override
  List<Object?> get props => [status, image, message, favorites];
}
