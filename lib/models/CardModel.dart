import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AppConst.dart';


class CardModel with ChangeNotifier{

  List<ScanCard> scanCards = [];
  List<ScanCard> notificationCards = [];
  final LocalStorage storage = LocalStorage('tcg_vision');
  CardType scanCardType = CardType.ygo;

  Future<ScanCard> searchCard(String name,{int cardId})async{
    try{
      String url;
      if(scanCardType == CardType.ygo){
        url = AppConst.searchYGOCard;
      }else if(scanCardType == CardType.pokemon){
        url = AppConst.searchPMCard;
      }else if(scanCardType == CardType.magic){
        url = AppConst.searchMGCard;
      }
      var res = await http.post(
          url,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'name':name,
            'currency':appCurrency
          }
      );
      print("[CardModel.searchCard] ${res.body}");
      if(res.statusCode==200){
        List<TCGCard> cards = [];
        List<String> conditions = [];
        List<String> editions = [];
        List<String> rarities = [];

        for(var json in jsonDecode(res.body)){
          TCGCard card;
          if(scanCardType == CardType.ygo){
            card = TCGCard.fromYGOJson(json);
          }else if(scanCardType == CardType.pokemon){
            card = TCGCard.fromPMJson(json);
          }else if(scanCardType == CardType.magic){
            card = TCGCard.fromMGJson(json);
          }
          cards.add(card);
          if(card.condition!=null && card.condition.isNotEmpty && !conditions.contains(card.condition)){
            conditions.add(card.condition);
          }
          if(card.edition!=null && card.edition.isNotEmpty && !editions.contains(card.edition)){
            editions.add(card.edition);
          }
          if(card.setRarity!=null && card.setRarity.isNotEmpty && !rarities.contains(card.setRarity)){
            rarities.add(card.setRarity);
          }
        }
        if(cards.isNotEmpty){
          TCGCard selectedCard;
          if(cardId!=null){
            selectedCard = cards.firstWhere((c) => c.id == cardId,orElse: ()=>null);
          }else{
            selectedCard = cards.firstWhere((c) => c.condition=="Near Mint", orElse: ()=>null);
          }
          if(selectedCard==null){
            selectedCard = cards[0];
          }
          ScanCard scanCard = ScanCard(
            cards: cards,
            conditions:conditions,
            editions: editions,
            rarities: rarities,
            selectedCard: selectedCard,
          );
          notifyListeners();
          return scanCard;
        }
      }
    }catch(e){
      print("[CardModel.searchCard] $e");
    }
    return null;
  }

  removeNotificationCard(ScanCard card){
    notificationCards.remove(card);
    notifyListeners();
  }

  insertNotificationCard(ScanCard scanCard){
    notifyListeners();
  }

  insertScanCard(ScanCard scanCard){
    notificationCards.insert(0, scanCard);
    scanCards.insert(0, scanCard);
    notifyListeners();
  }

  changeScanMode(CardType type){
    scanCardType = type;
    notifyListeners();
  }

}

class ScanCard{
  List<TCGCard> cards;
  TCGCard selectedCard;
  CardSet selectedSet;
  List<String> conditions;
  List<String> editions;
  List<String> rarities;

  ScanCard({
    this.cards,
    this.conditions,
    this.editions,
    this.rarities,
    this.selectedCard,
    this.selectedSet,
  });


  selectSet(CardSet set){
    selectedSet = set;
    selectedCard = set.cards.firstWhere((c) => c.condition == 'Near Mint' ,orElse: ()=>null);
  }

  selectCondition(String condition){
    TCGCard newCard;
    if(selectedCard!=null){
      newCard = selectedSet.cards.firstWhere((c) => (c.edition==selectedCard.edition && c.condition==condition),orElse: ()=>null);
    }else{
      newCard = selectedSet.cards.firstWhere((c) => c.condition==condition,orElse: ()=>null);
    }
    if(newCard!=null){
      selectedCard = newCard;
    }
  }

  selectEdition(String edition){
    TCGCard newCard;
    if(selectedCard!=null){
      newCard = selectedSet.cards.firstWhere((c) => (c.edition==edition && c.condition==selectedCard.condition),orElse: ()=>null);
    }else{
      newCard = selectedSet.cards.firstWhere((c) => c.edition==edition,orElse: ()=>null);
    }
    if(newCard!=null){
      selectedCard = newCard;
    }
  }
}

