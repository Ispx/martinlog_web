
typedef InstanceOf = Object Function();
typedef Bind = Simple Function(Simple i);

Simple simple = Simple();

class Simple {
  static Simple _i = Simple._();
  factory Simple() => _i;
  Simple._();
  final Map<Type, Props> _instances = {};
  static Simple Function(Simple i)? statup;
  void startUp(Bind b) {
    statup = b;
    _i = statup!(this);
  }

  void addFactory<T>(InstanceOf instance) {
    if (_instances[T] != null) {
      throw Exception("Already exists instance of $T registered");
    }
    _instances.addAll({
      T: Props(
        instanceOf: instance,
        isSingleton: false,
      )
    });
  }

  void addSingleton<T>(InstanceOf instance) {
    if (_instances[T] != null) {
      throw Exception("Already exists instance of $T registered");
    }
    _instances.addAll({
      T: Props(
        instanceOf: instance,
        isSingleton: true,
      )
    });
  }

  T get<T>() {
    try {
      final props = _instances[T];
      if (props == null) {
        throw Exception("NOT FOUND INSTANCE OF $T");
      }
      return props.get() as T;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void update<T>(InstanceOf instance) {
    _instances.update(T, (value) {
      return Props(
        instanceOf: instance,
        isSingleton: value.isSingleton,
      );
    });
  }

  void reset() {
    clear();
    if (statup == null) return;
    statup!(this);
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
