import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Load the shared library
final dylib = DynamicLibrary.open("lib/ziti.dll");

// Define structures
final class Ver extends Struct {
  external Pointer<Utf8> version;
  external Pointer<Utf8> revision;
}

// Define function bindings
final ziti_lib_init =
    dylib.lookupFunction<Void Function(), void Function()>('Ziti_lib_init');

final ziti_lib_shutdown =
    dylib.lookupFunction<Void Function(), void Function()>('Ziti_lib_shutdown');

final ziti_last_error =
    dylib.lookupFunction<Int32 Function(), int Function()>('Ziti_last_error');

final ziti_errorstr = dylib.lookupFunction<Pointer<Utf8> Function(Int32),
    Pointer<Utf8> Function(int)>('ziti_errorstr');

final ziti_get_version =
    dylib.lookupFunction<Pointer<Ver> Function(), Pointer<Ver> Function()>(
        'ziti_get_version');

final ziti_socket = dylib
    .lookupFunction<Int32 Function(Int32), int Function(int)>('Ziti_socket');

final ziti_close = dylib
    .lookupFunction<Int32 Function(Int32), int Function(int)>('Ziti_close');

final ziti_connect = dylib.lookupFunction<
    Int32 Function(Int32, Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
    int Function(int, Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>(
  'Ziti_connect',
);

final ziti_bind = dylib.lookupFunction<
    Int32 Function(Int32, Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
    int Function(int, Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>(
  'Ziti_bind',
);

final ziti_listen =
    dylib.lookupFunction<Int32 Function(Int32, Int32), int Function(int, int)>(
        'Ziti_listen');

final ziti_accept = dylib.lookupFunction<
    Int32 Function(Int32, Pointer<Utf8>, Int32),
    int Function(int, Pointer<Utf8>, int)>('Ziti_accept');

final ziti_enroll_identity = dylib.lookupFunction<
    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<Pointer<Utf8>>, Pointer<Uint64>),
    int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<Pointer<Utf8>>, Pointer<Uint64>)>('Ziti_enroll_identity');

final Ziti_load_context = dylib.lookupFunction<
    Pointer Function(Pointer<Utf8> identity),
    Pointer Function(Pointer<Utf8> identity)>('Ziti_load_context');

late final ZitiConnectAddrDart ziti_connect_addr = dylib
    .lookupFunction<ZitiConnectAddrC, ZitiConnectAddrDart>('Ziti_connect_addr');

// Create the Dart function
final ZitiCheckSocketDart zitiCheckSocket = dylib
    .lookupFunction<ZitiCheckSocketC, ZitiCheckSocketDart>('Ziti_check_socket');

typedef ziti_connect_func = Int32 Function(Int32 socket, Pointer<Void> ztx,
    Pointer<Utf8> service, Pointer<Utf8> terminator);
typedef ZitiConnect = int Function(int socket, Pointer<Void> ztx,
    Pointer<Utf8> service, Pointer<Utf8> terminator);

// Define the Ziti_check_socket function signature
typedef ZitiCheckSocketC = Int32 Function(Int32 socket);
typedef ZitiCheckSocketDart = int Function(int socket);

typedef ZitiConnectAddrC = Int32 Function(
    Pointer<Void> socket, Pointer<Utf8> host, Uint32 port);
typedef ZitiConnectAddrDart = int Function(
    Pointer<Void> socket, Pointer<Utf8> host, int port);

// final ZitiConnect zitiConnect =
//     dylib.lookupFunction<ziti_connect_func, ZitiConnect>('Ziti_connect');

// Helper functions
void checkError(int code) {
  if (code != 0) {
    final err = ziti_last_error();
    final errMsg = ziti_errorstr(err);
    throw Exception('Ziti error: ${errMsg.toDartString()}');
  }
}

void zitiVersion() {
  final ver = ziti_get_version();
  final version = ver.ref.version.toDartString();
  final revision = ver.ref.revision.toDartString();
  print('Ziti Version: $version, Revision: $revision');
}

int zitiSocket(int type) {
  final int fd = ziti_socket(type);
  if (fd <= 0) {
    throw Exception("Ziti_socket failed, returned invalid descriptor");
  }
  return fd;
}

final ZitiConnect zitiConnect =
    dylib.lookupFunction<ziti_connect_func, ZitiConnect>('Ziti_connect');

// void zitiConnect(int fd, Pointer<Void> ztx, String service,
//     {String? terminator}) {
//   final servicePtr = service.toNativeUtf8();
//   final terminatorPtr =
//       terminator != null ? terminator.toNativeUtf8() : nullptr;
//   final result = ziti_connect(fd, ztx, servicePtr, terminatorPtr);
//   malloc.free(servicePtr);
//   if (terminatorPtr != nullptr) malloc.free(terminatorPtr);
//   checkError(result);
// }

void zitiBind(int fd, Pointer<Void> ztx, String service, {String? terminator}) {
  final servicePtr = service.toNativeUtf8();
  final terminatorPtr =
      terminator != null ? terminator.toNativeUtf8() : nullptr;
  final result = ziti_bind(fd, ztx, servicePtr, terminatorPtr);
  malloc.free(servicePtr);
  if (terminatorPtr != nullptr) malloc.free(terminatorPtr);
  checkError(result);
}

void zitiListen(int fd, int backlog) {
  final result = ziti_listen(fd, backlog);
  checkError(result);
}

int zitiAccept(int fd) {
  final buffer = calloc.allocate<Utf8>(128);
  final client = ziti_accept(fd, buffer, 128);
  malloc.free(buffer);
  if (client < 0) {
    throw Exception("Ziti_accept failed");
  }
  return client;
}

String zitiEnroll(String jwt, {String? key, String? cert}) {
  final jwtPtr = jwt.toNativeUtf8();
  final keyPtr = key != null ? key.toNativeUtf8() : nullptr;
  final certPtr = cert != null ? cert.toNativeUtf8() : nullptr;

  final Pointer<Pointer<Utf8>> idJson = calloc<Pointer<Utf8>>();
  final Pointer<Uint64> idJsonLen = calloc<Uint64>();

  final retcode =
      ziti_enroll_identity(jwtPtr, keyPtr, certPtr, idJson, idJsonLen);

  malloc.free(jwtPtr);
  if (keyPtr != nullptr) malloc.free(keyPtr);
  if (certPtr != nullptr) malloc.free(certPtr);

  checkError(retcode);

  final enrolledIdentity = idJson.value.toDartString();
  malloc.free(idJson.value);
  malloc.free(idJson);
  malloc.free(idJsonLen);

  return enrolledIdentity;
}

Pointer loadZitiContext(String identity) {
  final identityPtr = identity.toNativeUtf8();
  final contextPtr = Ziti_load_context(identityPtr);
  calloc.free(identityPtr); // Clean up memory after use
  return contextPtr;
}

void zitiConnectWrapper(int fd, Pointer<NativeType> ztx, String service,
    {String? terminator}) {
  final servicePtr = service.toNativeUtf8();
  final terminatorPtr =
      terminator != null ? terminator.toNativeUtf8() : nullptr;

  // Cast the ztx pointer to Pointer<Void> in case it isn't already
  final contextPointer = ztx.cast<Void>();

  // Call the Ziti connect function
  final result = zitiConnect(fd, contextPointer, servicePtr, terminatorPtr);
  malloc.free(servicePtr);
  if (terminatorPtr != nullptr) malloc.free(terminatorPtr);

  // Check for errors
  if (result == 0) {
    print("Connected to Ziti service successfully.");
  } else {
    print("Ziti connection failed. Error code: $result");
  }
}

void connectToZitiAddr(Pointer<Void> socket, String host, int port) {
  final hostPtr = host.toNativeUtf8();
  print('Connecting to Ziti service at $host:$port');
  final result = ziti_connect_addr(socket, hostPtr, port);
  malloc.free(hostPtr);

  // Check for errors
  checkError(result);

  print('Successfully connected to Ziti service.');
}

// Function to call Ziti_check_socket
int checkSocket(int socket) {
  final result = zitiCheckSocket(socket);
  return result;
}

void shutdown() {
  ziti_lib_shutdown();
}
