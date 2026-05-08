import 'package:cloud_functions/cloud_functions.dart';

class NotificationService {
  static final _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  static Future<void> send({
    required String toUserId,
    required String type,
    required Map<String, String> payload,
  }) async {
    try {
      await _functions.httpsCallable('sendNotification').call({
        'toUserId': toUserId,
        'type': type,
        'payload': payload,
      });
    } catch (e) {
      print('Erreur notification: $e');
    }
  }
}