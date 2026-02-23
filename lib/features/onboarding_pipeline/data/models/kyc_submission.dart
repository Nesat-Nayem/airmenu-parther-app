import 'package:equatable/equatable.dart';

/// KYC Submission model for Onboarding Pipeline
/// Contains all fields from the API response
class KycSubmission extends Equatable {
  final String id;
  final String restaurantName;
  final String status; // 'pending', 'approved', 'rejected'

  // Contact Details
  final String fullName;
  final String email;
  final String phone;

  // Location Details
  final String city;
  final String locality;
  final String shopNo;
  final String floor;
  final String landmark;

  // Package Details
  final String packageName;
  final String packageDisplayPrice;

  // Document Numbers
  final String? gstNumber;
  final String? panNumber;
  final String? panFullName;
  final String? panAddress;
  final String? fssaiNumber;
  final String? fssaiExpiry;

  // Verification Status
  final String gstRegistered; // 'yes' or 'no'
  final bool documentsVerified;

  // Digital Signature
  final String? signatureUrl;

  // Adobe Agreement
  final String? agreementId;
  final String? agreementStatus;
  final bool vendorSigned;
  final bool adminSigned;

  // Dates
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  // Reviewer Info
  final String? reviewerName;

  // User relational data
  final String? userId;

  const KycSubmission({
    required this.id,
    required this.restaurantName,
    required this.status,
    required this.fullName,
    required this.email,
    required this.phone,
    this.city = '',
    this.locality = '',
    this.shopNo = '',
    this.floor = '',
    this.landmark = '',
    this.packageName = '',
    this.packageDisplayPrice = '',
    this.gstNumber,
    this.panNumber,
    this.panFullName,
    this.panAddress,
    this.fssaiNumber,
    this.fssaiExpiry,
    this.gstRegistered = 'no',
    this.documentsVerified = false,
    this.signatureUrl,
    this.agreementId,
    this.agreementStatus,
    this.vendorSigned = false,
    this.adminSigned = false,
    this.submittedAt,
    this.reviewedAt,
    this.reviewerName,
    this.userId,
  });

  factory KycSubmission.fromJson(Map<String, dynamic> json) {
    // User object (may be populated or just an ID string)
    final userObj = json['userId'] is Map
        ? json['userId'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Package object
    final packageObj = json['selectedPackage'] is Map
        ? json['selectedPackage'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Reviewer object
    final reviewerObj = json['reviewedBy'] is Map
        ? json['reviewedBy'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Adobe Agreement object
    final adobeObj = json['adobeAgreement'] is Map
        ? json['adobeAgreement'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Parse restaurant name - try multiple possible fields
    String restaurantName = '';
    if (json['restaurantName'] != null &&
        json['restaurantName'].toString().trim().isNotEmpty) {
      restaurantName = json['restaurantName'].toString().trim();
    } else if (json['businessName'] != null &&
        json['businessName'].toString().trim().isNotEmpty) {
      restaurantName = json['businessName'].toString().trim();
    } else if (json['name'] != null &&
        json['name'].toString().trim().isNotEmpty) {
      restaurantName = json['name'].toString().trim();
    }

    return KycSubmission(
      id: json['_id']?.toString() ?? '',
      restaurantName: restaurantName,
      status: json['status']?.toString() ?? 'pending',

      // Contact
      fullName:
          json['fullName']?.toString() ?? userObj['name']?.toString() ?? '',
      email: json['email']?.toString() ?? userObj['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? userObj['phone']?.toString() ?? '',

      // Location
      city: json['city']?.toString() ?? '',
      locality: json['locality']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',

      // Package
      packageName: packageObj['name']?.toString() ?? '',
      packageDisplayPrice: packageObj['displayPrice']?.toString() ?? '',

      // Document Numbers
      gstNumber: json['gstNumber']?.toString(),
      panNumber: json['panNumber']?.toString(),
      panFullName: json['panFullName']?.toString(),
      panAddress: json['panAddress']?.toString(),
      fssaiNumber: json['fssaiNumber']?.toString(),
      fssaiExpiry: json['fssaiExpiry']?.toString(),

      // Verification
      gstRegistered: json['gstRegistered']?.toString() ?? 'no',
      documentsVerified: json['documentsVerified'] == true,

      // Digital Signature
      signatureUrl:
          json['digitalSignature']?.toString() ?? json['signature']?.toString(),

      // Adobe Agreement
      agreementId: adobeObj['agreementId']?.toString() ??
          json['adobeAgreementId']?.toString(),
      agreementStatus: adobeObj['status']?.toString() ??
          json['adobeStatus']?.toString(),
      vendorSigned: adobeObj['vendorSigned'] == true ||
          json['vendorSignedAt'] != null,
      adminSigned: adobeObj['adminSigned'] == true ||
          json['adminSignedAt'] != null,

      // Dates
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,

      // Reviewer
      reviewerName: reviewerObj['name']?.toString(),

      // User ID
      userId:
          userObj['_id']?.toString() ??
          (json['userId'] is String ? json['userId'] : null),
    );
  }

  /// Calculate days since submission
  int get daysInStage {
    if (submittedAt == null) return 0;
    return DateTime.now().difference(submittedAt!).inDays;
  }

  /// Format duration as "X days" or "Y months" based on duration
  String get formattedDuration {
    final days = daysInStage;
    if (days < 30) {
      return '${days}d';
    } else {
      final months = (days / 30).floor();
      return '${months}mo';
    }
  }

  @override
  List<Object?> get props => [
    id,
    restaurantName,
    status,
    fullName,
    email,
    phone,
    city,
    locality,
    shopNo,
    floor,
    landmark,
    packageName,
    packageDisplayPrice,
    gstNumber,
    panNumber,
    panFullName,
    panAddress,
    fssaiNumber,
    fssaiExpiry,
    gstRegistered,
    documentsVerified,
    signatureUrl,
    agreementId,
    agreementStatus,
    vendorSigned,
    adminSigned,
    submittedAt,
    reviewedAt,
    reviewerName,
    userId,
  ];
}
