import 'package:airmenuai_partner_app/features/menu_audit/data/models/menu_audit_response.dart';
import 'package:airmenuai_partner_app/features/menu_audit/domain/repositories/i_menu_audit_repository.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IMenuAuditRepository)
class MenuAuditRepositoryImpl implements IMenuAuditRepository {
  @override
  Future<Either<String, MenuAuditStats>> getMenuAuditStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Response derived from user provided JSON
    final mockStats = MenuAuditStats(
      summary: const MenuAuditSummary(
        totalIssues: 168, // 89 + 67 + 12
        missingImages: 89,
        missingPrices: 12,
        unmappedItems:
            5, // Arbitrary count for "Unmapped/Inventory" from issues
      ),
      issues: const [
        MenuAuditIssue(
          restaurantId: "rest_123",
          restaurantName: "Spice Garden",
          itemId: "item_456",
          itemName: "Dal Makhani",
          issueDescription: "Missing description",
          category: "Content",
          severity: "Warning",
          actionUrl: "/menu/item/item_456",
        ),
        MenuAuditIssue(
          restaurantId: "rest_124",
          restaurantName: "Bistro 42",
          itemId: "item_789",
          itemName: "Cappuccino",
          issueDescription: "Missing image",
          category: "Media",
          severity: "Critical",
          actionUrl: "/menu/item/item_789",
        ),
        MenuAuditIssue(
          restaurantId: "rest_125",
          restaurantName: "Cloud Kitchen Pro",
          itemId: "item_101",
          itemName: "Burger Combo",
          issueDescription: "Missing price",
          category: "Pricing",
          severity: "Critical",
          actionUrl: "/menu/item/item_101",
        ),
        MenuAuditIssue(
          restaurantId: "rest_126",
          restaurantName: "Royal Dine",
          itemId: "item_202",
          itemName: "Paneer Tikka",
          issueDescription: "No category assigned",
          category: "Organization",
          severity: "Warning",
          actionUrl: "/menu/item/item_202",
        ),
        MenuAuditIssue(
          restaurantId: "rest_127",
          restaurantName: "Curry House",
          itemId: "item_303",
          itemName: "Biryani",
          issueDescription: "Inventory not mapped",
          category: "Inventory",
          severity: "Warning",
          actionUrl: "/menu/item/item_303",
        ),
        // Duplicating for table population testing
        MenuAuditIssue(
          restaurantId: "rest_124",
          restaurantName: "Bistro 42",
          itemId: "item_790",
          itemName: "Latte",
          issueDescription: "Missing image",
          category: "Media",
          severity: "Critical",
          actionUrl: "/menu/item/item_790",
        ),
      ],
    );

    return Right(mockStats);
  }
}
