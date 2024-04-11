import 'dart:typed_data';


class Review {
  int? seq;
  String name;
  String phone;
  double lat;
  double long;
  Uint8List image;
  String estimate;
  String initdate;
  // String updatedate;

  Review ({
    this.seq,
    required this.name,
    required this.phone,
    required this.lat,
    required this.long,
    required this.image,
    required this.estimate,
    required this.initdate,
    // required this.updatedate,
  });

  Review.fromMap(Map<String, dynamic> res)
    : seq = res['seq'],
      name = res['name'],
      phone = res['phone'],
      lat = res['lat'],
      long = res['long'],
      image = res['image'],
      estimate = res['estimate'],
      initdate = res['initdate'];
      // updatedate = res['updatedate'];

}