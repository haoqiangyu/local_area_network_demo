import 'dart:io';

class Constant{
  Constant._();

  static final InternetAddress broadcastAddress= InternetAddress("255.255.255.255");
  static final int portUDP = 8889;
  static final int portTCP = 8887;



}

class ResponseCode{
  ResponseCode._();

  static final int ok = 111;
  static final int error = 222;
  static final int passwordError = 333;
}