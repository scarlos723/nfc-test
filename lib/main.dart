
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: MyHomePage()
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterTts flutterTts = FlutterTts();
  ValueNotifier<dynamic> result = ValueNotifier(null);


  String producto = "";
  List tagID = [
    {"id":1, "name":"Cafe", "tagId":[4, 245, 119, 58, 20, 111, 128]},
    {"id":2, "name":"Chocolate", "tagId":[62, 245, 28, 228]}


  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future:  checkNfc(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting){
              return Text("Esperando Data");
            } 
            else {
            return Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    direction: Axis.vertical,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.all(4),
                          constraints: BoxConstraints.expand(),
                          decoration: BoxDecoration(border: Border.all()),
                          child: SingleChildScrollView(
                            child: ValueListenableBuilder<dynamic>(
                              valueListenable: result,
                              builder: (context, value, _) =>
                                  Text('${value ?? ''}'),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: GridView.count(
                          padding: EdgeInsets.all(4),
                          crossAxisCount: 2,
                          childAspectRatio: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: [
                            Text(producto),
                            /* ElevatedButton(
                                child: Text('Tag Read'), onPressed: _tagRead), */

                          ],
                        ),
                      ),
                    ],
                  );
              }
            },     
      )
    );
  }

  Future _speak () async{
     await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak("El producto es café");
      
    
  }

  Future<bool> checkNfc() async {
    final aux = await  NfcManager.instance.isAvailable();
    return aux;
  }

  

  bool areListsEqual(var list1, var list2) {
    // check if both are lists
    if(!(list1 is List && list2 is List)
        // check if both have same length
        || list1.length!=list2.length) {
        return false;
    }
     
    // check if elements are equal
    for(int i=0;i<list1.length;i++) {
        if(list1[i]!=list2[i]) {
            return false;
        }
    }
     
    return true;
  }
  
  void _setId(_list){
    
    print (_list);
    if(areListsEqual(_list, [4, 245, 119, 58, 20, 111, 128]) ){
      setState(() {
        producto="Cafe";
      });
      _speak();
      print ("Entro al  If");
    }else{
      print ("No entro");
    }
    
  }
  
  void _tagRead() {
    

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      _setId( result.value['nfca']['identifier']);
      //NfcManager.instance.stopSession();  // When is uncoment, the app stop the session and init the session by default from NFC phone
    });
  }
  @override
  void initState() { // antes de dibujar por primera vez se ejecuta esto
    super.initState();
    _tagRead();
  
  }

  @override
  void dispose() {
    
    super.dispose();
    
  }

}