library send_messagee;

import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:imageview360/imageview360.dart';
import 'package:projectx/myprovider/is_visible.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice? server;
  const ChatPage({
    Key? key,
    this.server,
    this.lcdMessage,
  }) : super(key: key);
  final String? lcdMessage;

  @override
  _ChatPageState createState() => _ChatPageState();
}

var hadi;

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {

  BluetoothConnection? connection;

  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  @override
  void initState() {
    super.initState();
  print("connection $connection");
  print("isConnecting $isConnecting");

    BluetoothConnection.toAddress(widget.server!.address).then((_connection) {
      connection = _connection;

      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    });
  }

  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
      mineController.close();
    }
    super.dispose();
  }

  bool btnColor = false;
  
  StreamController<String> mineController = StreamController<String>.broadcast();
  stopController () {
    mineController.close();
  }
  String incomingData = '';
  Stream<String> myStream() async* {
  CarIsVisible carIsVisible = Provider.of(context,listen: false);
    connection?.input?.listen((Uint8List data) {
      incomingData = ascii.decode(data);
      print('Reciveing : $incomingData');
      carIsVisible.setValue = incomingData;
      mineController.add(ascii.decode(data));
    });
  }

  Widget build(BuildContext context) {
    CarIsVisible carIsVisible = Provider.of(context,listen: false);
   List<ImageProvider> imageList = [];
    TextEditingController lcdController = TextEditingController();
    mineController.addStream(myStream());
    for (int i = 1; i <= 52; i++) {
      imageList.add(AssetImage('assets/images/$i.png'));
// To precache images so that when required they are loaded faster.
       precacheImage(AssetImage('assets/images/$i.png'), context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Parking'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const SizedBox(height: 40,),
            Consumer<CarIsVisible>(builder: (context, value, child) {
              if (carIsVisible.is_visible) {
                return ImageView360(
              key: UniqueKey(),                                           
              imageList: imageList,                                       
              autoRotate: false,                                          
              rotationCount: 1,                                           
              rotationDirection: RotationDirection.anticlockwise,         
              frameChangeDuration: const Duration(milliseconds: 50),      
              swipeSensitivity: 2,                                        
              allowSwipeToRotate: true,                                   
              onImageIndexChanged: (currentImageIndex) {                  
              var adding = currentImageIndex;
              if(adding == 10) {
                _sendMessage('A');
              }else if(adding == 40) {
                _sendMessage('B');
              }
            },
            );
              } else {
                return Image.asset('assets/images/shadow.png');
              }
            },),
            Consumer<CarIsVisible>(builder: (context, value, child) {
            if (carIsVisible.is_visible) {
              return Text("Car is Available",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 22,fontFamily: 'Sono'));
            } else {
              return Text("Car is Not Available",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 22,fontFamily: 'Sono'));
            }
              
            },),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async{
                          _sendMessage('A');
                          await Future.delayed(Duration(seconds: 3));
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/images/redoone.png'),)
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async{
                          _sendMessage('B');
                          await Future.delayed(Duration(seconds: 3));
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/images/undoone.png'),)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60,),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  _sendMessage(String text) async {
    text = text.trim();
    print('SEND : $text');

    if (text.length > 0) {
      try {
        // connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        print("This $e");
      }
    }
  }

  _receiveMessage() {
    connection!.input!.listen((Uint8List data) {
      print('Data incoming: ${ascii.decode(data)}');
      void deneme = ascii.decode(data);
      return deneme;
    });
  }
}

