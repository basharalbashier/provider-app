import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:backdrop/backdrop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/dashboard.dart';
import 'package:provider/order.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import 'dbpath.dart';
import 'make_offer.dart';
import 'map&routes.dart';
import 'reg.dart';
import 'vari.dart';

  errono(a, e,la) {
    Fluttertoast.showToast(
        msg: !la ? a : e,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

 String? url = 'https://appshr.dynssl.com/appshr';
  Future<void> showNotificationWithSubtitle(jsonDecode, i) async {
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(subtitle: '${jsonDecode[0]['type'].toString()}');

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        int.parse(jsonDecode[0]['id']),
        i == 1 ? 'لديك طلب جديد' : 'لديك طلب تقييم',
        '${jsonDecode[0]['com']}',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> showNotification(jsonDecode, i) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        int.parse('${jsonDecode[0]['id']}'),
        i == 1 ? 'لديك طلب جديد' : 'لديك طلب تقييم',
        '${jsonDecode[0]['type']}',
        platformChannelSpecifics,
        payload: 'item x');
  }



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();
String? selectedNotificationPayload;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String initialRoute = Home.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = Home.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {
            didReceiveLocalNotificationSubject.add(
              ReceivedNotification(
                id: id,
                title: title,
                body: body,
                payload: payload,
              ),
            );
          });

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Cairo',
      brightness: Brightness.light,
      /* light theme settings */
    ),
    darkTheme: ThemeData(
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      /* dark theme settings */
    ),
    themeMode: ThemeMode.dark,
    /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */

    debugShowCheckedModeBanner: false,
    initialRoute: initialRoute,
    routes: <String, WidgetBuilder>{
      Home.routeName: (_) => Chicking(),
    },
  ));
}

class Chicking extends StatefulWidget {
  const Chicking({Key? key}) : super(key: key);

  @override
  _ChickingState createState() => _ChickingState();
}

//////fixes http error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _ChickingState extends State<Chicking> with SingleTickerProviderStateMixin {
  var me;
  info() {
    DBProvider.db.getMe().then((value) {
      //  print(value);
      value != 0 ? setState(() => {me = value[0]['phone']}) : null;
      Future.delayed(Duration(seconds: 2)).then((value) {
        if (me == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Vari()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home(me)),
            (Route<dynamic> route) => false,
          );
        }
      });
    });
  }

  @override
  void initState() {
    info();
       _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _playAnimation();
    super.initState();
  }
    @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
       AnimationController? _controller;
  Future<void> _playAnimation() async {
    try {
      await _controller!.forward().orCancel;
      await _controller!.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because it was disposed of
    }
  }
  @override
  Widget build(BuildContext context) {
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
        child: ScaleTransition(
                           scale: Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(
                  parent: _controller!, curve: Curves.easeInOutSine)),
          child: Text(
            'آبشر',
            style: TextStyle(color: Colors.white, fontSize: 100),
          ),
        ),
      ),
    ));
  }
}

class Home extends StatefulWidget {
  var me;
  Home(
    this.me, {
    Key? key,
  }) : super(key: key);
  static const String routeName = '/';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  bool value1 = false;
 
  String? id;
  String? name;
  String? namee;
  String? phone;
  String? palance;
  int? blocked;
  Timer? _timer;
  var data;
  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

//keep working

  back() async {
    if (Platform.isAndroid) {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Appshr provider",
        notificationText: "Waiting..",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      await FlutterBackground.hasPermissions;
      await FlutterBackground.initialize(androidConfig: androidConfig);
      await FlutterBackground.enableBackgroundExecution();
    }
  }

  var oyo;
  var myRow;
  bool btn = true;
  List? fllo = [];
  int dis = 0;
  List<Map<String, dynamic>> all_wested_orders = [];
  bool show_me_wested_bool = true;

