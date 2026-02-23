class MenuItemMock {
  final String id;
  final String name;
  final String category;
  final String categoryId;
  final String description;
  final double price;
  final bool isVeg;
  final String imageUrl;
  final int variants;
  final int addOns;
  final int ordersToday;
  final bool isVisible;

  const MenuItemMock({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.description,
    required this.price,
    required this.isVeg,
    required this.imageUrl,
    this.variants = 0,
    this.addOns = 0,
    this.ordersToday = 0,
    this.isVisible = true,
  });
}

// Mock data for different categories
class MockMenuData {
  static final List<MenuItemMock> allItems = [
    // Main Course
    const MenuItemMock(
      id: '1',
      name: 'Butter Chicken',
      category: 'Main Course',
      categoryId: 'main-course',
      description: 'Creamy tomato-based curry with tender chicken pieces',
      price: 350,
      isVeg: false,
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80',
      variants: 2,
      addOns: 2,
      ordersToday: 45,
    ),
    const MenuItemMock(
      id: '2',
      name: 'Paneer Tikka Masala',
      category: 'Main Course',
      categoryId: 'main-course',
      description: 'Grilled cottage cheese in rich tomato gravy',
      price: 280,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80',
      variants: 1,
      addOns: 3,
      ordersToday: 32,
    ),
    const MenuItemMock(
      id: '3',
      name: 'Chicken Korma',
      category: 'Main Course',
      categoryId: 'main-course',
      description: 'Aromatic curry with nuts and cream',
      price: 340,
      isVeg: false,
      imageUrl:
          'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
      variants: 1,
      addOns: 2,
      ordersToday: 28,
    ),

    // Starters
    const MenuItemMock(
      id: '4',
      name: 'Paneer Tikka',
      category: 'Starters',
      categoryId: 'starters',
      description: 'Grilled cottage cheese marinated in spices',
      price: 220,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400&q=80',
      variants: 2,
      addOns: 1,
      ordersToday: 38,
    ),
    const MenuItemMock(
      id: '5',
      name: 'Chicken Wings',
      category: 'Starters',
      categoryId: 'starters',
      description: 'Crispy chicken wings with tangy sauce',
      price: 280,
      isVeg: false,
      imageUrl:
          'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=400&q=80',
      variants: 3,
      addOns: 2,
      ordersToday: 52,
    ),
    const MenuItemMock(
      id: '6',
      name: 'Spring Rolls',
      category: 'Starters',
      categoryId: 'starters',
      description: 'Crispy vegetable rolls with sweet chili sauce',
      price: 180,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400&q=80',
      variants: 1,
      addOns: 1,
      ordersToday: 25,
    ),

    // Breads
    const MenuItemMock(
      id: '7',
      name: 'Butter Naan',
      category: 'Breads',
      categoryId: 'breads',
      description: 'Soft flatbread brushed with butter',
      price: 45,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80',
      variants: 0,
      addOns: 0,
      ordersToday: 95,
    ),
    const MenuItemMock(
      id: '8',
      name: 'Garlic Naan',
      category: 'Breads',
      categoryId: 'breads',
      description: 'Naan topped with fresh garlic and coriander',
      price: 55,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1619887308055-3125162e30cd?w=400&q=80',
      variants: 0,
      addOns: 0,
      ordersToday: 78,
    ),

    // Rice
    const MenuItemMock(
      id: '9',
      name: 'Biryani',
      category: 'Rice',
      categoryId: 'rice',
      description: 'Fragrant basmati rice with spiced meat',
      price: 320,
      isVeg: false,
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
      variants: 3,
      addOns: 4,
      ordersToday: 67,
    ),
    const MenuItemMock(
      id: '10',
      name: 'Veg Pulao',
      category: 'Rice',
      categoryId: 'rice',
      description: 'Aromatic rice with mixed vegetables',
      price: 180,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&q=80',
      variants: 1,
      addOns: 2,
      ordersToday: 42,
    ),

    // Desserts
    const MenuItemMock(
      id: '11',
      name: 'Gulab Jamun',
      category: 'Desserts',
      categoryId: 'desserts',
      description: 'Sweet milk solids in sugar syrup',
      price: 120,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1610119472355-39919e7c5a6b?w=400&q=80',
      variants: 0,
      addOns: 1,
      ordersToday: 34,
    ),
    const MenuItemMock(
      id: '12',
      name: 'Kulfi',
      category: 'Desserts',
      categoryId: 'desserts',
      description: 'Traditional Indian ice cream',
      price: 100,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1582716401346-a29f56ea8dc6?w=400&q=80',
      variants: 3,
      addOns: 0,
      ordersToday: 28,
    ),

    // Beverages
    const MenuItemMock(
      id: '13',
      name: 'Mango Lassi',
      category: 'Beverages',
      categoryId: 'beverages',
      description: 'Refreshing yogurt drink with mango',
      price: 80,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1589651076953-7cc4d7abe5d6?w=400&q=80',
      variants: 0,
      addOns: 0,
      ordersToday: 56,
    ),
    const MenuItemMock(
      id: '14',
      name: 'Masala Chai',
      category: 'Beverages',
      categoryId: 'beverages',
      description: 'Spiced Indian tea with milk',
      price: 40,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1575487426366-079595af2247?w=400&q=80',
      variants: 0,
      addOns: 0,
      ordersToday: 102,
    ),

    // Combos
    const MenuItemMock(
      id: '15',
      name: 'Thali Combo',
      category: 'Combos',
      categoryId: 'combos',
      description: 'Complete meal with rice, bread, curry, and dessert',
      price: 450,
      isVeg: true,
      imageUrl:
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80',
      variants: 2,
      addOns: 0,
      ordersToday: 35,
    ),
  ];

  static List<MenuItemMock> getItemsByCategory(String categoryId) {
    if (categoryId == 'all') {
      return allItems;
    }
    return allItems.where((item) => item.categoryId == categoryId).toList();
  }
}
