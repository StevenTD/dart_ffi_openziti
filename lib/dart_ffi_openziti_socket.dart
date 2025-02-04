import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'dart_ffi_openziti.dart';

enum SocketType {
  stream, // Represents a streaming socket (TCP)
  datagram, // Represents a datagram socket (UDP)
}

class ZitiSocket {
  static const int stream = 1;
  static const int datagram = 2;
  final DartFfiOpenziti _ziti;
  final int _fd;
  final Map<String, dynamic> _zitiOpts;
  final Map<String, dynamic> _zitiBindings;
  InternetAddress? _bindAddress;

  ZitiSocket({
    required DartFfiOpenziti ziti,
    int type = stream,
    Map<String, dynamic>? opts,
  })  : _ziti = ziti,
        _fd = ziti.zitiSocket(type),
        _zitiOpts = opts ?? {},
        _zitiBindings = _processBindings(opts?['bindings']);

  static Map<String, dynamic> _processBindings(dynamic orig) {
    final bindings = <String, dynamic>{};

    if (orig != null) {
      for (var key in orig.keys) {
        var host = '';
        var port = 0;
        var val = orig[key];

        if (key is List) {
          host = key[0];
          port = key[1];
        } else if (key is String) {
          var parts = key.split(':');
          if (parts.length == 1) {
            port = int.parse(parts[0]);
          } else {
            host = parts[0];
            port = int.parse(parts[1]);
          }
        } else if (key is int) {
          port = key;
        }

        host = host.isEmpty ? '0.0.0.0' : host;
        bindings['$host:$port'] = val;
      }
    }

    return bindings;
  }

  void connect(dynamic addr, String identity) {
    if (addr is List && addr.length == 2) {
      final host = addr[0];
      final port = addr[1];

      if (_zitiBindings.containsKey('$host:$port')) {
        print('Ziti connect to $host:$port');
        // Use Ziti-specific connection logic
        final cfg = _zitiBindings['$host:$port'];
        final ztx = _ziti.loadZitiContext(cfg['ztx']);
        final service = cfg['service'];
        final terminator = cfg['terminator'];
        print('Socket is $_fd');
        print('Connecting with parameters:');
        print('ztx: $ztx');
        print('service: $service');
        print('terminator: $terminator');
        print('host: $host');
        print('port: $port');
        _ziti.zitiConnectWrapper(_fd, ztx, service, terminator: terminator);
      } else {
        // Fallback to regular socket connection logic
        // Convert the file descriptor (_fd) to a Pointer<Void>
        final socketPtr = calloc<IntPtr>();
        socketPtr.value = _fd;
        final ztx = _ziti.loadZitiContext(identity);
        print('Socket is $_fd');
        print('Connecting with parameters:');

        print('host: $host');
        print('port: $port');

        final result =
            _ziti.zitiConnectWrapper(_fd, ztx, "ziti-weather-service");
        _ziti.connectToZitiAddr(socketPtr.cast<Void>(), host, port);

        // Free the allocated memory
        calloc.free(socketPtr);
      }
    } else {
      throw ArgumentError('Invalid address format. Expected [host, port].');
    }
  }

  Future<void> bind(dynamic addr) async {
    if (addr is List && addr.length == 2) {
      final host = addr[0];
      final port = addr[1];
      _bindAddress = InternetAddress(host);
      print('Binding: $_bindAddress');

      final cfg = _zitiBindings['$host:$port'];
      if (cfg != null) {
        final ztx = _ziti
            .loadZitiContext(cfg['ztx'])
            .cast<Void>(); // Cast to Pointer<Void>
        final service = cfg['service'];
        final terminator = cfg['terminator'];
        print('Trying to bind');
        // Binding the socket using Ziti
        print('Socket is $_fd');
        print('Binding with parameters:');
        print('ztx: $ztx');
        print('service: $service');
        print('terminator: $terminator');
        print('host: $host');
        print('port: $port');

        _ziti.zitiBind(_fd, ztx, service, terminator: terminator);
        print('Socket bound successfully');
      } else {
        throw Exception('No binding configuration found for $host:$port');
      }
    } else {
      throw ArgumentError('Invalid address format. Expected [host, port].');
    }
  }

  void listen([int backlog = 5]) {
    print('Listening using socket: $_fd');
    _ziti.zitiListen(_fd, backlog);
  }

  Future<ZitiSocket> accept() async {
    final clientFd = _ziti.zitiAccept(_fd);
    print('Accept: $clientFd');
    return ZitiSocket(ziti: _ziti, opts: _zitiOpts);
  }

  void close() {
    _ziti.ziti_close(_fd);
  }

  void setsockopt(int level, int optname, dynamic value) {
    // Dart does not support setting socket options directly, so this is a no-op.
  }

  dynamic getsockname() {
    return ['127.0.0.1', 0];
  }
}
