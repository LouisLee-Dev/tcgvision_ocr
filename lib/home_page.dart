import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'google_scan_page.dart';
import 'history_page.dart';
import 'models/AppConst.dart';
import 'setting_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  final int initPage;
  Home({this.initPage=0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PageController _controller;
  BannerAd _bannerAd;
  MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(testDevices: ['9fac03571f16e43057e3c16727b60f7a']);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initPage,keepPage: false,);
    _initAppCurrency();
    _initAds();
    _initFireBaseNotification();
  }

  _initAppCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currency = prefs.getString("currency");
    buyMode = prefs.getBool("buy_mode")??false;
    isLowestPrice = prefs.getBool("is_tcg_lowest_price")??true;
    if(currency!=null){
      appCurrency = currency;
    }
  }

  Future _initAds()async{
    try{
      _bannerAd = BannerAd(
        adUnitId: Platform.isIOS?adsUnitIdIOS:adsUnitIdAndroid,
        size: AdSize.fullBanner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event $event");
          if(event==MobileAdEvent.loaded){
            _bannerAd.show(anchorOffset: 0-MediaQuery.of(context).padding.bottom, anchorType: AnchorType.bottom);
          }
        },
      )..load();
    }catch(e){
      print("[Home.initAds] $e");
    }
  }

  _initFireBaseNotification()async{
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var notification;
        if(message['data']!=null){
          notification = message['data']; // android
        }else{
          notification = message; // iOS
        }
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.all(0),
              title: Text("${notification['title']}",style: TextStyle(fontWeight: FontWeight.bold),),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Text("${notification['body']}"),
              ),
              actions: [
                TextButton(
                  onPressed: ()=>Navigator.pop(dialogContext),
                  child: Text("close",style: TextStyle(color: Colors.red),),
                )
              ],
            );
          },
        );
      },
      onLaunch: (Map<String, dynamic> message) async {

      },
      onResume: (Map<String, dynamic> message) async {

      },
    );
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool topic = prefs.getBool('new_set_notification');
    if(topic==null || topic){
      _firebaseMessaging.subscribeToTopic('buylist');
    }else{
      _firebaseMessaging.unsubscribeFromTopic('buylist');
    }
  }


  @override
  void dispose() {
    _bannerAd?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (v)async{
                setState(() {
                  currentPage = v;
                });
              },
              children: [
                CameraPreviewScanner(),
                ScanHistoryPage(),
                SettingPage(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for(int i=0; i<3; i++)
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == i ? Colors.white:Colors.white.withOpacity(0.3),
                      ),
                    )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}