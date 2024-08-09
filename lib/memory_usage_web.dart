import "dart:js_interop";

@JS('window.flutterCanvasKit.HEAP8.byteLength')
external JSNumber get _canvasKitMemory;

int getMemoryUsageBytes() {
  return _canvasKitMemory.toDartInt;
}
