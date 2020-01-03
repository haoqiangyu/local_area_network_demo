import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_area_network_demo/broadcast_model.dart';
import 'package:local_area_network_demo/constant.dart';
import 'package:local_area_network_demo/lan_discovery.dart';
import 'package:local_area_network_demo/password_input.dart';
import 'package:local_area_network_demo/uuid.dart';
import 'sp_util.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data;
  List<BroadcastModel> devices;
  String deviceName;

  @override
  void initState() {
    data = '';
    devices = List<BroadcastModel>();
    if(SpUtil.getBool('isFirst',defValue: true)){
      SpUtil.putString('uuid', Uuid().generateV4());
      SpUtil.putBool('isFirst', false);
    }
    deviceName = '设备';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Offstage(
                offstage: Platform.isAndroid,
                child: CupertinoButton(
                    child: Text('IOS联网权限'),
                    onPressed: () {
                      getHttp();
                    }),
              ),
              CupertinoButton(
                  child: Text('发送(请求加入队伍)'),
                  onPressed: () {
                    testSend();
                  }),
              Expanded(
                child: TextField(
                    decoration: InputDecoration(
                      hintText: '昵称',
                    ),
                  onChanged: (text){
                      deviceName = text;
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.black26,
              child: SingleChildScrollView(
                child: Text(
                  data,
                  style: TextStyle(fontSize: 21),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: devices.length!=0?ListView.builder(
                itemCount: devices.length,
                  itemBuilder: (context , index){
                return Text(devices[index].deviceName,style: TextStyle(fontSize: 21,color: Colors.lightGreen),);
              }):null,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black54,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                  child: Text('接收(建立队伍)'),
                  onPressed: () {
                    testReceive();
                  }),
              CupertinoButton(
                  child: Text('关闭接收者(关闭队伍)'),
                  onPressed: () {
                    closeReceive();
                  }),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                  child: Text('testUDPsSend'),
                  onPressed: () {
                    LANDiscovery().sendUDP(BroadcastModel(password: 21,deviceUuid: 'uuid',deviceName: 'xxx'));
                  }),
              CupertinoButton(
                  child: Text('testUDPsRec'),
                  onPressed: () {
                    LANDiscovery().receiveUDP();
                  }),
            ],
          ),
          VerificationCodePage(),
        ],
      ),
    );
  }

  void testSend() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((e) {
        Datagram dg = udpSocket.receive();
        if (dg != null) {
          udpSocket.close();
        }
      });
      BroadcastModel device  = BroadcastModel(deviceName: deviceName,deviceUuid: SpUtil.getString('uuid'));
      List<int> data = utf8.encode(json.encode(device.toJson()));
      udpSocket.send(data, Constant.broadcastAddress, Constant.portUDP);
      setState(() {
        this.data = '发送数据--${device.toJson().toString()}';
      });
    });
  }

  void testReceive() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.portUDP)
        .then((RawDatagramSocket udpSocket) {
      receiver = udpSocket;
      receiver.listen((e) {
        Datagram dg = udpSocket.receive();
        if (dg != null) {
          print('ip${dg.address.address}');
          Utf8Decoder utf8decoder= Utf8Decoder();
          String jsonDevice = utf8decoder.convert(dg.data);
          BroadcastModel device = BroadcastModel.fromJson(json.decode(jsonDevice));
          if(devices.length==0){
            devices.add(device);
          }else{
            List<String> uuids = List<String>();
            for(BroadcastModel deviceModel in devices){
              uuids.add(deviceModel.deviceUuid);
            }
            if(!uuids.contains(device.deviceUuid)){
              devices.add(device);
            }

          }
          setState(() {
            this.data =
            '接收数据--$jsonDevice\nip${dg.address}\nport${dg.port}\nhost${dg.address.host}';
          });
        }
      });
    });
  }

  RawDatagramSocket receiver;

  void closeReceive() {
    receiver?.close();
    setState(() {
      data = '';
      devices.clear();
    });
  }

  void getHttp() async {
    try {
      Response response = await Dio().get("http://www.baidu.com");
      print(response);
    } catch (e) {
      print(e);
    }
  }
}
