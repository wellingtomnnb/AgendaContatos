import 'package:contatos/ui/contact_page.dart';
import 'package:contatos/ui/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false //remove borda de debug
  ));
}