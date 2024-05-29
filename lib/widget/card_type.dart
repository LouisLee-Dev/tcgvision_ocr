import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcgvision/models/AppConst.dart';
import 'package:tcgvision/models/CardModel.dart';


class CardTypeTabs extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width/4;
    CardType cardType = context.watch<CardModel>().scanCardType;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            onTap: (){
              context.read<CardModel>().changeScanMode(CardType.ygo);
            },
            child: Image.asset('assets/images/${cardType==CardType.ygo?'ygo-logo-selected':'ygo-logo'}.png',width: width,)
          ),
          InkWell(
            onTap: (){
              context.read<CardModel>().changeScanMode(CardType.pokemon);
            },
            child: Image.asset('assets/images/${cardType==CardType.pokemon?'pokemon-logo-selected':'pokemon-logo'}.png',width: width,)
          ),
          InkWell(
            onTap: (){
              context.read<CardModel>().changeScanMode(CardType.magic);
            },
            child: Image.asset('assets/images/${cardType==CardType.magic?'magic-logo-selected':'magic-logo'}.png',width: width,)
          ),
        ],
      ),
    );
  }
}