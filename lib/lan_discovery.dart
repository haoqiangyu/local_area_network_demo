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
  Utf8Decoder utf8decoder = Utf8Decoder();

  LANDiscovery({this.sendUDPSuccessCallback});

  ///从机发送UDP广播寻找主机
  void sendUDP(BroadcastModel broadcastModel) async {
    RawDatagramSocket senderUDP =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP);
    senderUDP.broadcastEnabled = true;
    senderUDP.listen((e) {
      Datagram dg = senderUDP.receive();
      if (dg != null) {
        //receiveTCP();
        String jsonDevice = utf8decoder.convert(dg.data);
        if (AnswerModel.fromJson(json.decode(jsonDevice)).answer == null) {
          print(
              '从机---发送UDP广播成功-发送内容${utf8decoder.convert(dg.data)}自身ip-${dg.address.address}端口号-${dg.port}');

        } else {
          print('从机--收到主机应答内容--json$jsonDevice--主机ip${dg.address.address}端口号-${dg.port}');
          senderUDP.close();
          print('从机--准备通过TCP连接主机');
          sendTCP(ip: dg.address.address,answer: AnswerModel(answer: '从机：我发送了联机请求'));
        }
      }
    });
    List<int> data = utf8.encode(json.encode(broadcastModel.toJson()));
    senderUDP.send(data, Constant.broadcastAddress, Constant.portUDP);
    print('从机---发送UDP广播~');
  }

  ///主机接收UDP广播包，校验后发送应答包
  void receiveUDP() async {
    receiveTCP();
    if(receiverUDP==null){
      receiverUDP =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP);
    }
    receiverUDP.listen((e) {
      Datagram dg = receiverUDP.receive();
      if (dg != null) {
        print('主机---接收UDP广播成功--从机ip${dg.address.address}端口号-${dg.port}');
        print('主机--校验密码及uuid并回复');

        AnswerModel answer = AnswerModel(answer: '主机：我已收到UDP包~');
        List<int> data = utf8.encode(json.encode(answer.toJson()));
        receiverUDP.send(
            data, InternetAddress(dg.address.address), Constant.portUDP);
      }
    });
  }

  ///从机发送TCP请求连接主机
  void sendTCP({String ip, AnswerModel answer}) async {
    Socket senderTCP = await Socket.connect(ip, Constant.portTCP);
    senderTCP.listen((data) {
      print('从机--收到主机TCP的回复--${utf8decoder.convert(data)}');
    }, onDone: () {
      print('从机--向主机发送联机TCP请求完成');
      senderTCP.close();
    }, onError: (error) {
      print('从机--发送联机TCP请求错误-$error');
    });
    List<int> data = utf8.encode(json.encode(answer.toJson()));
    senderTCP.add(data);
    print('从机--向主机发送联机请求');
  }

  ///主机建立TCP服务器
  void receiveTCP() async {
    if(receiverTCP==null){
      receiverTCP = await ServerSocket.bind(
          InternetAddress.anyIPv4, Constant.portTCP,
          shared: true);
    }
    print('主机--成功建立TCP-ServerSocket连接~');
    receiverTCP.listen((soc) async {
      print(
          '主机--接收到从机的连接请求--ip和端口为${soc.remoteAddress.address}:${soc.remotePort}');
      await for (List<int> d in soc.asBroadcastStream()) {
        if (d != null) {
          print('主机--接收从机联机请求内容-${utf8decoder.convert(d)}');
          break;
        }
      }
      AnswerModel answer = AnswerModel(answer: '主机：我已知道你的联机请求');
      List<int> data = utf8.encode(json.encode(answer.toJson()));
      soc.add(data);
      print('主机--发送回复从机联机请求的数据包');
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
