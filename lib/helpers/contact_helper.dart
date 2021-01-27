import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";

final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String LnameColumn = "LnameColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  //factory function that return the instance of a class
  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  //gets all the data from the database
  Future<Database> get db async {
    if(_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    // `path` package  ensure the path is correct
    final databasesPath = await getDatabasesPath();

    //set path to the databse
    // When the database is first created, create a table to store contacts.
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerversion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $LnameColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  //saving contact in the database through id
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }


  //getting contact details
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, LnameColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );
    if(maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }

  }


  //delete data from database through id
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }


  //update data from database through id
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }


  //getting all contact details
  Future<List> getAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }


  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  bool isSelected = false;
  int id;
  String Fname;
  String Lname;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    Fname = map[nameColumn];
    Lname = map[LnameColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: Fname,
      LnameColumn: Lname,
      phoneColumn: phone,
      imgColumn: img
    };

    if(id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "ContactId: $id, name: $Fname, Lname: $Lname, phone: $phone, img: $img";
  }
}