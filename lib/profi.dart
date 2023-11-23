import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/reg.dart';
import 'package:provider/vari.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dbpath.dart';
import 'main.dart';
import 'make_offer.dart';
import 'widgets/appbar_widget.dart';

import 'widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  var data;
  String url;
  List oyo;
  bool la;
  String? sumc;
  String? rankc;
  ProfilePage(this.data, this.url, this.oyo, this.la, this.sumc, this.rankc);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String sumc = '';
  String rankc = '';
  List<Job> myJobs = [];
  get() async {
    List<Job> job = await DBProvider.db.jobsList();
    for (var i in job) {
      if (i.id == widget.data[0]['job'] ||
          i.id == widget.data[0]['joba'] ||
          i.id == widget.data[0]['jobb'] ||
          i.id == widget.data[0]['jobc']) {
        setState(() {
          myJobs.add(i);
        });
      }
    }
  }

  File? picme;
  Future<void> changeOrNot() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(!widget.la
              ? "Do you want to change the picture?"
              : " هل تريد تغيير الصورة؟"),
          content: SingleChildScrollView(
            child: Center(
                child: Container(
              child: Image.file(
                picme!,
                fit: BoxFit.fill,
              ),
            )),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                !widget.la ? 'No' : "لا",
                style: TextStyle(color: Colors.pink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(!widget.la ? 'Yes' : "نعم",
                  style: TextStyle(color: Colors.teal)),
              onPressed: () async {
                var postImag = http.MultipartRequest('POST',
                    Uri.parse('${widget.url}/d/workers/photos/add_pic.php'));
                postImag.fields["name"] = '${widget.data[0]['phone']}';
                var pic = http.MultipartFile.fromPath("img", picme!.path)
                    .then((value) {
                  postImag.files.add(value);
                });
                try {
                  await postImag.send().then((value) async {
                    if (value.statusCode == 200) {
                      value.stream.transform(utf8.decoder).listen((value) {});

                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                    }
                  });
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    get();

    sumc = widget.sumc!;
    rankc = widget.rankc!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.la == false ? 'Profile' : 'حسابي'),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Center(child: buildUpgradeButton()),
          const SizedBox(height: 24),
          GestureDetector(
            onTap:()async{
              try {
                await ImagePicker()
                    .pickImage(source: ImageSource.gallery)
                    .then((v) async {
                  if (v != null) {
                    setState(() {
                      picme = File(v.path);
                    });
                    changeOrNot();
                  }
                });
              } catch (e) {
                print(e);
              }
            },
            child: ProfileWidget(
              imagePath:
                  '${widget.url}/d/workers/photos/${widget.data[0]['phone']}',
              onClicked: () async {
                
              },
            ),
          ),
          const SizedBox(height: 24),
          buildName(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildButton(
                  context, rankc, widget.la == false ? 'Ranking' : "تقييمي"),
              buildDivider(),
              buildButton(context, widget.oyo.length.toString(),
                  widget.la == false ? 'Jobs' : "أعمالي"),
              buildDivider(),
              buildButton(
                  context, sumc, widget.la == false ? 'Income' : "دخلي"),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              !widget.la ? 'My services' : 'خدماتي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
          ),
          Center(
              child: Container(
            height: 1,
            width: 200,
            color: Colors.grey,
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i in myJobs)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      !widget.la ? i.jobe! : i.job!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
              ],
            ),
          )

          // buildAbout(widget.data),
        ],
      ),
    );
  }

  Widget buildDivider() => Container(
        color: Colors.grey,
        height: 30,
        width: 1,
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget buildName() => Column(
        children: [
          Text(
            ///////
            widget.la == true
                ? '${widget.data[0]['name']}'
                : '${widget.data[0]['namee']}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            '+249${widget.data[0]['phone']}',
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => RatingBar.builder(
        ignoreGestures: true,
        initialRating: double.parse(rankc),
        minRating: 0,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, i) => Icon(
          Icons.star,
          color: Colors.pink[100 * i],
        ),
        onRatingUpdate: (rating) {
          print(rating);
        },
      );

  Widget buildAbout(user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'About',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16),
            // Text(
            //   '${widget.data[0]['img']}',
            //   style: TextStyle(fontSize: 16, height: 1.4),
            // ),
            TextField(
              onSubmitted: (c) {
                print(c);
              },
              maxLines: 3,
              maxLength: 140,
              cursorColor: Colors.amber,
              cursorWidth: .5,
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white, fontSize: 40),
                  labelText: widget.la == false ? 'About' : "عني",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  // filled: false,

                  hintStyle: TextStyle(color: Colors.grey[400]),
                  hintText: '${widget.data[0]['img']}',
                  fillColor: Colors.white70),
            ),
          ],
        ),
      );
}

