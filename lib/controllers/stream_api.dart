import 'package:http/http.dart' as http;
import 'dart:convert';

/// Create a new Stream io user.
Future<void> createStreamUser(String userId) async {
  http.Response response = await http.post(
    Uri.parse('https://yamh-server.vercel.app/users?user_id=$userId'),
  );

  if (response.statusCode != 200) {
    throw Exception("Could not create Stream io user");
  }
}

/// Get the user token used for video calling
Future<String> getStreamUserToken(String userId) async {
  http.Response response = await http.get(
    Uri.parse('https://yamh-server.vercel.app/tokens?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    try {
      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return data["userToken"]! as String;
    } catch (error) {
      throw Exception("Could not parse response body");
    }
  } else {
    throw Exception("Could not fetch user token");
  }
}

/// Delete a stream io user
Future<void> deleteStreamUser(String userId) async {
  http.Response response = await http.delete(
    Uri.parse("https://yamh-server.vercel.app/users?user_id=$userId"),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception("Couldn't delete user");
  }
}
