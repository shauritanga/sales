class Sale {
  final int totalSales;
  final int totalOutlets;
  final List<Map<String, dynamic>>? topSellers;

  Sale({
    required this.totalSales,
    required this.totalOutlets,
    this.topSellers,
  });
}
