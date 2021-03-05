import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

class FirebaseUtils {
  static Future<List<Map>> users({String nextPageToken}) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'users',
      );

      final params = <dynamic, dynamic>{
        'nextPageToken': nextPageToken,
      };

      return callable.call<Map>(params).then((HttpsCallableResult resp) {
        if (resp != null && resp.data != null) {
          final Map m = resp.data as Map;

          if (m.listVal<Map>('list') != null) {
            return m.listVal<Map>('list');
          }
        }
        return null;
      });
    } catch (error) {
      print('error $error');
    }

    return null;
  }

  static Future<List<String>> getSubCollections(String docPath) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'users',
      );

      final params = <dynamic, dynamic>{
        'docPath': docPath,
      };

      return callable.call<Map>(params).then((HttpsCallableResult resp) {
        if (resp != null && resp.data != null) {
          final respMap = resp.data as Map<String, dynamic>;

          final List<String> m = respMap['collections'] as List<String>;

          return m;
        }
        return null;
      });
    } catch (error) {
      print('error $error');
    }

    return null;
  }

  static Future<bool> modifyClaims({
    @required String email,
    @required String uid,
    @required Map<String, bool> claims,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'addUserClaims',
      );
      final HttpsCallableResult resp =
          await callable.call<Map>(<String, dynamic>{
        'email': email,
        'uid': uid,
        'claims': claims,
      });

      if (resp != null && resp.data != null) {
        final respMap = resp.data as Map<String, dynamic>;

        if (respMap['error'] != null) {
          print(resp.data);
          return false;
        }

        return true;
      }
    } catch (error) {
      print('error $error');
    }

    return false;
  }

  static Future<bool> sendEmail({
    @required String to,
    @required String subject,
    @required String content,
    @required String from,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendEmail',
      );
      final HttpsCallableResult resp =
          await callable.call<Map>(<String, dynamic>{
        'to': to,
        'subject': subject,
        'from': from,
        'content': content,
      });

      if (resp != null && resp.data != null) {
        final respMap = resp.data as Map<String, dynamic>;

        if (respMap['error'] != null) {
          print(resp.data);
          return false;
        }

        return true;
      }
    } catch (error) {
      print('error $error');
    }

    return false;
  }
}
