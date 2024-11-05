part of '_nconsole.dart';

typedef _OnCall = void Function(List<dynamic> arguments);

class _VarArgsFunction {
  final _OnCall callback;

  _VarArgsFunction(this.callback);

  void call() => callback([]);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!NConsole._instance._isEnable && !NConsole._instance._enableSaveLog) {
      return;
    }

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
