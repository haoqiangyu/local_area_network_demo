class Request {
  String _deviceName;
  String _deviceUuid;
  String _roomPassword;

  Request({String deviceName, String deviceUuid, String roomPassword}) {
    this._deviceName = deviceName;
    this._deviceUuid = deviceUuid;
    this._roomPassword = roomPassword;
  }

  String get deviceName => _deviceName;
  String get deviceUuid => _deviceUuid;
  String get roomPassword => _roomPassword;

  Request.fromJson(Map<String, dynamic> json) {
    _deviceName = json['device_name'];
    _deviceUuid = json['device_uuid'];
    _roomPassword = json['room_password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_name'] = this._deviceName;
    data['device_uuid'] = this._deviceUuid;
    data['room_password'] = this._roomPassword;
    return data;
  }
}