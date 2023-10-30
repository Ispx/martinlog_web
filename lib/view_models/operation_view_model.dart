abstract interface class IOperationViewModel {
  Future<void> create({
    required String dockCode,
    required String liscensePlate,
    required String description,
  });
  Future<void> updateProgress({
    required String operationKey,
    required int progress,
  });

  Future<void> cancel({
    required operationKey,
  });

  Future<void> getAll();

  Future<void> getOperation({
    required operationKey,
  });
}

class OperationViewModel implements IOperationViewModel {
  @override
  Future<void> cancel({required operationKey}) {
    // TODO: implement cancel
    throw UnimplementedError();
  }

  @override
  Future<void> create(
      {required String dockCode,
      required String liscensePlate,
      required String description}) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<void> getOperation({required operationKey}) {
    // TODO: implement getOperation
    throw UnimplementedError();
  }

  @override
  Future<void> updateProgress(
      {required String operationKey, required int progress}) {
    // TODO: implement updateProgress
    throw UnimplementedError();
  }
}
