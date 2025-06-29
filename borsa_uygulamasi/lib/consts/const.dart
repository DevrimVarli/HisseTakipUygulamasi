import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Constlar{
  ElevatedButton elevatedButton(VoidCallback onPressed,String buton_isim,Color backgroundColor,Color isimColor,double fonstize,{FontWeight? fontweight}){
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(buton_isim,style:textStyle(fonstize, isimColor,fontweight:fontweight ),),
        style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )

    ),
    );
  }
  TextStyle textStyle(double fontsize,Color color,{FontWeight? fontweight}){
    return TextStyle(
      fontSize: fontsize,
      fontWeight: fontweight,
      color: color,


    );

  }
  final Textcolor=Colors.white;

  AppBar appBar(String title,BuildContext context){
    return AppBar(
      leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_outlined,color: Colors.white,)),
  title: Text(
      title,style: Constlar().textStyle(30, Constlar().Textcolor,fontweight: FontWeight.bold)),
  centerTitle: true,
  backgroundColor:HexColor("#3674B5"),
  );}

  TextField textField(TextEditingController tfc,String label,String hintext,var arama){
    return TextField(
      onChanged: (aramaSonucu){
        arama=aramaSonucu;
      },
      controller: tfc,
      style: TextStyle(fontSize: 20, color: HexColor("#333446")),
      decoration: InputDecoration(
        //labelText: label,
        labelStyle: Constlar().textStyle( 22, HexColor("#3674B5"),fontweight: FontWeight.bold),
        hintText: hintext,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: HexColor("#F5F5F5"),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: HexColor("#3674B5"), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: HexColor("#333446"), width: 2),
        ),
      ),
    );
  }
  Form form({
    required GlobalKey<FormState> formKey,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    required TextEditingController controller2,
    required String label2,
    required String hintText2,
    required String? Function(String?) validator2,// 🔥 dışarıdan validator fonksiyonu
  }) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 20, color: HexColor("#333446")),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Constlar().textStyle(22, HexColor("#3674B5"), fontweight: FontWeight.bold),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: HexColor("#F5F5F5"),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: HexColor("#3674B5"), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: HexColor("#333446"), width: 2),
              ),
            ),
            validator: validator, // 🔥 dışarıdan gelen fonksiyon burada kullanılır
          ),
           SizedBox(
             height:25,
           ),
           TextFormField(
             obscureText: true,
            controller: controller2,
            style: TextStyle(fontSize: 20, color: HexColor("#333446")),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: label2,
              labelStyle: Constlar().textStyle(22, HexColor("#3674B5"), fontweight: FontWeight.bold),
              hintText: hintText2,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: HexColor("#F5F5F5"),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: HexColor("#3674B5"), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: HexColor("#333446"), width: 2),
              ),
            ),
            validator: validator2, // 🔥 dışarıdan gelen fonksiyon burada kullanılır
          ),
        ],
      ),

    );
  }
  TextFormField customTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      //obscureText: obscure, // şifre alanıysa true
      style: TextStyle(fontSize: 20, color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Constlar().textStyle(26, Colors.black, fontweight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: HexColor("#0B1D51").withOpacity(0.07),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: HexColor("#333446"), width: 2),
        ),
      ),
      validator: validator,
    );
  }
  TextFormField customTextFormFieldpass({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true, // şifre alanıysa true
      style: TextStyle(fontSize: 20, color: Colors.black),
      //keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Constlar().textStyle(26, Colors.black, fontweight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: HexColor("#0B1D51").withOpacity(0.07),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: HexColor("#333446"), width: 2),
        ),
      ),
      validator: validator,
    );
  }
  TextFormField customTextFormFieldson({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      //obscureText: obscure, // şifre alanıysa true
      style: TextStyle(fontSize: 20, color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Constlar().textStyle(26, Colors.white, fontweight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: HexColor("#0B1D51").withOpacity(0.07),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: HexColor("#333446"), width: 2),
        ),
      ),
      validator: validator,
    );
  }



}