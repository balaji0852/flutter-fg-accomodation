import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:folkguideapp/forwardreq.dart';
import 'package:intl/intl.dart';
import 'callocation.dart';
import 'forwardreq.dart';

// ignore: camel_case_types
class allocation extends StatefulWidget{
  allocation({this.center,this.no});
  final String center,no;
  @override
  allocationpage createState()=>allocationpage(center: center,no: no);
}

// ignore: camel_case_types
class allocationpage extends State<allocation>{
   allocationpage({this.center,this.no});
  final String center,no;
  String zone;
  num lb=0,mb=0,ub=0,rlb=0,rmb=0,rub=0,count=0,totalr=0,prob=0,allocs=0,alb=0,amb=0,aub=0,highest;
  bool flag=false;
  String note="Loading..",note1="Loading..",req="Loading..",docid;
  bool adm=false;
  static DateTime now = DateTime.now();
  static var  formatter = DateFormat('yyyy-MM-dd');
  static var today = formatter.format(now);
  var collectonRef = Firestore.instance.collection('Centres');
  var db = Firestore.instance;

  // ignore: non_constant_identifier_names
  List<String>lower_b = [];
  // ignore: non_constant_identifier_names
  List<String> middle_b = [];

  // ignore: non_constant_identifier_names
  List<String> upper_b = [];
  // ignore: non_constant_identifier_names






