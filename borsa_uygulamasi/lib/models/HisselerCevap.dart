import 'package:borsa_uygulamasi/models/Hisseler.dart';

class HisselerCevap{
  List<Hisseler>hisselerListesi;

  HisselerCevap(this.hisselerListesi);
  factory HisselerCevap.fromJson(Map<String,dynamic>json){
    var jsonArray=json["result"] as List;
    List<Hisseler> hisselerListesi=jsonArray.map((jsonArrayNesnesi)=>Hisseler.fromJson(jsonArrayNesnesi)).toList();
    return HisselerCevap(hisselerListesi);
  }
}