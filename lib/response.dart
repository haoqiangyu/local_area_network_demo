class Response {
  int _responseCode;

  Response({int responseCode}) {
    this._responseCode = responseCode;
  }

  int get responseCode => _responseCode;

  Response.fromJson(Map<String, dynamic> json) {
    _responseCode = json['response_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this._responseCode;
    return data;
  }
}
