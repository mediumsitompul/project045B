import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentLocation extends StatelessWidget {
  const CurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("CURRENT LOCATION")),
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences pref;
  late String username_pref_ = "";
  late String name_pref_ = "";



  Future<void> initial() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      username_pref_ = pref.getString('username_pref_').toString();
      name_pref_ = pref.getString('name_pref_').toString();
    });
  }

//..................................................................................................

//DECLARATION
  Location? _location;
  final Completer<GoogleMapController> _googleMapController = Completer();
  LocationData? _currentLocation;
//..................................................................................................
//no.1
  currentLocation() {
    _location?.getLocation().then((location) => _currentLocation = location);
    setState(() {
      _location?.onLocationChanged.listen((newLocation) {
        _currentLocation = newLocation;
        moveToNewPosition(LatLng(
            _currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
      });
    });
  } //..................................................................................................


//no.2
  moveToNewPosition(LatLng latLng) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 18,
    )));
  } //..................................................................................................

//no.3
  @override
  void initState() {
    _location = Location();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      currentLocation();
    });

    // TODO: implement initState
    super.initState();
    initial();
  } //..................................................................................................

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getMap(),
    );
  }

  Widget _getMap() {
    return Stack(children: [
      //=========================================================================
      //Layer-1
      GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: LatLng(0.0, 0.0), zoom: 3),
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          }),
      //=========================================================================
      //Layer-2
      Positioned.fill(
          child: Align(
        alignment: Alignment.center,
        child: _getMarker(), //ClipOval
      )),
      //=========================================================================
      //Layer-3
      Positioned(
        height: 80,
        bottom: 70,
        left: 90,
        width: 200,
        child: Card(
          color: Colors.yellowAccent,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Current Location"),
                Text('Latitude: ${(_currentLocation?.latitude).toString()}'),
                Text('Longitude: ${(_currentLocation?.longitude).toString()}'),
              ],
            ),
          ),
        ),
      ),
      //=========================================================================
    ]);
  }

//.......................................

  Widget _getMarker() {
    return Container(
      height: 40,
      width: 40,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
                color: Colors.deepOrange,
                offset: Offset(1, 1),
                spreadRadius: 6,
                blurRadius: 1)
          ]),
      child: ClipOval(
        child: Image.asset("assets/profile.jpg"),
      ),
    );
  }
}
