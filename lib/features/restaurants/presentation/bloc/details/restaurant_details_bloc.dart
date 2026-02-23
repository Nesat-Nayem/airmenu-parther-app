import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'restaurant_details_event.dart';
import 'restaurant_details_state.dart';

class RestaurantDetailsBloc
    extends Bloc<RestaurantDetailsEvent, RestaurantDetailsState> {
  final AdminRestaurantsRepository _repository;

  RestaurantDetailsBloc({
    required AdminRestaurantsRepository repository,
    RestaurantModel? restaurant,
  }) : _repository = repository,
       super(RestaurantDetailsInitial()) {
    on<LoadRestaurantDetails>(_onLoadRestaurantDetails);
    on<SwitchDetailsTab>(_onSwitchDetailsTab);
  }

  Future<void> _onLoadRestaurantDetails(
    LoadRestaurantDetails event,
    Emitter<RestaurantDetailsState> emit,
  ) async {
    emit(RestaurantDetailsLoading());

    try {
      // Always fetch fresh data to ensure we have complete restaurant details including galleryImages
      final restaurant = await _repository.getRestaurantDetails(
        restaurantId: event.restaurantId,
      );

      // Generate Mock Data based on screenshots

      // Overview Stats
      final overviewStats = {
        'ordersToday': '156',
        'gmvToday': '₹2.4L',
        'avgPrepTime': '18 min',
        'kitchenHealth': '92%',
        'inventoryRisk': '8 items',
        'slaScore': '96%',
      };

      // Branches
      final branches = [
        {
          'name': 'Indiranagar',
          'city': 'Bangalore',
          'status': 'Active',
          'lastSync': '2 min ago',
        },
        {
          'name': 'Koramangala',
          'city': 'Bangalore',
          'status': 'Active',
          'lastSync': '5 min ago',
        },
        {
          'name': 'HSR Layout',
          'city': 'Bangalore',
          'status': 'Inactive',
          'lastSync': '1 hr ago',
        },
      ];

      // Menu Issues
      final menuIssues = [
        {
          'name': 'Paneer Tikka',
          'category': 'Starters',
          'issue': 'Missing Image',
          'severity': 'Warning',
        },
        {
          'name': 'Dal Makhani',
          'category': 'Main Course',
          'issue': 'No Price Set',
          'severity': 'Error',
        },
        {
          'name': 'Gulab Jamun',
          'category': 'Desserts',
          'issue': 'No Category',
          'severity': 'Warning',
        },
        {
          'name': 'Chicken Biryani',
          'category': 'Main Course',
          'issue': 'Inventory Not Mapped',
          'severity': 'Warning',
        },
        {
          'name': 'Butter Naan',
          'category': 'Breads',
          'issue': 'Missing Description',
          'severity': 'Info',
        },
      ];

      // Tables
      final tables = List.generate(
        6,
        (index) => {
          'id': 'Table ${index + 1}',
          'capacity': (index % 2 == 0) ? 4 : 2,
          'status': [
            'Occupied',
            'Vacant',
            'Occupied',
            'Reserved',
            'Vacant',
            'Cleaning',
          ][index],
          'lastOrder': [
            '15 min ago',
            '2 hrs ago',
            '5 min ago',
            '1 hr ago',
            '3 hrs ago',
            '30 min ago',
          ][index],
        },
      );

      // Inventory Health
      final inventoryHealth = {
        'overallHealth': '85%',
        'lowStockItems': '8',
        'nearExpiry': '3',
        'fastMoving': '12',
        'alerts': [
          {
            'item': 'Paneer',
            'stock': '2 kg',
            'threshold': '5 kg',
            'status': 'Critical',
          },
          {
            'item': 'Tomatoes',
            'stock': '3 kg',
            'threshold': '10 kg',
            'status': 'Low',
          },
          {
            'item': 'Chicken',
            'stock': '8 kg',
            'threshold': '15 kg',
            'status': 'Low',
          },
          {
            'item': 'Cream',
            'stock': '1 L',
            'threshold': 'Expires in 2 days',
            'status': 'Expiring',
          },
        ],
      };

      // Billing Info
      final billingInfo = {
        'currentPlan': {
          'name': 'Premium',
          'price': '₹15,999/month',
          'renewsOn': 'Apr 15, 2024',
          'status': 'Active',
        },
        'invoices': [
          {
            'id': 'INV-2024-001',
            'date': 'Jan 15, 2024',
            'amount': '₹15,999',
            'status': 'Paid',
          },
          {
            'id': 'INV-2024-002',
            'date': 'Feb 15, 2024',
            'amount': '₹15,999',
            'status': 'Paid',
          },
          {
            'id': 'INV-2024-003',
            'date': 'Mar 15, 2024',
            'amount': '₹15,999',
            'status': 'Pending',
          },
        ],
      };

      // Staff List
      final staffList = [
        {
          'name': 'Rahul Sharma',
          'role': 'Manager',
          'email': 'rahul@spicegarden.com',
          'lastLogin': '2 hrs ago',
          'status': 'Active',
        },
        {
          'name': 'Priya Patel',
          'role': 'Chef',
          'email': 'priya@spicegarden.com',
          'lastLogin': '1 hr ago',
          'status': 'Active',
        },
        {
          'name': 'Amit Kumar',
          'role': 'Waiter',
          'email': 'amit@spicegarden.com',
          'lastLogin': '30 min ago',
          'status': 'Active',
        },
        {
          'name': 'Sneha Gupta',
          'role': 'Cashier',
          'email': 'sneha@spicegarden.com',
          'lastLogin': '5 hrs ago',
          'status': 'Inactive',
        },
      ];

      // Integrations Data
      final integrationsData = {
        'apiKey': 'sk-live-****************************abcd',
        'webhooks': [
          {
            'event': 'order.created',
            'url': 'https://api.example.com/orders',
            'status': 'Active',
            'lastTriggered': '5 min ago',
          },
          {
            'event': 'order.updated',
            'url': 'https://api.example.com/orders',
            'status': 'Active',
            'lastTriggered': '2 min ago',
          },
          {
            'event': 'inventory.low',
            'url': 'https://api.example.com/inventory',
            'status': 'Active',
            'lastTriggered': '1 hr ago',
          },
        ],
        'logs': [
          {
            'time': '12:45:23',
            'event': 'order.created',
            'status': 'Success',
            'duration': '124ms',
          },
          {
            'time': '12:42:18',
            'event': 'order.updated',
            'status': 'Success',
            'duration': '98ms',
          },
          {
            'time': '12:38:45',
            'event': 'payment.confirmed',
            'status': 'Success',
            'duration': '156ms',
          },
          {
            'time': '12:35:12',
            'event': 'inventory.update',
            'status': 'Failed',
            'duration': '2340ms',
          },
        ],
      };

      // Onboarding Data
      final onboardingData = {
        'manager': 'Vikram Singh',
        'steps': [
          {
            'title': 'Documents Submitted',
            'date': 'Dec 1, 2023',
            'description': 'All documents verified',
            'status': 'Completed',
          },
          {
            'title': 'Menu Digitization',
            'date': 'Dec 10, 2023',
            'description': '124 items added',
            'status': 'Completed',
          },
          {
            'title': 'QR Code Kit Ready',
            'date': 'Dec 15, 2023',
            'description': '25 QR codes generated',
            'status': 'Completed',
          },
          {
            'title': 'Staff Training',
            'date': 'Dec 20, 2023',
            'description': '18 staff trained',
            'status': 'Completed',
          },
          {
            'title': 'Go-Live',
            'date': 'Jan 1, 2024',
            'description': 'Successfully launched',
            'status': 'Completed',
          },
        ],
      };

      // Emit initial state with loading for buffets
      emit(
        RestaurantDetailsLoaded(
          restaurant: restaurant,
          overviewStats: overviewStats,
          menuIssues: menuIssues,
          tables: tables,
          inventoryHealth: inventoryHealth,
          branches: branches,
          billingInfo: billingInfo,
          staffList: staffList,
          integrationsData: integrationsData,
          onboardingData: onboardingData,
          isBuffetsLoading: true,
        ),
      );

      // Fetch buffets from API
      try {
        final buffets = await _repository.getRestaurantBuffets(
          restaurantId: event.restaurantId,
        );
        
        if (state is RestaurantDetailsLoaded) {
          emit(
            (state as RestaurantDetailsLoaded).copyWith(
              buffets: buffets,
              isBuffetsLoading: false,
            ),
          );
        }
      } catch (e) {
        // Silently fail for buffets - just mark as not loading
        if (state is RestaurantDetailsLoaded) {
          emit(
            (state as RestaurantDetailsLoaded).copyWith(
              isBuffetsLoading: false,
            ),
          );
        }
      }
    } catch (e) {
      emit(RestaurantDetailsError(e.toString()));
    }
  }

  void _onSwitchDetailsTab(
    SwitchDetailsTab event,
    Emitter<RestaurantDetailsState> emit,
  ) {
    if (state is RestaurantDetailsLoaded) {
      emit(
        (state as RestaurantDetailsLoaded).copyWith(
          selectedTabIndex: event.index,
        ),
      );
    }
  }
}
