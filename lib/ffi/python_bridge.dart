import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

class PythonBridge {
  DynamicLibrary? _pythonLib;
  late Function detectFingerprint;

  PythonBridge() {
    _initializePythonLibrary();
  }

  void _initializePythonLibrary() {
    try {
      if (Platform.isWindows) {
        _pythonLib = _loadLibrary([
          "C:\\Users\\Mohamed Amr\\AppData\\Local\\Programs\\Python\\Python312\\python3.dll",
          "C:\\Users\\Mohamed Amr\\AppData\\Local\\Programs\\Python\\Python312\\python312.dll"
        ]);
      } else if (Platform.isLinux) {
        _pythonLib = _loadLibrary(["/usr/lib/libpython3.so"]);
      } else if (Platform.isMacOS) {
        _pythonLib = _loadLibrary(["/usr/local/lib/libpython3.dylib"]);
      } else {
        throw UnsupportedError("❌ Platform not supported: ${Platform.operatingSystem}");
      }

      if (_pythonLib == null) throw Exception("⚠ Python library not found!");

      detectFingerprint = _pythonLib!
          .lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>("detect_fingerprint")
          .asFunction<int Function(Pointer<Utf8>)>();

      print("✅ Python FFI Library Loaded Successfully!");
    } catch (e) {
      print("⚠ Error: Python library could not be loaded - $e");
      throw Exception("Python library not found. Ensure Python is installed and set in PATH.");
    }
  }

  DynamicLibrary? _loadLibrary(List<String> paths) {
    for (var path in paths) {
      if (File(path).existsSync()) {
        return DynamicLibrary.open(path);
      }
    }
    return null;
  }

  bool processFingerprint(String imagePath) {
    final imagePathPtr = imagePath.toNativeUtf8();
    final result = detectFingerprint(imagePathPtr);
    malloc.free(imagePathPtr);
    return result == 1;
  }
}
