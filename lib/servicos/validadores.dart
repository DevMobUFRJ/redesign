class Validadores {

  static bool facebookUrl(String url) {
    if(!url.startsWith("http")){
      url = "http://" + url;
    }
    
    url = url.toLowerCase();
    return Validadores.url(url) &&
        (url.contains("facebook.com") || url.contains("fb.com"));
  }

  static bool url(String url){
    if(!url.startsWith("http")){
      url = "http://" + url;
    }
    RegExp regExp = RegExp(r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+", caseSensitive: false);
    return regExp.hasMatch(url);
  }
}
