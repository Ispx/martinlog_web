typedef InstanceOf = Object Function();

class Simple {
  static final Simple _i = Simple._();
  factory Simple() => _i;
  Simple._();
  final Map<Type, Props> _instances = {};

  void add<T>(InstanceOf instance, {bool isSingleton = false}) {
    if (_instances[T] != null) {
      throw Exception("Already exists instance of $T registered");
    }
    _instances.addAll({
      T: Props(
        instanceOf: instance,
        isSingleton: isSingleton,
      )
    });
  }

  T get<T>() {
    final props = _instances[T];
    if (props == null) {
      throw Exception("NOT FOUND INSTANCE OF $T");
    }
    return props.get() as T;
  }

  void update<T>(InstanceOf instance) {
    _instances.update(T, (value) {
      return Props(
        instanceOf: instance,
        isSingleton: value.isSingleton,
      );
    });
  }

  void clear() {
    _instances.clear();
  }
}

class Props {
  bool isSingleton;
  Object? _singletonInstance;
  InstanceOf instanceOf;
  Props({
    required this.instanceOf,
    required this.isSingleton,
  }) {
    if (isSingleton) {
      _singletonInstance = instanceOf();
    }
  }

  Object get() {
    return _singletonInstance ?? instanceOf();
  }
}
