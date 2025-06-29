
import 'package:borsa_uygulamasi/screen/HesapSayfasi.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../consts/const.dart';
import 'Anasayfa.dart';
import 'Favoriler.dart';

class Secim extends StatefulWidget {
  const Secim({super.key});

  @override
  State<Secim> createState() => _SecimState();
}

class _SecimState extends State<Secim> {
  int secilenIndeks=0;
  var sayfaLisetsi=[Anasayfa(),Favoriler(),HesapSayfasi()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        centerTitle: true,
        title: Text("Hisse Takip",style: Constlar().textStyle(33, Colors.white),),
        backgroundColor: HexColor("#0B1D51"),
      ),*/
      body:sayfaLisetsi[secilenIndeks],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: HexColor("#0B1D51"),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on,color: Colors.white,),
            label: "Hisseler",
            backgroundColor: Colors.white
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,color: Colors.red,),
            label: "Favoriler",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Hesap",
          ),
        ],
        currentIndex: secilenIndeks,
        //fixedColor: Colors.white,

        onTap: (indeks){
          setState(() {
            secilenIndeks=indeks;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        unselectedFontSize: 20,
        selectedFontSize: 20,

      ),
    );
  }
}
