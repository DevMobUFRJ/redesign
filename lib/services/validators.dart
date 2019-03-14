class Validators {

  static bool facebookUrl(String url) {
    if(!url.startsWith("http")){
      url = "http://" + url;
    }

    url = url.toLowerCase();
    return Validators.url(url) &&
        (url.contains("facebook.com") || url.contains("fb.com"));
  }

  static bool url(String url){
    if(!url.startsWith("http")){
      url = "http://" + url;
    }
    RegExp regExp = RegExp(r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+", caseSensitive: false);
    return regExp.hasMatch(url);
  }

  static bool email(String email){
    RegExp regExp = RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$", caseSensitive: false);
    return regExp.hasMatch(email);
  }
}
