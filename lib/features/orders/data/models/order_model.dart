class OrderModel {
  final String? id;
  final String? user;
  final List<OrderUser>? users;
  final List<OrderItemModel>? items;
  final num? subtotal;
  final num? cgstAmount;
  final num? sgstAmount;
  final num? serviceCharge;
  final num? totalAmount;
  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? tableNumber;
  final String? couponCode;
  final num? discountAmount;
  final num? offerDiscount;
  final num? amountPaid;
  final num? amountRefunded;
  final String? orderType;
  final bool? inventoryConsumed;
  final String? createdAt;
  final String? updatedAt;
  final OrderPaymentDetails? paymentDetails;
  final String? paymentId;
  final OrderHotel? hotel;
  final String? kitchenStatus;
  final List<RefundModel>? refunds;
  final String? hotelName; // Populated by admin API
  final String? hotelId; // Populated by admin API

  OrderModel({
    this.id,
    this.user,
    this.users,
    this.items,
    this.subtotal,
    this.cgstAmount,
    this.sgstAmount,
    this.serviceCharge,
    this.totalAmount,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.tableNumber,
    this.couponCode,
    this.discountAmount,
    this.offerDiscount,
    this.amountPaid,
    this.amountRefunded,
    this.orderType,
    this.inventoryConsumed,
    this.createdAt,
    this.updatedAt,
    this.paymentDetails,
    this.paymentId,
    this.kitchenStatus,
    this.hotel,
    this.refunds,
    this.hotelName,
    this.hotelId,
  });

  /// Create a copy with updated hotelName/hotelId
  OrderModel withHotelInfo({String? hotelName, String? hotelId}) {
    return OrderModel(
      id: id,
      user: user,
      users: users,
      items: items,
      subtotal: subtotal,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      serviceCharge: serviceCharge,
      totalAmount: totalAmount,
      status: status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      tableNumber: tableNumber,
      couponCode: couponCode,
      discountAmount: discountAmount,
      offerDiscount: offerDiscount,
      amountPaid: amountPaid,
      amountRefunded: amountRefunded,
      orderType: orderType,
      inventoryConsumed: inventoryConsumed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paymentDetails: paymentDetails,
      paymentId: paymentId,
      kitchenStatus: kitchenStatus,
      hotel: hotel,
      refunds: refunds,
      hotelName: hotelName ?? this.hotelName,
      hotelId: hotelId ?? this.hotelId,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse items first so we can extract hotelId from the first item
    final parsedItems = json['items'] != null
        ? (json['items'] as List)
              .map((i) => OrderItemModel.fromJson(i))
              .toList()
        : null;

    // Extract hotelId from first item if not provided at order level
    String? hotelId = json['hotelId'];
    if (hotelId == null && parsedItems != null && parsedItems.isNotEmpty) {
      hotelId = parsedItems.first.hotelId;
    }

    return OrderModel(
      id: json['_id'],
      user: json['user'],
      users: json['users'] != null
          ? (json['users'] as List).map((i) => OrderUser.fromJson(i)).toList()
          : null,
      items: parsedItems,
      subtotal: json['subtotal'],
      cgstAmount: json['cgstAmount'],
      sgstAmount: json['sgstAmount'],
      serviceCharge: json['serviceCharge'],
      totalAmount: json['totalAmount'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      tableNumber: json['tableNumber'],
      couponCode: json['couponCode'],
      discountAmount: json['discountAmount'],
      offerDiscount: json['offerDiscount'],
      amountPaid: json['amountPaid'],
      amountRefunded: json['amountRefunded'],
      orderType: json['orderType'],
      inventoryConsumed: json['inventoryConsumed'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      paymentDetails: json['paymentDetails'] != null
          ? OrderPaymentDetails.fromJson(json['paymentDetails'])
          : null,
      paymentId: json['paymentId'],
      kitchenStatus: json['kitchenStatus'],
      hotel: json['hotel'] != null ? OrderHotel.fromJson(json['hotel']) : null,
      refunds: json['refunds'] != null
          ? (json['refunds'] as List)
                .map((i) => RefundModel.fromJson(i))
                .toList()
          : null,
      hotelName: json['hotelName'],
      hotelId: hotelId,
    );
  }
}

class OrderUser {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;

  OrderUser({this.id, this.name, this.phone, this.email});

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class OrderItemModel {
  final String? id;
  final String? menuItem;
  final String? hotelId;
  final int? quantity;
  final String? size;
  final num? price;
  final String? status;
  final String? specialInstructions;
  final OrderMenuItemData? menuItemData;
  final String? orderedBy;
  final String? station;
  final List<String>? modifiers;

  OrderItemModel({
    this.id,
    this.menuItem,
    this.hotelId,
    this.quantity,
    this.size,
    this.price,
    this.status,
    this.specialInstructions,
    this.menuItemData,
    this.orderedBy,
    this.station,
    this.modifiers,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id'],
      menuItem: json['menuItem'],
      hotelId: json['hotelId']?.toString(),
      quantity: json['quantity'],
      size: json['size'],
      price: json['price'],
      status: json['status'],
      specialInstructions: json['specialInstructions'],
      menuItemData: json['menuItemData'] != null
          ? OrderMenuItemData.fromJson(json['menuItemData'])
          : null,
      orderedBy: json['orderedBy'],
      station: json['station'],
      modifiers: json['modifiers'] != null
          ? List<String>.from(json['modifiers'])
          : null,
    );
  }
}

class OrderHotel {
  final String? id;
  final String? name;

  OrderHotel({this.id, this.name});

  factory OrderHotel.fromJson(Map<String, dynamic> json) {
    return OrderHotel(id: json['_id'], name: json['name']);
  }
}

class RefundModel {
  final String? id;
  final num? amount;
  final String? method;
  final String? reason;
  final String? createdAt;

  RefundModel({this.id, this.amount, this.method, this.reason, this.createdAt});

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['_id'],
      amount: json['amount'],
      method: json['method'],
      reason: json['reason'],
      createdAt: json['createdAt'],
    );
  }
}

class OrderMenuItemData {
  final String? id;
  final String? title;
  final String? image;
  final String? description;
  final num? price;
  final String? category;

  OrderMenuItemData({
    this.id,
    this.title,
    this.image,
    this.description,
    this.price,
    this.category,
  });

  factory OrderMenuItemData.fromJson(Map<String, dynamic> json) {
    return OrderMenuItemData(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
    );
  }
}

class OrderPaymentDetails {
  final String? phonePeOrderId;
  final String? razorpayOrderId;

  OrderPaymentDetails({this.phonePeOrderId, this.razorpayOrderId});

  factory OrderPaymentDetails.fromJson(Map<String, dynamic> json) {
    return OrderPaymentDetails(
      phonePeOrderId: json['phonePeOrderId'],
      razorpayOrderId: json['razorpayOrderId'] ?? json['razorpay_order_id'],
    );
  }
}
