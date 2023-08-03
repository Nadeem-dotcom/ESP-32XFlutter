

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectx/devices.dart';


class SelectBondedDevicePage extends StatefulWidget {
  final bool? checkAvailability;
  final Function? onCahtPage;

  SelectBondedDevicePage(
      {this.checkAvailability = true, required this.onCahtPage});

  @override
  _SelectBondedDevicePageState createState() => _SelectBondedDevicePageState();
}

enum _DeviceAvailability {
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  final BluetoothDevice? device;
  final _DeviceAvailability? availability;
  final int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi])
      : super(address: "");
}

class _SelectBondedDevicePageState extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];

  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool? _isDiscovering;

  @override
  void initState() {
    super.initState();
    _isDiscovering = widget.checkAvailability!;
    if (_isDiscovering!) {
      _startDiscovery();
    }
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                  device,
                  widget.checkAvailability!
                      ? _DeviceAvailability.maybe
                      : _DeviceAvailability.yes),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription!.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  void dispose() {
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map(
          (_device) => BluetoothDeviceListEntry(
            device: _device.device,
            // rssi: _device.rssi,
            // enabled: _device.availability == _DeviceAvailability.yes,
            onTap: () {
              widget.onCahtPage!(_device.device);
            },
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
        centerTitle: true,
        leading: IconButton(onPressed: () {
          showDialog(context: context, builder: (context) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Developed by Nadeem Ahmed',style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Sono')),
                    Text('Email: nadeemahmed52401@gmail.com',style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Sono')),
                    Text('Phone No: 0304-8766511',style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Sono')),
                  ],
                ),
              ),
            )
          )  ;
          },);
        }, icon: Icon(Icons.info_outline)),
      ),
      body: ListView(
      children: list,
    ),
    );
  }
}