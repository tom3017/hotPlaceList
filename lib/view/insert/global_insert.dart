import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GlobalInsert extends StatefulWidget {
  const GlobalInsert({super.key});

  @override
  State<GlobalInsert> createState() => _GlobalInsertState();
}

class _GlobalInsertState extends State<GlobalInsert> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late bool _isloading;

  late String name;
  late String phone;
  late String estimate;
  late double lat;
  late double long;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile; // XFile 의 타입을 바꾸기 위함

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    lat = 0;
    long = 0;
    checkLocationPermission();
  }

  checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.whileInUse || permission == LocationPermission.always){
      getCurrentLocation();
    }


  }

  
    getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true
    ).then((position) {
      lat = position.latitude;
      long = position.longitude;

      setState(() {});
    }).catchError((e) {
      // print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          '세계 맛집 리스트 추가하기',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: ElevatedButton(
                  onPressed: () => getImageFromGallery(ImageSource.gallery),
                  child: const Text('가게 사진 선택')),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.grey,
              child: Center(
                child: imageFile == null
                    ? const Text('가게 사진을 등록해주세요')
                    : Image.file(File(imageFile!.path)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '위도 ${lat}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  ),
                Text(
                  '경도 ${long}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '가게을 입력 하세요.',
                  border: OutlineInputBorder()
                  ),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호를 입력 하세요.',
                  border: OutlineInputBorder()
                  ),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
              child: SizedBox(
                width: 400,
                height: 150,
                child: TextField(
                  controller: estimateController,
                  decoration: const InputDecoration(
                    labelText: '나만의 평가',
                    border: OutlineInputBorder(borderSide: BorderSide()),
                  ),
                  maxLength: 50,
                  // keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () => insertAction(), child: const Text('추가하기')),
          ],
        ),
      ),
    );
  }

  //---Function---
  _showDiaglog() {
    Get.defaultDialog(
      title: '완료',
      middleText: '맛집 리스트가 추가되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('확인')
        )
      ]
    );
  }

  insertAction() async {
        setState(() {
      _isloading = true;
      _loadingDialog();
    });
    String name = nameController.text;
    String phone = phoneController.text;
    String estimate = estimateController.text;
    String image = await preparingImage();

    FirebaseFirestore.instance.collection('hotplace').add({
      'name': name,
      'phone': phone,
      'estimate': estimate,
      'lat': lat,
      'long': long,
      'image': image,
      'initdate': DateTime.now().toString(),
      }
    );
    setState(() {
      _isloading = false;
      Get.back();
    });
    _showDiaglog();
  }

  getImageFromGallery(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    imgFile = File(imageFile!.path);
    setState(() {});
  }

  Future<String> preparingImage() async {
    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('hotplaceimages')
        .child('${nameController.text}.png');
    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  _loadingDialog() {
    if(_isloading) {
      Get.defaultDialog(
        barrierDismissible: false,
        title: '안내',
        middleText: '저장 중 입니다. 잠시만 기다려주세요.',
      );
    }
  }

  
}
