import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:folkguideapp/forwardreq.dart';
import 'package:intl/intl.dart';

import 'callocation.dart';
import 'forwardreq.dart';
// ignore: camel_case_types
class allocation extends StatefulWidget{
  allocation({this.center});
  final String center;
  @override
  allocationpage createState()=>allocationpage(center: center);
}

// ignore: camel_case_types
class allocationpage extends State<allocation>{
  allocationpage({this.center});
  final String center;
  String zone;
  num lb=0,mb=0,ub=0,rlb=0,rmb=0,rub=0,count=0,totalr=0,prob=0,allocs=0,alb=0,amb=0,aub=0;
  bool flag=false;
  String note="Loading..",note1="Loading..",req="Loading..",docid;
  static DateTime now = DateTime.now();
  static var  formatter = DateFormat('yyyy-MM-dd');
  static var today = formatter.format(now);
  var collectonRef = Firestore.instance.collection('Centers');
  // ignore: non_constant_identifier_names
  List<bedelements> lower_b = [];
  // ignore: non_constant_identifier_names
  List<bedelements> middle_b = [];
  // ignore: non_constant_identifier_names
  List<bedelements> upper_b = [];
  // ignore: non_constant_identifier_names




  Future allocater(String berth,String no,String reqid,String doc,num type) async {
    String bed;
    num temp;
    var hUpdate = Firestore.instance.collection('Profile').document(no).collection('history').document(reqid);
    var cUpdate =  Firestore.instance.collection(center).document(today).collection('allrequest').document(doc);
    var activeallocs = collectonRef.document(docid).collection('Activeallocs');
    if(berth=="LOWER_BERTH"){
      temp = alb++;
      bed = lower_b.elementAt(temp).room+','+lower_b.elementAt(temp).bed;
      lower_b.removeAt(temp);
    }
    else if(berth=="MIDDLE_BERTH"){
      temp = amb++;
      bed = middle_b.elementAt(temp).room+','+middle_b.elementAt(temp).bed;
      middle_b.removeAt(temp);
    }
    else if(berth=="UPPER_BERTH"){
      temp = aub++;
      bed = upper_b.elementAt(temp).room+','+upper_b.elementAt(temp).bed;
      upper_b.elementAt(temp);
        }


      hUpdate.updateData({
              "status": "Ready to occupy",
              "allocated": bed
            }).then((value){
                  cUpdate.updateData({
                      "status": "Ready to occupy",
                      "allocated": bed,
                    });
                  activeallocs.add({
                        'bedno':lower_b.elementAt(temp).bed,
                        'room': lower_b.elementAt(temp).room,
                        'allocated_to':no,
                        'reqid':reqid,
                        'type':type
                    });
            });
  }



//
//  Future<void> bedupdater(String reqid,String berth,String docid,String no,String tbc,num count,num type) async {
//            await Firestore.instance.collection('users').document(no).
//            collection('history').document(reqid).updateData({
//              "status": "Bed allocated",
//              "allocated": "$berth",
//              "type": "$type"
//            }).then((value) async {
//              await Firestore.instance.collection('requests').document(today).
//              collection('allrequests').document(docid).updateData({
//                "status": "Bed allocated",
//                "allocated": "$berth"
//              });
//            }).then((value)  async{
//              var collectonRef = Firestore.instance.collection('beds');
//              var doc = await collectonRef.document('details');
//              doc.updateData({
//                "$tbc": count,
//              });
//            });
//  }



// ignore: non_constant_identifier_names
void bed_checker(num lb,num mb,num ub,String room){
    for(int i=1;i<=lb+mb+ub;i++){
      setState(() {
         if(i<=lb){
        lower_b.add(bedelements(room: room,bed: 'lb-$i'));
      }
        if(i<=mb){
        middle_b.add(bedelements(room: room,bed: 'mb-$i'));
      }
       if(i<=ub){
        upper_b.add(bedelements(room: room,bed: 'ub-$i'));
        }
        });
      }
}