class CardSet{
  String setCode;
  String setName;
  String setRarity;
  List<TCGCard> cards;
  List<String> conditions;
  List<String> editions;

  CardSet({
    this.setName,
    this.setCode,
    this.setRarity,
    this.cards,
    this.conditions,
    this.editions
  });
}

class TCGCard{
  int id;
  int cardId;
  String type;
  String name;
  String setName;
  String setCode;
  String setRarity;
  String edition;
  String condition;

  String lastUpdated;

  String ebayCaUrl;
  String ebayComUrl;
  String tcgUrl;
  String scanDate;

  List<CardPrice> prices = [];

  double tcgCADLowestPrice;
  double tcgUSDLowestPrice;
  double tcgCADMarketPrice;
  double tcgUSDMarketPrice;
  String historyPrice;


  TCGCard.fromYGOJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      type = 'ygo';
      name = json['name'];
      setCode = json['set_code'];
      setName = json['set_name'];
      setRarity = json['set_rarity'];
      edition = json['edition'];
      condition = json['condition'];
      lastUpdated = json['last_updated'];
      ebayCaUrl = json['ebay_ca_aff_urls'];
      ebayComUrl = json['ebay_com_aff_urls'];
      tcgUrl = json['tcg_url'];
      if(json['prices']!=null){
        for(var p in json['prices']){
          prices.add(CardPrice.fromJson(p));
        }
      }
      tcgCADLowestPrice = json['tcg_avg_cad_low']??0.0;
      tcgUSDLowestPrice = json['tcg_avg_usd_low']??0.0;
      tcgCADMarketPrice = json['tcg_market_price_cad']??0.0;
      tcgUSDMarketPrice = json['tcg_market_price']??0.0;
    }catch(e){
      print("[Card.fromYGOJson] $e");
    }
  }

  TCGCard.fromPMJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      type = 'pokemon';
      name = json['card_name'];
      setCode = json['set_number'];
      setName = json['set_name'];
      setRarity = json['rarity'];
      edition = json['edition'];
      condition = json['condition'];
      lastUpdated = json['last_updated'];
      ebayCaUrl = json['ebayca_aff_urls'];
      ebayComUrl = json['ebay_com_aff_urls'];
      tcgUrl = json['tcg_url_aff'];
      if(json['prices']!=null){
        for(var p in json['prices']){
          prices.add(CardPrice.fromJson(p));
        }
      }

      tcgCADLowestPrice = json['tcg_low_cad']??0.0;
      tcgUSDLowestPrice = json['tcg_low_usd']??0.0;
      tcgCADMarketPrice = json['tcg_market_price_cad']??0.0;
      tcgUSDMarketPrice = json['tcg_market_price_usd']??0.0;
    }catch(e){
      print("[Card.fromPMJson] $e");
    }
  }

  TCGCard.fromMGJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      cardId = json['card_id'];
      type = 'magic';
      name = json['name'];
      setCode = json['set_code'];
      setName = json['set_name'];
      setRarity = json['rarity'];
      edition = json['edition'];
      condition = json['condition'];

      lastUpdated = json['last_updated'];

      ebayCaUrl = json['ebayca_aff_url'];
      ebayComUrl = json['ebaycom_aff_url'];
      tcgUrl = json['tcg_aff_url'];
      if(json['prices']!=null){
        for(var p in json['prices']){
          prices.add(CardPrice.fromJson(p));
        }
      }

      tcgCADLowestPrice = json['tcg_low_cad']??0.0;
      tcgUSDLowestPrice = json['tcg_low_usd']??0.0;
      tcgCADMarketPrice = json['tcg_market_price_cad']??0.0;
      tcgUSDMarketPrice = json['tcg_market_price_usd']??0.0;

      if(json['prices']!=null){
        for(var p in json['prices']){
          prices.add(CardPrice.fromJson(p));
        }
      }
    }catch(e){
      print("[Card.fromYGOJson] $e");
    }
  }

  TCGCard.fromHistoryJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      type = json['type'];
      name = json['name'];
      setCode = json['set_code'];
      setRarity = json['set_rarity'];
      edition = json['edition'];
      condition = json['condition'];
      scanDate = json['scan_date'];
      historyPrice = json['price'];
    }catch(e){
      print("[Card.fromHistoryJson] $e");
    }
  }

  double toDouble(json){
    if(json!=null){
      return double.parse(double.parse(json.toString()).toStringAsFixed(2),(_)=>0.0);
    }
    return 0;
  }

  Widget getSitePrice(){
    try{
      if(condition=='Near Mint'){
        return Container(
          height: 100,
          width: double.infinity,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                for(var price in prices)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: ()async{
                        addClickHistory(price.siteName, price.url);
                        if(await canLaunch(price.url)){
                          launch(price.url);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/sites/${price.siteKey}.png',height: 50,),
                          Text(price.siteKey=='tcgplayer'?'In Stock':price.inventory==0?'Out of Stock':'${price.inventory} Listings',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                          Text('Lowest Price:', style: TextStyle(fontSize: 12),),
                          Text('\$${price.price.toStringAsFixed(2)} ${price.currency}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      }
      var tcgPrice = prices.firstWhere((v) => v.siteKey=='tcgplayer',orElse: ()=>null);
      if(tcgPrice!=null){
        double price = tcgPrice.price;
        if(condition=='Slightly Played'){
          price = price*0.85;
        }else if(condition=='Moderately Played'){
          price = price*0.65;
        }else if(condition=='Heavily Played'){
          price = price*0.50;
        }
        return Container(
          height: 100,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Base on this card, here is the market price for a MP cards', style: TextStyle(fontSize: 12),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 100),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Near Mint',style: TextStyle(fontSize: 12),),
                        Text('100%',style: TextStyle(fontSize: 12),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Slightly Played',style: TextStyle(fontSize: 12),),
                        Text('85%',style: TextStyle(fontSize: 12),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Moderately Played',style: TextStyle(fontSize: 12),),
                        Text('65%',style: TextStyle(fontSize: 12),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Heavily Played',style: TextStyle(fontSize: 12),),
                        Text('50%',style: TextStyle(fontSize: 12),),
                      ],
                    ),
                  ],
                ),
              ),
              Text("\$${price.toStringAsFixed(2)} ${tcgPrice.currency}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
            ],
          ),
        );
      }
    }catch(e){
      print('[TCGCard.getSitePrice]$e');
    }
    return SizedBox(height: 100,);
  }

  addClickHistory(String storeName,String url)async{
    try{
      var res = await http.post(
          AppConst.addClickHistory,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'id':id.toString(),
            'type':type,
            'store_name':storeName,
            'store_url':url
          }
      );
      print("[TCGCard.addClickHistory] ${res.body}");
    }catch(e){
      print("[TCGCard.searchCard] $e");
    }
    return null;
  }

  String imageUrl(){
    if(type=='ygo'){
      if(isNotEmpty(setCode) && isNotEmpty(setRarity) && isNotEmpty(edition)){
        return 'https://www.ygolegacystore.com/static/img_ygo/${setCode.toLowerCase()}_${setRarity.replaceAll(' ', '_').toLowerCase()}_${edition.replaceAll(' ', '_').toLowerCase()}.jpg';
      }
    }
    if(type=='pokemon'){
      if(isNotEmpty(setName) && isNotEmpty(setCode) && isNotEmpty(name)){
        return 'https://www.ygolegacystore.com/static/img_pkm/${setName.replaceAll(' ', '_').toLowerCase()}_${setCode}_${name.replaceAll(' ', '_').toLowerCase()}.jpg';
      }
    }
    if(type=='magic'){
      return 'https://www.ygolegacystore.com/static/img_magic/${cardId}_${name.replaceAll('/', '_').replaceAll(' ', '_').toLowerCase()}.jpg';
    }
    return '';
  }

  bool isNotEmpty(String v){
    return v!=null && v.isNotEmpty;
  }

  double getPrice(){
    if(appCurrency=="CAD"){
      if(isLowestPrice){
        return tcgCADLowestPrice??0.0;
      }
      return tcgCADMarketPrice??0.0;
    }else{
      if(isLowestPrice){
        return tcgUSDLowestPrice??0.0;
      }
      return tcgUSDMarketPrice??0.0;
    }
  }

}

class CardPrice{
  String siteName;
  String siteKey;
  int inventory;
  String currency;
  double price;
  String date;
  String time;
  String url;

  CardPrice.fromJson(List json){
    try{
      siteName = json[0];
      siteKey = json[1];
      inventory = int.parse(json[2].toString(),onError: (_)=>0);
      currency = json[3];
      price = double.tryParse(json[4].toString());
      date = json[5];
      time = json[6];
      url = json[7];
    }catch(e){
      print('[CardPrice.fromJson] $e');
    }
  }
}