import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:nghinv_device_info/nghinv_device_info.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part '_model.dart';
part '_arguments.dart';

const _kDefaultUri = "ws://localhost:9090";

class NConsole {
  /// Send log to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// NConsole.log({
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  ///
  /// NConsole.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  ///
  /// NConsole.log(json.decode(response));
  /// ```
  static dynamic log = _VarArgsFunction((args) {
    _sendRequest(args);
  });

  /// Send log group to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// NConsole.group("Group 1");
  /// NConsole.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  /// NConsole.groupEnd();
  /// ```
  static dynamic group = _VarArgsFunction((args) {
    _sendRequest(args, LogType.group);
  });

  /// Send log group collapsed to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// NConsole.groupCollapsed("Group 1");
  /// NConsole.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  /// NConsole.groupEnd();
  /// ```
  static dynamic groupCollapsed = _VarArgsFunction((args) {
    _sendRequest(args, LogType.groupCollapsed);
  });

  /// End log group or collapsed group
  static dynamic groupEnd = _VarArgsFunction((args) {
    _sendRequest(args, LogType.groupEnd);
  });

  /// Send log info to [Server Log] app
  static dynamic info = _VarArgsFunction((args) {
    _sendRequest(args, LogType.info);
  });

  /// Send log warn to [Server Log] app
  static dynamic warn = _VarArgsFunction((args) {
    _sendRequest(args, LogType.warn);
  });

  /// Send log error to [Server Log] app
  static dynamic error = _VarArgsFunction((args) {
    _sendRequest(args, LogType.error);
  });

  static dynamic clear = _VarArgsFunction((args) {
    _sendRequest(args, LogType.clear);
  });

  static dynamic bloc = _VarArgsFunction((args) {
    _sendRequest(args, LogType.bloc);
  });

  static NConsole? __instance;

  static NConsole get _instance {
    __instance ??= NConsole();
    return __instance!;
  }

  bool _isEnable = kDebugMode;

  bool _enableSaveLog = false;

  String? _publicKey;

  String _uri = _kDefaultUri;

  ClientInfo? _clientInfo;

  WebSocketChannel? _webSocket;

  bool _useSecure = true;

  Function(List<dynamic>, LogType)? _listenLog;
  Function(List<dynamic>, LogType)? _listenSaveLog;

  static setUseSecure(bool value) {
    _instance._useSecure = value;
  }

  static setUri(String? uri) {
    _instance._uri = _instance._getUri(uri);
    _instance._webSocket?.sink.close();
    _instance._webSocket = null;
  }

  static setPublicKey(String? publicKey) {
    _instance._publicKey = publicKey;
  }

  static bool get isEnable => _instance._isEnable;

  static set isEnable(bool value) {
    _instance._isEnable = value;
  }

  static bool get enableSaveLog => _instance._enableSaveLog;

  static set enableSaveLog(bool value) {
    _instance._enableSaveLog = value;
  }

  static String get uri => _instance._uri;

  static setLogListener(Function(List<dynamic>, LogType)? listen) {
    _instance._listenLog = listen;
  }

  static setSaveLogListener(Function(List<dynamic>, LogType)? listen) {
    _instance._listenSaveLog = listen;
  }

  static setClientInfo(ClientInfo? clientInfo) {
    _instance._clientInfo = clientInfo;
  }

  String _getUri(String? uri) {
    if (uri == null) {
      return _kDefaultUri;
    }

    String uriNew = uri.trim();

    if (!uri.startsWith("ws://") && !uri.startsWith("wss://")) {
      uriNew = "ws://$uriNew";
    }

    final uriParts = uriNew.split(':');
    if (uriParts.length == 3) {
      return uriNew;
    }

    if (uriParts.length == 2) {
      final ipParts = uriParts[1].split('.');
      if (ipParts.length == 4) {
        return "$uriNew:9090";
      }

      if (uriParts[1] == "localhost") {
        return "$uriNew:9090";
      }

      return uriNew;
    }

    return uriNew;
  }

