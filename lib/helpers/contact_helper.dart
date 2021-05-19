import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn    = "idColumn";
final String nameColumn  = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn   = "imgColumn";

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();
  
  Database _db;


  ///CHAMA O DB, SE ELE NÃO ESTIVER INICIALIZADO É CHAMADA A FUNÇÃO DE INICIALIZAÇÃO
  Future<Database>get db async {
    if(_db != null) return _db;
    else _db = await initDb();
    return _db;
  }
  ///FUNÇÃO DE INICIALIZAÇÃO DO DB
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath(); //pega o local do db
    final path = join(databasesPath, "contacts2.db"); //pega os dados
    
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }
  ///FUNÇÃO DE SALVAR
  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }
  ///FUNÇÃO APAGAR
  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }
  ///FUNÇÃO ATUALIZAR
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }
  ///FUNÇÃO RESGATAR CONTATO POR ID
  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id] //^referencia a intorrogação acima^
    );
    if(maps.length > 0) return Contact.FromMap(maps.first); //retorna o primeiro mapa(linha) encontrado
    else return null;
  }
  ///FUNÇÃO RESGATAR TODOS OS CONTATOS
  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List <Contact> listContact = List();
    //PARA CADA MAPA EU PEGO E INSIRO NA MINHA LISTA DE CONTATOS
    for(Map m in listMap) listContact.add(Contact.FromMap(m));
    return listContact;
  }
  ///RETORNA A QUANTIDADE DE LINHAS DA TABELA
  Future<int>getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }
  ///FECHA A CONEXÃO COM O DB
  Future  close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact{
  int id;
  String name, email, phone, img;

  Contact();

  Contact.FromMap(Map map){
    id    = map[idColumn   ];
    name  = map[nameColumn ];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img   = map[imgColumn  ];
  }

  Map toMap(){
    Map<String, dynamic> map ={
      nameColumn  : name ,
      emailColumn : email,
      phoneColumn : phone,
      imgColumn   : img  ,
    };
    if(id != null) map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img";
  }
}