import 'dart:convert';
import 'dart:io' as Io;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as ima;
import 'package:provider/vari.dart';
import 'dbpath.dart';
import 'main.dart';
import 'reg.dart';

class Add_pro extends StatefulWidget {
  String? url;
  String? id;
  var data;
  var item;
  bool la;

  Add_pro(
      {Key? key,
      required this.url,
      required this.id,
      required this.data,
      required this.item,
      required this.la})
      : super(key: key);

  @override
  State<Add_pro> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Add_pro> {
  List<Io.File> pho = [];
  bool la = true;
  TextEditingController title = TextEditingController();
  TextEditingController vdio = TextEditingController();
  TextEditingController shortDis = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController brand = TextEditingController();
  TextEditingController des = TextEditingController();

  TextEditingController timD = TextEditingController();
  TextEditingController timG = TextEditingController();
  List<bool>? isSelected = [];
  int status = 0;
  bool dl = false;
  bool gr = false;
  Widget photos() {
    return Stack(
      children: [
        SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: pho.isEmpty
                ? Container(
                    height: 200,
                  )
                : ListView.builder(
                    itemCount: pho.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.red[index * 10],
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Center(
                              child: Image.file(
                                pho[index],
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: IconButton(
                                onPressed: () async {
                                  setState(() {
                                    pho.remove(pho[index]);
                                  });
                                },
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.pink.shade800,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    })),
        Positioned(
            right: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: () async {
                  if (pho.length < 4) {
                    try {
                      await ImagePicker()
                          .pickImage(source: ImageSource.gallery,imageQuality: 100,maxHeight: 1000,maxWidth: 1000)
                          .then((v) {
                        final bytes =
                            Io.File(v!.path).readAsBytesSync().lengthInBytes;
                        final kb = bytes / 1024;
                        final mb = kb / 1024;
                        // print(mb);
                        // ima.Image? image =
                        //     ima.decodeImage(Io.File(v.path).readAsBytesSync());

                        // // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
                        // ima.Image thumbnail = ima.remapColors(image!);

                        // // Save the thumbnail as a PNG.
                        // Io.File(v.path)
                        //     .writeAsBytesSync(ima.encodePng(thumbnail));
                        if (v != null && mb < 1.0) {
                          try {
                            setState(() {
                              pho.add(Io.File(v.path));
                            });
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          errono('The image is too big',
                              "  حجم الصورة كبير جدا", la);
                        }
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                icon: Icon(Icons.add_a_photo),
              ),
            ))
      ],
    );
  }

  bool wait = false;
  List<Job> myJobs = [];
  get() async {
    List<Job> job = await DBProvider.db.jobsList();
    for (var i in job) {
      if (i.id == widget.data['job'] ||
          i.id == widget.data['joba'] ||
          i.id == widget.data['jobb'] ||
          i.id == widget.data['jobc']) {
        print(i.job);
        setState(() {
          myJobs.add(i);
        });
      }
    }
  }

  @override
  void initState() {
    get();
    if (widget.item != 0) {
      print(widget.item);
      setState(() {
        title.text = widget.item['name'];

        des.text = widget.item['description'];
        price.text = widget.item['price'];
      });
    }
    super.initState();
  }

  Job? ser;
  Widget pop() {
    return PopupMenuButton(
      child: Center(
          child: Text(
              '${ser == null ? !widget.la ? 'Choose service' : 'إختر الخدمة' : !widget.la ? ser!.jobe : ser!.job}')),
      itemBuilder: (context) {
        return List.generate(myJobs.length, (index) {
          return PopupMenuItem(
            child: GestureDetector(
              child:
                  Text(!widget.la ? myJobs[index].jobe! : myJobs[index].job!),
              onTap: () => setState(() {
                ser = myJobs[index];
                Navigator.of(context).pop();
              }),
            ),
          );
        });
      },
    );
  }

  int uploadedImag = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Visibility(visible: widget.item == 0,
            child: photos()),
          const SizedBox(
            height: 10,
          ),
          Text(
            !widget.la
                ? 'Youtube link to offer video (optional)'
                : ' رابط يوتيوب لفيديو العرض (إختياري)',
            textAlign: widget.la ? TextAlign.end : null,
          ),
          TextField(
            decoration: InputDecoration(
              hintText:   !widget.la
                  ? 'Enter the YouTube link of the offer video'
                  : 'ادخل رابط يوتيوب لفيديو العرض',
            ),
            textAlign: widget.la ? TextAlign.end : TextAlign.start,
            controller: vdio,
            maxLength: 100,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(!widget.la ? 'Title ' : "إسم العرض"),
          TextField(
            controller: title,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(!widget.la ? 'Price ' : "السعر"),
              Text(!widget.la ? 'Service ' : "الخدمة"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(suffix: Text(!widget.la ? 'SDG' : "ج.س")),
              )),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: pop(),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            !widget.la ? 'Discreption ' : "وصف",
            textAlign: TextAlign.left,
          ),
          TextField(
            controller: des,
            maxLines: 3,
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: !wait && widget.item == 0,
            child: Center(
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                              child: RaisedButton(
                                  child: Text(la ? "Send" : "إرسال"),
                                  textColor: Colors.white,
                                  color: Colors.teal,
                                  onPressed: () async {
                                    if (title.text.isEmpty) {
                                      errono('Enter a title please !',
                                          'أدخل الإسم رجاء', widget.la);
                                    } else if (price.text.isEmpty ||
                                        price.text[0] == '0') {
                                      errono('Enter price please',
                                          "أدخل السعر  رجاء", widget.la);
                                    } else if (des.text.isEmpty) {
                                      errono('Enter discreption please',
                                          "أدخل الوصف  رجاء", widget.la);
                                    } else if (ser == null) {
                                      errono('ُType of service  please',
                                          '   نوع الخدمة رجاء', widget.la);
                                    } else if (pho.isEmpty) {
                                      //picme
                                      errono('Add service\'s photo please !',
                                          "أدخل صورة الخدمة", la);
                                      // } else if (idPic == null) {
                                      //   errono('Add your id image please !',
                                      //       "أدخل صورة رقمك الوطني رجاء");
                                    } else {
                                      setState(() {
                                        wait = !wait;
                                      });
                                      if (widget.item != 0) {
                                      } else {
                                        List<String> ids = ['a', 'b', 'c', 'd'];

                                        var date = DateFormat("dd-MM-yyyy")
                                            .format(DateTime.now());
                                        DateTime now = DateTime.now();
                                        String formattedTime =
                                            DateFormat.Hm().format(now);
                                        try {
                                          var reguest = await http.post(
                                              Uri.parse(
                                                  "${widget.url}/d/workers/${widget.item == 0 ? 'add_of_one' : 'update_of_one'}.php"),
                                              body: {
                                                'name': title.text,
                                                'phone': widget.data['phone'],
                                                'description': des.text,
                                                'price': replaceFarsiNumber(
                                                    price.text),
                                                'category_id': ser!.cat,
                                                'created':
                                                    '$date $formattedTime',
                                                'modified':
                                                    '$date $formattedTime',
                                                'job_id': ser!.id,
                                                'worker_id': widget.id,
                                                'picn': '${pho.length}',
                                                'vdio': vdio.text.length > 40
                                                    ? vdio.text
                                                    : 'no',
                                              });

                                          if (reguest.statusCode == 200) {
                                            if (int.parse(reguest.body) >= 1) {
                                              for (int i = 0;
                                                  i <= pho.length - 1;
                                                  i++) {
                                                print(ids[i]);
                                                var postImag =
                                                    http.MultipartRequest(
                                                        'POST',
                                                        Uri.parse(
                                                            '${widget.url}/d/workers/photos/add_pic_one.php'));
                                                postImag.fields["name"] =
                                                    '${int.parse(reguest.body)}${ids[i]}of';
                                                var pic =
                                                    http.MultipartFile.fromPath(
                                                            "img", pho[i].path)
                                                        .then((value) {
                                                  postImag.files.add(value);
                                                });
                                                try {
                                                  await postImag
                                                      .send()
                                                      .then((n) async {
                                                    if (n.statusCode == 200) {
                                                      n.stream
                                                          .transform(
                                                              utf8.decoder)
                                                          .listen((value) {
                                                        // var i=int.parse(json.decode(value).toString());

                                                        if (value == '1') {
                                                          setState(() {
                                                            uploadedImag++;
                                                          });
                                                          if (uploadedImag ==
                                                              pho.length) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        } else {
                                                          print(
                                                              '$value nnnnnn');
                                                          print(' nnnnnn');
                                                        }
                                                      });
                                                    }
                                                  });
                                                } catch (e) {}
                                              }
                                              // print('uploaded');
                                            } else {
                                              print(reguest.body);
                                            }
                                          }
                                        } catch (e) {
                                          print('$e error------');
                                        }
                                      }
                                    }
                                  })))),
                ],
              ),
            ),
          ),
          Visibility(
              visible: wait,
              child: Center(
                child: LinearProgressIndicator(
                  color: Colors.teal,
                ),
              ))
        ],
      ),
    );
  }
}