class HistPage extends StatefulWidget {
  var oyo;
  String url;
  bool la;
  HistPage(this.oyo, this.url, this.la);

  @override
  _HistPageState createState() => _HistPageState();
}

class _HistPageState extends State<HistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.la ? 'طلباتي' : 'History'),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          for (var o in widget.oyo!)
            Card(
              color: Colors.grey.shade800,
              child: GestureDetector(
                child: ListTile(
                  trailing: Column(
                    children: [
                      Text(o['price'] != '0' ? '${o['price']} \$' : '',
                          style: TextStyle(color: Colors.white)),
                      Text(o['per'] != null ? '${o['per']} \$' : '',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  leading: Column(
                    children: [
                      Text(
                        '${o['id']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      o['status'] == '0'
                          ? Icon(
                              Icons.search,
                              color: Colors.cyanAccent,
                            )
                          : o['status'] == '1'
                              ? Icon(Icons.question_answer)
                              : o['status'] == '8'
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.lightGreenAccent,
                                    )
                                  : o['status'] == '2'
                                      ? Icon(
                                          Icons.warning,
                                          color: Colors.lightGreenAccent,
                                        )
                                      : o['status'] == '7'
                                          ? Icon(
                                              Icons.attach_money,
                                              color: Colors.lightGreenAccent,
                                            )
                                          : o['status'] == '6'
                                              ? CupertinoActivityIndicator(
                                                  radius: 15
                                                  // color: Colors.amber,
                                                  )
                                              : Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                ),
                    ],
                  ),

                  title: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: widget.la == true
                            ? '${o['type'] == null ? '' : o['type']}   '
                            : '${o['typee'] == null ? '' : o['typee']}   ',
                      ),
                      TextSpan(
                          text: '${o['date']}    ',
                          style: TextStyle(color: Colors.white)),
                      TextSpan(
                          text: ' ${o['time']}',
                          style: TextStyle(color: Colors.white)),
                    ],
                  )),

                  subtitle: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                          text: o['username'] == null
                              ? ' '
                              : '${o['username']}     ',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      TextSpan(
                          text: '${o['sta'] == null ? '' : o['sta']}   \n',
                          style: TextStyle(color: Colors.green[300])),
                      TextSpan(
                          text: ' ${o['fin'] == null ? '' : o['fin']}',
                          style:
                              TextStyle(color: Colors.red[300], fontSize: 20)),
                    ],
                  )),

                  // Text(o['workername'] ==
                  //         null
                  //     ? ''
                  //     : "${o['workername']}\n ${o['sta'] == null ? '' :
                  //      o['sta']}\n ${o['fin'] == null ? '' :
                  //       o['fin']} "),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PayMePage extends StatefulWidget {
  var data;
  String url;
  bool la;
  PayMePage(
    this.data,
    this.url,
    this.la,
  );

  @override
  _PayMePagePageState createState() => _PayMePagePageState();
}

class _PayMePagePageState extends State<PayMePage> {
  List mine = [];
  get_mine() async {
    var response =
        await http.get(Uri.parse("${widget.url}/d/users/get_all_of.php"));

    List<dynamic> i = jsonDecode(response.body);
    for (var o in i) {
      //
      if (o['worker_id'] == widget.data[0]['id']) {
        print(o);
        setState(() {
          mine.add(o);
        });
      }
    }
    if(mine.isEmpty){
       setState(() {
          oops=false;
        });
    }

  }






