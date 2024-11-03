part of 'coffee_cubit.dart';

enum CoffeeStatus { initial, loading, success, failure }

final class CoffeeState extends Equatable {
  const CoffeeState({
    required this.status,
    this.image,
    this.messageId,
    this.favorites,
  });

  final CoffeeStatus status;
  final CoffeeImage? image;
  final String? messageId;
  final List<LocalCoffeeImage>? favorites;

  @override
  List<Object?> get props => [status, image, messageId, favorites];

  CoffeeState copyWith({
    CoffeeStatus? status,
    CoffeeImage? image,
    String? messageId,
    List<LocalCoffeeImage>? favorites,
  }) =>
      CoffeeState(
        status: status ?? this.status,
        image: image ?? this.image,
        messageId: messageId ?? this.messageId,
        favorites: favorites ?? this.favorites,
      );

  bool get isLoading => status == CoffeeStatus.loading;

  bool get isFavorite {
    if (image == null || favorites == null) return false;
    return favorites?.contains(image) ?? false;
  }
}
