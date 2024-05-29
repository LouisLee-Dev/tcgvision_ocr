import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:tcgvision/models/DataBaseModel.dart';
import '../models/AppConst.dart';
import '../models/CardModel.dart';
import 'package:provider/provider.dart';
import '../models/ReferDataModel.dart';
import 'autocomplete_textfield.dart';

Future<void> showCardSetDialog(BuildContext context, ScanCard card) async{
  return await showDialog(
    context: context,
    builder: (_context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: StatefulBuilder(
          builder: (BuildContext __context,StateSetter setState){
            if(buyMode){
              return Container(
                height: MediaQuery.of(context).size.height*0.7,
                width: MediaQuery.of(context).size.width*0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        color: Colors.green,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                        child: Text("${card.selectedCard.name}",style: TextStyle(color: Colors.white,fontSize: 18), textAlign: TextAlign.center,)
                    ),
                    SizedBox(height: 4,),
                    Expanded(
                        child: GridView.count(
                          crossAxisCount:  2,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                          children: [
                            for(var c in card.cards.where((cc) => cc.condition == "Near Mint").toList())
                              InkWell(
                                onTap: (){
                                  setState((){
                                    card.selectedCard = c;
                                  });
                                },
                                child: Container(
                                  color: (card.selectedCard!=null && card.selectedCard == c)?Colors.green:Color(0xFF211f1f),
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: c.imageUrl(),
                                        placeholder: (context, url) => Image.asset('assets/images/card_ph.png'),
                                        errorWidget: (context, url, error) => Image.asset('assets/images/card_ph.png'),
                                      ),
                                      Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(c.lastUpdated==null?"":"${c.lastUpdated.replaceAll(' ', '\n')}", style: TextStyle(fontSize: 10, color: Colors.white), textAlign: TextAlign.center,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("${c.setCode??''}",style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 1,),
                                                  Text("${c.setRarity}",style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 1,),
                                                  Text("${c.edition??''}",style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 1,),
                                                  Text("\$${c.getPrice().toStringAsFixed(2)} $appCurrency", style: TextStyle(color: Colors.white,fontSize: 10, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                              Text(
                                                "\$${context.watch<ReferDataModel>().roundPrice(c.getPrice()).toStringAsFixed(2)}",
                                                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),),
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        )
                    ),
                    SizedBox(height: 4,),
                    MaterialButton(
                      onPressed: card.selectedCard==null?null:()async{
                        context.read<CardModel>().insertScanCard(card);
                        context.read<DatabaseModel>().saveCardToSQLite(card.selectedCard);
                        Navigator.pop(_context);
                      },
                      highlightColor: card.selectedCard==null?Colors.grey.withOpacity(0.9):Colors.green.withOpacity(0.9),
                      elevation: 0,
                      color: Colors.green,
                      minWidth: MediaQuery.of(context).size.width,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      height: 0,
                      child: Text("Next",style: TextStyle(color: Colors.white,fontSize: 20),),
                    )
                  ],
                ),
              );
            }

            List<TCGCard> newCards = card.cards;
            TCGCard selectedCard = buyMode?newCards[0]:card.selectedCard;
            List<String> editions = card.editions;
            List<String> conditions = card.conditions;
            List<CardSet> sets = [];
            newCards.forEach((c) {
              CardSet cardSet = sets.firstWhere((s) =>(s.setRarity==c.setRarity && s.setCode==c.setCode),orElse: ()=>null);
              if(cardSet!=null){
                cardSet.cards.add(c);
                if(!cardSet.editions.contains(c.edition))cardSet.editions.add(c.edition);
                if(!cardSet.conditions.contains(c.condition))cardSet.editions.add(c.condition);
              }else{
                sets.add(CardSet(setName: c.setName, setCode: c.setCode,setRarity: c.setRarity, cards: [c], conditions: [c.condition],editions: [c.edition]));
              }
            });
            if(sets.isNotEmpty && card.selectedSet==null){
              var selectedSet = sets.firstWhere((s) => s.cards.contains(card.selectedCard),orElse: ()=>null);
              if(selectedSet!=null){
                card.selectedSet = selectedSet;
              }else{
                card.selectedSet = sets[0];
              }
            }
            return Container(
              height: MediaQuery.of(context).size.height*0.7,
              width: MediaQuery.of(context).size.width*0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      color: Colors.green,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                      child: Text("${card.selectedCard.name}",style: TextStyle(color: Colors.white,fontSize: 18), textAlign: TextAlign.center,)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    child: Text("SET"),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount:  3,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      childAspectRatio: 2.3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      children: [
                        for(var set in sets)
                          MaterialButton(
                            onPressed: (){
                              setState((){
                                card.selectSet(set);
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minWidth: 0,
                            color: (selectedCard!=null && selectedCard.setRarity==set.setRarity && selectedCard.setCode==set.setCode)?Colors.green:Color(0xFF211f1f),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("${set.setCode}",style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 1,),
                                if(selectedCard.type=='pokemon')
                                  Text('${set.setName}', style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                Text("${set.setRarity}", style: TextStyle(color: Colors.white,fontSize: 10),maxLines: 1,),
                              ],
                            ),
                          )
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    child: Text("Edition"),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for(String edition in editions)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: MaterialButton(
                              onPressed: (){
                                setState((){
                                  card.selectEdition(edition);
                                });
                              },
                              color: (selectedCard!=null && selectedCard.edition==edition)?Colors.green:Color(0xFF211f1f),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minWidth: 0,
                              height: 0,
                              padding: EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                              child: Text("$edition",style: TextStyle(color: Colors.white),),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    child: Text("Condition"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      for(String condition in conditions)
                        MaterialButton(
                          onPressed: (){
                            setState((){
                              card.selectCondition(condition);
                            });
                          },
                          color: (selectedCard!=null && selectedCard.condition==condition)?Colors.green:Color(0xFF211f1f),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minWidth: 0,
                          height: 0,
                          padding: EdgeInsets.symmetric(vertical: 6,horizontal: 20),
                          child: Text(
                            condition.contains(" ")
                                ?"${condition.split(" ")[0][0].toUpperCase()}${condition.split(" ")[1][0].toUpperCase()}"
                                :"${condition.substring(0,2).toUpperCase()}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  selectedCard.getSitePrice(),
                  SizedBox(height: 8,),
                  MaterialButton(
                    onPressed: selectedCard==null?null:()async{
                      context.read<CardModel>().insertScanCard(card);
                      context.read<DatabaseModel>().saveCardToSQLite(card.selectedCard);
                      Navigator.pop(_context);
                    },
                    highlightColor: selectedCard==null?Colors.grey.withOpacity(0.9):Colors.green.withOpacity(0.9),
                    elevation: 0,
                    color: Colors.green,
                    minWidth: MediaQuery.of(context).size.width,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    height: 0,
                    child: Text("Next",style: TextStyle(color: Colors.white,fontSize: 20),),
                  )
                ],
              ),
            );
          },
        ),
      );
    }
  );
}

Future<void> showManualSearchDialog(BuildContext context) async{
  List<String> cardNames = [];
  CardType cardType = context.read<CardModel>().scanCardType;
  if(cardType==CardType.ygo){
    cardNames = context.read<ReferDataModel>().ygoCardNames;
  }else if(cardType==CardType.pokemon){
    cardNames = context.read<ReferDataModel>().pmCardNames;
  }else{
    cardNames = context.read<ReferDataModel>().mgCardNames;
  }
  return await showDialog(
    context: context,
    builder: (_)=> Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetAnimationDuration: Duration(milliseconds: 500),
      child: Container(
        child: SimpleAutoCompleteTextField(
          key: GlobalKey(),
          suggestions: cardNames,
          suggestionsAmount: 5,
          submitOnSuggestionTap: true,
          clearOnSubmit: false,
          textSubmitted: (v)async{
            context.showLoaderOverlay ();
            ScanCard scanCard = await context.read<CardModel>().searchCard(v);
            context.hideLoaderOverlay();
            if(scanCard!=null){
              await showCardSetDialog(context,scanCard);
            }
          },
          minLength: 1,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              isDense: true,
          ),
          style: TextStyle(fontSize: 20,color: Colors.black,),
          autoFocus: true,
        ),
      ),
    ),
  );
}