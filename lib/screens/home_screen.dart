import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:friendsapp/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'contact_screen.dart';

enum OrderOptions {orderaz, orderza}

class MyApp extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash1(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash1 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: new HomeScreen(),
      loadingText: Text("Loading"),
      image: Image.asset("assets/images/friends.jpg", width: double.infinity, height: double.infinity, fit: BoxFit.fill),
      photoSize: 200.0,
      loaderColor: Colors.blue,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    controller.set(contacts.length);
    _getAllContacts();
  }

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
  MultiSelectController controller = new MultiSelectController();


  void delete()  {
    var list = controller.selectedIndexes;
    list.sort((b, a) =>
        a.compareTo(b)); 
    list.forEach((element) {
       helper.deleteContact(contacts[element].id);
      contacts.removeAt(element);
    });

    setState(() {
      controller.set(contacts.length);
    });
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {

            },
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Call",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          launch("tel:${contacts[index].phone}");
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Edit",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Delete",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () async {
                          await helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  Widget _buildContactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        color:  controller.isSelected(index) ?  Colors.grey : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? FileImage(File(contacts[index].img)) : AssetImage("assets/user.png"),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(contacts[index].Fname ?? " ",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                    Text(contacts[index].Lname ?? "",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                      ],
                    ),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(
                          fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {

        if ( contacts.any((item) => item.isSelected)) {
          setState(() {
            contacts[index].isSelected = !contacts[index].isSelected;
          });
        }
        else{
          _showOptions(context, index);
        }

      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friends App"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: (controller.isSelecting)
            ? <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: delete,
          )
        ]
            : <Widget>[

          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                  child: Text("Sort by A-Z"),
                  value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                  child: Text("Sort by Z-A"),
                  value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.grey[250],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactPage(),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {},
          child: MultiSelectItem(
          isSelecting: controller.isSelecting,
          
          onSelected: () {
          setState(() {
          controller.toggle(index);
          });
          },

              child:Container(
                child:  _buildContactCard(context, index),
          ),
          ),
          );

        },
      )
    );
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b){
          return a.Fname.toLowerCase().compareTo(b.Fname.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((b, a){
          return a.Fname.toLowerCase().compareTo(b.Fname.toLowerCase());
        });
        break;
    }

    setState(() {

    });
  }

  Future<dynamic> _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactScreen(contact: contact,))
    );
    if (recContact != null) {
      if(contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
