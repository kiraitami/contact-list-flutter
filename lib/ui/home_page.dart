import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_contact_list/helpers/contact_helper.dart';
import 'package:flutter_app_contact_list/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderAz, orderZa}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> contactList = List();


  @override
  void initState() {
    super.initState();

    _refreshAllContacts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>> [
              const PopupMenuItem<OrderOptions>(
                child: Text("Order by A-Z"),
                value: OrderOptions.orderAz,
              ),

              const PopupMenuItem<OrderOptions>(
                child: Text("Order by Z-A"),
                value: OrderOptions.orderZa,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),

      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),

      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: contactList.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        }
      ),

    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.0,14.0,8.0,14.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contactList[index].img != null ? FileImage(File(contactList[index].img)) : AssetImage("images/lll.png"),
                    fit: BoxFit.cover
                  )
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contactList[index].name ?? "",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),

                    Text(contactList[index].email ?? "",
                        style: TextStyle(fontSize: 16.0)),

                    Text(contactList[index].phone ?? "",
                        style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      }
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text("Edit", style: TextStyle(fontSize: 20.0)),
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: contactList[index]);
                      },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text("Remove", style: TextStyle(fontSize: 20.0)),
                    onPressed: (){
                      setState(() {
                        Navigator.pop(context);
                        helper.deleteContact(contactList[index].id);
                        contactList.removeAt(index);
                      });
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text("Call", style: TextStyle(fontSize: 20.0)),
                    onPressed: (){
                      launch("tel:${contactList[index].phone}");
                      Navigator.pop(context);
                    },
                  ),
                )

              ],
            ),
          );
        },
      );
    });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null){
      if (contact != null){ // if editing a contact
        await helper.updateContact(recContact);
      }
      else { //if was a new contact
        await helper.saveContact(recContact);
      }
      _refreshAllContacts();
    }
  }

  void _refreshAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contactList = list;
      });
    });
  }

  void _orderList(OrderOptions reult){
    switch(reult){
      case OrderOptions.orderAz:
        contactList.sort((a, b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;

      case OrderOptions.orderZa:
        contactList.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

}
