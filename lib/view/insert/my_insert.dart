import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hot_place_list_app/model/review.dart';
import 'package:hot_place_list_app/vm/db_handler.dart';
import 'package:image_picker/image_picker.dart';

class MyInsert extends StatefulWidget {
  const MyInsert({super.key});

  @override
  State<MyInsert> createState() => _MyInsertState();
}

class _MyInsertState extends State<MyInsert> {

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late DatabaseHandler dbHandler;

  late double latData;
  late double longData;

  ImagePicker picker = ImagePicker();
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    latData = 0;
    longData = 0;
    nameController =TextEditingController();
    phoneController =TextEditingController();
    estimateController =TextEditingController();
    dbHandler = DatabaseHandler();
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
      latData = position.latitude;
      longData = position.longitude;

      setState(() {});
    }).catchError((e) {
      // print(e);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '나만의 맛집 리스트 추가하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: OutlinedButton(
                      onPressed: () {
                        getImageFromDevice(ImageSource.gallery);
                      },
                      child: const Text('사진 추가하기')
                    ),
                  ),
                  Container(
                    // width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/6,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 188, 186, 186),
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width/3*2,
                      height: 150,
                      child: imageFile == null
                      ? Center(
                          child: Text(
                            '이미지를 선택해 주세요!',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer
                            ),
                          )
                        )
                      : Image.file(File(imageFile!.path)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                          child: Row(
                            children: [
                              const Text(
                              '위도 : '
                              ),
                              Text(
                                '$latData'
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Row(
                            children: [
                              const Text(
                              '경도 : '
                              ),
                              Text(
                                '$longData'
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '맛집 이름 입력하세요',
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: '맛집 전화번호를 입력하세요',
                        border: OutlineInputBorder()
                      ),
                      keyboardType: TextInputType.phone,
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
                          labelText: '평가를 입력하세요',
                          border: OutlineInputBorder(
                            borderSide: BorderSide()
                          ),
                        ),
                        maxLength: 50,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if(imageFile == null) {
                        checkImage();
                        return;
                      }
                      insertSQLite();
                      _showDiaglog();
                    },
                    child: const Text('저장하기')
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getImageFromDevice(imageSource) async {
  final XFile? pickedFile = await picker.pickImage(source: imageSource);
  if(pickedFile == null) {
    imageFile = null;
  }
  else {
    imageFile = XFile(pickedFile.path);
  }
  setState(() {});
}

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

  insertSQLite() async {
    await dbHandler.insertReview(
      Review(
        name: nameController.text,
        phone: phoneController.text,
        lat: latData,
        long: longData,
        image: await imageFile!.readAsBytes(),
        estimate: estimateController.text,
        initdate: DateTime.now().toString()
      )
    );
  }

  checkImage() {
    Get.defaultDialog(
      title: '경고',
      middleText: '이미지를 선택해 주세요!',
      barrierDismissible: false,
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('확인')
        )
      ]
    );
  }

}