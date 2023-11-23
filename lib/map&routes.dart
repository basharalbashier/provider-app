import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}

class Working extends StatefulWidget {
  bool value1;
  String url;
  String? palance;
  String? id;
  Working(
    this.value1,
    this.url,
    this.palance,
    this.id,
  );

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Working> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
        zoom: 15)));
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      location.onLocationChanged.listen((LocationData currentLocation) {
        if (mounted) {
          setState(() {
            moveCamera();
            storLocation(currentLocation);
          });
        }
      });
    });
  }

  Timer? _timer;
  void storLocation(LocationData i) async {
    if (widget.value1 == true) {
      // try {
      //   await http.post(Uri.parse('${widget.url}/d/workers/ad.php'), body: {
      //     "late": '${i.latitude}',
      //     "longe": '${i.longitude}',
      //     "id": '${widget.id}',
      //   }).then((value) {});

      //   setState(() {});
      // } catch (e) {}
    } else {
   

    }
  }

  @override
  void dispose() {
    _timer!.cancel();

    super.dispose();
  }

  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;
  void getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();

    // print(_locationData!.latitude);

    // print(markers.last);
    var _locationDataa;
    if (mounted) {
      setState(() {
        _locationDataa = _locationData;
      });
    }
    return _locationDataa;
  }

  var distance = Text('Polyline Demo');
  @override
  Widget build(BuildContext context) {
    if (_locationData == null)
      return Scaffold(
          body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade900,
          ],
        )),
        child: Center(
          child: Text(
            'آبشر',
            style: TextStyle(color: Colors.white, fontSize: 100),
          ),
        ),
      ));
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              // myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _locationData!.latitude!, _locationData!.longitude!),
                  zoom: 15),
              onTap: (LatLng o) {},
            ),
          ],
        ),
      ),
    );
  }
}
