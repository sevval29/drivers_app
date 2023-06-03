




//import 'dart:async';


import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/Models/allUsers.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Models/rideDetails.dart';
import '../configMaps.dart';
import '../main.dart';
import 'dart:io' show Platform;

import 'notificationDialog.dart';

class PushNotificationService
{
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(context) async {
    // Bildirim olaylarını dinlemek için gerekli olan configure metodu kullanılıyor.
    print("***********************/////****************/*/*/*/*/");



    // onMessage: When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage data: ${message.data}");
      getRideRequestId(message.data);
      retrieveRideRequestInfo(getRideRequestId(message.data),context);
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      getRideRequestId(message.data);
      retrieveRideRequestInfo(getRideRequestId(message.data),context);

    });

/*
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('getInitialMessage data: ${initialMessage.data}');
      getRideRequestId(initialMessage!.data as Map<String, dynamic>);
    }
*/
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      print('getInitialMessage data: ${message.data}');
      getRideRequestId(message!.data as Map<String, dynamic>);
      retrieveRideRequestInfo(getRideRequestId(message.data),context);
      print("*********************/////////////////************************");
      retrieveRideRequestInfo(getRideRequestId(message!.data as Map<String, dynamic>),context);
      Map<String, dynamic> convertedData = Map<String, dynamic>.from(message.data);
     // Map<String, dynamic> data = Map<String, dynamic>.from(message.data as Map);
      retrieveRideRequestInfo(getRideRequestId(convertedData),context);
    }




  }

  Future<String> getToken() async {
    await firebaseMessaging.requestPermission();
    String? token = await firebaseMessaging.getToken();
    print("This is token: $token");

   // if (token != null) {
      driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
   // }

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");

    return token!;
  }






  String getRideRequestId(Map<String, dynamic> message)
  {

    String rideRequestId = "";
    if(Platform.isAndroid)
    {
      print("this is Ride request ıd::");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }
    else
    {
      print("this is Ride request ıd::");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }

    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context)
  {DatabaseReference reference = FirebaseDatabase.instance.reference().child("Ride Requests").child(rideRequestId);

  reference.once().then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;


      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      if(snapshot.value != null)
      {
        assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();


        double pickUpLocationLat = double.parse(data['pickup']['latitude'].toString());
        double pickUpLocationLng = double.parse(data['pickup']['longitude'].toString());
        double dropOffLocationLat = double.parse(data['dropoff']['latitude'].toString());
        double dropOffLocationLng = double.parse(data['dropoff']['longitude'].toString());
        String pickUpAddress = data['pickup_address'].toString();
        String dropOffAddress = data['dropoff_address'].toString();
        String paymentMethod=data['payment_method'].toString();
        String rider_name=data['rider_name'].toString();
        String rider_phone=data['rider_phone'].toString();


       // String paymentMethod = dataSnapShot.value['payment_method'].toString();

       // String rider_name = dataSnapShot.value["rider_name"];
       // String rider_phone = dataSnapShot.value["rider_phone"];

        RideDetails rideDetails = RideDetails(pickup_address: '', dropoff_address: '', pickup: null, dropoff: null, ride_request_id: '', payment_method: '', rider_name: '', rider_phone: '');
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;
       rideDetails.rider_name = rider_name;
       rideDetails.rider_phone = rider_phone;

        print("Information :: ");
        print(rideDetails.pickup_address);
        print(rideDetails.dropoff_address);
        print(rideDetails.rider_name);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
        );

  /*
  void retrieveRideRequestInfo(String rideRequestId ,BuildContext context ) async {

  static RideDetails fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

    // Verileri doğru şekilde alın
    double pickUpLocationLat = double.parse(data['pickup']['latitude'].toString());
    double pickUpLocationLng = double.parse(data['pickup']['longitude'].toString());
    double dropOffLocationLat = double.parse(data['dropoff']['latitude'].toString());
    double dropOffLocationLng = double.parse(data['dropoff']['longitude'].toString());
    String pickUpAddress = data['pickup_address'].toString();
    String dropOffAddress = data['dropoff_address'].toString();

    RideDetails rideDetails = RideDetails(
        pickup_address: pickUpAddress,
        dropoff_address: dropOffAddress,
        pickup: LatLng(pickUpLocationLat, pickUpLocationLng),
    dropoff: LatLng(dropOffLocationLat, dropOffLocationLng), ride_request_id: '', payment_method: '',




  void retrieveRideRequestInfo(String rideRequestId ,BuildContext context ) async {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Ride Requests").child(rideRequestId);

    reference.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        RideDetails rideDetails = RideDetails.fromSnapshot(snapshot);
        print("**********");
        print(rideDetails);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
        );

      } else {
        print("*****************");
      }



    });


  }*/


};
  }
  );
  }



}













