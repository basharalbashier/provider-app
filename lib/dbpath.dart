import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/main.dart';
import 'package:provider/reg.dart';
import 'package:sqflite/sqflite.dart';
import 'clint.dart';
import 'dart:math' show cos, sqrt, asin;


 double calculateDistance(p1, p2) {
   double lat1=p1.latitude;
   double lon1=p1.longitude;
   double lat2=p2.latitude;
   double lon2=p2.longitude;
 
 var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - (c((lat2 - lat1) * p)/2) +
        c(lat1 * p) * c(lat2 * p) *
            ((1 - c((lon2 - (lon1)) * p))/2);
        var distance =  12742 * asin(sqrt(a));
        // print(distance *1000);
             
 
    return distance;
  }


class NetworkHelper {
  NetworkHelper({required this.startLng, required this.startLat, required this.endLng, required this.endLat});
  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey = '5b3ce3597851110001cf62482d61f1272f3943d9803332b06e13eb33';
  final String journeyMode = 'driving-car';
// Change it if you want or make it variable
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;
  Future getData() async {
    http.Response response = await     http.get(Uri.parse('$url$journeyMode?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));

    // print(
    //     "$url$journeyMode?$apiKey&start=$startLng,$startLat&end=$endLng,$endLat");
    if (response.statusCode == 200) {
      String data = response.body;
      // print(jsonDecode(data)['features'][0]['properties']['summary']['distance']);
      // print(jsonDecode(data)['features'][0]['properties']['summary']);
      
      return jsonDecode(data);
      
    } else {
      // print(response.statusCode);
    }
  }
}
class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "work5.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE info (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT)');
    await db.execute(
          'CREATE TABLE job (id INTEGER PRIMARY KEY, job TEXT, jobe TEXT, cat TEXT)');

    });
  }
 Future get(url)async{
  try{

            var n='$url/d/admin/getalljobs.php';
     ////
 await http.get(Uri.parse(n)).catchError((error) {
  // handle error here
}).then((jobres) async{


try{
if(jobres.statusCode==200){

 final db = await database;
 var j=db.rawQuery("SELECT * FROM job").then((value) {
List<dynamic> i=json.decode(jobres.body);


value.length!=i.length?db.rawDelete("Delete  from job").whenComplete(() {

i.forEach((element) async{ 

    var raw = await db.rawInsert(
        "INSERT Into job (id,job,jobe,cat)"
        " VALUES (?,?,?,?)",
        [
          element['id'],
          element['job'],
          element['jobe'],
           element['cat'],
       

        ]);
   


});

  
})



 :print('all job good');
 });

}else{

  print('Connection error !');
}
}catch(e){
  print(e);
}
});

  }catch(e){

  }

}


    jobsList()async{
 Database db = await this.database;
  var result =
        await db.rawQuery("SELECT * FROM job  ");
        List<Job> memberList = <Job>[];
        for (int i = 0; i < result.length; i++) {
      // print("for loop working: ${i + 1}");
      memberList.add(Job.fromMap(result[i]));
    }
 return memberList;
  }

   Future getMe() async {
   
    final db = await database;
    var result = await db.rawQuery("SELECT * FROM info  ");
    // WHERE job = '%${search}%' OR joba = '${search}' OR jobb = '${search}' OR jobc = '${search}' ORDER BY distance;
 
  if(result.isEmpty)return 0;

    return result;
  }



  addMe(Client newPro) async {
    final db = await database;
     db.rawDelete("Delete from info");
    var raw = await db.rawInsert(
        "INSERT Into info (id,name,phone)"
        " VALUES (?,?,?)",
        [
          1,
          newPro.name,
          newPro.number,
        ]);

        return raw;
  }




}
