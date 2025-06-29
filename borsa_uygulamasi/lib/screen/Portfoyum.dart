import 'package:animate_do/animate_do.dart';
import 'package:borsa_uygulamasi/consts/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:borsa_uygulamasi/screen/HisseEkle.dart'; // Bu import artık gerekmeyebilir
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:dropdown_search/dropdown_search.dart'; // dropdown_search paketini import edin

import '../models/Hisseler.dart';
import '../models/HisselerCevap.dart';

class Portfoyum extends StatefulWidget {
  var mevcutKullaniciUidTutucu;

  Portfoyum(this.mevcutKullaniciUidTutucu);

  @override
  State<Portfoyum> createState() => _PortfoyumState();
}

class _PortfoyumState extends State<Portfoyum> {
  @override
  void initState() {
    super.initState();
    tumHisseleriGetir().then((gelenTumHisseler) {
      if (mounted) { // Widget ağaçta mı diye kontrol edin
        setState(() {
          tumHisseler = gelenTumHisseler;
        });
      }
    });
  }

  List<Hisseler> tumHisseler = [];
  Map<String, dynamic> portfoydakitumHisseler = {};
  Map<String, dynamic> portfoydakitumHisselerID = {};
  final String apiKey = "apikey 4VFmJ7q6q12Hl24v2wQRpT:63iwn6e1lKAwCoRAuWa5Qt";
  final Dio dio = Dio();