  show_queued() {
    if (all_wested_orders.isNotEmpty && show_me_wested_bool == true) {
      setState(() {
        show_me_wested_bool = false;
      });

      Map<String, dynamic> o = all_wested_orders[0];

      if (Platform.isIOS) {
        showNotificationWithSubtitle([o], 1);
      } else {
        showNotification([o], 1);
      }
      orderDia([o]);
      all_wested_orders.remove(o);
    }
  }

  getWested() async {
    print('${myRow[0]['job']}--nhvnh---');
    try {
      await http
          .post(Uri.parse("$url/d/workers/check_wested.php"), body: {
            "id": myRow[0]['job'],
            "ida": myRow[0]['joba'],
            "idb": myRow[0]['jobb'],
            "idc": myRow[0]['jobc'],
          })
          .catchError((error) {})
          .then((vila) {
       

            List<dynamic> i = jsonDecode(vila.body);
            if (i.isEmpty) {
            } else {
              for (Map<String, dynamic> o in jsonDecode(vila.body)) {
                if (!fllo!.contains(o['id'])) {
                  all_wested_orders.add(o);
                  fllo!.add(o['id']);
                }
              }
              show_queued();
            }
          });
    } catch (e) {}
  }

  getData(me) async {
    setState(() {
      work = false;
    });
    if (url != null) {
      if (rankc == null) {
        try {
          var response = await http.post(
              Uri.parse("$url/d/workers/myorders.php"),
              body: {"userphone": me}).catchError((e) {});
          if (response.statusCode == 200) {
            // print(response.body);
            if (mounted) {
              setState(() {
                oyo = json.decode(response.body);
              });
              sumC();
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
    if (mounted) {
      setState(() {
        work = true;
      });
    }
  }

  bool work = true;
bool mesBool=true;
  howImi() async {
    getLocation();

    if (mounted) {
      if (widget.me != null) {
        setState(() {
          work = false;
        });
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            await http.post(Uri.parse("$url/d/workers/howimi.php"), body: {
              "phone": widget.me,
            }).then((howimi) async {
              if (howimi.statusCode == 200) {
              

                if (howimi.body != "[]") {
                  if (mounted) {
                    setState(() {
                      myRow = jsonDecode(howimi.body);
                      id = jsonDecode(howimi.body)[0]['id'];
                      name = jsonDecode(howimi.body)[0]['name'];
                      namee = jsonDecode(howimi.body)[0]['namee'];
                      phone = jsonDecode(howimi.body)[0]['phone'];
                      palance = jsonDecode(howimi.body)[0]['palance'];
                      blocked =
                          int.parse(jsonDecode(howimi.body)[0]['blocked']);
                    });
                    // if(value1){
                    //   getWested();
                    // }

                  }
                  if(jsonDecode(howimi.body)[0]['mes']!='.'&&mesBool){
                   showOuermes(jsonDecode(howimi.body)[0]['mes']);
                    setState(() {
                      mesBool=false;
                    });
                  }
                  if (rankc == null) {
                    getData(widget.me);
                  }
                  if (mounted) {
                    setState(() {
                      data = jsonDecode(howimi.body);
                      mes = la
                          ? 'I am :${data[0]['namee']}\n  my phone number is:${data[0]['phone']} \n   please top-up my palance with value in the payment notification'
                          : 'أنا:${data[0]['name']}\n رقم هاتفي:${data[0]['phone']}\n الرجاء تعبئة رصيدي بالقيمة المرفقة في إشعار الدفع ';
                    });
                  }
                  if (jsonDecode(howimi.body)[0]['online'] == "1") {
                    setState(() {
                      value1 = true;
                      work = true;
                    });
                  }
                  if (jsonDecode(howimi.body)[0]['blocked'] == "1") {
                    setState(() {
                      value1 = false;
                    });
                  }
                  if (jsonDecode(howimi.body)[0]['online'] == "1" &&
                      int.parse(jsonDecode(howimi.body)[0]['palance']) >= 0) {
                    if (jsonDecode(howimi.body)[0]['orderw'] != "0") {
                      setState(() {
                        work = false;
                      });
                      await http.post(Uri.parse("$url/d/workers/orderinfo.php"),
                          body: {
                            "id": jsonDecode(howimi.body)[0]['orderw'],
                          }).catchError((error) {
                        // handle error here
                      }).then((orderinfo) {
                        if (jsonDecode(howimi.body)[0]['inorder'] != "0") {
                          var userL = LatLng(
                              double.parse(
                                  jsonDecode(orderinfo.body)[0]['userlate']),
                              double.parse(
                                  jsonDecode(orderinfo.body)[0]['userlonge']));
                          RingtonePlayer.play(
                              android: Android.notification,
                              ios: Ios.glass,
                              volume: 5,
                              loop: true);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderScreen(
                                    userL,
                                    url!,
                                    jsonDecode(orderinfo.body)[0]['username'],
                                    jsonDecode(orderinfo.body)[0]['userphone'],
                                    id!,
                                    jsonDecode(orderinfo.body)[0]['id'],
                                    la)),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          if (Platform.isIOS) {
                            showNotificationWithSubtitle(
                                jsonDecode(orderinfo.body), 1);
                          } else {
                            showNotification(jsonDecode(orderinfo.body), 1);
                          }

                          // if (fllo!.contains(
                          //         jsonDecode(orderinfo.body)[0]['id']) ==
                          //     false) {
                          //   fllo!.add(jsonDecode(orderinfo.body)[0]['id']);
                          if (blocked == 0) {
                            List<dynamic> i = jsonDecode(orderinfo.body);
                            orderDia(i);
                            getWested();

                            // }
                          }
                        }
                      });
                    } else {
                      if (value1 && blocked == 0) {
                        getWested();
                    
                      }
                    }
                  }
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Apply(widget.me, url!)),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            });
          } else {
            if (mounted) {
              setState(() {
                work = false;
              });
            }
          errono( "أنت غير متصل بالإنترنت ، فعل البيانات  ", 'You are not connected to the internet,Swich on data ', la) ;
                  
               
           
                  setState(() {
                    work = true;
                  });
                  howImi();
            
          }
        } catch (e) {}

//912228763

      }
    }
  }

  Future<void> showOuermes(i) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(la ? ' رسالة ' : 'Message'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
         
           
             
                
               
                 Text(i
                  ,
                  style: TextStyle( fontSize: 30),
                ),
                TextButton(
                  onPressed: () async {
        
                    try {
                      await launch("https://wa.me/+249923109551?text=''");
                    } catch (e) {}
                  },
                  child: Text(la ? '  تواصل معنا' : 'Contact us it  !'),
                )
             
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(la ? 'OK' : 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  String? sumc;
  String? rankc;
  sumC() async {
    var sum = 0;
    var rank = 0.0;
    var k = [];
    for (var i = 0; i < oyo.length; i++) {
      sum += int.parse(oyo[i]['price']);
      if (oyo[i]['fr'] != null && oyo[i]['fr'] != "") {
        rank += double.parse(oyo[i]['fr']);
        k.add(i);
      }
    }
    setState(() {
      sumc = '${(sum / oyo.length).toStringAsFixed(1)}';
      rankc = '${(rank / oyo.length).toStringAsFixed(1)}';
    });
    // try {
    //   await http.post(Uri.parse("$url/d/workers/rank.php"), body: {
    //     "id": data[0]['id'],
    //     "rank": rankc,
    //   }).then((value) {
    //     print(value.body);
    //   });
    // } catch (e) {}
  }

  bool la = true;
  bool show = true;
  Timer? _timerr;
  final Set<Marker> markers = {};
  orderDia(orderData) {
    int _start = 10;
    var distance;
    if (_locationData != null) {
      var a = LatLng(double.parse(orderData[0]['userlate']),
          double.parse(orderData[0]['userlonge']));
      var b = LatLng(_locationData!.latitude!, _locationData!.longitude!);
      distance = calculateDistance(a, b);
      print(distance);
    }
    RingtonePlayer.play(
        android: Android.notification,
        ios: const IosSound(1023),
        volume: 5,
        loop: true);
    if (rangString == '∞' || distance <= double.parse(rangString)) {
      showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              const oneSec = const Duration(seconds: 1);
              _timerr = Timer.periodic(
                oneSec,
                (Timer timer) {
                  if (_start == 0) {
                    if (mounted) {
                      _timerr!.cancel();
                      timer.cancel();
                      show = true;

                      RingtonePlayer.stop();
                    }
                  } else if (_start > 0) {
                    if (mounted) {
                      setState(() {
                        _start--;
                        show = false;
                      });
                    }
                  }
                },
              );
              return Material(
                child: Card(
                    color: Colors.white,
                    child: ListView(
                      children: [
                        Container(
                          width: 300,
                          color: Colors.pink,
                          child: Center(
                            child: Text(
                              la == true ? 'طلب جديد' : 'New Order',
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            child: Stack(fit: StackFit.expand, children: [
                              CircularProgressIndicator(
                                color: Colors.pink,
                                strokeWidth: 20,
                                value: _start.floorToDouble() / 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                      child: Visibility(
                                    visible: _start != 0,
                                    child: Text(
                                      '$_start',
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.blueGrey.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                                  Card(
                                    color: Colors.white,
                                    child: TextButton(
                                        onPressed: () async {
                                          _timerr!.cancel();
                                          RingtonePlayer.stop();
                                          try {
                                            await http.post(
                                                Uri.parse(
                                                    "$url/d/workers/approve.php"),
                                                body: {
                                                  //////
                                                  "id": orderData[0]['id'],
                                                  "name": name,
                                                  "phone": phone,
                                                  "wid": id,
                                                  "rank": rankc,
                                                }).then((value) {
                                              print(jsonDecode(value.body));
                                              if (jsonDecode(value.body) ==
                                                  "1") {
                                                _timerr!.cancel();
                                                var userL = LatLng(
                                                    double.parse(orderData[0]
                                                        ['userlate']),
                                                    double.parse(orderData[0]
                                                        ['userlonge']));
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderScreen(
                                                              userL,
                                                              url!,
                                                              orderData[0]
                                                                  ['username'],
                                                              orderData[0]
                                                                  ['userphone'],
                                                              id!,
                                                              orderData[0]
                                                                  ['id'],
                                                              la)),
                                                  (Route<dynamic> route) =>
                                                      false,
                                                );
                                              } else {
                                                print('else');
                                                errono(
                                                  'Some one else got the order ',
                                                  "تأخرت ، آحدهم أخذ الطلب",la
                                                );
                                                Navigator.of(context).pop();
                                              }
                                            });
                                          } catch (e) {}
                                        },
                                        child: Text(
                                          la == true ? 'قبول' : 'Accept',
                                          style: TextStyle(
                                              fontSize: 24, color: Colors.teal),
                                        )),
                                  )
                                ],
                              )
                            ]),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,
                            child: Text(
                              la == true
                                  ? '${orderData[0]['username']} بحاجه ل${orderData[0]['type']}'
                                  : '${orderData[0]['username']} Needs ${orderData[0]['typee']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blueGrey.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 200,
                          child: GoogleMap(
                            onMapCreated: (c) => (c),
                            // myLocationButtonEnabled: true,
                            // myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    double.parse(orderData[0]['userlate']),
                                    double.parse(orderData[0]['userlonge'])),
                                zoom: 15),
                            markers: {
                              Marker(
                                icon: BitmapDescriptor.defaultMarker,
                                markerId: MarkerId("Destination"),
                                position: LatLng(
                                    double.parse(orderData[0]['userlate']),
                                    double.parse(orderData[0]['userlonge'])),
                                infoWindow: InfoWindow(
                                  title: "${orderData[0]['userlonge']}",
                                ),
                              )
                            },
                            // polylines: polyLines,
                            // onTap: (LatLng o) => setMarkers(o),
                          ),
                        ),
                        //
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Text(
                                  distance != null
                                      ? '${distance.toStringAsFixed(1)}/${!la ? 'KM' : 'كم'}'
                                      : '',
                                  style: TextStyle(
                                      color: Colors.blueGrey.shade900),
                                ))),

                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,
                            child: Text(
                              ' ${orderData[0]['com']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Card(
                              color: Colors.white,
                              child: TextButton(
                                  onPressed: () async {
                                    RingtonePlayer.stop();
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _timerr!.cancel();
                                      show_me_wested_bool = true;
                                      show_queued();
                                    });
                                  },
                                  child: Text(
                                      la == true
                                          ? _start != 0
                                              ? 'رفض'
                                              : 'رجوع'
                                          : _start != 0
                                              ? 'Reject'
                                              : 'Back',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.pink))),
                            ),
                          ],
                        ),
                      ],
                    )),
              );
            });
          });
    } else {
      errono(
        'Order out of your range',
        'طلب خارج نطاقك',la
      );
    }
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

  Future<void> fill_palance() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(la ? 'إضافة رصيد' : 'Top-up!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  la
                      ? "١- قم بتحويل قيمة التعبئة المرغوب إضافتها في رقم الحساب ادناه بنكك  ورقم الهاتف ٩٢٣١٠٩٥٥١"
                      : "1-Transfer the recharge value to be added to the account number.",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '1410502',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                Text(
                  la
                      ? "٢-قم بإرسال إشعار الدفع و رقم هاتفك على الواتسآب في الرقم آدناه"
                      : "2- Send the payment notification and the phone number on WhatsApp at the number below",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () async {
                    var mas = !la
                        ? 'I am :${data[0]['namee']}\n  my phone number is:${data[0]['phone']} \n   Please inquire about the reason for the suspension'
                        : 'أنا:${data[0]['name']}\n رقم هاتفي:${data[0]['phone']}\n الرجاء الإستعلام عن سبب الإيقاف';
                    try {
                      await launch("https://wa.me/+249923109551?text=$mas");
                    } catch (e) {}
                  },
                  child: Text(la ? 'أرسل الإشعار هنا' : 'Send it here !'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(!la ? 'OK' : 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> blockedAndUnonline() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(la ? 'نأسف' : 'Oops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(la
                    ? 'أنت غير قادر على إستقبال الطلبات'
                    : 'You are unable to receive orders'),
                Text(la
                    ? "قد تكون موقف لعدم إستكمال التسجيل"
                    : "You may be suspended to not complete the registration"),
                TextButton(
                  onPressed: () async {
                    var mas = !la
                        ? 'I am :${data[0]['namee']}\n  my phone number is:${data[0]['phone']} \n   Please inquire about the reason for the suspension'
                        : 'أنا:${data[0]['name']}\n رقم هاتفي:${data[0]['phone']}\n الرجاء الإستعلام عن سبب الإيقاف';
                    try {
                      await launch("https://wa.me/+249923109551?text=$mas");
                    } catch (e) {}
                  },
                  child: Text(la ? 'تواصل معنا' : 'Contact with us please !'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(!la ? 'OK' : 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List rang = ['5', '10', '20', '∞'];
  String rangString = '∞';
  Widget pop() {
    return PopupMenuButton(
      child: Center(
          child: Text(
        '$rangString/KM',
        style: TextStyle(color: Colors.blueGrey.shade900),
      )),
      itemBuilder: (context) {
        return List.generate(rang.length, (index) {
          return PopupMenuItem(
            child: GestureDetector(
              child: Text('${rang[index]}/KM'),
              onTap: () => setState(() {
                rangString = rang[index];
                Navigator.of(context).pop();
              }),
            ),
          );
        });
      },
    );
  }

  String? mes;
  @override
  void initState() {
    getLocation();
    howImi();
    _requestPermissions();
    Wakelock.enable();

    super.initState();

    back();

    if (mounted) {
      _timer = Timer.periodic(
          Duration(seconds: 300), (Timer t) => work ? howImi() : null);
    }
  }

  @override
  void dispose() {
    _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    if (name == null) {
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
    }
    return Scaffold(
      body: Stack(
        children: [
          BackdropScaffold(
              appBar: BackdropAppBar(
                backgroundColor: Colors.grey.shade900,
                title: Text(
                  name == null
                      ? ''
                      : la == true
                          ? name!
                          : namee!,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                actions: <Widget>[
                  Visibility(
                    visible: blocked == 0,
                    child: Visibility(
                      visible: palance == null
                          ? false
                          : double.parse(palance!) >= 0.1
                              ? true
                              : false,
                      child: CupertinoSwitch(
                          activeColor: Colors.tealAccent,
                          value: value1,
                          onChanged: (value2) async {
                            if (mounted) {
                              if (value1 == false) {
                                try {
                                  await http.post(
                                      Uri.parse("$url/d/workers/online.php"),
                                      body: {
                                        "id": id,
                                      }).then((value) {
                                    if (jsonDecode(value.body) == "1") {
                                      setState(() {
                                        value1 = value2;
                                        work = true;
                                      });
                                      getWested();
                                    } else {
                                      print(value.body);
                                    }
                                  });
                                } catch (e) {
                                  errono('تآكد من إتصالك بالإنترنت',
                                      'Oops! Make sure you are connected to the internet',la);
                                }
                              } else {
                                try {
                                  var url0 = "$url/d/workers/unonline.php";

                                  await http.post(Uri.parse(url0), body: {
                                    "id": id,
                                  }).then((value) {
                                    if (jsonDecode(value.body) == "1") {
                                      setState(() {
                                        value1 = value2;
                                        RingtonePlayer.stop();
                                      });
                                    } else {
                                      print(value);
                                    }
                                  });
                                } catch (e) {
                                  errono('تآكد من إتصالك بالإنترنت',
                                      'Oops! Make sure you are connected to the internet',la);
                                }
                              }
                            }
                          }),
                    ),
                  ),
                  Visibility(
                    visible: blocked == 1,
                    child: IconButton(
                      icon: Icon(
                        Icons.error,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        blockedAndUnonline();
                      },
                    ),
                  )

                  //  ,Text(name==null?'':'${palance} SDG'),
                ],
              ),
              backLayer: DashboardScreen(
                  data, url!, oyo != null ? oyo : [], la, sumc, rankc,_locationData,blocked!),
              frontLayer: Working(value1, url!, palance, id)),
          Positioned(
              left: 20,
              bottom: 20,
              child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: palance != null
                        ? double.parse(palance!) >= 0.1
                            ? Colors.blueGrey.shade900
                            : Colors.red.withOpacity(0.7)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        fill_palance();
                      },
                      child: Text(
                        palance == null ? '' : '$palance SDG',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ))),
          Positioned(
              left: 10,
              bottom: 50,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    la = !la;
                  });
                },
                child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: la ? Colors.pink : Colors.amber,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(la == true ? 'A' : 'ع',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                    )),
              )),
          Positioned(
              left: 70,
              bottom: 50,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      la = !la;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: pop(),
                    ),
                  ))),
          Positioned(
              left: 130,
              bottom: 50,
              child: GestureDetector(
                onTap: () {
                  if (blocked == 0 && int.parse(palance!)>1) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Add_pro(
                                url: url,
                                id: data[0]['id'],
                                data: data[0],
                                item: 0,
                                la: la,
                              )),
                      (Route<dynamic> route) => true,
                    );
                  } else {
                    blockedAndUnonline();
                  }
                },
                child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Icon(Icons.edit),
                    )),
              ))
        ],
      ),
    );
  }
}
