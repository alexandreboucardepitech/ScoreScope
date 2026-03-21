abstract class IUtilsRepository {
  Future<void> addFeedback({required String title, required String detail, required String? userId});
}