  Future<List<Hisseler>> tumHisseleriGetir() async {
    try { // Hata yakalama ekleyin
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
        throw Exception("Veri alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi vermek veya loglamak için
      print("Hisse verileri alınırken hata oluştu: $e");
      // İsteğe bağlı olarak boş liste veya null dönebilirsiniz
      // ya da kullanıcıya bir hata mesajı gösterebilirsiniz.
      return []; // Boş liste döndürerek uygulamanın çökmesini engelleyebilirsiniz.
    }
  }
  Future<List<Hisseler>> arananHisseleriGetir(String arananHisse)async{
    final tumHisseler = await tumHisseleriGetir();
    return tumHisseler.where((hisse) =>
        hisse.hisseAdi.toLowerCase().contains(arananHisse.toLowerCase())
    ).toList();

  }


  var key = GlobalKey<FormState>();
  // tfcHisseAdi'nı artık doğrudan kullanmayacağız, seçilen hisseyi tutmak için yeni bir değişken
  Hisseler? secilenHisse; // Seçilen hisseyi tutmak için
  var tfcAdet = TextEditingController();
  var tfcMaliyet = TextEditingController();

  // Validator'lar aynı kalabilir
  String? HisseAdiValidator(Hisseler? value) { // Parametre tipini Hisseler? olarak değiştirin
    if (value == null) return "Lütfen bir hisse seçin.";
    return null;
  }

  String? HisseMaliyetValidator(String? value) {
    if (value == null || value.isEmpty) return "Boş bırakılamaz.";
    // Sayısal değer kontrolü de ekleyebilirsiniz
    if (double.tryParse(value) == null) return "Geçerli bir sayı girin.";
    return null;
  }

  String? HisseAdetValidator(String? value) {
    if (value == null || value.isEmpty) return "Boş bırakılamaz.";
    // Sayısal değer kontrolü de ekleyebilirsiniz
    if (int.tryParse(value) == null) return "Geçerli bir sayı girin.";
    return null;
  }
  Future<List<Hisseler>> portfoyddekiHisseleriGetir() async {
    final tumHisseler = await tumHisseleriGetir();             // Tüm API verisi
    List<String> portfoyHisseAdlari = portfoydakitumHisseler.keys.toList();
    return tumHisseler.where((hisse) => portfoyHisseAdlari.contains(hisse.hisseAdi)).toList();
  }
  Color getRateColor(double rate) => rate >= 0 ? Colors.greenAccent : Colors.redAccent;
  IconData getRateIcon(double rate) => rate >= 0 ? Icons.trending_up : Icons.trending_down;
  var eklemeZamani="";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
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
          "Portföyüm",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0B1D51),
      body: widget.mevcutKullaniciUidTutucu==null?Center(child: CircularProgressIndicator(),):Column(
        children: [
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Portfoy").doc(widget.mevcutKullaniciUidTutucu).collection("Hisselerim").snapshots(),
              builder: (context,snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }
                if(!snapshot.hasData||snapshot.data!.docs.isEmpty){
                  return Center(child: Text("Henüz Hisse Yok"),);
                }
                var veriler=snapshot.data!.docs;
                return ListView.builder(
                    itemCount: veriler.length,
                    itemBuilder: (context,indeks){
                      var hisse=veriler[indeks];
                      var eklemeZamani=(hisse["tamZaman"]as Timestamp).toDate();


                      setState(() {
                        portfoydakitumHisseler.clear(); // önce temizle
                        portfoydakitumHisselerID.clear();
                        for (var hisse in veriler) {
                          eklemeZamani = (hisse["tamZaman"] as Timestamp).toDate();
                          portfoydakitumHisseler[hisse["hisseAdi"]] = {
                            "adet": hisse["adet"],
                            "maliyet": hisse["maliyet"],
                            "eklemeZamani": eklemeZamani
                          };
                          portfoydakitumHisselerID[hisse["hisseAdi"]] = {
                            "hisseID": hisse.id,

                          };

                        }

                      });

                    });

              },
            ),
          ),
          Expanded(
            flex: 10000,
            child: FutureBuilder<List<Hisseler>>(
              future: portfoyddekiHisseleriGetir(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var hisseListesi = snapshot.data;

                  double toplamYatirim = 0;
                  double toplamGuncelDeger = 0;

                  for (var hisse in hisseListesi!) {
                    var adet = portfoydakitumHisseler[hisse.hisseAdi]["adet"];
                    var maliyet = portfoydakitumHisseler[hisse.hisseAdi]["maliyet"];
                    toplamYatirim += (maliyet * adet);
                    toplamGuncelDeger += (hisse.anlikFiyat * adet);
                  }

                  var toplamKarZarar = toplamGuncelDeger - toplamYatirim;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: hisseListesi.length,
                          itemBuilder: (context, indeks) {
                            var hisse = hisseListesi[indeks];
                            var adet = portfoydakitumHisseler[hisse.hisseAdi]["adet"];
                            var maliyet = portfoydakitumHisseler[hisse.hisseAdi]["maliyet"];
                            var eklemeZamani = portfoydakitumHisseler[hisse.hisseAdi]["eklemeZamani"];
                            return FadeInUp(
                              duration: Duration(milliseconds: 300 + indeks * 50),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 3.5,
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
                                        Icon(getRateIcon(hisse.gunlukDegisim),
                                            color: getRateColor(hisse.gunlukDegisim), size: 36),
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
                                          "Değişim: %${hisse.gunlukDegisim.toStringAsFixed(2)}",
                                          style: TextStyle(fontSize: 24, color: getRateColor(hisse.gunlukDegisim)),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("Portfoy")
                                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                                  .collection("Hisselerim")
                                                  .doc(portfoydakitumHisselerID[hisse.hisseAdi]["hisseID"])
                                                  .delete();
                                              setState(() {
                                                portfoydakitumHisseler.remove(hisse.hisseAdi);
                                                portfoydakitumHisselerID.remove(hisse.hisseAdi);
                                              });
                                              Fluttertoast.showToast(msg: "Hisse silindi");

                                            },
                                            icon: Icon(Icons.delete, color: Colors.white, size: 40))
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text("Adet: ${adet}",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white70))),
                                        Expanded(
                                            child: Text("Maliyet: ${maliyet}",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white70))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.07),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: maliyet * adet < adet * hisse.anlikFiyat
                                            ? Text("Kar: ${(hisse.anlikFiyat * adet - maliyet * adet).toStringAsFixed(2)}TRY",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.greenAccent))
                                            : Text("Zarar: ${(hisse.anlikFiyat * adet - maliyet * adet).toStringAsFixed(2)} TRY",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.redAccent)),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text("Toplam Yatırım: ${toplamYatirim.toStringAsFixed(2)} TRY", style: TextStyle(fontSize: 22, color: Colors.white)),
                              Text("Güncel Değer: ${toplamGuncelDeger.toStringAsFixed(2)} TRY", style: TextStyle(fontSize: 22, color: Colors.white)),
                              Text(
                                toplamKarZarar >= 0
                                    ? "Toplam Kar: ${toplamKarZarar.toStringAsFixed(2)} TRY"
                                    : "Toplam Zarar: ${toplamKarZarar.abs().toStringAsFixed(2)} TRY",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: toplamKarZarar >= 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showDialog'a basıldığında seçilen hisseyi sıfırla
          setState(() {
            secilenHisse = null;
            tfcAdet.clear();
            tfcMaliyet.clear();
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor("#0B1D51"), HexColor("#122F6D")],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: key,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_chart, color: Colors.white, size: 30),
                              SizedBox(width: 10),
                              Text(
                                "Hisse Ekle",
                                style: GoogleFonts.montserrat(
                                    fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(color: Colors.white54, thickness: 1.2),
                          SizedBox(height: 20),

                          // Dropdown Search
                          DropdownSearch<Hisseler>(
                            asyncItems: (String filter) => tumHisseleriGetir(),
                            itemAsString: (Hisseler u) => u.hisseAdi ?? "Bilinmeyen Hisse",
                            onChanged: (Hisseler? data) {
                              setState(() {
                                secilenHisse = data;
                              });
                            },
                            selectedItem: secilenHisse,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Hisse Adı",
                                labelStyle: TextStyle(color: Colors.white70),
                                hintText: "Hisse seçin veya arayın",
                                hintStyle: TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            dropdownBuilder: (context, Hisseler? selectedItem) {
                              return Text(
                                selectedItem?.hisseAdi ?? "Hisse seçiniz",
                                style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              );
                            },
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Hisse ara...",
                                  hintStyle: TextStyle(color: Colors.black),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: HexColor("#333446"), width: 2),
                                  ),
                                ),
                              ),
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  title: Text(item.hisseAdi ?? "Bilinmeyen", style: TextStyle(color: HexColor("#0B1D51"))),
                                );
                              },
                            ),
                            validator: HisseAdiValidator,
                          ),

                          SizedBox(height: 20),

                          // Adet ve Maliyet alanları
                          Row(
                            children: [
                              Expanded(
                                child: Constlar().customTextFormFieldson(
                                    controller: tfcAdet,
                                    label: "Adet",
                                    hintText: "Adet gir",
                                    validator: HisseAdetValidator),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Constlar().customTextFormFieldson(
                                    controller: tfcMaliyet,
                                    label: "Maliyet",
                                    hintText: "Maliyet gir",
                                    validator: HisseMaliyetValidator),
                              ),
                            ],
                          ),

                          SizedBox(height: 25),

                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              icon: Icon(Icons.check, color: Colors.white),
                              label: Text(
                                "Ekle",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              onPressed: () {
                                if (key.currentState!.validate()) {
                                  verileriEkle(secilenHisse?.hisseAdi, tfcAdet.text, tfcMaliyet.text);
                                }
                              }

                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

        },
        backgroundColor: Color(0xFF122F6D),
        child: Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
  void verileriEkle(String? hisseAdi, String adetText, String maliyetText) async {
    try {
      var mevcutKullanici = FirebaseAuth.instance.currentUser;

      if (mevcutKullanici == null) {
        Fluttertoast.showToast(msg: "Kullanıcı oturumu bulunamadı!");
        return;
      }

      int adet = int.tryParse(adetText) ?? 0;
      double maliyet = double.tryParse(maliyetText) ?? 0.0;

      if (adet <= 0 || maliyet <= 0 || hisseAdi == null) {
        Fluttertoast.showToast(msg: "Lütfen tüm alanları geçerli girin.");
        return;
      }

      var zaman = DateTime.now();

      await FirebaseFirestore.instance
          .collection("Portfoy")
          .doc(mevcutKullanici.uid)
          .collection("Hisselerim")
          .doc(zaman.toIso8601String())
          .set({
        'hisseAdi': hisseAdi,
        'adet': adet,
        'maliyet': maliyet,
        'zaman': zaman.toIso8601String(),
        'tamZaman': zaman,
      });
      setState(() {

      });

      Fluttertoast.showToast(msg: "Hisse başarıyla eklendi!");
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Hata oluştu: $e");
      print("Firestore hata: $e");
    }
  }



  @override
  void dispose() {
    tfcAdet.dispose();
    tfcMaliyet.dispose();
    super.dispose();
  }
}