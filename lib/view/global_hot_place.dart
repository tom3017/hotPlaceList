import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hot_place_list_app/model/hotplace.dart';
import 'package:hot_place_list_app/view/detail/global_location.dart';
import 'package:hot_place_list_app/view/insert/global_insert.dart';
import 'package:hot_place_list_app/view/update_page/global_update.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalHotPlace extends StatefulWidget {
  const GlobalHotPlace({super.key});

  @override
  State<GlobalHotPlace> createState() => _GlobalHotPlaceState();
}

class _GlobalHotPlaceState extends State<GlobalHotPlace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('세계의 맛집 리스트',),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const GlobalInsert());
            },
            icon: const Icon(Icons.add)
            )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
                  .collection('hotplace')
                  .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator(),);
          }
          final documents = snapshot.data!.docs;
          return ListView(
            children: documents.map((e) => buildHotplaceWidget(e)).toList(),
          );
        },
        ),
      ),
    );
  }

  Widget buildHotplaceWidget(doc) {
    final hotplace = HotPlace(
      id :doc.id,
      name: doc['name'],
      phone: doc['phone'],
      lat: doc['lat'],
      long: doc['long'],
      image: doc['image'],
      estimate: doc['estimate'],
      initdate: doc['initdate']
      );

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Get.to(const GlobalUpdate(), arguments: hotplace);
              },
              icon: Icons.edit,
              label: '수정하기',
              backgroundColor: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
          ]
        ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              FirebaseFirestore.instance.collection('musteatplace').doc(doc.id).delete();
              _deleteDialog();
            },
            icon: Icons.delete_outline,
            label: '삭제하기',
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ]
      ),
      child: GestureDetector(
        onTap: () => Get.to(const GlobalLocation(), arguments: hotplace),
        child: Card(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.height / 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    hotplace.image!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3 * 1.78,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        hotplace.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width /
                              3 *
                              1.4,
                          height:
                              MediaQuery.of(context).size.height /
                                  16,
                          child: Text(
                            hotplace.estimate,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width /
                              5.5,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            callActionSheet(hotplace.phone);
                          },
                          icon: const Icon(Icons.home),
                          label: Text(hotplace.phone),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //---Function---
  callActionSheet(phone) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(
          '통화 연결',
          style: TextStyle(),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              final Uri call = Uri(
                path: 'tel:$phone'
              );
              if(await canLaunchUrl(call)) {
                await launchUrl(call);
              }
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home),
                  Text(' $phone')
                ],
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20
            ),
          )
        )
      ),
    );
  }


  deleteImage(deleteCode) async{
    final firebaseStorage = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child('$deleteCode.png');
    await firebaseStorage.delete();
  }

  _deleteDialog() {
    Get.defaultDialog(
      title: '완료',
      middleText: '맛집 리스트가 삭제되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('확인')
        )
      ]
    );
  }



} //End