import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udp/udp.dart';

void main() => runApp(MyApp());

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
  UDP sender;
  UDP receiver;

  @override
  void initState() {
    data = '';
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
              CupertinoButton(
                  child: Text('开始发送'),
                  onPressed: () {
                    _startSend();
                  }),
              CupertinoButton(
                  child: Text('停止发送'),
                  onPressed: () {
                    _stopSend();
                  }),
              //CupertinoButton(child: Text('发送消息'), onPressed: () {}),
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Text(
                data,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                  child: Text('开始接收'),
                  onPressed: () {
                    _startReceive();
                  }),
              CupertinoButton(
                  child: Text('停止接收'),
                  onPressed: () {
                    _stopReceive();
                  }),
              //CupertinoButton(child: Text('发送消息'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  _startSend() async {
    sender = await UDP.bind(Endpoint.loopback(port: Port(54321)));
    var dataLength = await sender.send(
        "Hello World!".codeUnits, Endpoint.broadcast(port: Port(54321)));
    //stdout.write("$dataLength bytes sent.");
    setState(() {
      data = '发送成功\n字符长度为$dataLength\n${sender.local.port.toString()}';
    });
  }

  _stopSend() {
//    sender?.close();
//    setState(() {
//      data='';
//    });
    testSend();
  }

  _startReceive() async {
//    ServerSocket serverSocket =await ServerSocket.bind(InternetAddress.loopbackIPv4, 54321,shared: true);
//    setState(() {
//      data = '开始接收';
//    });
//    serverSocket.listen(dataHandler,onError: errorHandler,cancelOnError: false,onDone: (){
//      serverSocket.close();
//    });

    receiver = await UDP.bind(Endpoint.loopback(port: Port(54321)));
    await receiver.listen(
      (datagram) {
        var str = String.fromCharCodes(datagram.data);
        //stdout.write(str);
        setState(() {
          data = '接受响应成功\n$str';
        });
      },
      timeout: Duration(seconds: 20),
    );
  }

  _stopReceive() {
//    receiver?.close();
//    setState(() {
//      data='';
//    });

    textReceive();
  }

  void dataHandler(data) {
    setState(() {
      this.data = '接受UDP包\n$data';
    });
    print(String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void testSend() {
    var DESTINATION_ADDRESS = InternetAddress("255.255.255.255");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((e) {
        Datagram dg = udpSocket.receive();
        if (dg != null) {
          print("received ${String.fromCharCodes(dg.data)}");
          setState(() {
            this.data = '接收数据--${String.fromCharCodes(dg.data)}';
          });
        }
      });
      List<int> data = utf8.encode('TEST');
      udpSocket.send(data, DESTINATION_ADDRESS, 8889);
      setState(() {
        this.data = '发送数据--TEST';
      });
    });
  }

  void textReceive() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.listen((e) {
        Datagram dg = udpSocket.receive();
        if (dg != null) {
          print("received ${String.fromCharCodes(dg.data)}");
          print('ip${dg.address.address}');
          setState(() {
            this.data =
                '接收数据--${String.fromCharCodes(dg.data)}\nip${dg.address.address}\nport${dg.port}';
          });
        }
      });
    });
  }
}