  Future allocater(String berth,String no,String reqid,String doc,num type) async {
    String bed,room,udoc;
    num temp = 0,n;
    var hUpdate;
    // ignore: unused_local_variable
    var time = DateFormat('yMMMEd').format(DateTime.now());

    // ignore: non_constant_identifier_names
    String T_doc;
      var beds = await collectonRef.where('centre',isEqualTo:center).getDocuments();
      beds.documents.forEach((checkforbed) {
        setState(() {
          T_doc = checkforbed.documentID;
        });
        });
    await Firestore.instance.collection('Profile').where('mobile',isEqualTo: no).getDocuments().then((value) {
        value.documents.forEach((element) {
          hUpdate = Firestore.instance.collection('Profile').document(element.documentID).collection('history').document(reqid);
        });
    });
    var cUpdate =  collectonRef.document(T_doc).collection('AccommodationRequest').document(doc);
    var activeallocs = collectonRef.document(T_doc).collection('Activeallocs');
    if(berth=="LOWER_BERTH"){
      // temp = alb;
      bed = lower_b.elementAt(temp);  
      lower_b.removeAt(temp);
      // alb++;
    }
    else if(berth=="MIDDLE_BERTH"){
      // temp = amb;
      bed = middle_b.elementAt(temp);
      middle_b.removeAt(temp);
      // amb++;
    }
    else if(berth=="UPPER_BERTH"){
      // temp = aub;
      bed = upper_b.elementAt(temp);
      upper_b.elementAt(temp);
      // aub++;
        }
    String date = DateTime.now().toString();
    var  val =DateTime.utc(int.parse(date.substring(0,4)),int.parse(date.substring(5,7))
     ,int.parse(date.substring(8,10)),int.parse(date.substring(11,13)),int.parse(date.substring(14,16)),
     int.parse(date.substring(17,19))).millisecondsSinceEpoch.toString();

      if(bed.substring(0,n)!=room){
      for(int i=0;i<bed.length;i++){
        if(bed[i]==','){
          setState(() {
            room = bed.substring(0,i);
            n = i;
          });
          break;
        }
        }
      }
      else{
        setState((){
          room = room;
        });
      }

      
      hUpdate.updateData({
              "status": "Ready to occupy",
              "allocated": bed,
              'from':val,
              'fg':no
            }).then((value){
                  cUpdate.updateData({
                      "status": "Ready to occupy",
                      "allocated":bed,
                      'from':val,
                       'fg':no
                    });
                  activeallocs.add({
                        'allocated':bed,
                        'allocated_to':no,
                        'reqid':reqid,
                        'type':type,
                        'room':room,
                    });
            });
  }




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




void greatest(num l,num m,num u){
    setState(() {
      if(l>=m && l>=u){
        highest = l;
      }
      else if(m>=l && m>=u){
        highest =m;
      }
      else{
        highest = u;
      }
    });
  }


// ignore: non_constant_identifier_names
void bed_checker(num lb,num mb,num ub,String room){
  greatest(lb, mb, ub);
    for(int i=1;i<=highest;i++){
      setState(() {
         if(i<=lb){
        lower_b.add(room+','+'lb-$i');
      }
        if(i<=mb){
        middle_b..add(room+','+'mb-$i');
      }
       if(i<=ub){
        upper_b..add(room+','+'ub-$i');
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
        lower_b.remove(activeBeds.data['allocated']);
        }
      else if(activeBeds.data['type']==2){
        middle_b.remove(activeBeds.data['allocated']);
        }
      else{
        upper_b.remove(activeBeds.data['allocated']);
        }
        });
        });
    }







  Future allocaterequests() async {

    var formatter = new DateFormat('yyyy-MM-dd');
    var date = formatter.format(DateTime.now());
    // ignore: unused_local_variable
    String cdoc;
    var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
        bed.documents.forEach((checkfor) {
          setState(() {
            cdoc = checkfor.documentID;
          });
        });
        var db = collectonRef.document(cdoc).collection('AccommodationRequest');
        var docu= await db.where('date',isEqualTo: date).where('status',isEqualTo: "Waiting for approval").getDocuments();
        if(docu!=null) {
          docu.documents.forEach((element) async {
            if (element.data['preferred_berth'] == "LOWER_BERTH"  && lower_b.length!=0) {
              await allocater("LOWER_BERTH", element.data['mobile'],
                  element.data['reqid'], element.documentID,1);
            }
            else if (element.data['preferred_berth'] == "MIDDLE_BERTH"  && middle_b.length!=0) {
              await allocater("MIDDLE_BERTH", element.data['mobile'],
                  element.data['reqid'], element.documentID,2);
            }
            else if (element.data['preferred_berth'] == "UPPER_BERTH"&& upper_b.length!=0) {
            await allocater("UPPER_BERTH", element.data['mobile'],
                  element.data['reqid'], element.documentID,3);
            }
            else {
              if (lower_b.length> 0) {
                await allocater("LOWER_BERTH" , element.data['mobile'],
                    element.data['reqid'], element.documentID,1);
              }
              else if (middle_b.length> 0) {
                await allocater("MIDDLE_BERTH" , element.data['mobile'],
                    element.data['reqid'], element.documentID,2);
              }
              else if (upper_b.length>0)
              {
                await allocater("UPPER_BERTH" , element.data['mobile'],
                    element.data['reqid'], element.documentID,3);
              }
              else {
                await Firestore.instance.collection('Profile').where('mobile',isEqualTo: element.data['mobile']).getDocuments().
                then((value){
                   value.documents.forEach((elements) async{
                      await Firestore.instance.collection('Profile').document(elements.data['mobile']).
                      collection('history').document(element.data['reqid']).updateData({
                        "status":"No beds available, Currently",
                        "allocated":"No bed was allocated"
                      }).then((value){
                        db.document(element.documentID).delete();
                      });
                   });
                });
              }
            }
          });
          // noreqs('Beds allocated successfully.');
          await bedData();
        }
        else if(count==0){
          noreqs("No beds nor Requests , To allocate bed.");
        }
        else{
          noreqs("No requests, To allocate bed.");
        }
      }

        Future checkforadmin() async{
         var admr = await Firestore.instance.collection('FOLKGuides').where('mobile_number',isEqualTo:no).
         where('accommodation_admin',arrayContains: center).getDocuments();
         this.adm = admr.documents.isNotEmpty;
        }



      Future deleterequests() async {
        String cdocu;
        var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
        bed.documents.forEach((checkfor) {
          setState(() {
            cdocu = checkfor.documentID;
          });
        });
        var userhistory = Firestore.instance.collection('Profile');
        var db = collectonRef.document(cdocu).collection('AccommodationRequest');
        var docu= await db.where('status',isEqualTo: "Waiting for approval").getDocuments();
        if(docu.documents.isNotEmpty) {
          docu.documents.forEach((element) async {
            await userhistory.where('mobile',isEqualTo: element.data['mobile']).getDocuments().then((value){
                 value.documents.forEach((elements) {
                    userhistory.document(elements.documentID).
                   collection('history').document(element.data['reqid']).updateData({
                     "status": 'Request was declined.',
                     "allocated":"No bed was allocated"
                   }).then((value) async {
                     db.document(element.documentID).delete();
                   });
                 });
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
          duration: Duration(seconds:3),
        ));
      }

  Future reqcount() async{
      String cdocu;
      var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
      bed.documents.forEach((checkfor) {
      setState(() {
      cdocu = checkfor.documentID;
      });
      });
    var db =  collectonRef.document(cdocu).collection('AccommodationRequest');
    var docu = await db.where('status',isEqualTo:'Waiting for approval').getDocuments();
       if(docu.documents.isNotEmpty) {
         docu.documents.forEach((element) {
           setState(() {
             totalr++;
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
          await checkforadmin();

          var bed = await collectonRef.where('centre',isEqualTo:center).getDocuments();
          bed.documents.forEach((checkforbed) {
            setState(() {
              TDoc = checkforbed.documentID;
            });
            });
      var doc = await Firestore.instance.collection('Centres').document(TDoc).collection('data').getDocuments();
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
           await reqcount();
           bed_correcter();
           }
       else{
         setState(() async{
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



   Future expiredbeds() async{
    // ignore: non_constant_identifier_names
    String TDoc;
    String bedno,from,no,tempdoc;
    var ceterdoc,temp,temp1,hUpdate;
    DateTime val = DateTime.now().toUtc();

    var centerdoc = await collectonRef.where('centre',isEqualTo:center).getDocuments();
    centerdoc.documents.forEach((checkforbed) {
         TDoc = checkforbed.documentID;
    });
    var database =  collectonRef.document(TDoc);
    var activeallocs = database.collection('Activeallocs');
    var cUpdate =  database.collection('AccommodationRequest');
    temp1 =  cUpdate.where('status',isEqualTo:'Ready to occupy').getDocuments();
    var profile = db.collection('Profile');

    if(temp1.documents.isNotEmpty){
        // ignore: non_constant_identifier_names
        temp1.documents.forEach((ExpiredReq) async{
          DateTime temporary = DateTime.fromMicrosecondsSinceEpoch(ExpiredReq.data['to']).toUtc();

          if(temporary.isBefore(val)){
          temp = await activeallocs.where('allocated',isEqualTo:ExpiredReq.data['allocated']).getDocuments();
          profile.where('mobile',isEqualTo:ExpiredReq.data['mobile'] ).getDocuments().then((value) {
              value.documents.forEach((element) {
                 tempdoc = element.documentID;
              });
          });

          db.collection('Profile').document(tempdoc).collection('history').document(ExpiredReq.data['reqid']).updateData({
                    'status' : 'Request expired'
                    });

          temp.documents.forEach((deactivate){
                    activeallocs.document(deactivate.documentID).delete();
            });           


          cUpdate.document(ExpiredReq.documentID).updateData({
            'status':'Request expired',
          });
          }
        });
      }
    }
     


      



      @override
      void initState(){
      super.initState();
      zone = center;
      
      bedData();
      expiredbeds();
      getdoc();
      }

      @override
      Widget build(BuildContext context)
      {
        return  Scaffold(
            body:Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Expanded(child:Text( adm.toString(),style: TextStyle(
                    //   fontSize: 10
                    //             ),)),
                    Expanded(child:requestlist(center: center,adm: adm,doc: docid,no: no,)),
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
  requestlist({this.center,this.adm,this.doc,this.no});
  final String center,doc,no;
  final bool adm;
  static DateTime now = DateTime.now();
  static var  formatter = DateFormat('yyyy-MM-dd');
  static var today = formatter.format(now);
  final List<String> images = ['https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-fabian-wiktor-994605.jpg?alt=media&token=75531d8e-3cf5-4f3d-b06b-cc7745114b37',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-jiarong-deng-1034662.jpg?alt=media&token=c827d22a-4d31-4747-97f9-7ce32a05d7ba',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-pavlo-luchkovski-337909.jpg?alt=media&token=1a650cfa-752c-440e-81f3-56fd92da5923',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-ricardo-esquivel-1586298.jpg?alt=media&token=39c1928e-88f9-4754-ab2d-4c38fc518da3',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-stijn-dijkstra-2583852.jpg?alt=media&token=f9308f22-ec5c-44aa-99bc-3ec99c1157f0',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-todd-trapani-2754200.jpg?alt=media&token=ae149bf0-412d-4880-819c-33352aafa2a6',
  'https://firebasestorage.googleapis.com/v0/b/folkapp-a0871.appspot.com/o/pexels-sourav-mishra-1149831.jpg?alt=media&token=cf023b19-f06e-4e64-baaa-d7d2398bf0b6'];

   
     


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('Centres').document(doc).
        collection('AccommodationRequest').where('date',isEqualTo: today).where('status',isEqualTo: "Waiting for approval").where('admin',isEqualTo: adm).
        snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            // case ConnectionState.waiting:
            //   return new Text('Loading...');
            // case ConnectionState.active:
            //   return new Text('Loading');

               
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
                                        //   document['preferred_berth']=='MIDDLE_BERTH'?images.elementAt(3):
                                        // document['preferred_berth']=='UPPER_BERTH'?images.elementAt(2):images.elementAt(0)),
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
                                      Text(document['name'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      SizedBox(height: 7.0,),
                                      Text(document['preferred_berth'].toString().toLowerCase()
                                          +" for "+DateTime.fromMillisecondsSinceEpoch(int.parse(document['from'])).toUtc().toString().substring(0,16)
                                          +' - '+DateTime.fromMillisecondsSinceEpoch(int.parse(document['to'])).toUtc().toString().substring(0,16),
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
                                Firestore.instance.collection('Profile').where('mobile',isEqualTo:document['mobile'] )
                                    .getDocuments().then((value) {
                                  value.documents.forEach((element) async {
                                    await Firestore.instance.collection('Profile').document(element.documentID).
                                    collection('history').document(
                                        document['reqid']).updateData({
                                      "status": "Request was declined",
                                      "allocated": "No bed was allocated"
                                    }).then((value) async {
                                      await Firestore.instance.collection(
                                          'Centres').document(doc).
                                      collection('AccommodationRequest').document(
                                          document.documentID).delete();
                                    });
                                  });
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
                        callocation(berth: document['preferred_berth'],phone:document['mobile'],
                        message: document['Message'],uname: 
                        document['name'],from:document['from']
                        ,to:document['to'],profile: images.elementAt(2),
                        center:center,doc:document.documentID,reqid:document['reqid'],no: no,)));
                        },
                      ),
                      IconSlideAction(
                        caption: 'Forward',
                        color: Colors.green[700],
                        icon: Icons.forward,
                        onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                        forwardreq(berth: document['preferred_berth'],phone:document['mobile'],
                        message: document['Message'],uname: 
                        document['name'],from:document['from'],to:
                        document['to'],profile: images.elementAt(2),
                        center:center,doc:document.documentID,reqid:document['reqid'],no:no ,)));
                         },
                      ),
                    ],);
            }).toList()
            );
          }
        });
  }
}



