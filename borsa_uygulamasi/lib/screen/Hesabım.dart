import 'package:borsa_uygulamasi/consts/const.dart';
import 'package:borsa_uygulamasi/screen/Portfoyum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class Hesabim extends StatefulWidget {
  const Hesabim({super.key});

  @override
  State<Hesabim> createState() => _HesabimState();
}

class _HesabimState extends State<Hesabim> {
  String? mevcutKullaniciUidTutucu;

  void mevcutKullaniciUidsiAl() async {
    var mevcutKullanici = FirebaseAuth.instance.currentUser;
    setState(() {
      mevcutKullaniciUidTutucu = mevcutKullanici?.uid;
    });
  }

  @override
  void initState() {
    super.initState();
    mevcutKullaniciUidsiAl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#0B1D51"),
      appBar: AppBar(
        backgroundColor: HexColor("#0B1D51"),
        title: Text("Hesabım", style: Constlar().textStyle(30, Colors.white)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {}, icon: Icon(Icons.arrow_back, color: Colors.white)),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              icon: Icon(Icons.exit_to_app, color: Colors.white, size: 30))
        ],
      ),
      body: mevcutKullaniciUidTutucu == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(mevcutKullaniciUidTutucu!)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text("Kullanıcı verisi bulunamadı",
                    style: TextStyle(color: Colors.white)));
          }

          var veri = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [HexColor("#ffffff"), HexColor("#d1e3ff")],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 6))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Hero(
                    tag: "profile_icon",
                    child: CircleAvatar(
                      backgroundColor: HexColor("#0B1D51"),
                      radius: 48,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Hoşgeldiniz",
                    style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: HexColor("#0B1D51")),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${veri["kullaniciAdi"].toString().toUpperCase()}",
                    style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Portfoyum(mevcutKullaniciUidTutucu)));
                    },
                    leading: Icon(Icons.monetization_on,size: 32,),
                    title: Text("Portföyüm",style: GoogleFonts.montserrat(fontSize: 24,fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: HexColor("#0B1D51")),
                    title: Text("Email",
                        style: GoogleFonts.montserrat(fontSize: 24)),
                    subtitle: Text(veri["email"],
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                  // İsteğe bağlı ek bilgi:
                  // ListTile(
                  //   leading: Icon(Icons.access_time),
                  //   title: Text("Kayıt Tarihi"),
                  //   subtitle: Text("12.05.2024"),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
