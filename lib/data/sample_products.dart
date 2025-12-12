// lib/data/sample_products.dart
import '../models/product.dart';

final sampleProducts = <Product>[
  Product(
    id: "p1",
    name: "Caffe Mocha",
    subtitle: "Deep foam, chocolate & espresso.",
    price: 15000,
    category: "Mocha",
    imageUrl: "assets/mocha.jpg", 
  ),
  Product(
    id: "p2",
    name: "Flat White",
    subtitle: "Smooth espresso with velvety milk.",
    price: 15000,
    category: "Flat White",
    imageUrl: "assets/latte.jpg", 
  ),
  Product(
    id: "p3",
    name: "Latte",
    subtitle: "Classic latte with foam art.",
    price: 12000,
    category: "Latte",
    imageUrl: "assets/cappucino.jpg", 
  ),
  Product(
    id: "p4",
    name: "Americano",
    subtitle: "Simple, black, and bold.",
    price: 10000,
    category: "Americano",
    imageUrl: "assets/americano.jpg", 
  ),
  Product(
    id: "p5",
    name: "Kopi Hitam",
    subtitle: "Kopi hitam spesial dari Tuban.",
    price: 8000,
    category: "Americano",
    imageUrl: "assets/kopi_hitam.jpg", 
  ),
  Product(
    id: "p6",
    name: "Espresso Shot",
    subtitle: "A strong, concentrated coffee.",
    price: 18000,
    category: "Espresso",
    imageUrl: "assets/esspreso.jpg", 
  ),
];