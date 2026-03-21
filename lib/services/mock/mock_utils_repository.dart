import 'package:scorescope/services/repositories/i_utils_repository.dart';

class MockUtilsRepository implements IUtilsRepository {
  @override
  Future<void> addFeedback({
    required String title,
    required String detail,
    required String? userId,
  }) async {
    // rien en mock
  }
}
