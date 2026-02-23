import 'dart:js_interop';
import 'dart:async';

// Fetch the image as a blob to force download (avoids cross-origin open-in-tab issue)
@JS('fetch')
external JSPromise _jsFetch(String url);

@JS('URL.createObjectURL')
external String _createObjectURL(JSObject blob);

@JS('URL.revokeObjectURL')
external void _revokeObjectURL(String url);

@JS('document.createElement')
external JSObject _createElement(String tag);

@JS('document.body.appendChild')
external void _appendChild(JSObject element);

@JS('document.body.removeChild')
external void _removeChild(JSObject element);

@JS()
extension type _Response(JSObject _) implements JSObject {
  external JSPromise blob();
}

@JS()
extension type _AnchorElement(JSObject _) implements JSObject {
  external set href(String value);
  external set download(String value);
  external void click();
}

void downloadFileFromUrl(String url, String filename) {
  _fetchAndDownload(url, filename);
}

Future<void> _fetchAndDownload(String url, String filename) async {
  try {
    final responseJs = await _jsFetch(url).toDart;
    final response = _Response(responseJs as JSObject);
    final blobJs = await response.blob().toDart;
    final blobUrl = _createObjectURL(blobJs as JSObject);

    final anchor = _AnchorElement(_createElement('a'));
    anchor.href = blobUrl;
    anchor.download = filename;
    _appendChild(anchor as JSObject);
    anchor.click();
    _removeChild(anchor as JSObject);
    _revokeObjectURL(blobUrl);
  } catch (_) {
    // Fallback: open in new tab if fetch fails (e.g. CORS)
    _openFallback(url);
  }
}

@JS('window.open')
external void _openFallback(String url);
