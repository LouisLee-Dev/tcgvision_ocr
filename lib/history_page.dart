import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:tcgvision/models/AppConst.dart';
import 'package:tcgvision/models/DataBaseModel.dart';
import 'package:tcgvision/widget/card_type.dart';
import 'package:tcgvision/widget/dialogs.dart';
import 'models/CardModel.dart';

class ScanHistoryPage extends StatefulWidget {

  @override
  _ScanHistoryPageState createState() => _ScanHistoryPageState();

}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
  }



  void _onRefresh() async {
    await context.read<DatabaseModel>().getAllCardsFromSql();
    _refreshController.refreshCompleted();
    _refreshController.resetNoData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    CardType cardType = context.watch<CardModel>().scanCardType;
    List<TCGCard> histories = [];
    if(cardType==CardType.ygo){
      histories = context.watch<DatabaseModel>().scanHistories.where((c) => c.type=='ygo').toList();
    }else if(cardType==CardType.pokemon){
      histories = context.watch<DatabaseModel>().scanHistories.where((c) => c.type=='pokemon').toList();
    }else{
      histories = context.watch<DatabaseModel>().scanHistories.where((c) => c.type=='magic').toList();
    }
    histories.sort((a,b){
      return b.scanDate.compareTo(a.scanDate);
    });
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            child: CardTypeTabs(),
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 5,left: width*0.05,right: width*0.05,top: MediaQuery.of(context).padding.top-(Platform.isIOS?10:0)),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8,right: 8,bottom: 120),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey,width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 8,horizontal: 4),
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: WaterDropMaterialHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: null,
                child: histories.isEmpty?Center(child: Text("No History",style: TextStyle(color: Colors.white,fontSize: 16),),):
                ListView.builder(
                  itemCount: histories.length,
                  itemBuilder: (_,index){
                    TCGCard card = histories[index];
                    return Card(
                      child: InkWell(
                        onTap: ()async{
                          context.showLoaderOverlay();
                          ScanCard scanCard = await context.read<CardModel>().searchCard(card.name,cardId: card.id);
                          context.hideLoaderOverlay();
                          if(scanCard!=null && mounted){
                            showCardSetDialog(context,scanCard);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${card.name}, ${card.setCode}, ${card.edition}, ${card.condition}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),maxLines: 2,),
                              SizedBox(height: 4,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${card.scanDate?.substring(0,16)}",style: TextStyle(color: Colors.blue),),
                                  if(card.historyPrice!=null)
                                    Text(card.historyPrice, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}