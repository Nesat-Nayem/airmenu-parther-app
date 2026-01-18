/// Generic pagination model for API responses
class PaginationModel {
  final int? totalItems;
  final int? currentPage;
  final int? itemsPerPage;
  final int? totalPages;

  const PaginationModel({
    this.totalItems,
    this.currentPage,
    this.itemsPerPage,
    this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalItems: json['total'] as int? ?? json['totalItems'] as int?,
      currentPage: json['page'] as int? ?? json['currentPage'] as int?,
      itemsPerPage: json['limit'] as int? ?? json['itemsPerPage'] as int?,
      totalPages: json['pages'] as int? ?? json['totalPages'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalItems': totalItems,
    'currentPage': currentPage,
    'itemsPerPage': itemsPerPage,
    'totalPages': totalPages,
  };

  /// Create a default pagination for single page results
  factory PaginationModel.singlePage(int itemCount) {
    return PaginationModel(
      totalItems: itemCount,
      currentPage: 1,
      itemsPerPage: itemCount,
      totalPages: 1,
    );
  }
}
