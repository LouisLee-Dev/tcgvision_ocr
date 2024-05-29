import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcgvision/models/AppConst.dart';
import 'package:tcgvision/models/ReferDataModel.dart';
import 'about_page.dart';

class SettingPage extends StatefulWidget {

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  bool newSetNotification = true;

  @override
  void initState() {
    _initNewSetNotification();
    super.initState();
  }

  _initNewSetNotification()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted)setState(() {
      newSetNotification = prefs.getBool("new_set_notification")??true;
    });
  }

  _changeAppCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
  }

  _changeNotificationSetting(bool value)async{
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    if(value){
      _firebaseMessaging.subscribeToTopic('buylist');
    }else{
      _firebaseMessaging.unsubscribeFromTopic('buylist');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("new_set_notification", value);
  }

  _changeBuyMode(bool v)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("buy_mode", v);
  }

  _changeTCGPrice(bool v)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_tcg_lowest_price", v);
  }


  @override
  Widget build(BuildContext context) {
    List<PriceRounding> roundings = context.watch<ReferDataModel>().roundings;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            child: Text("Settings",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 10),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 120
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey,width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: InkWell(
                        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutScreen())),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.info,color: Colors.grey,size: 35,),
                              SizedBox(width: 20,),
                              Text("About App",style: TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                      margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("  Currency",style: TextStyle(fontSize: 16,),),
                          SizedBox(height: 4,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: RaisedButton(
                                  onPressed: ()async{
                                    await _changeAppCurrency("CAD");
                                    setState(() {
                                      appCurrency = "CAD";
                                    });
                                  },
                                  child: Text("CAD",style: TextStyle(color: appCurrency=="CAD"?Colors.white:Colors.grey,fontSize: 20,fontWeight: FontWeight.bold),),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),side: BorderSide(color: appCurrency=="CAD"?Colors.red:Colors.black45)),
                                  color: appCurrency=="CAD"?Colors.red:Colors.white,
                                  elevation: 8,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              Expanded(
                                child: RaisedButton(
                                  onPressed: ()async{
                                    await _changeAppCurrency("USD");
                                    setState(() {
                                      appCurrency = "USD";
                                    });
                                  },
                                  elevation: 8,
                                  child: Text("USD",style: TextStyle(color: appCurrency=="USD"?Colors.white:Colors.grey,fontSize: 20,fontWeight: FontWeight.bold),),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),side: BorderSide(color: appCurrency=="USD"?Colors.red:Colors.black45)),
                                  color: appCurrency=="USD"?Colors.red:Colors.white,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        value: newSetNotification,
                        onChanged: (v){
                          _changeNotificationSetting(v);
                          setState(() {newSetNotification=v;});
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("New Set Notifications",style: TextStyle(color: Colors.black54,fontSize: 18),),
                        ),
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        value: buyMode,
                        onChanged: (v){
                          _changeBuyMode(v);
                          setState(() {buyMode=v;});
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Buy Mode",style: TextStyle(color: Colors.black54,fontSize: 18,),),
                        ),
                      ),
                    ),
                    if(buyMode)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("  TCGPLAYER PRICE",style: TextStyle(fontSize: 16),),
                            SizedBox(height: 4,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: ()async{
                                      await _changeTCGPrice(true);
                                      setState(() {
                                        isLowestPrice = true;
                                      });
                                    },
                                    child: Text("Lowest Price",style: TextStyle(color: isLowestPrice?Colors.white:Colors.grey,fontSize: 20,fontWeight: FontWeight.bold),),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),side: BorderSide(color: isLowestPrice?Colors.red:Colors.black45)),
                                    color: isLowestPrice?Colors.red:Colors.white,
                                    elevation: 8,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: ()async{
                                      await _changeTCGPrice(false);
                                      setState(() {
                                        isLowestPrice = false;
                                      });
                                    },
                                    elevation: 8,
                                    child: Text("Market Price",style: TextStyle(color: isLowestPrice?Colors.grey:Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),side: BorderSide(color: isLowestPrice?Colors.black45:Colors.red)),
                                    color: isLowestPrice?Colors.white:Colors.red,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if(buyMode)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("  PRICE %",style: TextStyle(fontSize: 16),),
                            for(PriceRounding r in roundings)
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(width: 4,),
                                    Flexible(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(2),
                                            isDense: true,
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(text: "${r.start??''}"),
                                          onChanged: (v){
                                            r.start = double.tryParse(v);
                                          },
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("To"),
                                    ),
                                    Flexible(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(2),
                                            isDense: true,
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(text: "${r.end??''}"),
                                          onChanged: (v){
                                            r.end = double.tryParse(v);
                                          },
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("="),
                                    ),
                                    Flexible(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(2),
                                            isDense: true,
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(text: "${r.value??''}"),
                                          onChanged: (v){
                                            r.value = double.tryParse(v);
                                          },
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("%"),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        context.read<ReferDataModel>().removePriceRounding(r);
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.close, color: Colors.red,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            SizedBox(height: 8,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MaterialButton(
                                  onPressed: (){
                                    context.read<ReferDataModel>().addPriceRounding();
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                  child: Text("+Add"),
                                  minWidth: 0,
                                  color: Colors.blue,
                                  height: 30,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                SizedBox(width: 20,),
                                MaterialButton(
                                  onPressed: (){
                                    context.read<ReferDataModel>().savePriceRoundings();
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                  child: Text("Save"),
                                  minWidth: 0,
                                  color: Colors.red,
                                  height: 30,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                SizedBox(width: 20,),
                              ],
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
    );
  }
}