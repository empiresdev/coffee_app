import 'package:http/http.dart';
import 'package:http/testing.dart';

MockClient generateHttpMockClient(int statusCode, String body) {
  return MockClient((request) async {
    const body = '''
{
  "file": "https://coffee.alexflipnote.dev/2GiUIZKXR1s_coffee.jpg"
}
''';
    return Response(body, statusCode);
  });
}
