import 'package:flutter/material.dart';

/// Render Material Icon dari hex codepoint string (e.g. 'e532')
IconData iconFromHex(String hex) {
  final cp = int.tryParse(hex, radix: 16);
  if (cp == null) return Icons.help_outline;
  // ignore: prefer_const_constructors
  return IconData(cp, fontFamily: 'MaterialIcons');
}

/// 30 icon hex codepoint untuk kategori
const List<String> kCategoryMaterialIcons = [
  'e532', // restaurant
  'e1d7', // directions_car
  'e59a', // shopping_bag
  'e5e8', // sports_esports
  'e3d8', // medical_services
  'e80c', // school
  'e50d', // receipt_long
  'e38d', // local_cafe
  'e041', // account_balance_wallet
  'e67f', // trending_up
  'e482', // payments
  'e553', // savings
  'e402', // more_horiz
  'e318', // home
  'e297', // flight
  'e28d', // fitness_center
  'e415', // music_note
  'e4a1', // pets
  'e13e', // card_giftcard
  'e5f2', // sports_soccer
  'e116', // build
  'e367', // laptop
  'e5c6', // smartphone
  'e40d', // movie
  'e25a', // fastfood
  'e1d5', // directions_bus
  'e396', // local_hospital
  'e217', // eco
  'e25b', // favorite
  'e59c', // shopping_cart
  'e040', // account_balance
  'e148', // category
  'e0b2', // attach_money
  'e6f2', // work
  'e3d8', // medical_services (kesehatan alt)
  'e3dd', // menu_book
  'e34a', // inventory_2
  'e5d8', // spa
  'e15d', // checkroom
  'f04ed', // diamond
];

/// 20 icon hex codepoint untuk rencana tabungan
const List<String> kSavingsMaterialIcons = [
  'e553', // savings
  'e318', // home
  'e297', // flight
  'e1d7', // directions_car
  'f04ed', // diamond
  'e5c6', // smartphone
  'e367', // laptop
  'e80c', // school
  'e040', // account_balance
  'e0d6', // beach_access
  'e28d', // fitness_center
  'e5e8', // sports_esports
  'e160', // child_care
  'e396', // local_hospital
  'e59c', // shopping_cart
  'e0ee', // bolt
  'e366', // language
  'e415', // music_note
  'e130', // camera_alt
  'e13e', // card_giftcard
];

/// Label deskriptif untuk icon (untuk tooltip/accessibility)
const Map<String, String> kIconLabels = {
  'e532': 'Restoran',
  'e1d7': 'Kendaraan',
  'e59a': 'Belanja',
  'e5e8': 'Game',
  'e3d8': 'Kesehatan',
  'e80c': 'Pendidikan',
  'e50d': 'Tagihan',
  'e38d': 'Kafe',
  'e041': 'Dompet',
  'e67f': 'Investasi',
  'e482': 'Pembayaran',
  'e553': 'Tabungan',
  'e402': 'Lainnya',
  'e318': 'Rumah',
  'e297': 'Perjalanan',
  'e28d': 'Olahraga',
  'e415': 'Musik',
  'e4a1': 'Hewan',
  'e13e': 'Hadiah',
  'e5f2': 'Sepak Bola',
  'e116': 'Peralatan',
  'e367': 'Laptop',
  'e5c6': 'Smartphone',
  'e40d': 'Film',
  'e25a': 'Makanan Cepat',
  'e1d5': 'Bus',
  'e396': 'Rumah Sakit',
  'e217': 'Alam',
  'e25b': 'Favorit',
  'e59c': 'Keranjang',
  'e040': 'Bank',
  'e148': 'Kategori',
  'e0b2': 'Uang',
  'e6f2': 'Pekerjaan',
  'e3dd': 'Buku Menu',
  'e34a': 'Inventaris',
  'e5d8': 'Spa',
  'e15d': 'Pakaian',
  'f04ed': 'Berlian',
  'e0d6': 'Pantai',
  'e160': 'Anak',
  'e0ee': 'Listrik',
  'e366': 'Bahasa',
  'e130': 'Kamera',
};
