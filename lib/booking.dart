import 'package:flutter/material.dart';

// Define custom colors based on the design
const Color kPrimaryColorStart = Color(0xFF63B8FF); // Light Blue
const Color kPrimaryColorEnd = Color(0xFF1E88E5);   // Slightly darker Blue
const Color kBackgroundColor = Color(0xFFF7F9FC);

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColorEnd,
        elevation: 0,  // Removes shadow for a clean look
        title: const Text(
          'Add Booking',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0.0),

              // Vehicle Type Selection (Car, Van, Bus)
              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildVehicleTypeOption('Car', Icons.directions_car),
                  _buildVehicleTypeOption('Van', Icons.local_taxi),
                  _buildVehicleTypeOption('Bus', Icons.directions_bus),
                ],
              ),
              const SizedBox(height: 16.0),

              // Pick-Up & Return Location
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLocationSelection('Pick-Up Location'),
                  _buildLocationSelection('Return Location'),
                ],
              ),
              const SizedBox(height: 16.0),

              // Date & Time Picker
              _buildDateTimeSelection(),
              const SizedBox(height: 16.0),

              // Search Button
              _buildSearchButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Vehicle Type Option Button
  Widget _buildVehicleTypeOption(String vehicleType, IconData icon) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColorEnd,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: kPrimaryColorEnd),
          ),
        ),
        onPressed: () {
          // Handle action when a vehicle type is selected
          print('$vehicleType selected');
        },
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8.0),
            Text(vehicleType),
          ],
        ),
      ),
    );
  }

  // Location selection widget
  Widget _buildLocationSelection(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Color(0xFFDDDDDD)),
          ),
          child: Row(
            children: const [
              Icon(Icons.location_on, color: kPrimaryColorEnd),
              SizedBox(width: 8.0),
              Text('Select Location'),
            ],
          ),
        ),
      ],
    );
  }

  // Date and Time Picker widget
  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pick-Up & Return Date & Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Color(0xFFDDDDDD)),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_today, color: kPrimaryColorEnd),
              SizedBox(width: 8.0),
              Text('Pick-Up Date'),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Color(0xFFDDDDDD)),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_today, color: kPrimaryColorEnd),
              SizedBox(width: 8.0),
              Text('Return Date'),
            ],
          ),
        ),
      ],
    );
  }

  // Search Button widget
  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColorStart, kPrimaryColorEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Perform search action
            print('Search button clicked');
          },
          borderRadius: BorderRadius.circular(10.0),
          child: const Center(
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
