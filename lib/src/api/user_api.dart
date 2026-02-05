import '../models/user.dart';
import 'api_client.dart';

/// API methods for users.
class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  /// Updates user information.
  Future<ApiResult<void>> update(UserInfo userInfo) async {
    return _client.postVoid('/user/update', userInfo.toJson());
  }
}
