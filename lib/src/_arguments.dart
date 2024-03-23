part of '_nconsole.dart';

typedef _OnCall = void Function(List<dynamic> arguments);

class _VarArgsFunction {
  final _OnCall callback;
  final bool isEnable;

  _VarArgsFunction(this.callback, this.isEnable);

  void call() => callback([]);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!isEnable) return;

    return callback(
      invocation.positionalArguments.map(
        (argument) {
          try {
            return json.encode(argument);
          } catch (e) {
            return json.encode("$argument");
          }
        },
      ).toList(),
    );
  }
}
