import 'package:http/http.dart';
import 'package:http/testing.dart';

MockClient generateHttpMockClient({
  required int statusCode,
  required String body,
  List<int>? bytes,
}) {
  return MockClient((request) async {
    return bytes != null
        ? Response.bytes(bytes, statusCode)
        : Response(body, statusCode);
  });
}
