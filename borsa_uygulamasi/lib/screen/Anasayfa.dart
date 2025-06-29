import 'dart:convert';
import 'package:borsa_uygulamasi/consts/const.dart';
import 'package:borsa_uygulamasi/models/Hisseler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/HisselerCevap.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  var tfchisse=TextEditingController();
  var aramaYapiliyorMu=false;
  final String apiKey = "apikey 4VFmJ7q6q12Hl24v2wQRpT:63iwn6e1lKAwCoRAuWa5Qt";
  final Dio dio=Dio();
  List<Hisseler> parseHisselerCevap(Map<String,dynamic> cevap) {
    //final jsonVeri = json.decode(cevap);
    return HisselerCevap.fromJson(cevap).hisselerListesi;
  }

  Future<List<Hisseler>> fetchHisseler() async {
    final response = await dio.get(
      "https://api.collectapi.com/economy/liveBorsa",
      options: Options(
        headers: {
          "authorization": apiKey,
          "content-type": "application/json"
        },
      ),

    );

    if (response.statusCode == 200) {
      //final jsonData = json.decode(response.body);
      return parseHisselerCevap(response.data);
    } else {
      throw Exception("API'den veri alınamadı.");
    }
  }

  Color getRateColor(double rate) => rate >= 0 ? Colors.greenAccent : Colors.redAccent;
  IconData getRateIcon(double rate) => rate >= 0 ? Icons.trending_up : Icons.trending_down;

  List<String> favoriKodlar = [];

  var arama = ""; // cihazda kayıtlı favoriler

  Future<void> favorileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    favoriKodlar = prefs.getStringList("favoriler") ?? [];
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    favorileriYukle().then((_) {
      setState(() {});
    });
  }
  Future<void> favoriDegistir(String kod) async {
    final prefs = await SharedPreferences.getInstance();

    if (favoriKodlar.contains(kod)) {
      favoriKodlar.remove(kod);
    } else {
      favoriKodlar.add(kod);
    }

    await prefs.setStringList("favoriler", favoriKodlar);
    setState(() {});
  }
  
  Future<List<Hisseler>> arananHisseleriGetir(String arananHisse)async{
    final tumHisseler = await fetchHisseler();
    return tumHisseler.where((hisse) =>
        hisse.hisseAdi.toLowerCase().contains(arananHisse.toLowerCase())
    ).toList();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1D51), Color(0xFF122F6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: aramaYapiliyorMu?TextField(
          onChanged: (aramaSonucu){
            setState(() {
              arama=aramaSonucu;
            });

          },
          controller: tfchisse,
          style: TextStyle(fontSize: 20, color: HexColor("#333446")),
          decoration: InputDecoration(
            //labelText: label,
            labelStyle: Constlar().textStyle( 22, HexColor("#3674B5"),fontweight: FontWeight.bold),
            hintText: "Hisse adını giriniz",
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
        ):Text(
          "Hisse Takip",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
              onPressed: (){
                setState(() {
                  aramaYapiliyorMu=!aramaYapiliyorMu;
                  tfchisse.text="";
                });
              }, icon:aramaYapiliyorMu? Icon(Icons.cancel,color: Colors.white,size: 36,) : Icon(Icons.search,color: Colors.white,size: 36,))
        ],
      ),
      backgroundColor: const Color(0xFF0B1D51),
      body: FutureBuilder<List<Hisseler>>(
        future: aramaYapiliyorMu?arananHisseleriGetir(arama):fetchHisseler(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}", style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Veri yok", style: TextStyle(color: Colors.white)));
          }

          final hisseler = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: hisseler.length,
              itemBuilder: (context, index) {
                final hisse = hisseler[index];
                final double rate = hisse.gunlukDegisim.toDouble() ?? 0.0;
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + index * 50),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(hisse.hisseAdi,
                                style: GoogleFonts.montserrat(
                                    fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                favoriDegistir(hisse.hisseAdi); // hisse adı ile favori işlemi
                              },
                              icon: Icon(
                                favoriKodlar.contains(hisse.hisseAdi)
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                size: 36,
                                color: favoriKodlar.contains(hisse.hisseAdi)
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),

                            const Spacer(),
                            Icon(getRateIcon(rate), color: getRateColor(rate), size: 36),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${hisse.anlikFiyat} ${hisse.fiyatTuru}",
                          style: GoogleFonts.montserrat(fontSize: 28, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "Değişim: %${rate.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 24,color: getRateColor(rate)),
                            ),
                            const Spacer(),
                            IconButton(onPressed: (){}, icon: Icon(Icons.add,color: Colors.white,size: 48,))
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text("Lot: ${hisse.hacimLot}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white70))),
                            Expanded(child: Text("TL: ${hisse.hacimTl}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white70))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Saat: ${hisse.sonGuncellenmeZamani}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white38)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
