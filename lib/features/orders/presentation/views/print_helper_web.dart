// Web implementation using dart:js_interop (Dart 3+)
import 'dart:js_interop';

@JS('window.open')
external JSObject _windowOpen(String url, String name, String features);

@JS()
extension type _JsWindow(JSObject _) implements JSObject {
  external _JsDocument get document;
  external void print();
}

@JS()
extension type _JsDocument(JSObject _) implements JSObject {
  external void write(String html);
  external void close();
}

void printHtmlContent(String htmlContent) {
  final win = _JsWindow(_windowOpen('', 'PRINT', 'height=600,width=400'));
  win.document.write(htmlContent);
  win.document.close();
  Future.delayed(
    const Duration(milliseconds: 300),
    () => win.print(),
  );
}
