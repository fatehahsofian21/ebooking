// DriTrip.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
// Assume these packages are added to your pubspec.yaml
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform; // For platform-specific map URL


// --- Re-using brand guidelines for consistency ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kRejectColor = Color(0xFFdc3545); // For Emergency
const Color kApproveColor = Color(0xFF28a745); // For Call/Online Status
const Color kCompletedColor = Color(0xFF17a2b8); 

// Mock data for the map view's current location/status
const String kDriverStatusText = "You're ready for trip.";

// Re-implement or import DriverActions
class DriverActions {
  static const String adminPhoneNumber = '0322221111';

  static Future<void> callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) { 
      await launchUrl(launchUri);
    } else {
      // ignore: avoid_print
      print('Could not launch $phoneNumber');
    }
  }

  static Future<void> callRequester(String phoneNumber) async {
    await callNumber(phoneNumber);
  }

  static Future<void> callAdmin() async {
    await callNumber(adminPhoneNumber);
  }
}

// ENUM to define the stages of the trip for button/map logic
enum TripStage {
  enRouteToPickup,
  arrivedAtPickup,
  enRouteToDestination,
  arrivedAtDestination,
  completed,
}


// [FIX] Converted to StatefulWidget to manage trip state and map controller
class DriTripPage extends StatefulWidget {
  final Map<String, dynamic> tripDetails;

  const DriTripPage({super.key, required this.tripDetails});

  @override
  State<DriTripPage> createState() => _DriTripPageState();
}

class _DriTripPageState extends State<DriTripPage> {
  
  GoogleMapController? _mapController;
  // [MODIFIED] Start the trip at the 'arrivedAtPickup' stage
  TripStage _currentTripStage = TripStage.arrivedAtPickup; 

  // --- DUMMY COORDINATES (Replace with actual geocoding of pickup/destination strings) ---
  // Assuming 'pickupLocation' is the first stop (A) and 'destination' is the final stop (B)
  // These are mock points near Kuala Lumpur for demonstration
  final LatLng _initialPosition = const LatLng(3.1419, 101.6938); // Start/Driver's Location
  final LatLng _pickupCoords = const LatLng(3.1390, 101.6869); // Pickup Location
  final LatLng _destinationCoords = const LatLng(3.1500, 101.7100); // Final Destination

  @override
  void initState() {
    super.initState();
    // [MODIFIED] Initial state is now set to 'arrivedAtPickup' 
    // The previous 'enRouteToPickup' is skipped upon entering this page.
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Utility to launch WhatsApp
  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    String whatsappNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (whatsappNumber.startsWith('0')) {
        whatsappNumber = '6${whatsappNumber}';
    } else if (!whatsappNumber.startsWith('6') && whatsappNumber.length == 9) {
        whatsappNumber = '60${whatsappNumber}';
    } else if (whatsappNumber.length == 10 && whatsappNumber.startsWith('1')) {
        whatsappNumber = '60${whatsappNumber}';
    }

    final Uri url = Uri.parse("https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: avoid_print
      print('Could not launch WhatsApp for $whatsappNumber');
    }
  }

