import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tcgvision/config.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About APP"),
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Text("App Version: 1.0.3",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Text("Created By Philippe Vernier & Li Qiang",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "We are a participant in the Ebay Associates Program, an affiliate advertising program designed to provide a means for us to earn fees by linking to Ebay.com and affiliated sites.\nWe are a participant in the Tcgplayer Associates Program, an affiliate advertising program designed to provide a means for us to earn fees by linking to tcgplayer.com and affiliated sites. \nCard images are copyright by the game provider. This application is not produced, endorsed, supported nor affiliated with any game provider.",
                  style: TextStyle(color: Colors.white,fontSize: 18,),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(color: Colors.white,),
              Text("Check our other Apps & Mobile Apps:",style: TextStyle(color: Colors.white,fontSize: 14),),
              Image.asset("assets/about/tcgpawnshopicon.png",width: 100,height: 100,),
              Text("TCG PAWNSHOP",style: TextStyle(color: Colors.white,fontSize: 20),),
              SizedBox(height: 20,),
              Platform.isAndroid?InkWell(
                  onTap: ()=>launch('https://play.google.com/store/apps/details?id=com.golden.star.tcgpawnshop'),
                  child: Image.asset("assets/about/google.png",height: 50,)
              ):InkWell(
                  onTap: ()=>launch('https://apps.apple.com/us/app/tcg-pawnshop/id1548267640'),
                  child: Image.asset("assets/about/apple.png",height: 50,)
              ),
              SizedBox(height: 20,),
              Image.asset("assets/about/tcg_card_value.png",width: 100,height: 100,),
              Text("TCG CARD VALUE",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
              InkWell(
                  onTap: ()async{
                    const url = 'http://www.tcgcardvalue.com';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child: Text("www.tcgcardvalue.com",style: TextStyle(color: Colors.white,fontSize: 16,decoration: TextDecoration.underline),)
              ),
              SizedBox(height: 20,),
              Image.asset("assets/about/tcg_estimator.png",width: 100,height: 100,),
              Text("TCG CARD VALUE ESTIMATOR",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
              InkWell(
                  onTap: ()async{
                    const url = 'http://www.tcgcardvalueestimator.com';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child: Text("www.tcgcardvalueestimator.com",style: TextStyle(color: Colors.white,fontSize: 16,decoration: TextDecoration.underline),)
              ),
              SizedBox(height: 120,),
            ],
          ),
        ),
      ),
    );
  }
}