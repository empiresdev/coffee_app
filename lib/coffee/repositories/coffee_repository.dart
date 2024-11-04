import 'package:coffee_app/coffee/models/models.dart';

abstract class CoffeeRepository {
  Future<CoffeeImage> fetchRandomImage();
  Future<List<LocalCoffeeImage>> addImage(CoffeeImage coffeeImage);
  Future<List<LocalCoffeeImage>> fetchAllFavorites();
}
