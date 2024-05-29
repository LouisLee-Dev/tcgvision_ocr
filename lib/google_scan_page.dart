import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tcgvision/models/AppConst.dart';
import 'package:tcgvision/widget/card_type.dart';
import 'models/CardModel.dart';
import 'models/ReferDataModel.dart';
import 'widget/carmera_overlay.dart';
import 'widget/detector_painter.dart';
import 'widget/dialogs.dart';
import 'widget/scanner_utils.dart';
import 'package:provider/provider.dart';

class CameraPreviewScanner extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> with SingleTickerProviderStateMixin{

  static CameraController _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  CameraDescription description;
  bool isSearching = false;
  bool lampOn = false;
  TextBlock _scanResult;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    super.initState();
    _initializeCamera();

  }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
    closeScanPage();
  }

  void _initializeCamera() async {
    description = await ScannerUtils.getCamera(_direction);
    _camera = CameraController(
        description,
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.medium
            : ResolutionPreset.high,
        enableAudio: false
    );

    _camera?.initialize()?.whenComplete((){
      setState(() {});
    })?.catchError((e)=>print('[_initializeCamera]$e'));
  }

  _startImageStream(){
    _camera.startImageStream((CameraImage image) {
      if(context==null || !this.mounted)return;
      if (_isDetecting) return;
      _isDetecting = true;
      ScannerUtils.detect(
        image: image,
        detectInImage: _recognizer.processImage,
        imageRotation: description.sensorOrientation,
      ).then((dynamic results) {
        cardScan(results);
      },
      ).whenComplete(() => _isDetecting = false);
    }).catchError((e)=>print('[_startImageStream]$e'));
  }

  closeScanPage()async{
    if(_camera!=null){
      await _recognizer.close();
      if(_camera.value.isStreamingImages){
        await _camera.stopImageStream();
      }
      Future.delayed(Duration(milliseconds: 100));
      await _camera?.dispose();
    }
  }

  cardScan(VisionText visionText)async{
    try{
      List<String> cardNames = [];
      final scanType = context.read<CardModel>().scanCardType;
      if(scanType==CardType.ygo){
        cardNames = context.read<ReferDataModel>().ygoCardNames;
      }else if(scanType==CardType.pokemon){
        cardNames = context.read<ReferDataModel>().pmCardNames;
      }else if(scanType==CardType.magic){
        cardNames = context.read<ReferDataModel>().mgCardNames;
      }
      if(cardNames.isEmpty)return;
      for(int b=0; b<visionText.blocks.length; b++){
        var block = visionText.blocks[b];
        if(cardNames.firstWhere((n) => (n.toLowerCase()==block.text.toLowerCase()),orElse: ()=>null)!=null){
          if(mounted)setState(() {_scanResult = block;});
          if(isSearching)return;
          _camera.stopImageStream();
          _animationController.reset();
          isSearching = true;
          context.showLoaderOverlay();
          ScanCard scanCard = await context.read<CardModel>().searchCard(block.text);
          context.hideLoaderOverlay();
          if(scanCard!=null && mounted){
            await showCardSetDialog(context,scanCard);
          }
          isSearching = false;
        }else{
          if(mounted)setState(() {_scanResult = null;});
        }
      }
    }catch(e){
      print("[cardScan] $e");
      isSearching = false;
    }
  }

  setIsSearching(bool b){
    isSearching = b;
  }

  Widget _buildResults() {
    if (_scanResult == null || _camera == null || !_camera.value.isInitialized) {
      return SizedBox();
    }
    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
    var painter = TextDetectorPainter(imageSize, _scanResult);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final scanType = context.watch<CardModel>().scanCardType;

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: Color(0xFF211f1f),
        child: SingleChildScrollView(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: (_camera==null)
                    ?CircularProgressIndicator()
                    :SizedBox(
                      width: width*0.9,
                      child: AspectRatio(
                        aspectRatio: _camera.value.aspectRatio,
                        child: CameraPreview(_camera)
                      ),
                    ),
                ),
                if(_camera!=null && _camera.value.isInitialized)
                  Center(
                      child:SizedBox(
                        width: width*0.9,
                        child: AspectRatio(
                            aspectRatio: _camera.value.aspectRatio,
                            child: _buildResults()
                        ),
                      )
                  ),
                if(_camera!=null && _camera.value.isInitialized)
                Container(
                  decoration: ShapeDecoration(
                    shape: ScannerOverlayShape(
                        borderColor: Colors.white,
                        borderWidth: 7.0,
                        aspectRadio: _camera.value.aspectRatio
                    ),
                  ),
                ),
                if(_camera!=null && _camera.value.isInitialized)
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100,
                      child: Center(
                        child: GestureDetector(
                          onTap: (){
                            print(_camera.value.isStreamingImages);
                            if(_camera.value.isStreamingImages){
                              _camera.stopImageStream();
                              _animationController.reset();
                            }else{
                              _startImageStream();
                              _animationController.repeat();
                            }
                          },
                          child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                              child: Image.asset("assets/images/${scanType==CardType.ygo?"ygo_btn.png":scanType==CardType.pokemon?"pokemon_btn.png":"magic_btn.png"}", height: 60,)
                          )
                        ),
                      )
                  ),
                if(_camera!=null && _camera.value.isInitialized)
                  Positioned(
                    bottom: (MediaQuery.of(context).size.height-_camera.value.previewSize.height)/2+50,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: ()async{
                              isSearching = true;
                              await showManualSearchDialog(context);
                              isSearching = false;
                            },
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.search_rounded,size: 35,),
                            color: Colors.white,
                          ),
                          SizedBox(height: 10,),
                          RaisedButton(
                            onPressed: ()async{
                                if(!lampOn){
                                  _camera?.setFlashMode(FlashMode.torch);
                                }else{
                                  _camera?.setFlashMode(FlashMode.off);
                                }
                                setState(() {lampOn = !lampOn;});
                            },
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(4),
                            child: Icon(lampOn?Icons.flash_on:Icons.flash_off,
                              color: lampOn?Colors.red:Colors.black,
                              size: 35,
                            ),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                    top: MediaQuery.of(context).padding.top+(Platform.isIOS?5:15),
                    right: width*0.05,
                    left: width*0.05,
                    child: CardTypeTabs()
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF211f1f),
    );
  }

}
