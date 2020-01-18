import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper {
  //Singleton
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();
  //--

  Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    else {
      _db = await createDatabase();
      return _db;
    }
  }

  Future<Database> createDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$nameColumn TEXT,"
            "$emailColumn TEXT,"
            "$phoneColumn TEXT,"
            "$imageColumn TEXT"
            ")"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    print(contact.toString());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> map = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, idColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );

    if (map.isNotEmpty)
      return Contact.fromMap(map.first);
    else
      return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id]
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id]
    );
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    String sql = "SELECT * FROM $contactTable";
    List listMap = await dbContact.rawQuery(sql);
    List<Contact> contactList = new List();

    for (Map map in listMap){
      contactList.add(Contact.fromMap(map));
    }

    return contactList;
  }


  Future<int> getContactAmount() async {
    Database dbContact = await db;
    String sql = "SELECT COUNT(*) FROM $contactTable";
    return Sqflite.firstIntValue(await dbContact.rawQuery(sql));
  }

  Future closeDatabase() async {
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imageColumn];
  }

  Map toMap(){
    Map <String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: img,
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}