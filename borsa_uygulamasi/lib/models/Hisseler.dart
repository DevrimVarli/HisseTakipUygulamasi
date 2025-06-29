class Hisseler {
  String hisseAdi;
  String fiyatTuru;
  double anlikFiyat;
  double gunlukDegisim;
  String hacimLot;
  String hacimTl;
  String sonGuncellenmeZamani;

  Hisseler(
      this.hisseAdi,
      this.fiyatTuru,
      this.anlikFiyat,
      this.gunlukDegisim,
      this.hacimLot,
      this.hacimTl,
      this.sonGuncellenmeZamani,
      );

  factory Hisseler.fromJson(Map<String, dynamic> json) {
    return Hisseler(
      json["name"] ?? "",
      json["currency"] ?? "",
      (json["price"] as num).toDouble(),   // int veya double olabilir
      (json["rate"] as num).toDouble(),    // int veya double olabilir
      json["hacimlot"] ?? "",
      json["hacimtl"] ?? "",
      json["time"] ?? "",
    );
  }
}
