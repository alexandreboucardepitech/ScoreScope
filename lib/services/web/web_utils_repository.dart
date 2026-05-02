import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scorescope/services/repositories/i_utils_repository.dart';

class WebUtilsRepository implements IUtilsRepository {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('feedbacks');
  @override
  Future<void> addFeedback({
    required String title,
    required String detail,
    required String? userId,
  }) async {
    final data = {
      'title': title,
      'detail': detail,
      'userId': userId,
      'traite': "non",
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _collection.add(data);
  }
}
