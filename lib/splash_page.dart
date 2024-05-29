import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcgvision/home_page.dart';
import 'package:tcgvision/models/ReferDataModel.dart';
import 'config.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value)async{
      bool result = await context.read<ReferDataModel>().getMGCardsFromLocal();
      await context.read<ReferDataModel>().getPriceRoundings();
      if(result){
        context.read<ReferDataModel>().getReferDataFromServer();
      }else{
        await context.read<ReferDataModel>().getReferDataFromServer();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home(initPage: 0,)));
    });
  }


  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width-100;
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/app_logo.png",
          width: imageSize,
          height: imageSize,
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}