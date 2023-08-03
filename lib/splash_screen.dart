import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectx/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    another();
     Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (BuildContext context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.bluetooth_disabled,
                    size: 200,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          } else {
            return Home();
          }
        },
      ),));
    },);
  }
  another() async{
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
    opacity = 1;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(seconds: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(image: AssetImage('assets/images/robot.png')),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const[
                    Text("Smart",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    Text(" Parking",style: TextStyle(fontSize: 22,color: Colors.blue,fontWeight: FontWeight.bold),),
                  ],
                )
              ],
            ),
          ),
        )),
    );
  }
}




//  0 45  90  135 180