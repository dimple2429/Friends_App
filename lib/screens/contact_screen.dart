
import 'dart:io';

import 'package:friendsapp/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactScreen extends StatefulWidget {
  final Contact contact;

  ContactScreen({this.contact});
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  Contact _editedContact;
  bool _userEdited = false;

  //provides initial value to the textfield
  final _FnameController = TextEditingController();
  final _LnameController = TextEditingController();
  var _phoneController = TextEditingController();

//focuses textfield when button is tapped.
  final _nameFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;


  @override
  //method called once when stateful widegt is inserted into the widget tree
  void initState() {
    super.initState();

    if(widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _FnameController.text = _editedContact.Fname;
      _LnameController.text = _editedContact.Lname;
      _phoneController.text = _editedContact.phone;

    }
  }

  Future<bool> _requestPop() {
    if(_userEdited) {
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Discard alterations?"),
            content: Text("If you leave the changes will be lost"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Dial"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(_editedContact.Fname ?? "New contact"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
           /* if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
            }*/
            if(_formKey.currentState.validate() &&_editedContact.Fname != null && _editedContact.Fname.isNotEmpty  ) {
              Navigator.pop(context, _editedContact);
              _formKey.currentState.save();
            }
            else if(_editedContact.phone != null && _editedContact.phone.isNotEmpty  ){
              Navigator.pop(context, _editedContact);
            }
            else {
            FocusScope.of(context).requestFocus(_nameFocus);
            setState(() {
            _autoValidate = true;
            });
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child:
          Form(
            key: _formKey,
            autovalidate: _autoValidate,
           child:Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  File image = null;
                  if(image == null) return;
                  setState(() {
                    _editedContact.img = image.path;
                  });
                },
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null ? FileImage(File(_editedContact.img)) : AssetImage("assets/user.png"),
                          fit: BoxFit.cover
                      ),
                  ),
                ),
              ),
              TextFormField(
                controller: _FnameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "First Name"
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.Fname = text;
                  });
                },
              ),
              TextFormField(
                controller: _LnameController,
                //keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Last Name"
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.Lname = text;
                },
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Phone"
                ),
                onChanged : (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                  maxLines: 1,
                  validator: validateMobile,
                  onSaved: (String val) {
                    _phoneController.text = val;
                  }),
            ],
          ),
          ),
        ),
      ),
    );
  }

}


/// Validation Check
String validateName(String value) {
  if (value.length < 3)
    return 'Name must be more than 2 charater';
  else if (value.length > 30) {
    return 'Name must be less than 30 charater';
  } else
    return null;
}

String validateMobile(String value) {
  Pattern pattern = r'^[0-9]*$';
  RegExp regex = new RegExp(pattern);
  if (value.trim().length != 10)
    return 'Mobile Number must be of 10 digit';
  else if (value.startsWith('+', 0)) {
    return 'Mobile Number should not contain +91';
  } else if (value.trim().contains(" ")) {
    return 'Blank space is not allowed';
  } else if (!regex.hasMatch(value)) {
    return 'Characters are not allowed';
  } else
    return null;
}

