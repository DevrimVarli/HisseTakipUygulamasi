import 'package:borsa_uygulamasi/consts/const.dart';
import 'package:borsa_uygulamasi/screen/Hesab%C4%B1m.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';

import 'Anasayfa.dart';

class HesapSayfasi extends StatefulWidget {
  const HesapSayfasi({super.key});

  @override
  State<HesapSayfasi> createState() => _HesapSayfasiState();
}

class _HesapSayfasiState extends State<HesapSayfasi> {
  String? mailValidator(String? value) {
    if (value == null || value.isEmpty) return "Boş bırakılamaz.";
    if (!value.contains("@") || !value.contains(".")) return "Geçersiz mail.";
    return null;
  }
  String ? passValidator(String? value){
    if(value!.length<6){
      return "Şifreniz en az 6 haneli olmalıdır.";
    }
    if(value!.isEmpty){
      return "Boş bırakılamaz.";
    }
    return null;
  }
  String ? KadiValidator(String? value){
    if (value == null || value.isEmpty) return "Boş bırakılamaz.";
    return null;
  }
  var key=GlobalKey<FormState>();
  var tfcMail=TextEditingController();
  var tfcPass=TextEditingController();
  var tfcKadi=TextEditingController();
  bool kayitMi=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height/2.5,
                  child: Image(image: AssetImage("resimler/hissearka.png"),fit: BoxFit.cover,)),
              Form(
                  key: key,
                  child: Column(
                    children: [
                      Visibility(
                        visible: kayitMi ?true:false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Constlar().customTextFormField(controller: tfcKadi, label: "Kullanıcı Adı", hintText: "Kullanıcı Adınızı Giriniz", validator: KadiValidator),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Constlar().customTextFormField(controller: tfcMail, label: "Email", hintText: "Mailinizi Giriniz", validator: mailValidator),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Constlar().customTextFormFieldpass(controller: tfcPass, label: "Şifre", hintText: "Şifrenizi Giriniz", validator: passValidator),
                      ),
        
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width/1.05,
                  height: MediaQuery.of(context).size.height/22,
                  child: Constlar().elevatedButton(
                      (){
                        kayitMi ? kayitEkle(tfcKadi.text, tfcMail.text, tfcPass.text):girisYap( tfcMail.text, tfcPass.text);
                      },
                      kayitMi?"Kayıt Ol":"Giriş Yap ",
                      HexColor("#0B1D51"),
                      Colors.white,
                      32),
                ),
              ),
              GestureDetector(
                  onTap: (){
                   setState(() {
                     kayitMi=!kayitMi;
                   });
        
                  },
                  child: kayitMi? Text("Hesabım Var",style: Constlar().textStyle(25,  HexColor("#0B1D51"))):Text("Yeni Hesap Oluştur",style: Constlar().textStyle(25,  HexColor("#0B1D51")),)
              ),
            ],
          ),
        ),
      ),
    );
  }
  void kayitEkle(String kullaniciAdi, String mail, String password) async {
    if (key.currentState!.validate()) {
      try {
        UserCredential yetkiSonucu = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: mail,
          password: password,
        );

        String uidTutucu = yetkiSonucu.user!.uid;

        await FirebaseFirestore.instance.collection("Kullanicilar").doc(uidTutucu).set({
          "kullaniciAdi": kullaniciAdi,
          "email": mail,
        });
        tfcKadi.text="";
        tfcMail.text="";
        tfcPass.text="";

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Hesabim())
        );

      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? "Firebase hatası");
      }
    }
  }

  void girisYap(var email,var password){
    if(key.currentState!.validate()){
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((user){
        tfcKadi.text="";
        tfcMail.text="";
        tfcPass.text="";
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Hesabim()));
      }).catchError((hata){
        Fluttertoast.showToast(msg: hata.toString());
      });
    }
  }
}
