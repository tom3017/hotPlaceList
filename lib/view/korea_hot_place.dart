import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hot_place_list_app/view/detail/korea_location.dart';
import 'package:hot_place_list_app/view/insert/korea_insert.dart';
import 'package:hot_place_list_app/view/update_page/korea_update.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class KoreaHotPlace extends StatefulWidget {
  const KoreaHotPlace({super.key});

  @override
  State<KoreaHotPlace> createState() => _KoreaHotPlaceState();
}

class _KoreaHotPlaceState extends State<KoreaHotPlace> {

  late List placeList;

  @override
  void initState() {
    placeList = [];
    super.initState();
    getJSPData();
  }

  getJSPData() async {
    var url = Uri.parse('http://localhost:8080/Flutter/JSP/select_hotplace_list.jsp');
    var response = await http.readBytes(url);
    List result = json.decode(utf8.decode(response))['placeList'];
    placeList.addAll(result);
    setState(() {});
  }

  reloadData () {
    placeList.clear();
    getJSPData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "               한국의 맛집 리스트",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
                onPressed: () {
                  Get.to(const KoreaInsert())!.then((value) => setState(() {reloadData();}));
                }, icon: const Icon(Icons.add)),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: placeList.length,
          itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                child: Slidable(
                  startActionPane:
                      ActionPane(motion: const DrawerMotion(), children: [
                    SlidableAction(
                      onPressed: (context) {
                        // 수정 Action
                        Get.to(const KoreaUpdate(), arguments: placeList[index])!.then((value) => reloadData());
                      },
                      icon: Icons.edit,
                      label: '수정하기',
                      backgroundColor: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ]),
                  endActionPane:
                      ActionPane(motion: const DrawerMotion(), children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await sendDeleteJSP(index);
                        reloadData();
                      },
                      icon: Icons.delete_outline,
                      label: '삭제하기',
                      backgroundColor: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ]),
                  child: GestureDetector(
                    onTap: () => Get.to(const KoreaLocation(), arguments: placeList[index]),
                    child: Card(
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'http://localhost:8080/Flutter/hotplace/image/${placeList[index]['image']}',
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
                                    placeList[index]['name'],
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
                                        placeList[index]['estimate'],
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
                                        callActionSheet(placeList[index]['phone']);
                                      },
                                      icon: const Icon(Icons.call),
                                      label: Text(placeList[index]['phone']),
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
            // } else {}
          }),
    );
  }

  showDeleteDialog() {
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

  sendDeleteJSP(index) async {
    String seq = placeList[index]['seq'];

    var url = Uri.parse('http://localhost:8080/Flutter/hotplace/delete_hotplace_list.jsp?seq=$seq');
    var response = await http.get(url);
    var convert = json.decode(utf8.decode(response.bodyBytes));
    
    var result = convert['result'];
    result == 'OK' ? showDeleteDialog() : _errorDelteSnackBar();
  }

  _errorDelteSnackBar() {
    Get.snackbar(
      '오류 발생',
      '삭제 중 오류가 발생하였습니다. 다시 시도해주세요.',
      borderColor: Colors.red, 
      colorText: Colors.white,
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
  
}