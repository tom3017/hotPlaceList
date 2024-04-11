import 'package:flutter/material.dart';
import 'package:hot_place_list_app/view/global_hot_place.dart';
import 'package:hot_place_list_app/view/korea_hot_place.dart';
import 'package:hot_place_list_app/view/my_hot_place.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '맛찜',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
          ),
        bottom: TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.all(2),
          tabs: const [
            Tab(
              icon: Icon(Icons.ballot),
              text: '나만의 맛집',
            ),
            Tab(
              icon: Icon(Icons.ballot),
              text: '한국의 맛집',
            ),
            Tab(
              icon: Icon(Icons.ballot),
              text: '세계의 맛집',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          MyHotPlace(),
          KoreaHotPlace(),
          GlobalHotPlace()
        ],
      ),
    );
  }
}
