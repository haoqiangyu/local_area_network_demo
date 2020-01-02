import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:local_area_network_demo/answer_model.dart';
import 'package:local_area_network_demo/broadcast_model.dart';
import 'constant.dart';

///局域网发现
class LANDiscovery {
  RawDatagramSocket receiverUDP;
  ServerSocket receiverTCP;
  VoidCallback sendUDPSuccessCallback;

  LANDiscovery({this.sendUDPSuccessCallback});

  ///从机发送UDP广播寻找主机
  void sendUDP(BroadcastModel broadcastModel) async {
    RawDatagramSocket senderUDP =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP);
    senderUDP.broadcastEnabled = true;
    senderUDP.listen((e) {
      Datagram dg = senderUDP.receive();
      if (dg != null) {
        receiveTCP();
        print('从机---发送UDP广播成功');
        senderUDP.close();
      }
    });
    List<int> data = utf8.encode(json.encode(broadcastModel.toJson()));
    senderUDP.send(data, Constant.broadcastAddress, Constant.portUDP);
    print('从机---发送UDP广播~');
  }

  ///主机接收UDP广播包，校验后发送TCP应答包
  void receiveUDP() async {
    receiverUDP =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP);
    receiverUDP.listen((e) {
      Datagram dg = receiverUDP.receive();
      if (dg != null) {
        print('主机---接收UDP广播成功--我知道了从机的ip，让从机知道我的ip--发送TCP');
        sendTCP(ip: dg.address.address, answer: AnswerModel(answer: '主机：我已知晓从机的联机请求'));
      }
    });
  }

  ///主机发送TCP应答
  void sendTCP({String ip, AnswerModel answer}) async {
    Socket senderTCP = await Socket.connect(ip, Constant.portTCP);
    Utf8Decoder utf8decoder = Utf8Decoder();
    senderTCP.listen((data) {
      print('主机--收到从机对应答数据包的回复--${utf8decoder.convert(data)}');
    }, onDone: () {
      print('主机--向从机发送接收广播应答包完成');
      senderTCP.close();
    }, onError: (error) {
      print('主机--发送应答包错误-$error');
    });
    List<int> data = utf8.encode(json.encode(answer.toJson()));
    senderTCP.add(data);
    print('主机--向从机发送接收广播应答包');
  }

  ///从机接收主机的TCP应答包并回复
  void receiveTCP() async {
    receiverTCP = await ServerSocket.bind(
        InternetAddress.anyIPv4, Constant.portTCP,
        shared: true);
    receiverTCP.listen((soc) async {
      print(
          '从机--接收主机的广播应答包成功||连接源即主机ip和端口为${soc.remoteAddress.address}:${soc.remotePort}');
      Utf8Decoder utf8decoder = Utf8Decoder();
      await for (List<int> d in soc.asBroadcastStream()) {
        if (d != null) {
          print('从机--接收主机应答包内容-${utf8decoder.convert(d)}');
          break;
        }
      }
      AnswerModel answer = AnswerModel(answer: '从机：我已知道你知道我的联机请求');
      List<int> data = utf8.encode(json.encode(answer.toJson()));
      soc.add(data);
      print('从机--发送回复主机应答的数据包');
      soc.close();
    });
  }

  void closeTCP() {
    receiverTCP?.close();
  }

  void closeUDP() {
    receiverUDP?.close();
  }
}
