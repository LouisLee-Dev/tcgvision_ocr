import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'config.dart';
import 'models/CardModel.dart';
import 'models/DataBaseModel.dart';
import 'models/ReferDataModel.dart';
import 'splash_page.dart';

void main(){
  runApp(
      MultiProvider(
          providers:[
            ChangeNotifierProvider(create: (_) => CardModel()),
            ChangeNotifierProvider(create: (_) => ReferDataModel(),),
            ChangeNotifierProvider(create: (_) => DatabaseModel(),lazy: false,),
          ],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FirebaseAdMob.instance.initialize(appId: Platform.isIOS?adsAppIdIOS:adsAppIdAndroid);
    return GlobalLoaderOverlay(
      overlayColor: Colors.black.withOpacity(0.6),
      overlayOpacity: 1,
      useDefaultLoading: false,
      overlayWidget: Center(child: CircularProgressIndicator()),
      child: MaterialApp(
        title: 'TCG VISION',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(primaryColor),
          splashColor: Color(primaryColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