  // ignore: non_constant_identifier_names
  Future bed_correcter() async{
    // ignore: non_constant_identifier_names
     String T_doc;
      var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
      bed.documents.forEach((checkforbed) {
        setState(() {
          T_doc = checkforbed.documentID;
        });
        });
    // ignore: non_constant_identifier_names
    var Activeallocs = await collectonRef.document(T_doc).collection('Activeallocs').getDocuments();
    if(Activeallocs.documents.isNotEmpty){}
    Activeallocs.documents.forEach((activeBeds) {
      setState(() {
        if(activeBeds.data['type']==1){
        lower_b.remove(bedelements(room:activeBeds.data['room'],bed: activeBeds.data['bedno']));
        }
      else if(activeBeds.data['type']==2){
        middle_b.remove(bedelements(room:activeBeds.data['room'],bed: activeBeds.data['bedno']));
        }
      else{
        upper_b.remove(bedelements(room:activeBeds.data['room'],bed: activeBeds.data['bedno']));
        }
        });
        });
    }







  Future allocaterequests() async {
        var db = Firestore.instance.collection(center).document(today).collection('allrequest');
        var docu= await db.where('status',isEqualTo: "Waiting for approval").getDocuments();
        if(docu!=null) {
          docu.documents.forEach((element) async {
            if (element.data['preferred_berth'] == "LOWER_BERTH"  && lower_b.length!=0) {
              await allocater("LOWER_BERTH", element.data['Mobile_Number'],
                  element.data['reqid'], element.documentID,1);
            }
            else if (element.data['preferred_berth'] == "MIDDLE_BERTH"  && middle_b.length!=0) {
              await allocater("MIDDLE_BERTH", element.data['Mobile_Number'],
                  element.data['reqid'], element.documentID,2);
            }
            else if (element.data['preferred_berth'] == "UPPER_BERTH"&& upper_b.length!=0) {
            await allocater("UPPER_BERTH", element.data['Mobile_Number'],
                  element.data['reqid'], element.documentID,3);
            }
            else {
              if (lower_b.length> 0) {
                await allocater("LOWER_BERTH" , element.data['Mobile_Number'],
                    element.data['reqid'], element.documentID,1);
              }
              else if (middle_b.length> 0) {
                await allocater("MIDDLE_BERTH" , element.data['Mobile_Number'],
                    element.data['reqid'], element.documentID,2);
              }
              else if (upper_b.length>0)
              {
                await allocater("UPPER_BERTH" , element.data['Mobile_Number'],
                    element.data['reqid'], element.documentID,3);
              }
              else {
                await Firestore.instance.collection('Profile').document(element.data['Mobile_Number']).
                 collection('history').document(element.data['reqid']).updateData({
                  "status":"No beds available, Currently",
                  "allocated":"No bed was allocated"
                }).then((value){
                  db.document(element.documentID).delete();
                });
              }
            }
          });
        }
        else if(count==0){
          noreqs("No beds nor Requests , To allocate bed.");
        }
        else{
          noreqs("No requests, To allocate bed.");
        }
      }



      Future deleterequests() async {
        var db = Firestore.instance.collection(center).document(today).collection('allrequest');
        var docu= await db.where('status',isEqualTo: "Waiting for approval").getDocuments();
        if(docu.documents.isNotEmpty) {
          docu.documents.forEach((element) async {
            await Firestore.instance.collection('Profile').document(
                element.data['Mobile_Number']).
            collection('history').document(element.data['reqid']).updateData({
              "status": 'Request was declined.',
              "allocated":"No bed was allocated"
            }).then((value) async {
              await Firestore.instance.collection(center).document(today).
              collection('allrequests').document(element.documentID).delete();
            });
          });
          noreqs("Request's declined, Successfully.");
        }
        else{
          noreqs("No requests found, To decline.");
        }
      }


