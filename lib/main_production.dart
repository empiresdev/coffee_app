import 'package:coffee_app/app/app.dart';
import 'package:coffee_app/bootstrap.dart';
import 'package:coffee_app/coffee/repositories/local_coffee_repository/local_coffee_repository.dart';
import 'package:coffee_app/coffee/repositories/remote_coffee_repository/remote_coffee_repository.dart';

void main() {
  bootstrap(
    () => App(
      localRepository: HttpPathProviderLocalCoffeeRepository(),
      remoteRepository: HttpRemoteCoffeeRepository(),
    ),
  );
}
