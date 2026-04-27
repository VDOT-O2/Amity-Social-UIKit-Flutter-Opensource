class UrlBuilder {
  static String appendParam(String? url, {required String name, required String value}) {
    if (url == null) {
      return '';
    }
    
    Uri uri = Uri.parse(url); 
    if (uri.queryParameters.containsKey(name)) {
      final Map<String, String> params = Map.from(uri.queryParameters)..remove(name);
      uri = uri.replace(queryParameters: params.isEmpty ? null : params);
      url = uri.toString();
    }

    final String valueEncoded = Uri.encodeComponent(value);

    if (url.contains('?')) {
      return '$url&$name=$valueEncoded';
    } else {
      return '$url?$name=$valueEncoded';
    }
  }
}
