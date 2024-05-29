import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'AppConst.dart';

class ReferDataModel with ChangeNotifier{
  bool isLoading = true;
  final LocalStorage storage = LocalStorage('tcg_vision');
  List<String> ygoCardNames = [];
  List<String> pmCardNames = [];
  List<String> mgCardNames = [];
  List<PriceRounding> roundings = [];

  Future getReferDataFromServer()async{
    isLoading = true;
    notifyListeners();
    await getMGCardNamesFromServer();
    await getPMCardNamesFromServer();
    await getYGOCardNamesFromServer();
    isLoading = false;
    notifyListeners();
  }

  getYGOCardNamesFromServer()async{
    try{
      var res = await http.get(
          AppConst.getYGOCardNames,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          }
      );
      print("[ReferDataModel.getYGOCardNamesFromServer] ${res.body}");
      if(res.statusCode==200){
        ygoCardNames = [];
        for(var card in jsonDecode(res.body)){
          ygoCardNames.add(card);
        }
        await saveYGOCardsToLocal();
      }
    }catch(e){
      print("[ReferDataModel.getYGOCardNamesFromServer] $e");
    }
  }
  getPMCardNamesFromServer()async{
    try{
      var res = await http.get(
          AppConst.getPMCardNames,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          }
      );

      print("[ReferDataModel.getPMCardNamesFromServer] ${res.body}");
      if(res.statusCode==200){
        pmCardNames = [];
        for(var card in jsonDecode(res.body)){
          pmCardNames.add(card);
        }
        await savePMCardsToLocal();
      }
    }catch(e){
      print("[ReferDataModel.getPMCardNamesFromServer] $e");
    }
  }
  getMGCardNamesFromServer()async{
    try{
      var res = await http.get(
          AppConst.getMGCardNames,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          }
      );

      print("[ReferDataModel.getMGCardNamesFromServer] ${res.body}");
      if(res.statusCode==200){
        mgCardNames = [];
        for(var card in jsonDecode(res.body)){
          mgCardNames.add(card);
        }
        await saveMGCardsToLocal();
      }
    }catch(e){
      print("[ReferDataModel.getMGCardNamesFromServer] $e");
    }
  }

  saveYGOCardsToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('ygo_card_name_list', ygoCardNames);
    }catch(e){
      print("[ReferDataModel.saveYGOCardsToLocal] $e");
    }
  }
  savePMCardsToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('pm_card_name_list', pmCardNames);
    }catch(e){
      print("[ReferDataModel.savePMCardsToLocal] $e");
    }
  }
  saveMGCardsToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('mg_card_name_list', mgCardNames);
    }catch(e){
      print("[ReferDataModel.saveMGCardsToLocal] $e");
    }
  }

  Future<bool> getYGOCardsFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var cardsJson = await storage.getItem('ygo_card_name_list');
        if(cardsJson!=null){
          ygoCardNames = [];
          ygoCardNames = cardsJson.cast<String>();
          notifyListeners();
          return true;
        }
      }
    }catch(e){
      print("[ReferDataModel.getYGOCardsFromLocal] $e");
    }
    return false;
  }

  Future<bool> getPMCardsFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var cardsJson = await storage.getItem('pm_card_name_list');
        if(cardsJson!=null){
          pmCardNames = [];
          pmCardNames = cardsJson.cast<String>();
          notifyListeners();
          return true;
        }
      }
    }catch(e){
      print("[ReferDataModel.getPMCardsFromLocal] $e");
    }
    return false;
  }

  Future<bool> getMGCardsFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var cardsJson = await storage.getItem('mg_card_name_list');
        if(cardsJson!=null){
          mgCardNames = [];
          mgCardNames = cardsJson.cast<String>();
          notifyListeners();
          return true;
        }
      }
    }catch(e){
      print("[ReferDataModel.getMGCardsFromLocal] $e");
    }
    return false;
  }

  Future<void> getPriceRoundings()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('price_roundings');
        if(json!=null){
          for(var j in json){
            roundings.add(PriceRounding.fromJson(j));
          }
          notifyListeners();
        }
      }
    }catch(e){
      print("[ReferDataModel.getPriceRoundings] $e");
    }
  }

  savePriceRoundings()async{
    try{
      roundings.removeWhere((r) => !r.validate());
      bool storageReady = await storage.ready;
      if(storageReady){
        storage.setItem('price_roundings', roundings.map((r) => r.toJson()).toList());
      }
      notifyListeners();
    }catch(e){
      print("[ReferDataModel.getPriceRoundings] $e");
    }
  }

  addPriceRounding(){
    roundings.add(PriceRounding());
    notifyListeners();
  }

  removePriceRounding(PriceRounding r){
    roundings.remove(r);
    notifyListeners();
  }

  double roundPrice(double price){

    for(PriceRounding r in roundings){
      if(r.validate()){
        if(r.start <= price && r.end >= price){
          return price * r.value /100;
        }
      }
    }
    return price;
  }

}

class PriceRounding{

  double start;
  double end;
  double value;

  PriceRounding({
    this.start,
    this.end,
    this.value
  });

  PriceRounding.fromJson(Map<String, dynamic> json){
    start = json['start'];
    end = json['end'];
    value = json['value'];
  }

  Map<String, dynamic> toJson(){
    return {
      'start':start,
      'end':end,
      'value':value
    };
  }

  bool validate(){
    if(start==null || end == null || value==null) return false;
    if(start<0 || end<0 || value<0) return false;
    return true;
  }
}