  Future<void> _showMyDialog(i) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
         
          actions: <Widget>[
            Center(
              child: TextButton(
                child:  Text(
                 !widget.la? 'Delete':"مسح",
                  style: TextStyle(color: Colors.pink),
                ),
                onPressed: () async{
                  await http.post(Uri.parse("${widget.url}/d/workers/delet_of.php"), body: {
            'id': i['id'],
          }).then((value) async{
             await http.post(Uri.parse("${widget.url}/d/workers/photos/delete_pro_pic.php"), body: {
            'ida': '${i['id']}aof',
            'idb': '${i['id']}bof',
            'idc': '${i['id']}cof',
            'idd': '${i['id']}dof',
          });
          setState(() {
          mine.remove(i);
          });
            Navigator.of(context).pop();
          });
                  
                },
              ),
            ),
         
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    get_mine();
  }
bool oops=true;
  @override
  Widget build(BuildContext context) {
    if (oops == false)
      return Scaffold(
         appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.speaker,
                size: 50,
              ),
              Text(!widget.la
                  ? 'You have not added offers'
                  : 'لم تقم بإضافة عروض')
            ],
          ),
        ),
      );
        if (mine.isEmpty && oops)
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator.adaptive(),
              Text(!widget.la
                  ? ' please wait'
                  : ' الرجاء الإنتظار')
            ],
          ),
        ),
      );
    
    return Scaffold(
      appBar: buildAppBar(context, !widget.la ? 'Offers' : " العروض"),
      body: ListView.builder(
          itemCount: mine.length,
          itemBuilder: (c, i) {
            return GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Add_pro(
                            url: widget.url,
                            id: widget.data[0]['id'],
                            data: widget.data[0],
                            item: mine[i],
                            la: widget.la,
                          )),
                  (Route<dynamic> route) => true,
                );
              },
              child: Card(
                child: ListTile(
                  leading: GestureDetector(
                    child: Icon(Icons.delete),
                    onTap:(){
                   _showMyDialog(mine[i]);
                  }),
                  trailing: Text('${mine[i]['price']} SDG'),
                  subtitle: Text(mine[i]['description']),
                  title: Text(mine[i]['name']),
                ),
              ),
            );
          }),
    );
  }
}

class ReportPage extends StatefulWidget {
  List oyo;
  bool la;
  ReportPage(this.oyo, this.la);

  @override
  _ReportPagePageState createState() => _ReportPagePageState();
}

class _ReportPagePageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, !widget.la ? 'Report' : "تقيماتي"),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          for (var o in widget.oyo)
            Card(
              child: ListTile(
                title: Text(o['fc'] != null ? o['fc'] : ''),
                trailing: Text(o['fr'] != null ? o['fr'] : ''),
              ),
            )
        ],
      ),
    );
  }
}

class OffersOrders extends StatefulWidget {
  var data;
  bool la;
  LocationData? _locationData;
  int blocked;
  OffersOrders(this.data, this.la, this._locationData,this.blocked);

  @override
  _OffersOrdersState createState() => _OffersOrdersState();
}

