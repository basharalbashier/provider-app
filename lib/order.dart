import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/dbpath.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'vari.dart';

class Linestring {
  Linestring(this.linestring);
  List<dynamic> linestring;
}

class OrderScreen extends StatefulWidget {
  LatLng userL;
  String url;
  String username;
  String userphone;
  String id;
  String oid;
  bool la;
  OrderScreen(this.userL, this.url, this.username, this.userphone, this.id,
      this.oid, this.la,
      {Key? key})
      : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {


  final Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  final List<LatLng> polypoints = [];
  final Set<Polyline> polylines = {};
  var data;
  bool btn = true;
  LatLng? latLng_2;
  LatLng? latLng_1;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _controller.complete(controller);
    final c = await _controller.future;
  }

  void addMarker(LatLng mLatLng, String mTitle, String mDescription) {
    _markers.length == 0
        ? _markers.add(Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(
                (mTitle + "_" + _markers.length.toString()).toString()),
            position: mLatLng,
            infoWindow: InfoWindow(
              title: mTitle,
              snippet: mDescription,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                // BitmapDescriptor.hueYellow
                BitmapDescriptor.hueRose),
          ))
        : _markers.add(Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(
                (mTitle + "_" + _markers.length.toString()).toString()),
            position: mLatLng,
            infoWindow: InfoWindow(
              title: mTitle,
              snippet: mDescription,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                // BitmapDescriptor.hueYellow
                BitmapDescriptor.hueCyan),
          ));
  }

  setpolylines() {
    Polyline polyline = Polyline(
      width: 3,
      polylineId: PolylineId("polyline"),
      color: Colors.pink,
      points: polypoints,
    );
    polylines.add(polyline);
    setState(() {});
  }

  void getjsondata(LatLng a, LatLng b) async {
    NetworkHelper network = NetworkHelper(
      startLat: a.latitude,
      startLng: a.longitude,
      endLat: b.latitude,
      endLng: b.longitude,
    );
    try {
      // getdata() returns a json decoded data
      data = await network.getData();
      // we can reach to our desired json data manually as following
      Linestring ls =
          Linestring(data['features'][0]['geometry']['coordinates']);
      for (int i = 0; i < ls.linestring.length; i++) {
        polypoints.add(LatLng(ls.linestring[i][1], ls.linestring[i][0]));
      }
      if (polypoints.length == ls.linestring.length) {
        setState(() {
          d = '${((double.parse('${data['features'][0]['properties']['summary']['distance']}') / 1000).toStringAsFixed(1))}/Km';
        });
        setpolylines();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  dynamic d = '';

  dynamic fi = Column(mainAxisAlignment: MainAxisAlignment.center,children: [
    Text('الرجاء الإنتظار حتى يوافق العميل بعرضك'),
    CircularProgressIndicator.adaptive()
  ],);
  int? done;
  int? canc;

  String? workerPic;
  Location location = new Location();

  Future<void> orderInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.la ? 'معلومات الطلب ' : 'Info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  widget.la
                      ? "الوقت والتاريخ"
                      : "Date and time",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  info[0]['date'],
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                Text(
                  info[0]['time'],
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                Text(
                  widget.la
                      ? "تعليق العميل"
                      : "Customer Comment",
                  style: TextStyle(color: Colors.grey),
                ),
                 Text(
                  info[0]['com'],
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                TextButton(
                  onPressed: () async {
        
                    try {
                      await launch("https://wa.me/+249923109551?text=''");
                    } catch (e) {}
                  },
                  child: Text(widget.la ? '  تواصل معنا' : 'Contact us it  !'),
                )
             
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(!widget.la ? 'OK' : 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  getLocation() async {
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
    if (mounted) {
      setState(() {
        latLng_1 = LatLng(_locationData.latitude!, _locationData.longitude!);
        latLng_2 = LatLng(widget.userL.latitude, widget.userL.longitude);
      });
      setState(() {});
    }

    return _locationData;
  }

  pay(json,i) {
    bool send;
    setState(() {
      done = 10;
      wt = 1;
      fi = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              color: Colors.teal,
              child: Center(
                  child: Text(widget.la ? 'رائع' : 'Nice',
                      style: TextStyle(fontSize: 24, color: Colors.white)))),
          Container(
            height: 5,
            color: Colors.grey,
          ),
          Text(widget.la
              ? 'تأكد من حصولك على تقييم الخدمة من قبل العميل '
              : 'Make sure you get service evaluation from the customer'),
          Text(widget.la
              ? 'التقييم العال يساعدك على إستقبال طلبات أكثر مستقبلا'
              : 'Higher rating helps you receive more requests in the future'),
          Text(widget.la
              ? 'إسحب    لتآكيد الدفع '
              : 'Drag the button below to confirm payment'),
          Container(
            height: 50,
          ),
          Visibility(
            visible: btn,
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoSwitch(value: false,

                  
                    onChanged: (send) async {
                      setState(() {
                        btn = !btn;
                      });
                      if (json[0]['per'] == null && i==0) {
                        var per = 5 *
                            double.parse(replaceFarsiNumber(json[0]['price'])) /
                            100;
                        try {
                          await http.post(
                              Uri.parse("${widget.url}/d/workers/pay.php"),
                              body: {
                                "id": widget.id,
                                "per": '$per',
                                "oid": json[0]['id'],
                              }).then((done) {
                            if (jsonDecode(done.body)[0] == "1") {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Chicking()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        } catch (e) {
                          setState(() {
                            btn = !btn;
                          });
                        }
                      } else if(json[0]['per'] != null && i==0) {
                        try {
                          await http.post(
                              Uri.parse("${widget.url}/d/workers/pay.php"),
                              body: {
                                "id": widget.id,
                                "per": json[0]['per'],
                                "oid": json[0]['id'],
                              }).then((done) {
                            if (jsonDecode(done.body)[0] == "1") {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Chicking()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        } catch (e) {
                          setState(() {
                            btn = !btn;
                          });
                        }
                      }else if( i==1) {
                        try {
                          await http.post(
                              Uri.parse("${widget.url}/d/workers/pay.php"),
                              body: {
                                "id": widget.id,
                                "per": '100',
                                "oid": json[0]['id'],
                              }).then((done) {
                            if (jsonDecode(done.body)[0] == "1") {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Chicking()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        } catch (e) {
                          setState(() {
                            btn = !btn;
                          });
                        }
                      }
                    },

          

                  ),
                 Text(i==0?widget.la?' تم دفع ج.س${json[0]['price']} ':'Paied ${json[0]['price']} SDG':widget.la?' تم الدفع ':'Paied ',
                              style: TextStyle(color: Colors.white, fontSize: 26))
               
                ],
              ),
            ),
          ),
          Visibility(
              visible: !btn,
              child: Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                    strokeWidth: 3,
                  ))),
        ],
      );
    });
  }
var error='';
var info;
  Timer? ch;
  checkS() async {
    addMarker(widget.userL, '', '');

    if (done != 3 && mounted) {
      try {
        await http.post(Uri.parse("${widget.url}/d/workers/offerc.php"), body: {
          "id": widget.oid,
        }).then((offerc) async {
          setState(() {
            info=jsonDecode(offerc.body);
          });
        
       
        
            if (jsonDecode(offerc.body)[0]['status']  == '6') {
              
  
                setState(() {
                  error=jsonDecode(offerc.body)[0]['status'];
                  fin = Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CupertinoSwitch(value: false,
                  
                  onChanged: (send) async {
                         print('object');
                         try {
                           await http.post(
                               Uri.parse("${widget.url}/d/workers/done.php"),
                               body: {
                                 "id": widget.oid,
                                 "fin":
                                     '${DateFormat("dd-MM-yyyy").format(DateTime.now())}  ${DateFormat.Hm().format(DateTime.now())}'
                               }).then((done) {
                             pay(jsonDecode(offerc.body),0);
                           });
                         } catch (e) {
                           print('object');
                           checkS();
                         }
                      },
                    
                    ),
                    Text(
                         widget.la
                             ? '  إسحب عند الإنتهاء'
                             : 'Slide to finish',
                         style: TextStyle(
                             color: Colors.amber,
                             fontWeight: FontWeight.w500,
                             fontSize: 17),
                         textAlign: TextAlign.right,
                      ),
                      ],
                    ),
                  );
                });

                if (mounted) {
                  setState(() {
                    fi = Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Text(
                            widget.la
                                ? ' قبل العميل بعرضك'
                                : 'Customer accepts your offer',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.la ? 'نوع الخدمة:' : 'Service type:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.withOpacity(.7),
                              ),
                            ),
                            Text(
                              ' ${jsonDecode(offerc.body)[0]['type']}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.la ? 'المدة:' : 'Duration:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.withOpacity(.7),
                              ),
                            ),
                            Text(
                              ' ${jsonDecode(offerc.body)[0]['dur']}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.la ? 'إبتداء من:' : 'Starting from:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.withOpacity(.7),
                              ),
                            ),
                            Text(
                              '${jsonDecode(offerc.body)[0]['sta']}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.la
                                  ? 'السعر المتفق عليه:'
                                  : 'Agreed price:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.withOpacity(.7),
                              ),
                            ),
                            Text(
                              ' ${jsonDecode(offerc.body)[0]['price']} SDG',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 5,
                        ),
                        Visibility(
                          visible: btn,
                          child: fin,
                        ),
                        Visibility(
                            visible: !btn,
                            child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                  strokeWidth: 3,
                                ))),
                      ],
                    );

                    done != 100 ? done = 10 : null;
                    wt = 1;
                  });
                }
              
            } else if (jsonDecode(offerc.body)[0]['status'] == "7") {
              pay(jsonDecode(offerc.body),0);
            }
            else if(jsonDecode(offerc.body)[0]['status'] == "5") {
              try {
                await http.post(Uri.parse("${widget.url}/d/workers/free.php"),
                    body: {
                      "wid": widget.id,
                    }).then((free) => {
                      if (jsonDecode(free.body)[0] == "1")
                        {
                          ch!.cancel(),
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Customer has canceled the order since offer!'))),
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Chicking()),
                            (Route<dynamic> route) => false,
                          )
                        }
                    });
              } catch (e) {
                checkS();
              }
            } else {
            
              if (mounted) {
                setState(() {
                  wt = 1;
                });
              }
            }

            if (jsonDecode(offerc.body)[0]['workername'] != null) {
              if (jsonDecode(offerc.body)[0]['workerlt'] != null) {
                polylines.clear();
                polypoints.clear();

                _markers.clear();
                latLng_1 = LatLng(
                    double.parse(jsonDecode(offerc.body)[0]['userlate']),
                    double.parse(jsonDecode(offerc.body)[0]['userlonge']));
                latLng_2 = LatLng(
                    double.parse(jsonDecode(offerc.body)[0]['workerlt']),
                    double.parse(jsonDecode(offerc.body)[0]['workerlg']));

                ///////////
                ///
                addMarker(
                    latLng_1!, jsonDecode(offerc.body)[0]['username'], '');
                addMarker(latLng_2!, jsonDecode(offerc.body)[0]['workername'],
                    jsonDecode(offerc.body)[0]['workernamee']);
                getjsondata(_markers.toList()[0].position,
                    _markers.toList()[1].position);
                Future.delayed(Duration(seconds: 1)).then((value) {
                  updateCameraLocation(latLng_1!, latLng_2!, mapController!);
                });
              }
            }
          
          
        });
      } catch (e) {
        checkS();
      }
    }else{
      print('olala');
    }
  }

  int? wt;
  var fin;

 
    
  @override
  void initState() {
    checkS();
    ch = Timer.periodic(Duration(minutes: 5), (Timer t) async {
      checkS();
          getLocation().whenComplete(() async {
      _locationData = await location.getLocation();
      try {
        await http.post(Uri.parse('${widget.url}/d/order/ad.php'), body: {
          "late": '${_locationData.latitude!}',
          "longe": '${_locationData.longitude!}',
          "id": widget.oid,
        });
      } catch (e) {}
    });
    });
    dura = widget.la == true ? durA[0] : dur[0];

    super.initState();
       if (done != 10) {
        mounted
            ? setState(() {
                canc = 0;
              })
            : null;
      }


    // location.onLocationChanged.listen((LocationData currentLocation) async {
    //   if (mounted) {
    //     setState(() {
    //       // targetLat = currentLocation.latitude!;
    //       // targetLong = currentLocation.longitude!;
    //     });
    //     await http.post(Uri.parse('${widget.url}/d/order/ad.php'), body: {
    //       "late": '${currentLocation.latitude!}',
    //       "longe": '${currentLocation.longitude!}',
    //       "id": widget.oid,
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    ch!.cancel();
    super.dispose();
  }

  String? dura = '?';
  double hiOfCont = 150;
  List<String> cancel = [
    ' is not answring !',
    'is way too far !',
    ' is not open to make a deal !',
  ];
  List<String> cancela = [
    ' العميل لا يستجيب  ',
    'العميل بعيد للغايه ',
    'العميل لم يتوصل معي لاتفاق ',
  ];
 
  List<String> dur = ['Hour', 'Day', 'Week', 'Month', 'Year'];
  List<String> durA = ['ساعة', 'يوم', 'إسبوع', 'شهر', 'سنة'];
  dynamic offer;
  @override
  Widget build(BuildContext context) {




    setState(() {
      offer = Visibility(
        visible: true,
        child: Container(
          height: 40,
          width: 200,
           child: Row(
             children: [
               CupertinoSwitch(value: false,
                  
                    onChanged: (send) async {
                    if(info!=null){
                        pay(info, 1);
                    }

          
                    }),
           Text(widget.la ? 'إسحب  عند الإنتهاء' : ' Slide when you finish',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.blueGrey.shade900)),
             ],
           ),
        ),
      );
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition:
                CameraPosition(target: widget.userL, zoom: 15),
            onMapCreated: _onMapCreated,
            markers: _markers,
            polylines: polylines,
            // onTap: (LatLng o) async {
            //   print(o.latitude);
            //   print(o.longitude);
            // },
          ),
          Visibility(
            visible: true,
            child: Positioned(
              top: 60,
              right: 0,
              width: MediaQuery.of(context).size.width,
              height: hiOfCont,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 2.5,
                      sigmaY:
                          2.5), //this determines the blur in the x and y directions best to keep to relitivly low numbers
                  child: GestureDetector(onTap: (){
                      RingtonePlayer.stop();
                  },
                    child: Container(child:  Column(
                    
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible:true,
                                child: Text(
                                  widget.la
                                      ? 'الرجاء الإتصال بالعميل للتحقق من الطلب'
                                      : 'Please contact the customer to verify the order',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: Colors.white),
                                ),
                              ),
                              Text(
                                '${widget.username}',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 19,
                                    color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  launch("tel://+249${widget.userphone}");
                                },
                                child: Text(
                                  '+249${widget.userphone}',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 26,
                                      color: Colors.white),
                                ),
                              ),
                              Visibility(
                                // done == 1 ? true : false
                                visible:true,
                                child: Container(child: offer),
                              ),
                            ],
                          ),
                      
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.cyan.withOpacity(0),
                            Colors.teal.withOpacity(
                                1), //This controls the darkness of the bar
                          ],
                          // stops: [0, 1], if you want to adjust the gradiet this is where you would do it
                        ),
                      ),
                  
                    
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              // done == 1 ? true : false
              visible: canc == 1,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var c in cancela)
                    TextButton(
                        onPressed: () async {

                   if(info!=null){
                        try {
                          await http.post(
                              Uri.parse("${widget.url}/d/workers/pay.php"),
                              body: {
                                "id": widget.id,
                                "per": '50',
                                "oid": info[0]['id'],
                              }).then((done) {
                            if (jsonDecode(done.body)[0] == "1") {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Chicking()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        } catch (e) {
                          setState(() {
                            btn = !btn;
                          });
                        }
                   }
                        },
                        child: Text(c,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 24,
                                color: Colors.red))),
                ],
              ))),
        
          // Positioned(
          //   bottom: 10,
          //   left: 30,
          //   // width: 400,
          //   // height: 150,
          //   child: Container(
          //       height: 50,
          //       width: 100,
          //       decoration: BoxDecoration(
          //         color: Colors.amber.shade200.withOpacity(.7),
          //         borderRadius: BorderRadius.circular(25),
          //       ),
          //       child: Row(
          //         children: [Icon(Icons.directions_walk_outlined), d],
          //       )),
          // ),
          Visibility(
            visible: done != 10 && done != 100,
            child: Positioned(
              top: 30,
              left: 50,
              // width: 400,
              // height: 150,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
               if(info!=null){
                  orderInfo();
               }
                  },
                  icon: Icon(Icons.info),
                ),
              ),
            ),
          ),
         
         

          Visibility(
            visible: canc == 0
                ? true
                : canc == 1
                    ? true
                    : false,
            child: Positioned(
              top: 30,
              left: 0,
              // width: 400,
              // height: 150,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    hiOfCont == 150
                        ? setState(() {
                            done = 0;
                            canc = 1;
                            hiOfCont = MediaQuery.of(context).size.height;
                          })
                        : setState(() {
                            canc = 0;
                            hiOfCont = 150;
                          });
                  },
                  icon: Icon(Icons.cancel),
                ),
              ),
            ),
          ),
          
         
          Visibility(
              visible: done == 10,
              child: Container(
                // height: 100,width: 100,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900.withOpacity(1.0),
                  borderRadius: BorderRadius.circular(0),
                  // gradient: LinearGradient(
                  //   begin: Alignment.bottomCenter,
                  //   end: Alignment.topCenter,
                  //   colors: [
                  //     Colors.cyan.withOpacity(0),
                  //     Colors.cyan.withOpacity(
                  //         1), //This controls the darkness of the bar
                  //   ],
                  //   // stops: [0, 1], if you want to adjust the gradiet this is where you would do it
                  // ),
                ),
                child: Center(
                  child: fi,
                ),
              )),
          Visibility(
            visible: done == 10
                ? true
                : done == 100
                    ? true
                    : false,
            child: Positioned(
              top: 30,
              left: 0,
              // width: 400,
              // height: 150,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    done == 10
                        ? setState(() {
                            done = 100;
                          })
                        : setState(() {
                            done = 10;
                          });
                  },
                  icon: Icon(Icons.hide_source),
                ),
              ),
            ),
          ),
       
          Visibility(
            visible: d != '',
            child: 
            Positioned(
              bottom: 30,
              left: 0,
              // width: 400,
              // height: 150,
              child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                      child: Text(
                    d != null ? '$d' : '',
                    style: TextStyle(
                        color: Colors.blueGrey.shade900, fontSize: 20),
                  ))),
            ),
         
          ),
        ],
      ),
    );
  }
}
