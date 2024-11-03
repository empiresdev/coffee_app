// ignore_for_file: one_member_abstracts

import 'package:coffee_app/coffee/models/models.dart';

abstract class RemoteCoffeeRepository {
  Future<RemoteCoffeeImage> fetchRandomImage();
}
