import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class KoreaLocation extends StatefulWidget {
  const KoreaLocation({super.key});

  @override
  State<KoreaLocation> createState() => _KoreaLocationState();
}

class _KoreaLocationState extends State<KoreaLocation> {
  late MapController mapController;
  var argument = Get.arguments;
  late LatLng latlng;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latlng = LatLng(argument['lat'], argument['long']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: const Row(
              children: [
                Text(
                  "나만의 ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '맛집',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 168, 14, 3)),
                ),
                Text(
                  ' 위치',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: latlng, initialZoom: 17.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(markers: [
              Marker(
                  width: 80,
                  height: 100,
                  point: latlng,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Text(
                          argument['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(
                        Icons.pin_drop,
                        size: 50,
                        color: Colors.red,
                      )
                    ],
                  )),
            ])
          ]),
    );
  }
}
