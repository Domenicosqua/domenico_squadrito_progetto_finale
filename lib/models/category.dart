/* enum CategoryName{
  salute,
  food,
  abbigliamento,
  trasporti,
  autoEMoto,
  alimentari,
  casa,
  igiene,
  sport,
  regali,
  ristorante,
  intrattenimento;

  String toDbValue() {
    switch (this) {
      case CategoryName.salute:
        return 'Salute';
      case CategoryName.food:
      return 'Food';
      case CategoryName.abbigliamento:
      return 'Abbigliamento';
      case CategoryName.trasporti:
      return 'Trasporti';
      case CategoryName.autoEMoto:
      return 'Auto E Moto';
      case CategoryName.alimentari:
      return 'Alimentari';
      case CategoryName.casa:
      return 'Casa';
      case CategoryName.igiene:
      return 'Igiene';
      case CategoryName.sport:
      return 'Sport';
      case CategoryName.regali:
      return 'Regali';
      case CategoryName.ristorante:
      return 'Ristorante';
      case 
      default:
    }
  }


} */

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'],
    name: m['name'],
    icon: m['icon'],
    color: m['color'],
  );
}