      void noreqs(String info){
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(info),
        ));
      }

  Future reqcount(String berth) async {
    var db = Firestore.instance.collection(center).document(today).collection('allrequest');
    var docu = await db.where("preferred_berth",isEqualTo:berth).where('status',isEqualTo:'Waiting for approval').getDocuments();
       if(docu.documents.isNotEmpty) {
         docu.documents.forEach((element) {
           setState(() {
             if (berth == "LOWER_BERTH") {
               rlb++;
               totalr++;
             }
             else if (berth == "MIDDLE_BERTH") {
               rmb++;
               totalr++;
              }
             else {
               rub++;
               totalr++;
             }
           });
         });
       }
       }


    Future getdoc() async{
      var bed = await collectonRef
      .where('centre',isEqualTo:center).getDocuments();
      bed.documents.forEach((checkforbed) {
        setState(() {
          docid = checkforbed.documentID;
        });
        }); 
    }


      Future bedData() async {
          // ignore: non_constant_identifier_names
          String TDoc;
          var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
          bed.documents.forEach((checkforbed) {
            setState(() {
              TDoc = checkforbed.documentID;
            });
            });
      var doc = await Firestore.instance.collection('Centers').document(TDoc).collection('data').getDocuments();
      var db = Firestore.instance.collection(center).document(today).collection('allrequest');
      // ignore: unused_local_variable
      var requests = await db.getDocuments();
       if(requests!=null) {
          doc.documents.forEach((beds) {
            bed_checker(beds.data['lowerberth'],beds.data['middleberth'],beds.data['upperberth'],beds.documentID);
          setState(() {
                lb = lb+beds.data['lowerberth'];
                mb = mb+beds.data['middleberth'];
                ub = ub+beds.data['upperberth'];
                count = count+lb+mb+ub;
                });
                });
          //  await reqcount("LOWER_BERTH");
          //  await reqcount("MIDDLE_BERTH");
          //  await reqcount("UPPER_BERTH");
           bed_correcter();
           }
       else{
         setState((){
           note="There is no requests to allocate beds..";
           note1="There is no requests to decline requests..";
           req="No, Folk have requested for bed today.";
         });
         }
     }

      Future<bool> allocate(BuildContext context,String field,String text,bool val) {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return new AlertDialog(
                title: Text(field),
                content: Text(text),
                contentPadding: EdgeInsets.all(10.0),
                actions: <Widget>[
                  new Row(
                    children: <Widget>[
                      FlatButton(
                        child: Text("No",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        padding: EdgeInsets.all(9),
                      ),
                      SizedBox(width: 4,),
                      FlatButton(
                        child: Text("Yes",
                        style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                        ),),
                        onPressed: () async{
                          if(val==true){
                              await allocaterequests();
                              Navigator.of(context).pop();
                            }
                          else {
                              await deleterequests();
                              Navigator.of(context).pop();
                            }
                          },
                        padding: EdgeInsets.all(9),
                      )
                    ],
                  )
                ],
              );
            });
      }

      Widget data(){
        if (totalr>0) {
          return requestlist(center: center);
        }
        else {
          return Container(
              child:Center(
                child:Text("$req",
                  style: TextStyle(
                      color: Colors.green[900],
                      fontSize: 15
                  ),) ,
              )
          );
        }
      }



      @override
      void initState(){
      super.initState();
      getdoc();
      bedData();
      zone = center;
      }

      @override
      Widget build(BuildContext context)
      {
        return  Scaffold(
            body:Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child:requestlist(center: center)),
                    Container(
                      height: 50,
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10,),
                          Expanded(
                            child: MaterialButton(
                              elevation: 10,
                              child: Text('Decline all',
                                style: TextStyle(
                                  color: Colors.black,
                                ),),
                              color: Colors.white,
                              shape: new RoundedRectangleBorder(side:BorderSide( width: 2,color: Colors.black,
                                  style: BorderStyle.solid),borderRadius:BorderRadius.circular(20)),
                              onPressed: (){
                                allocate(context,"Declining requests.",'Do you want to decline all the request?',false);
                              },
                            ) ,
                          ),
                          SizedBox(width: 25,),
                          Expanded(
                            child: MaterialButton(
                              elevation: 8,
                              child: Text('Accept all',
                                style: TextStyle(
                                  color: Colors.black,
                                ),),
                              color: Colors.white70,
                              shape: new RoundedRectangleBorder(side:BorderSide( width: 2,color: Colors.black,
                                  style: BorderStyle.solid),
                              borderRadius:BorderRadius.circular(20)),
                              onPressed: (){
                                allocate(context,"Confirmation for allocation.",'Do you want to allocated bes to all $totalr requests?',true);
                              },
                            ) ,
                          ),
                          SizedBox(width: 10,)
                        ],
                      ),
                    ),
                  ],
                )
        );
      }
    }


