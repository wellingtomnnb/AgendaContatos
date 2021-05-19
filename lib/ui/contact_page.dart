import 'dart:io';

import 'package:contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class ContactPage extends StatefulWidget {
  
  final Contact contact;
  ContactPage({this.contact});
  
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  bool _userEdited = false;

  Contact _editedContact;
  
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.contact == null) _editedContact = Contact();
    else {
      _editedContact = Contact.FromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }
 
 
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? "Novo Contato"), //(??) caso o campo seja null ele retorna o texto escrito
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              if(_editedContact.name != null && _editedContact.name.isNotEmpty) Navigator.pop(context, _editedContact); //retorna para tela anterior
              else FocusScope.of(context).requestFocus(_nameFocus); //ao tentar salvar sem inserir o nome o campo é focado
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView( //BARRA DE ROLAGEM
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                GestureDetector(//Possibilita o clique na imagem
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null && _editedContact.img.isNotEmpty ?
                            FileImage(File(_editedContact.img)) :
                            AssetImage("images/person.png")
                        )
                    ),
                  ),
                  onTap: (){
                    ImagePicker.pickImage(source: ImageSource.camera).then((file){
                      if(file == null) return; //usuario n tirou uma ft
                      setState(() {
                        _editedContact.img = file.path; //salva o local da imagem
                      });
                    });
                    
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text){
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress, //tipo do teclado
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone, //tipo do teclado
                )
              ],
            ),
          ),
        ),
    );
  }
  Future<bool> _requestPop(){
   if(_userEdited){
     showDialog(
         context: context,
         builder: (context) {
           return AlertDialog(
             title: Text("Descartar Alterações?"),
             content: Text("Todas as alterações serão perdidas."),
             actions: [
               FlatButton(
                   child: Text("Cancelar"),
                   onPressed: ()=> Navigator.pop(context) //sai do Dialog
               ),
               FlatButton(
                   child: Text("Sim"),
                   onPressed: (){
                     Navigator.pop(context); //sai do Dialog
                     Navigator.pop(context); //sai da tela de cadastro
                   }
               ),
             ],

           );
         }
     );
     return Future.value(false);
   }
   else return Future.value(true);

  }
}