class _OffersOrdersState extends State<OffersOrders> {
  bool btn = true;
  show(of) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          var com = TextEditingController();
          var time = TextEditingController();
          var price = TextEditingController();
          List<String> dur = ['Hour', 'Day', 'Week', 'Month', 'Year'];
          List<String> durA = ['ساعة', 'يوم', 'إسبوع', 'شهر', 'سنة'];
          String? dura = !widget.la ? 'Hour' : 'ساعة';
          var a = LatLng(
              double.parse(of['userlate']), double.parse(of['userlonge']));
          var b =widget._locationData!=null? LatLng(
              widget._locationData!.latitude !,
              widget._locationData!.longitude !):LatLng(
              double.parse(of['userlate']), double.parse(of['userlonge']));
          var distance = calculateDistance(a, b);
          return StatefulBuilder(builder: (context, setState) {
         
            return Material(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  RingtonePlayer.stop();
                },
                child: Card(
                  color: Colors.blueGrey.shade900,
                  child: ListView(
                    children: [
                      Container(
                        color: Colors.amber,
                        child: Center(
                          child: Text(
                            !widget.la
                                ? 'Evaluate please'
                                : 'العميل يطلب التقييم',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Cairo',
                                color: Colors.blueGrey.shade900),
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        child: Card(
                          child: GoogleMap(
                            onMapCreated: (c) => (c),
                            // myLocationButtonEnabled: true,
                            // myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                                target: LatLng(double.parse(of['userlate']),
                                    double.parse(of['userlonge'])),
                                zoom: 14),
                            markers: {
                              Marker(
                                icon: BitmapDescriptor.defaultMarker,
                                markerId: MarkerId("Destination"),
                                position: LatLng(double.parse(of['userlate']),
                                    double.parse(of['userlonge'])),
                                infoWindow: InfoWindow(
                                  title: "${of['com']}",
                                ),
                              )
                            },
                            // polylines: polyLines,
                            // onTap: (LatLng o) => setMarkers(o),
                          ),
                        ),
                      ),
                      Visibility(visible: widget._locationData!=null,
                        child: Text(
                            '${distance.toStringAsFixed(1)}/${!!widget.la ? 'KM' : 'كم'}'),
                      ),
                      Center(
                        child: Text(
                          widget.la
                              ? 'تعليق \n${of['com']}'
                              : 'Comment :\n${of['com']}',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Cairo',
                              color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          !widget.la
                              ? '${of['date']} ${of['time']}'
                              : '${of['date']} ${of['time']}',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Cairo',
                              color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              child: TextField(
                                maxLength: 15,
                                controller: price,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    suffix: Text(widget.la ? 'ج.س' : 'SDG',
                                        style: TextStyle(color: Colors.white)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: widget.la ? 'السعر' : "Price",
                                    fillColor: Colors.black12),
                              ),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Container(
                              child: TextField(
                                controller: time,
                                maxLength: 1,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    suffix: PopupMenuButton(
                                      child: Text(
                                        dura!,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                      itemBuilder: (context) => [
                                        for (var t
                                            in widget.la == true ? durA : dur)
                                          PopupMenuItem(
                                            child: GestureDetector(
                                                onTap: () => setState(() {
                                                      dura = t;
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                                child: Text(t)),
                                          ),
                                      ],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: widget.la ? 'المدة' : "Time",
                                    fillColor: Colors.black12),
                              ),
                            ),
                            flex: 2,
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: com,
                        maxLength: 140,
                        keyboardType: TextInputType.multiline,
                        maxLengthEnforced: true,
                        minLines: 2,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          // border: InputBorder.,
                          labelText: widget.la
                              ? 'أكتب تعليق للعميل '
                              : 'Description for the customer',
                          prefixIcon: Icon(
                            Icons.comment,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: btn,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Visibility(
                              visible: btn,
                              child: Container(
                                  child: GestureDetector(
                                onTap: () async {
                                  RingtonePlayer.stop();
                                  if (price.text.isEmpty) {
                                    errono('Price please!', "السعر رجاء",
                                        widget.la);
                                  } else if (time.text.isEmpty || dura == '?') {
                                    errono('Time please !', "المدة رجاء",
                                        widget.la);
                                  } else {
                                    setState(() => btn = !btn);

                                    await http.post(
                                        Uri.parse("$url/d/workers/giveof.php"),
                                        body: {
                                          //////
                                          "oid": of['id'],
                                          "price":
                                              '${replaceFarsiNumber(price.text)}',
                                          "time":
                                              '${replaceFarsiNumber(time.text)}-$dura',
                                          "com": com.text,
                                          "wid": widget.data[0]['id'],
                                          "wname": widget.data[0]['name'],
                                          "wnamee": widget.data[0]['namee'],
                                          "wphone": widget.data[0]['phone'],
                                          "rank": '5.0',
                                        }).then((value) {
                                      print(value.body);
                                      setState(() => btn = !btn);
                                    });
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.teal),
                                  child: Center(
                                    child: Text(
                                      !widget.la ? 'OK' : 'قييم',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            Container(
                              height: 30,
                            ),
                            Visibility(
                              visible: btn,
                              child: Container(
                                  child: GestureDetector(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  RingtonePlayer.stop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.pink),
                                  child: Center(
                                    child: Text(
                                      widget.la == false
                                          ? 'No thanks'
                                          : ' رجوع',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !btn,
                        child: Container(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.la ? '${of['type']} ' : '${of['typee']} ',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Cairo',
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  List fllo = [];
  givOffers() async {
    try {
      await http.post(Uri.parse("$url/d/workers/wit.php"), body: {
        "id": widget.data[0]['job'],
        "ida": widget.data[0]['joba'],
        "idb": widget.data[0]['jobb'],
        "idc": widget.data[0]['jobc'],
      }).catchError((error) {
        givOffers();
      }).then((value) {
        // getWested();
        // ignore: unnecessary_statements
        value.body == '[]'
            ? setState(() {
                oops = false;
              })
            // ignore: unnecessary_statements
            : {
                for (var of in jsonDecode(value.body))
                  {
                    setState(() {
                      fllo.add(of);
                    })
                    // if (fllo!.contains(of['id']))
                    //   {setState(() => work = true), print('i did it')}
                    // else
                    //   {
                    //     if (blocked == 0 && _locationData != null)
                    //       {
                    //         if (Platform.isIOS)
                    //           {
                    //             showNotificationWithSubtitle([of], 0)
                    //           }
                    //         else
                    //           {
                    //             showNotification([of], 0)
                    //           },

                    //       }

                    //   }
                  }
              };
      });
    } catch (e) {
      print(e);
    }
  }

  bool oops = true;
  @override
  void initState() {
    if(widget.blocked==0){
      givOffers();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (oops == false)
      return Scaffold(
         appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 50,
              ),
              Text(!widget.la
                  ? 'No evaluation requests'
                  : ' لا يوجد طلبات تقييم')
            ],
          ),
        ),
      );
        if (fllo.isEmpty && oops)
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator.adaptive(),
              Text(!widget.la
                  ? ' please wait'
                  : ' الرجاء الإنتظار')
            ],
          ),
        ),
      );
    
    return Scaffold(
      
      appBar: buildAppBar(
          context, !widget.la ? 'Evaluation Requests' : "طلبات التقييم"),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          for (var o in fllo)
            Card(
              color: Colors.grey.shade800,
              child: GestureDetector(
                child: ListTile(
                  trailing: Column(
                    children: [
                      Text(o['price'] != '0' ? '${o['price']} \$' : '',
                          style: TextStyle(color: Colors.white)),
                      Text(o['per'] != null ? '${o['per']} \$' : '',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  leading: Column(
                    children: [
                      Text(
                        '${o['id']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.question_answer)
                    ],
                  ),
                  title: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: widget.la == true
                            ? '${o['type'] == null ? '' : o['type']}   '
                            : '${o['typee'] == null ? '' : o['typee']}   ',
                      ),
                      TextSpan(
                          text: '${o['date']}    ',
                          style: TextStyle(color: Colors.white)),
                      TextSpan(
                          text: ' ${o['time']}',
                          style: TextStyle(color: Colors.white)),
                    ],
                  )),
                  subtitle: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                          text: "${o['username']}  ",
                          style: TextStyle(
                            fontSize: 20,
                          )),
                    ],
                  )),
                ),
                onTap: () {
                if(widget.blocked==0){
                    show(o);

                }
                },
              ),
            ),
        ],
      ),
    );
  }
}
