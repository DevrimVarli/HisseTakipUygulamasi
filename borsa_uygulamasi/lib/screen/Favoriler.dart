import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Hisseler.dart';
import '../models/HisselerCevap.dart';

class Favoriler extends StatefulWidget {
  const Favoriler({super.key});

  @override
  State<Favoriler> createState() => _FavorilerState();
}

class _FavorilerState extends State<Favoriler> {
  List<String> favoriKodlar = [];
  @override
  void initState() {
    super.initState();
    favoriKodlariGetir().then((liste) {
      favoriKodlar = liste;
      setState(() {});
    });
  }

  final String apiKey = "apikey 4VFmJ7q6q12Hl24v2wQRpT:63iwn6e1lKAwCoRAuWa5Qt";
  Color getRateColor(double rate) => rate >= 0 ? Colors.greenAccent : Colors.redAccent;
  IconData getRateIcon(double rate) => rate >= 0 ? Icons.trending_up : Icons.trending_down;

  final Dio dio=Dio();
  Future<List<String>> favoriKodlariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("favoriler") ?? [];
  }
  Future<List<Hisseler>> tumHisseleriGetir() async {
    final response = await dio.get(
      "https://api.collectapi.com/economy/liveBorsa",
      options: Options(
        headers: {
          "authorization": "apikey $apiKey",
          "content-type": "application/json"
        },
      ),
    );

    if (response.statusCode == 200) {
      return HisselerCevap.fromJson(response.data).hisselerListesi;
    } else {
      throw Exception("Veri alınamadı");
    }
  }
  Future<List<Hisseler>> favoriHisseleriGetir() async {
    favoriKodlar = await favoriKodlariGetir();           // ["ASELS", "THYAO"]
    final tumHisseler = await tumHisseleriGetir();             // Tüm API verisi

    return tumHisseler.where((hisse) => favoriKodlar.contains(hisse.hisseAdi)).toList();
  }
  Future<void> favoriDegistir(String kod) async {
    final prefs = await SharedPreferences.getInstance();

    if (favoriKodlar.contains(kod)) {
      favoriKodlar.remove(kod); // favoriden çıkar
    } else {
      favoriKodlar.add(kod); // favoriye ekle
    }

    await prefs.setStringList("favoriler", favoriKodlar); // SharedPreferences'a yaz

    setState(() {}); // UI güncelle
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
        title: Text(
          "Favoriler",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),

      ),
      backgroundColor: const Color(0xFF0B1D51),
      body: FutureBuilder<List<Hisseler>>(
        future: favoriHisseleriGetir(),
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
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 4),
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