  // Emergency Call Action
  void _handleEmergency(BuildContext context) {
    DriverActions.callAdmin();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling Emergency Admin Line (0322221111)')),
    );
  }

  // [FIX] Function to launch external Google Maps for navigation
  Future<void> _launchGoogleMapsNavigation(LatLng target) async {
    final String lat = target.latitude.toString();
    final String lng = target.longitude.toString();
    
    // Google Maps URL scheme for navigation
    String url = '';
    if (Platform.isAndroid) {
      // Use Google Maps app on Android
      url = 'google.navigation:q=$lat,$lng&mode=d'; // 'd' for driving mode
    } else if (Platform.isIOS) {
      // Use Maps app on iOS
      url = 'maps://?daddr=$lat,$lng&dirflg=d';
    } else {
      // Fallback for web/desktop
      url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    }

    final Uri launchUri = Uri.parse(url);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: avoid_print
      print('Could not launch map app for navigation to $lat,$lng. URL: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start navigation. URL: $url')),
      );
    }
  }

  // [MODIFIED] Main button logic handler
  void _handleMainAction() {
    setState(() {
      switch (_currentTripStage) {
        // [REMOVED CASE] TripStage.enRouteToPickup is now the default initial state logic.
        
        case TripStage.arrivedAtPickup:
          // Action: Driver confirms arrival at pickup
          // This should trigger a status update to the backend
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated: Arrived at Pickup!')),
          );
          // Next state: Start trip to final destination
          _currentTripStage = TripStage.enRouteToDestination;
          break;
        case TripStage.enRouteToDestination:
          // Action: Start navigation to final destination
          _launchGoogleMapsNavigation(_destinationCoords);
          // Next state: Arrived at final destination
          _currentTripStage = TripStage.arrivedAtDestination;
          break;
        case TripStage.arrivedAtDestination:
          // Action: Complete the trip
          // This should trigger a final status update and navigate back/to history
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip Completed! Navigating back...')),
          );
          _currentTripStage = TripStage.completed;
          // In a real app, you would pop to the root/history page after confirming completion
          Navigator.pop(context); 
          break;
        case TripStage.completed:
          // Should not happen, but for safety
          break;
        
        default:
          // Handle the initial state when the page loads (which is now arrivedAtPickup)
          // Since the initial state is now 'arrivedAtPickup', this 'default' case should not be hit
          // but if it were the previous 'enRouteToPickup' this would be the place for its action.
          break;
      }
    });
  }

  // [MODIFIED] Helper to get button text and color based on current stage
  Map<String, dynamic> _getMainButtonDetails() {
    switch (_currentTripStage) {
      case TripStage.enRouteToPickup:
      case TripStage.arrivedAtPickup: // New effective starting state
        return {'text': 'ARRIVED AT PICKUP', 'color': Colors.blueGrey};
      case TripStage.enRouteToDestination:
        return {'text': 'START NAVIGATION TO DESTINATION', 'color': kApproveColor};
      case TripStage.arrivedAtDestination:
        return {'text': 'COMPLETE TRIP', 'color': kCompletedColor};
      case TripStage.completed:
        return {'text': 'TRIP COMPLETED', 'color': Colors.grey};
    }
  }


  @override
  Widget build(BuildContext context) {
    final String destination = widget.tripDetails['destination'] ?? 'N/A';
    final String requester = widget.tripDetails['requester'] ?? 'N/A';
    final String pickupLocation = widget.tripDetails['pickupLocation'] ?? 'N/A';
    // final String returnLocation = widget.tripDetails['returnLocation'] ?? 'N/A'; // No longer needed for display
    final String requesterPhone = widget.tripDetails['requesterPhone'] ?? 'N/A';
    
    final buttonDetails = _getMainButtonDetails();
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map View
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              // Add markers for pickup and destination
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: _pickupCoords,
                  infoWindow: InfoWindow(title: 'Pickup: $pickupLocation'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: _destinationCoords,
                  infoWindow: InfoWindow(title: 'Destination: $destination'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              // Add other map configurations as needed (e.g., polyline for route)
            ),
          ),
          
          // 3. Bottom Card (Mimicking the image's bottom section)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status/Online Switch (from image)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: kApproveColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              kDriverStatusText,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        // Back/Close Button
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  
                  // Quick Action Icons (Removed 4 button at top section as requested, using just empty row here)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Quick action buttons are removed as requested.
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Trip Details and Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTripStage == TripStage.arrivedAtDestination 
                            ? 'Trip Drop-off Details' 
                            : 'Trip Details',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryColor),
                        ),
                        const SizedBox(height: 10),
                        
                        // Destination and Passenger
                        _buildInfoRowWithIcon(Icons.flag_circle, 'Final Destination', destination),
                        _buildInfoRowWithIcon(Icons.person, 'Passenger Name', requester),
                        
                        const SizedBox(height: 15),

                        // Pickup and Destination (Full Detail)
                        const Text(
                          'Route:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                        ),
                        _buildRouteInfo(Icons.arrow_circle_up_rounded, 'Pick Up', pickupLocation, Colors.green),
                        // [FIXED] Drop Off is correctly set to 'destination'
                        _buildRouteInfo(Icons.arrow_circle_down_rounded, 'Drop Off', destination, Colors.red),
                        
                        const SizedBox(height: 20),

                        // Action Buttons (Call, Message, Emergency)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. Message (WhatsApp)
                            _buildActionPill(
                              Icons.message_rounded, 
                              'Message', 
                              Colors.teal, 
                              () => _launchWhatsApp(
                                requesterPhone, 
                                'Hello $requester, this is your driver. I am currently ${_currentTripStage == TripStage.enRouteToPickup ? 'heading to your pickup location.' : 'en route to your final destination.'}'
                              ),
                            ),
                            
                            // 2. Call
                            _buildActionPill(
                              Icons.phone_in_talk_rounded, 
                              'Call', 
                              kApproveColor, 
                              () => DriverActions.callRequester(requesterPhone),
                            ),
                            
                            // 3. Emergency
                            _buildActionPill(
                              Icons.warning_rounded, 
                              'Emergency', 
                              kRejectColor, 
                              () => _handleEmergency(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Bottom Button (Contextual based on TripStage)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _currentTripStage == TripStage.completed ? null : _handleMainAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonDetails['color'] as Color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(buttonDetails['text'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for generic trip info rows 
  Widget _buildInfoRowWithIcon(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper for route info 
  Widget _buildRouteInfo(IconData icon, String label, String location, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (label == 'Pick Up') const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for action buttons (Call/Message/Emergency)
  Widget _buildActionPill(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 18),
          label: Text(label),
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  // Helper for the quick action buttons on the bottom sheet (kept as an empty placeholder row in build method)
  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}