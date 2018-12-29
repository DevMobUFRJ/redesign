class Validadores {

  static bool facebookUrl(String url) {
    url = url.toLowerCase();
    return Validadores.url(url) &&
        (url.contains("facebook.com") || url.contains("fb.com"));
  }

  static bool url(String url){
    RegExp regExp = RegExp(r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+", caseSensitive: false);
    return regExp.hasMatch(url);
  }
}
