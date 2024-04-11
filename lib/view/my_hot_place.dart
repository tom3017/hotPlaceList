import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hot_place_list_app/view/detail/my_location.dart';
import 'package:hot_place_list_app/view/insert/my_insert.dart';
import 'package:hot_place_list_app/view/update_page/my_update.dart';
import 'package:hot_place_list_app/vm/db_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHotPlace extends StatefulWidget {
  const MyHotPlace({super.key});

  @override
  State<MyHotPlace> createState() => _MyHotPlaceState();
}

class _MyHotPlaceState extends State<MyHotPlace> {
  late DatabaseHandler myHandler;

  @override
  void initState() {
    super.initState();
    myHandler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          '나만의 맛집 리스트',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(const MyInsert())!.then((value) {
                  setState(() {});
                });
              },
              icon: Icon(Icons.add))
        ],
      ),body: FutureBuilder(
        future: myHandler.queryReview(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            Get.to(const MyUpdate(), arguments: snapshot.data![index])!.then((value) => setState(() {}));
                          },
                          icon: Icons.edit,
                          label: 'Edit',
                          backgroundColor: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ]
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            _showDiaglog();
                            await myHandler.deleteReview(snapshot.data![index].seq);
                          },
                          icon: Icons.delete_forever,
                          label: 'Delete',
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ]
                    ),
                    child: GestureDetector(
                      onTap: () => Get.to(const MyLocation(), arguments: [
                        snapshot.data![index].lat,
                        snapshot.data![index].long,
                        snapshot.data![index].name,
                      ]),
                      child: Card(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width/3,
                              height: MediaQuery.of(context).size.height/6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  snapshot.data![index].image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width/3*1.78,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data![index].name,
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
                                        width: MediaQuery.of(context).size.width/3*1.4,
                                        height: MediaQuery.of(context).size.height/16,
                                        child: Text(
                                          snapshot.data![index].estimate,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(width: MediaQuery.of(context).size.width/5.5,),
                                      TextButton.icon(
                                        onPressed: () {
                                          callActionSheet(snapshot.data![index].phone);
                                        },
                                        icon: const Icon(Icons.home),
                                        label: Text(snapshot.data![index].phone),
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
                  ),
                );
              },
            );
          }
          else {
            return const Center(
              child: Text(
                '저장된 목록이 없습니다!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )
            );
          }
        },
      ),
    );
  }

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
                  const Icon(Icons.call),
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

  _showDiaglog() {
    Get.defaultDialog(
      title: '완료',
      middleText: '맛집 리스트가 삭제되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            setState(() {});
          },
          child: const Text('확인')
        )
      ]
    );
  }
}