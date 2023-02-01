import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(
      const MaterialApp(
        home: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationWidget2(),
    );
  }
}

class LocationWidget2 extends StatefulWidget {
  const LocationWidget2({super.key});

  @override
  State<LocationWidget2> createState() => _LocationWidget2State();
}

class _LocationWidget2State extends State<LocationWidget2> {
  late StreamSubscription<Position> _positionStreamSubscription;
  final TextEditingController _textEditingController = TextEditingController();
  Position? _currentLocation;
  Position _selectedLocation = Position(
    latitude: 11.0550722,
    longitude: 76.0561644,
    accuracy: 1.0,
    altitude: 1.0,
    heading: 1.0,
    speed: 1.0,
    speedAccuracy: 1.0,
    timestamp: DateTime.now(),
  );
  double _meter = 1;
  double _distance = 0;
  String _distanceText = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high))
            .listen((Position position) {
      setState(() {
        _currentLocation = position;
        _distanceText = _getDistanceText();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  void _changeMeter(double meter) {
    setState(() {
      _meter = meter;
    });
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void _updateSelectedLocation() async {
    Position targetLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = targetLocation;
    });
  }

  String _getDistanceText() {
    if (_currentLocation == null) {
      return 'Loading...';
    }
    double distanceInMeters = Geolocator.distanceBetween(_currentLocation!.latitude, _currentLocation!.longitude,
        _selectedLocation.latitude, _selectedLocation.longitude);
    setState(() {
      _distance = distanceInMeters;
    });

    return distanceInMeters <= _meter ? 'Within ${_meter}m' : 'More than ${_meter}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: _updateSelectedLocation, child: const Text('Select Starting location')),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(hintText: 'Enter Meter'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _changeMeter(double.parse(value));
                    },
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 100,
            ),
            Text(
              'Current Location: ${_currentLocation?.latitude ?? 'dasda'}, ${_currentLocation?.longitude ?? 'wdiquywugdwq'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Selected Location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}'),
            Text(_distanceText),
            Text(_distance.toString()),
          ],
        ),
      ),
    );
  }
}