// ignore: must_be_immutable
// ignore: camel_case_types
class requestlist extends StatelessWidget{
  requestlist({this.center});
  final String center;
  static DateTime now = DateTime.now();
  static var  formatter = DateFormat('yyyy-MM-dd');
  static var today = formatter.format(now);
  final List<String> images = ['https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.''appspot.com/o/pexels-fabian-wiktor-994605.jpg?alt=media&token=75531d8e'
      '   -3cf5-4f3d-b06b-cc7745114b37','https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-jiarong-deng-1034662.jpg?alt=media&'
      'token=c827d22a-4d31-4747-97f9-7ce32a05d7ba','https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-pavlo-luchkovski-337909.'
  'jpg?alt=media&token=1a650cfa-752c-440e-81f3-56fd92da5923','https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-ricardo-esqui'
      'vel-1586298.jpg?alt=media&token=39c1928e-88f9-4754-ab2d-4c38fc518da3','https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexe'
      'ls-stijn-dijkstra-2583852.jpg?alt=media&token=f9308f22-ec5c-44aa-99bc-3ec99c1157f0','https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.apps'
      'pot.com/o/pexels-todd-trapani-2754200.jpg?alt=media&token=ae149bf0-412d-4880-819c-33352aafa2a6','https://firebasestorage.googleapis.com/v0/b/folkapp'
      '-a0871.appspot.com/o/pexels-sourav-mishra-1149831.jpg?alt=media&token=cf023b19-f06e-4e64-baaa-d7d2398bf0b6'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(center).document(today).
        collection('allrequest').where('status',isEqualTo: "Waiting for approval").
        snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default: return  ListView(
                children: snapshot.data.documents.map((document) {
                  return new  Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            SizedBox(height:9,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topRight,
                                      child:CircleAvatar(
                                        backgroundImage: NetworkImage(images.elementAt(Random().nextInt(6))),
                                        backgroundColor: Colors.green[900],
                                        radius: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(document['Folkname'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      SizedBox(height: 7.0,),
                                      Text(document['preferred_berth'].toString().toLowerCase()
                                          +" for "+document['from'].substring(0,16)+' - '+document['to'].substring(0,16),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11
                                        ),),
                                      Text(document['Message']=='No message'? "" :"Message :" + document['Message'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15
                                        ),),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            ],
                            ),
                      ),
                  actions: <Widget>[
                    IconSlideAction(
                      caption: 'Decline',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async{
                        await Firestore.instance.collection('Profile').document(document['Mobile_Number']).
                        collection('history').document(document['reqid']).updateData({
                          "status":"Request was declined",
                          "allocated":"No bed was allocated"
                        }).then((value) async{
                          await Firestore.instance.collection(center).document(today).
                          collection('allrequest').document(document.documentID).delete();
                        });
                        },
                    ),
                  ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Allocate',
                        color: Colors.green[900],
                        icon: Icons.priority_high,
                        onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>
                        callocation(berth: document['preferred_berth'],phone:document['Mobile_Number'],
                        message: document['Message'],uname: 
                        document['Folkname'],from:document['from'].substring(0,16),to:document['to'].substring(0,16),profile: images.elementAt(2),
                        center:center,doc:document.documentID,reqid:document['reqid'],)));  
                        },
                      ),
                      IconSlideAction(
                        caption: 'Forward',
                        color: Colors.green[700],
                        icon: Icons.forward,
                        onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                        forwardreq(berth: document['preferred_berth'],phone:document['Mobile_Number'],
                        message: document['Message'],uname: 
                        document['Folkname'],from:document['from'].substring(0,16),to:document['to'].substring(0,16),profile: images.elementAt(2),
                        center:center,doc:document.documentID,reqid:document['reqid'],)));                         
                         },
                      ),
                    ],);
            }).toList()
            );
          }
        });
  }
}



//children: snapshot.data.documents.map((
//DocumentSnapshot document) {

//)
//);
//}).toList(),


// ignore: camel_case_types
class bedelements{
  bedelements({this.room,this.bed});
  final String room,bed;
}
