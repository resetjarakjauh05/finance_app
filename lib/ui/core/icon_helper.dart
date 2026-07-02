import 'package:flutter/material.dart';

/// Static map hex → IconData constant (tree-shake safe)
const Map<String, IconData> _kIconMap = {
  'e532': IconData(0xe532, fontFamily: 'MaterialIcons'), // restaurant
  'e1d7': IconData(0xe1d7, fontFamily: 'MaterialIcons'), // directions_car
  'e59a': IconData(0xe59a, fontFamily: 'MaterialIcons'), // shopping_bag
  'e5e8': IconData(0xe5e8, fontFamily: 'MaterialIcons'), // sports_esports
  'e3d8': IconData(0xe3d8, fontFamily: 'MaterialIcons'), // medical_services
  'e80c': IconData(0xe80c, fontFamily: 'MaterialIcons'), // school
  'e50d': IconData(0xe50d, fontFamily: 'MaterialIcons'), // receipt_long
  'e38d': IconData(0xe38d, fontFamily: 'MaterialIcons'), // local_cafe
  'e041': IconData(0xe041, fontFamily: 'MaterialIcons'), // account_balance_wallet
  'e67f': IconData(0xe67f, fontFamily: 'MaterialIcons'), // trending_up
  'e482': IconData(0xe482, fontFamily: 'MaterialIcons'), // payments
  'e553': IconData(0xe553, fontFamily: 'MaterialIcons'), // savings
  'e402': IconData(0xe402, fontFamily: 'MaterialIcons'), // more_horiz
  'e318': IconData(0xe318, fontFamily: 'MaterialIcons'), // home
  'e297': IconData(0xe297, fontFamily: 'MaterialIcons'), // flight
  'e28d': IconData(0xe28d, fontFamily: 'MaterialIcons'), // fitness_center
  'e415': IconData(0xe415, fontFamily: 'MaterialIcons'), // music_note
  'e4a1': IconData(0xe4a1, fontFamily: 'MaterialIcons'), // pets
  'e13e': IconData(0xe13e, fontFamily: 'MaterialIcons'), // card_giftcard
  'e5f2': IconData(0xe5f2, fontFamily: 'MaterialIcons'), // sports_soccer
  'e116': IconData(0xe116, fontFamily: 'MaterialIcons'), // build
  'e367': IconData(0xe367, fontFamily: 'MaterialIcons'), // laptop
  'e5c6': IconData(0xe5c6, fontFamily: 'MaterialIcons'), // smartphone
  'e40d': IconData(0xe40d, fontFamily: 'MaterialIcons'), // movie
  'e25a': IconData(0xe25a, fontFamily: 'MaterialIcons'), // fastfood
  'e1d5': IconData(0xe1d5, fontFamily: 'MaterialIcons'), // directions_bus
  'e396': IconData(0xe396, fontFamily: 'MaterialIcons'), // local_hospital
  'e217': IconData(0xe217, fontFamily: 'MaterialIcons'), // eco
  'e25b': IconData(0xe25b, fontFamily: 'MaterialIcons'), // favorite
  'e59c': IconData(0xe59c, fontFamily: 'MaterialIcons'), // shopping_cart
  'e040': IconData(0xe040, fontFamily: 'MaterialIcons'), // account_balance
  'e148': IconData(0xe148, fontFamily: 'MaterialIcons'), // category
  'e0b2': IconData(0xe0b2, fontFamily: 'MaterialIcons'), // attach_money
  'e6f2': IconData(0xe6f2, fontFamily: 'MaterialIcons'), // work
  'e3dd': IconData(0xe3dd, fontFamily: 'MaterialIcons'), // menu_book
  'e34a': IconData(0xe34a, fontFamily: 'MaterialIcons'), // inventory_2
  'e5d8': IconData(0xe5d8, fontFamily: 'MaterialIcons'), // spa
  'e15d': IconData(0xe15d, fontFamily: 'MaterialIcons'), // checkroom
  'f04ed': IconData(0xf04ed, fontFamily: 'MaterialIcons'), // diamond
  'e0d6': IconData(0xe0d6, fontFamily: 'MaterialIcons'), // beach_access
  'e160': IconData(0xe160, fontFamily: 'MaterialIcons'), // child_care
  'e0ee': IconData(0xe0ee, fontFamily: 'MaterialIcons'), // bolt
  'e366': IconData(0xe366, fontFamily: 'MaterialIcons'), // language
  'e130': IconData(0xe130, fontFamily: 'MaterialIcons'), // camera_alt
};

/// Lookup IconData dari hex codepoint string (tree-shake safe)
IconData iconFromHex(String hex) =>
    _kIconMap[hex] ?? Icons.help_outline;

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
