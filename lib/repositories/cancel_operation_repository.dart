abstract interface class ICancelOperationRepository {
  Future<void> call(String operationKey);
}

class CancelOperationRepository implements ICancelOperationRepository {
  @override
  Future<void> call(String operationKey) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
