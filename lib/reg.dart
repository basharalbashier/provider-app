import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ima;
import 'package:provider/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dbpath.dart';

class Apply extends StatefulWidget {
  var me;
  String url;
  Apply(this.me, this.url);
  @override
  _ApplyState createState() => _ApplyState();
}

class _ApplyState extends State<Apply> with TickerProviderStateMixin {
  bool _status = false;
  final FocusNode myFocusNode = FocusNode();

  TextEditingController name = TextEditingController();
  TextEditingController namee = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController id = TextEditingController();
  File? picme;
  File? idPic;
  TextEditingController joba = TextEditingController();
  TextEditingController jobb = TextEditingController();
  TextEditingController jobc = TextEditingController();
  TextEditingController job = TextEditingController();
  // TextEditingController loc_long = TextEditingController();
  bool la = true;
  bool val = true;
  bool inVal = false;

  errono(a, e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
      children: [
        Icon(
          Icons.error,
          color: Colors.pink,
        ),
        Container(
          width: 20,
          height: 12,
        ),
        Text(
          !la ? a : e,
          style: TextStyle(fontFamily: 'Cairo'),
        )
      ],
    )));
  }

  intro() {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Material(
              child: ListView(
                children: [
                  Card(
                      color: Colors.blueGrey.shade900,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: la
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                              color: Colors.pink,
                              child: Center(
                                  child: Text(la ? 'تنبيه' : 'Attention',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.white)))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Text(la ? 'A' : 'ع'),
                                onTap: () => setState(() => la = !la),
                              ),
                              Text(la
                                  ? 'لتجنب الحظر والعقوبات'
                                  : 'To avoid bans and penalties'),
                              Container()
                            ],
                          ),
                          Container(
                            height: 5,
                            color: Colors.grey,
                          ),
                          Text(la
                              ? '  ١-تأكد من مقدرتك على تآدية الخدمة قبل قبول الطلب  '
                              : '1-Make sure you are able to perform the service before accepting the request'),
                          Text(la
                              ? '  ٢-تأكد من مقدرتك على الوصول لموقع العميل قبل قبول الطلب  '
                              : '2-Make sure you can reach the customer\'s location before accepting the order'),
                          Text(
                            la
                                ? "٣-عدم الإلتزام بالإتفاق مع العميل أو أي تصرف غير لائق يعرضك لعقوبات متعددة تصل لوقف حسابك ،الرجاء التعامل بإحترافية "
                                : "3-Failure to comply with the agreement with the customer or any inappropriate behavior will expose you to multiple penalties, up to the suspension of your account.",
                          ),
                          Container(
                              color: Colors.teal,
                              child: Center(
                                  child: Text(
                                      la ? ' أنواع الطلبات ' : 'Request types',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.white)))),
                          Text(la
                              ? "١ـ طلب عاجل :    يطلب فيه العميل المساعدة فورا"
                              : '1- Urgent request: the customer requests help immediately.'),
                          Container(
                            width: 400,
                            child: Text(la
                                ? "٢- طلب تقييم:  يطلب فيه العميل تقييم مدة وتكلفة الخدمة آولا  ويمكنك إضافة تعليق إن رغبت، وفي حالة قبول العميل بعرضك تبدأ الخدمة"
                                : '2- Evaluation request: in which the customer requests an evaluation of the duration and cost of the service first, and you can add a comment if you wish, and if the customer accepts your offer, the service begins.'),
                          ),
                          Text(la
                              ? 'الرجاء الإنتباه للتعليق المرفق مع الطلب إن وجد'
                              : 'Please pay attention to the comment attached to the order, if any'),
                          Container(
                            height: 5,
                            color: Colors.grey,
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Text(la
                                    ? ' الرجاء إرسال أي وثائق متعلقة بالخدمات التي تقدمها علي رقم أدناه لتفعيل حسابك  '
                                    : 'Please send any documents related to the services you provide to the number below'),
                                Text(
                                  "+249923109551",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 100,
                                ),
                              ],
                            ),
                            onTap: () async {
                              try {
                                await launch("https://wa.me/+249923109551?");
                              } catch (e) {}
                            },
                          ),
                          Card(
                            color: Colors.white,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Chicking()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Center(
                                  child: Text(la == true ? 'موافق' : 'OK',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.teal)),
                                )),
                          ),
                        ],
                      )),
                ],
              ),
            );
          });
        });
  }

  @override
  void initState() {
    DBProvider.db.get(widget.url).then((value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.grey.shade800,
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 250.0,
                color: Colors.grey.shade800,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 0.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: new Text(
                                  la == false
                                      ? 'Parsonal Information'
                                      : 'البيانات الشخصية',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.white)),
                            ),
                            _getEditIcon()
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        Row(
                          children: [Container()],
                        ),
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                                child: picme == null
                                    ? Center(
                                        child: Text(la == false
                                            ? 'Your Image'
                                            : 'أدخل صورتك الشخصية'))
                                    : Image.file(
                                        picme!,
                                        fit: BoxFit.fill,
                                      ),
                                width: 140.0,
                                height: 140.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                )),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 90.0, right: 100.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  radius: 25.0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      try {
                                        await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 100,
                                                maxHeight: 1000,
                                                maxWidth: 1000)
                                            .then((v) async {
                                          final bytes = (await v!.readAsBytes())
                                              .lengthInBytes;
                                          final kb = bytes / 1024;
                                          final mb = kb / 1024;
                                          if (v != null && mb < 1.0) {
                                            setState(() {
                                              picme = File(v.path);
                                            });
                                          } else {
                                            errono("  حجم الصورة كبير جدا",
                                                'The image is too big');
                                          }
                                        });
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ]),
                    )
                  ],
                ),
              ),
              new Container(
                color: Colors.grey.shade800,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 10.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    la == false ? 'Name' : "الإسم",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextField(
                                  decoration: InputDecoration(
                                    hintText: la == false
                                        ? "Enter Your Name"
                                        : "أدخل الإسم",
                                  ),
                                  enabled: !_status,
                                  autofocus: !_status,
                                  controller: name,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    la == false
                                        ? 'Name in Arabic'
                                        : "  الإسم باللغة الإنجليزية",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextField(
                                  decoration: InputDecoration(
                                    hintText: la == false
                                        ? "Enter Your Name in Arabic"
                                        : " أدخل الإسم باللغة الإنجليزية",
                                  ),
                                  enabled: !_status,
                                  autofocus: !_status,
                                  controller: namee,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    la == false
                                        ? 'Another Mobile'
                                        : "رقم هاتف آخر",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextField(
                                  decoration: InputDecoration(
                                      hintText: la == false
                                          ? "Enter Another Mobile Number without (0)"
                                          : " (0)أدخل رقم هاتف شخص يمكن الرجوع له، بدون "),
                                  enabled: !_status,
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 9,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: GestureDetector(
                                    onTap: () => jobs(job, 0),
                                    child: Text(
                                      job.text.isEmpty
                                          ? la == false
                                              ? 'First Service'
                                              : "الخدمة الاولى"
                                          : job.text,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: GestureDetector(
                                    onTap: () => jobs(joba, 1),
                                    child: Text(
                                      joba.text.isEmpty
                                          ? la == false
                                              ? '2nd Service'
                                              : "الخدمة الثانية"
                                          : joba.text,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: GestureDetector(
                                    onTap: () => jobs(jobb, 2),
                                    child: new Text(
                                      jobb.text.isEmpty
                                          ? la == false
                                              ? '3rd Service'
                                              : "الخدمة الثالثة"
                                          : jobb.text,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: GestureDetector(
                                    onTap: () => jobs(jobc, 3),
                                    child: Text(
                                      jobc.text.isEmpty
                                          ? la == false
                                              ? '4th Service'
                                              : "الخدمة الرابعة"
                                          : jobc.text,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                      // Padding(
                      //     padding: EdgeInsets.only(
                      //         left: 25.0, right: 25.0, top: 25.0),
                      //     child: new Row(
                      //       mainAxisSize: MainAxisSize.max,
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: <Widget>[
                      //         Expanded(
                      //           child: Container(
                      //             child: new Text(
                      //               la == false
                      //                   ? 'Your Id Number'
                      //                   : "الرقم الوطني",
                      //               style: TextStyle(
                      //                   fontSize: 16.0,
                      //                   fontWeight: FontWeight.bold),
                      //             ),
                      //           ),
                      //           flex: 2,
                      //         ),
                      //         Expanded(
                      //           child: Container(
                      //             child: new Text(
                      //               la == false
                      //                   ? 'Your Id Photo'
                      //                   : "صورة البطاقة القومية",
                      //               style: TextStyle(
                      //                   fontSize: 16.0,
                      //                   fontWeight: FontWeight.bold),
                      //             ),
                      //           ),
                      //           flex: 2,
                      //         ),
                      //       ],
                      //     )),
                      // Padding(
                      //     padding: EdgeInsets.only(
                      //         left: 25.0, right: 25.0, top: 2.0),
                      //     child: new Row(
                      //       mainAxisSize: MainAxisSize.max,
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: <Widget>[
                      //         Flexible(
                      //           child: Padding(
                      //             padding: EdgeInsets.only(right: 10.0),
                      //             child: new TextField(
                      //               decoration: InputDecoration(
                      //                   hintText: la == false
                      //                       ? "Enter Your Id Number"
                      //                       : "أدخل الرقم الوطني"),
                      //               enabled: !_status,
                      //               controller: id,
                      //               keyboardType: TextInputType.number,
                      //             ),
                      //           ),
                      //           flex: 2,
                      //         ),
                      //         Container(
                      //           width: 60,
                      //         ),
                      //         Flexible(
                      //           child: new GestureDetector(
                      //             onTap: () async {
                      //               await ImagePicker()
                      //                   .pickImage(source: ImageSource.gallery)
                      //                   .then((v) {
                      //                 if (v != null) {
                      //                   setState(() {
                      //                     idPic = File(v.path);
                      //                   });
                      //                 }
                      //               });
                      //             },
                      //             child: Icon(
                      //               Icons.image_aspect_ratio,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //           flex: 2,
                      //         ),
                      //       ],
                      //     )),

                      // Padding(
                      //     padding: EdgeInsets.only(
                      //         left: 25.0, right: 25.0, top: 25.0),
                      //     child: new Row(
                      //       mainAxisSize: MainAxisSize.max,
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: <Widget>[
                      //         Container(
                      //           child: Checkbox(
                      //               checkColor: Colors.black,
                      //               activeColor: Colors.lime,
                      //               value: val,
                      //               onChanged: (v) =>
                      //                   setState(() => val = !val)),
                      //         ),
                      //         Container(
                      //           child: GestureDetector(
                      //             onTap: () {
                      //               showModalBottomSheet(
                      //                   context: context,
                      //                   builder: (BuildContext context) {
                      //                     return Column(
                      //                         children: [Text(terms)]);
                      //                   });
                      //             },
                      //             child: Text(
                      //               la == false
                      //                   ? 'I agree to terms and conditions'
                      //                   : "أوافق على الشروط والآحكام",
                      //               style: TextStyle(
                      //                   fontSize: 16.0,
                      //                   fontWeight: FontWeight.bold),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     )),

                      val
                          ? _getActionButtons()
                          : Center(
                              child: CircularProgressIndicator(
                              color: Colors.teal,
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  String? jo = '0';
  String? jt = '0';
  String? jth = '0';
  String? jf = '0';
  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: RaisedButton(
                child: Text(la == false ? "Send" : "إرسال"),
                textColor: Colors.white,
                color: Colors.teal,
                onPressed: () async {
                  if (name.text.isEmpty) {
                    errono('Enter a name please !', 'أدخل الإسم رجاء');
                  } else if (phone.text.length < 9) {
                    errono('Enter a valid phone number please !',
                        "أدخل رقم هاتف شخص مقرب رجاء");
                  } else if (jo == '0' &&
                      jt == '0' &&
                      jth == '0' &&
                      jf == '0') {
                    errono('Add at least one job  !',
                        "أدخل على الأقل خدمة تقدمها  رجاء");
                  } else if (namee.text.isEmpty) {
                    errono('Translate your name please !', 'ترجم الإسم رجاء');
                  } else if (picme == null) {
                    errono('Add your photo please !', "أدخل صورتك رجاء");
                    // } else if (idPic == null) {
                    //   errono('Add your id image please !',
                    //       "أدخل صورة رقمك الوطني رجاء");
                  } else {
                    setState(() {
                      val = !val;
                    });
                    // var stream =  http.ByteStream(picme!.openRead());
                    // var length = await picme!.length();
                    var postImag = http.MultipartRequest(
                        'POST',
                        Uri.parse(
                            '${widget.url}/d/workers/photos/addworker.php'));
                    // var multipartFile =  http.MultipartFile(
                    //     "image", stream, length,
                    //     filename: path.basename(picme!.path));
                    // postImag.files.add(multipartFile);
                    postImag.fields["name"] = '${name.text}';
                    postImag.fields["namee"] = '${namee.text}';
                    postImag.fields["phone"] = '${widget.me}';
                    postImag.fields["phonea"] = '${phone.text}';
                    postImag.fields["job"] = '$jo';
                    postImag.fields["joba"] = '$jt';
                    postImag.fields["jobb"] = '$jth';
                    postImag.fields["jobc"] = '$jf';
                    postImag.fields["lid"] = '${id.text}';

                    var pic = http.MultipartFile.fromPath("image", picme!.path)
                        .then((value) async {
                      postImag.files.add(value);
                      // // print(value.filename);
                      //  http.MultipartFile.fromPath("idPic", idPic!.path)
                      //         .then((value) async {
                      //   postImag.files.add(value);

                      try {
                        await postImag.send().then((value) {
                          if (value.statusCode == 200) {
                            //   // });

                            intro();
                          } else {
                            setState(() {
                              val = true;
                            });
                            print(value.statusCode);
                          }
                        });
                      } catch (e) {
                        setState(() {
                          val = true;
                        });
                      }

                      // var pic = http.MultipartFile.fromPath("img", picme!.path)
                      //     .then((value) async {
                      //   postImag.files.add(value);
                      //   // var picId =
                      //   //     http.MultipartFile.fromPath("idPic", idPic!.path)
                      //   //         .then((value) async {
                      //   //   postImag.files.add(value);

                      //   await postImag.send().then((value) {
                      //     if (value.statusCode == 200) {
                      //       print('bashar');
                      //       //     Client me = Client(name: name.text, number: widget.me);
                      //       // DBProvider.db.addMe(me);
                      //       // print(respons.statusCode);
                      //       //      Navigator.pushAndRemoveUntil(
                      //       //       context,
                      //       //       MaterialPageRoute(
                      //       //           builder: (context) => Home()
                      //       //               ),
                      //       //       (Route<dynamic> route) => false,
                      //       //     );
                      //     } else {
                      //       print(value.statusCode);
                      //     }
                      //   });

                      //   // });
                      // });
                    });

                    // });
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          // Expanded(
          //   child: Padding(
          //     padding: EdgeInsets.only(left: 10.0),
          //     child: Container(
          //         child: new RaisedButton(
          //       child: new Text("Cancel"),
          //       textColor: Colors.white,
          //       color: Colors.red,
          //       onPressed: () {
          //         setState(() {
          //           _status = true;
          //           FocusScope.of(context).requestFocus(new FocusNode());
          //         });
          //       },
          //       shape: new RoundedRectangleBorder(
          //           borderRadius: new BorderRadius.circular(20.0)),
          //     )),
          //   ),
          //   flex: 2,
          // ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.amber,
        radius: 20.0,
        child: new Icon(
          Icons.language,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          la = !la;
        });
      },
    );
  }

  jobs(i, t) async {
    List<Job> job = await DBProvider.db.jobsList();
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(
              // backgroundColor: Colors.white,
              // onSelectedItemChanged: (value) {

              // },
              itemExtent: 50.0,
              children: [
                // ignore: sdk_version_ui_as_code
                for (int v = 0; v < job.length; v++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        i.text = la == true ? job[v].job : job[v].jobe;
                        if (t == 0) {
                          jo = job[v].id;
                        } else if (t == 1) {
                          jt = job[v].id;
                        } else if (t == 2) {
                          jth = job[v].id;
                        } else if (t == 3) {
                          jf = job[v].id;
                        } else {}
                      });
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        la == true ? ' ${job[v].job}' : ' ${job[v].jobe}',
                        // style: CustomTextStyle.textFormFieldMedium
                        // .copyWith(color: Colors.cyan.shade700, fontSize: 24)
                      ),
                    ),
                  )
              ]);
        });
  }
}

class Job {
  String? id;
  String? job;
  String? jobe;
  String? cat;

  Job({
    this.id,
    this.job,
    this.jobe,
    this.cat,
  });

  factory Job.fromMap(Map<String, dynamic> json) => Job(
        id: json["id"].toString(),
        job: json["job"],
        jobe: json["jobe"],
        cat: json["cat"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "job": job,
        "jobe": jobe,
        "cat": cat,
      };
}