  Future _connectWebSocket([String? data]) async {
    if (_instance._webSocket != null) {
      return;
    }

    if (_instance._webSocket != null) {
      _instance._webSocket!.sink.close();
    }

    try {
      _instance._webSocket =
          WebSocketChannel.connect(Uri.parse(_instance._uri));
      _instance._webSocket!.ready.then((_) {
        _instance._webSocket!.stream.listen(
          (event) {},
          onDone: () {
            _instance._webSocket = null;
          },
          onError: (error) {
            _instance._webSocket = null;
          },
          cancelOnError: true,
        );
      }).onError((error, stackTrace) {
        _instance._webSocket = null;
      });
    } catch (e) {
      _instance._webSocket = null;
    }

    if (_instance._webSocket == null) {
      return;
    }

    if (data != null) {
      _instance._webSocket!.sink.add(data);
    }
  }

  String _genHexString(int len) {
    const hex =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String output = '';

    for (int i = 0; i < len; ++i) {
      output += hex[(Random().nextInt(hex.length))];
    }

    return output;
  }

  Future<_PayloadData> _encode(String data) async {
    if (_publicKey == null || !_useSecure) {
      return _PayloadData(data: data);
    }

    final publicKey = RSAPublicKey.fromPEM(_publicKey!);

    final keyRaw = _genHexString(32);
    final ivRaw = _genHexString(16);

    final key = Key.fromUtf8(keyRaw);
    final iv = IV.fromUtf8(ivRaw);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: iv).base64;
    final keyEncode = publicKey.encrypt("$keyRaw$ivRaw");

    return _PayloadData(
      data: encrypted,
      encryptionKey: keyEncode,
    );
  }

  static dynamic _sendRequest(List<dynamic> args,
      [LogType type = LogType.log]) async {
    if (_instance._enableSaveLog) {
      _instance._listenSaveLog?.call(args, type);
    }

    if (!_instance._isEnable) {
      return;
    }

    _instance._listenLog?.call(args, type);

    if (_instance._clientInfo == null) {
      final deviceInfo = await NDeviceInfo().getDeviceInfo();
      final clientInfo = ClientInfo(
        id: deviceInfo?.id ?? Platform.localHostname,
        name: (deviceInfo?.name == "iPhone"
                ? deviceInfo?.model
                : deviceInfo?.name) ??
            Platform.localHostname,
        platform: deviceInfo?.os ?? Platform.operatingSystem,
        version: deviceInfo?.version ?? Platform.operatingSystemVersion,
        os: deviceInfo?.os ?? (kIsWeb ? 'Web' : Platform.operatingSystem),
        osVersion: kIsWeb ? 'Web' : Platform.operatingSystem,
        language: kIsWeb ? null : Platform.localeName,
        userAgent: deviceInfo?.userAgent,
        timeZone: DateTime.now().timeZoneName,
        isSimulator: deviceInfo?.isSimulator ?? false,
        buildVersion: deviceInfo?.buildVersion ?? Platform.version,
        model: deviceInfo?.model,
        manufacturer: deviceInfo?.manufacturer,
      );
      setClientInfo(clientInfo);
    }

    final payloadData = {
      "clientInfo": _instance._clientInfo,
      "data": args,
    };

    final payload = await _instance._encode(json.encode(payloadData));
    final dataRequest = _RequestData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      logType: type,
      secure: payload.encryptionKey != null,
      payload: payload,
    );

    if (_instance._webSocket == null) {
      _instance._connectWebSocket(json.encode(dataRequest.toJson()));
      return;
    }

    if (_instance._webSocket!.closeCode != null) {
      _instance._connectWebSocket(json.encode(dataRequest.toJson()));
      return;
    }

    _instance._webSocket!.sink.add(json.encode(dataRequest.toJson()));
  }
}
