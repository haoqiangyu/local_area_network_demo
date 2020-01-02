
///从机广播消息model

class BroadcastModel {
  String _deviceName;
  String _deviceUuid;
  int _password;

  BroadcastModel({String deviceName, String deviceUuid, int password}) {
    this._deviceName = deviceName;
    this._deviceUuid = deviceUuid;
    this._password = password;
  }

  String get deviceName => _deviceName;
  String get deviceUuid => _deviceUuid;
  int get password => _password;

  BroadcastModel.fromJson(Map<String, dynamic> json) {
    _deviceName = json['device_name'];
    _deviceUuid = json['device_uuid'];
    _password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_name'] = this._deviceName;
    data['device_uuid'] = this._deviceUuid;
    data['password'] = this._password;
    return data;
  }
}