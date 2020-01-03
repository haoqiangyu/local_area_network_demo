class Device {
  String _deviceName;
  String _deviceUuid;
  String _deviceIp;
  int _devicePort;

  Device(
      {String deviceName, String deviceUuid, String deviceIp, int devicePort}) {
    this._deviceName = deviceName;
    this._deviceUuid = deviceUuid;
    this._deviceIp = deviceIp;
    this._devicePort = devicePort;
  }

  String get deviceName => _deviceName;

  String get deviceUuid => _deviceUuid;

  String get deviceIp => _deviceIp;

  int get devicePort => _devicePort;
}
