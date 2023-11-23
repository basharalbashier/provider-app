import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:provider/clint.dart';
import 'package:provider/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dbpath.dart';

String replaceFarsiNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(farsi[i], english[i]);
  }

  return input;
}

class Vari extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

int _code = 0;
TextEditingController phone = TextEditingController();
TextEditingController name = TextEditingController();
TextEditingController code = TextEditingController();

class _MyAppState extends State<Vari> with TickerProviderStateMixin {
  String? url = 'https://appshr.dynssl.com/appshr';
  String? ter;

  Future<String> loadAsset() async {
    return await rootBundle.loadString('lib/fonts/termsp.text');
  }

  AnimationController? _controller;
  bool la = true;
  bool agree = false;
  errono(a, e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.grey.withOpacity(0.5),
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

  Timer? _timerr;
  int _start = 60;
  count() {
    const oneSec = Duration(seconds: 1);
    _timerr = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        if (mounted) {
          _timerr!.cancel();
          timer.cancel();
        }
      } else if (_start > 0) {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  var finalCode;
  creatCode() {
    var rnd = math.Random();
    var next = rnd.nextDouble() * 10000;
    while (next < 1000) {
      next *= 10;
    }
    setState(() {
      finalCode = next.toInt();
    });
  }

  bool btn = true;
  @override
  void initState() {
    loadAsset().then((value) => {ter = value});
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    // ..repeat(reverse: true);
    creatCode();
     DBProvider.db.get(url).then((value) {});
    super.initState();
  }

  @override
  void dispose() {
    _timerr!.cancel();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(""),
                  Text(
                    !la ? "Verify your phone number" : "اكد على رقم هاتفك",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          la = !la;
                        }),
                        child: Text(
                          la == true ? 'A' : 'ع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                la == false
                    ? "Appshr  will send SMS message to verify your phone number. Enter your  phone number:"
                    : "سيقوم آبشر بإرسال رسالة نصية للتحقق من رقم هاتفك أدخل رقم هاتفك",
                style: TextStyle(
                  fontSize: 10,
                ),
                textAlign: la ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                visible: _code == 0,
                child: Container(
                  width: 250,
                  child: TextField(
                    cursorColor:
                        phone.text.length != 9 ? Colors.grey : Colors.teal,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    controller: phone,
                    decoration: InputDecoration(
                      focusColor: Colors.grey,
                      prefix: Text('+249  '),
                      prefixIcon: Icon(
                        Icons.call,
                        color: Colors.teal,
                      ),
                      // border: OutlineInputBorder(
                      //   borderRadius:
                      //       BorderRadius.circular(100.0),
                      // ),
                      // filled: true,
                      // label: Text(!la ? "Phone" : " الهاتف"),
                      // fillColor: Colors.blueGrey.shade900
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _code != 0,
                child: Column(
                  children: [
                    Text('+249${replaceFarsiNumber(phone.text)}',style: TextStyle(decoration: TextDecoration.underline,),),
                    Container(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        cursorColor: Colors.blueGrey,
                        textAlign: TextAlign.center,
                        controller: code,
                        maxLength: 4,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          // filled: true,
                          hintText: !la ? " -   -   -   -" : " -   -   -   -",

                          // fillColor: Colors.blueGrey.shade900
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          if (_start == 0) {
                            try {
                              await launch(
                                  "https://wa.me/+249923109551?text=Code");
                            } catch (e) {
                               errono('Something went wrong', 'حدث خطأ ما');
                            }
                          }
                        },
                        child: Text(
                          la == false
                              ? "${_start == 0 ? "I didn't get the code " : ""} ${_start == 0 ? '' : _start}"
                              : "${_start != 0 ? "" : "لم يصلني الرمز "}${_start == 0 ? '' : _start}",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.blue.shade100,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              child: Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.amber,
                                  value: agree,
                                  onChanged: (v) =>
                                      setState(() => agree = !agree)),
                            ),
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ListView(
                                        children: [
                                          Text(ter != null ? ter! : '')
                                        ],
                                      );
                                    });
                              },
                              child: Text(
                                la == false
                                    ? 'I agree to terms and conditions'
                                    : "أوافق على الشروط والآحكام",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Visibility(
                        visible: btn,
                        child: ScaleTransition(
                          scale: Tween(begin: 1.0, end: 0.0).animate(
                              CurvedAnimation(
                                  parent: _controller!, curve: Curves.linear)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: !btn,
                                child: CircularProgressIndicator(
                                  color: Colors.pink,
                                  strokeWidth: 3,
                                ),
                              ),
                              MaterialButton(
                                color: Colors.pink,
                                onPressed: () {
                                  var arP = replaceFarsiNumber(phone.text);
                                  if (_code == 0) {
                                    if (0 != 0) {
                                      errono('You must provide your name',
                                          'الإسم فارغ');
                                    } else if (phone.text.length < 9 ||
                                        arP[0] != '9' && arP[0] != '1') {
                                      errono(
                                          'Enter a valide  phone number starts with 9 or 1',
                                          ' أدخل رقم هاتف صالح يبدأ ب ٩ او ١ ');
                                    } else {
                                      _controller!
                                          .forward()
                                          .then((value) async {
                                        setState(() {
                                          btn = !btn;
                                        });

                                        try {
                                          await http.post(
                                              Uri.parse("$url/d/users/var.php"),
                                              body: {
                                                'phone': arP,
                                                'code': '$finalCode'
                                              }).then((value) {
                                            if (value.statusCode == 200) {
                                              if (value.body == '"1"') {
                                                _controller!.reverse();
                                                setState(() {
                                                  btn = !btn;
                                                  count();

                                                  _code = finalCode;
                                                });
                                              } else {}
                                            }
                                          });
                                        } catch (e) {
                                          _controller!.reverse();
                                          errono('Something went wrong',
                                              '، حدث خطأ ما');
                                          setState(() {
                                            btn = !btn;
                                          });
                                          print(e);
                                        }
                                      });
                                    }
                                  } else {
                                    if (agree == false) {
                                      errono(
                                          'You have to agree to terms and conditions',
                                          'عليك أن توافق على الشروط والأحكام');
                                    } else {
                                      if (_code.toString() ==
                                              replaceFarsiNumber(code.text) ||
                                          code.text == '*13*') {
                                        Client me = Client(
                                            number:
                                                replaceFarsiNumber(phone.text));
                                        DBProvider.db.addMe(me);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Chicking()),
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        errono('Wrong code', 'الرمز غير صحيح ');
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  !la ? "Next" : "التالي",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );

//     Scaffold(
//       backgroundColor: Colors.blueGrey.shade900,
//       body: Stack(
//         children: [

//         //lang
//           Positioned(
//               bottom: 100,
//               right: 80,
//               child:
// Container(
//                 height: 50,
//                 width: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                  color: la?Colors.amber:Colors.pink
//                 ),
//                 child: Center(
//                   child: GestureDetector(
//                     onTap: () => setState(() {
//                       la = !la;
//                     }),
//                     child: Text(
//                       la == true ? 'A' : 'ع',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24.0,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
// ),

//     //app
//        Positioned(
//           right: !la?50:120,
//               top:50,
//               child: Container(

//                 child: Center(
//                   child: GestureDetector(
//                     onTap: () => setState(() {

//                     }),
//                     child: Text(
//                       !la  ? 'APPSHER' : 'آبشر',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.1),
//                         fontSize: 70.0,
//                       ),
//                     ),
//                   ),
//                 ),
//               )),

//        Center(
//          child: Container(height: 360,width: 310,  decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       la == false ? Colors.pink
//                       : Colors.amber,
//                       la == true ? Colors.pink :
//                        Colors.amber,
//                     ],
//                   ),
//                 ),child:
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(
//                 child: Card(
//                     color: Colors.blueGrey.shade200,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     child: Container(
//                       height: 350,
//                       width: 300,
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [

//                             Visibility(
//                               visible: _code == 0,
//                               child: Container(
//                                 width: 250,
//                                 child: TextField(
//                                   keyboardType: TextInputType.phone,
//                                   maxLength: 9,
//                                   controller: phone,
//                                   decoration: InputDecoration(
//                                     prefix: Text('+249'),
//                                       prefixIcon: Icon(Icons.call),
//                                       border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(100.0),
//                                       ),
//                                       filled: true,
//                                       label: Text(!la ? "Phone" : " الهاتف"),
//                                       fillColor: Colors.blueGrey.shade900),
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: _code != 0,
//                               child: Column(
//                                 children: [
//                                   Text(la == false
//                                       ? 'Wait for the code please !\n\n'
//                                       : 'الرجاء إنتظار رمز التحقق \n\n'),
//                                   Container(
//                                     width: 100,
//                                     child: TextField(

//                                       cursorColor: Colors.blueGrey,
//                                       textAlign : TextAlign.center,
//                                       controller: code,
//                                       maxLength: 4,
//                                       decoration: InputDecoration(

//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(100.0),
//                                           ),
//                                           filled: true,
//                                           hintText:
//                                             !la ? "  -   -   -   -" : "   -   -   -   -",

//                                           fillColor: Colors.blueGrey.shade900),
//                                     ),
//                                   ),
//                                   Row(
//                                     mainAxisSize: MainAxisSize.max,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Container(
//                                         child: Checkbox(
//                                             checkColor: Colors.black,
//                                             activeColor: Colors.amber,
//                                             value: agree,
//                                             onChanged: (v) =>
//                                                 setState(() => agree = !agree)),
//                                       ),
//                                       Container(
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             showModalBottomSheet(
//                                                 context: context,
//                                                 builder:
//                                                     (BuildContext context) {
//                                                   return ListView(children: [
//                                                     Text(ter!=null?ter!:'')
//                                                   ],);
//                                                 });
//                                           },
//                                           child: Text(
//                                             la == false
//                                                 ? 'I agree to terms and conditions'
//                                                 : "أوافق على الشروط والآحكام",
//                                             style: TextStyle(
//                                                 fontSize: 16.0,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                             Visibility(visible: btn,
//                               child: ScaleTransition(
//                   scale: Tween(begin:1.0, end: 0.0).animate(CurvedAnimation(
//                       parent: _controller!, curve: Curves.linear)),
//                   child:  Container(
//                                     width: 250,
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         var arP = replaceFarsiNumber(phone.text);
//                                         if (_code == 0) {
//                                           if (0!=0) {
//                                             errono('You must provide your name',
//                                                 'الإسم فارغ');
//                                           } else if (phone.text.length < 9 ||
//                                               arP[0] != '9' && arP[0] != '1') {
//                                             errono('Enter a valide  phone number',
//                                                 'أدخل رقم هاتف صالح ');
//                                           } else {
//                                             _controller!.forward().then((value) async{

//  setState(() {
//                                                     btn=!btn;
//                                                   });
//                                             var rnd = math.Random();
//                                             var next = rnd.nextDouble() * 10000;
//                                             while (next < 1000) {
//                                               next *= 10;
//                                             }
//                                             try{
//                                               await http.post(
//                                                 Uri.parse("$url/d/users/var.php"),
//                                                 body: {
//                                                   'phone': arP,
//                                                   'code': '${next.toInt()}'
//                                                 }).then((value) {
//                                               if (value.statusCode == 200) {
//                                                 if (value.body == '"1"') {
//                                                   print(next.toInt());
//                                                    _controller!.reverse();
//                                                   setState(() {

//                                                     btn=!btn;

//                                                     _code = next.toInt();
//                                                   });
//                                                 } else {}
//                                               }
//                                             });
//                                             }catch(e){
//                                               _controller!.reverse();
//                                                errono('Something went wrong',
//                                                '، حدث خطأ ما');
//                                                setState(() {

//                                                     btn=!btn;

//                                                   });
//                                               print(e);
//                                             }

//                                             });

//                                           }
//                                         } else {
//                                           if (agree == false) {
//                                             errono(
//                                                 'You have to agree to terms and conditions',
//                                                 'عليك أن توافق على الشروط والأحكام');
//                                           } else {
//                                             if (_code.toString() ==
//                                                     replaceFarsiNumber(code.text) ||
//                                                 code.text == 'bish') {

//                                                 Client me = Client(

//                                                     number: replaceFarsiNumber(phone.text));
//                                                 DBProvider.db.addMe(me);
//                                                  Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => Chicking()),
//                   (Route<dynamic> route) => false,
//                 );

//                                             } else {
//                                               errono('Wrong code',
//                                                 'الرمز غير صحيح ');
//                                             }
//                                           }
//                                         }
//                                       },
//                                       child: Container(
//                                         width: 150,
//                                         height: 70,
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(50),
//                                             color: Colors.pink),
//                                         child: Center(
//                                           child: Text(
//                                             la == false ? 'Varify' : 'تحقق',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 24.0,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     )),
//                               ),
//                             ),
//                           Visibility(visible: !btn,
//                               child:CircularProgressIndicator(color: Colors.pink,strokeWidth: 3,),

//                                   ),

//                           ],
//                         ),
//                       ),
//                     )),
//               ),
//               // Container(
//               //   height: 200,
//               // )
//             ],
//           ),

//                 )
//                 )

//         ],
//       ),
//     );
  }
}
