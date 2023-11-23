import 'dart:convert';

Client clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Client.fromMap(jsonData);
}

String clientToJson(Client data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Client {
  String? id;
  String? name;
  String? cat;
  String? note;
  String? type;
  String? price;
  String? date;
  String? total;
  String? number;
  String? job;
  String? joba;
  String? jobb;
  String? jobc;
  String? late;
  String? longe;
  double? distance;
  String? img;
  String? jobe;

  Client(
      {this.id,
      this.name,
      this.cat,
      this.note,
      this.type,
      this.price,
      this.date,
      this.total,
      this.number,
      this.job,
      this.joba,
      this.jobb,
      this.jobc,
      this.late,
      this.longe,
      this.distance,
      this.img,
      this.jobe
      
      });

  factory Client.fromMap(Map<String, dynamic> json) => new Client(
        id: json["id"].toString(),
        name: json["name"],
        note: json["note"],
        price: json["price"],
        date: json["date"],
        total: json["total"],
        number: json["phone"],
        cat: json["cat"],
        job: json["job"],
        joba: json["joba"],
        jobb: json["jobb"],
        jobc: json["jobc"],
        late: json["late"],
        longe: json["longe"],
        distance: json["distance"],
        img: json["img"],
         jobe: json["jobe"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "note": note,
        "price": price,
        "date": date,
        "total": total,
        "phone": number,
        "cat": cat,
        "job": job,
        "joba": joba,
        "jobb": jobb,
        "jobc": jobc,
        "late": late,
        "longe": longe,
        "distance": distance,
        "img": img,
         "jobe": jobe,
      };
}


