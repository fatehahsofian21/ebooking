import 'package:flutter/material.dart';

// Define custom colors based on your current theme
const Color kPrimaryColorStart = Color(0xFF63B8FF); // Light Blue
const Color kPrimaryColorEnd = Color(0xFF1E88E5);   // Slightly darker Blue
const Color kBackgroundColor = Color(0xFFF7F9FC);

class VBookingPage extends StatelessWidget {
  const VBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColorEnd,
        elevation: 0,
        title: const Text(
          'Vehicle Booking',
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
              const SizedBox(height: 10.0),

              // Vehicle Type Selection (Car, Van, MPV, Bus)
              const Text(
                'Select Vehicle Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildVehicleTypeOption('Car', Icons.directions_car),
                  _buildVehicleTypeOption('Van', Icons.local_taxi),
                  _buildVehicleTypeOption('MPV', Icons.airport_shuttle),
                  _buildVehicleTypeOption('Bus', Icons.directions_bus),
                ],
              ),
              const SizedBox(height: 25.0),

              // Pick-Up & Return Location
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLocationSelection('Pick-Up Location'),
                  _buildLocationSelection('Return Location'),
                ],
              ),
              const SizedBox(height: 25.0),

              // Date & Time Picker
              _buildDateTimeSelection(),
              const SizedBox(height: 25.0),

              // Purpose of booking
              _buildPurposeField(),
              const SizedBox(height: 25.0),

              // Search Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Vehicle Type Option Button
  Widget _buildVehicleTypeOption(String vehicleType, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
      ),
    );
  }

  // Location selection widget
  Widget _buildLocationSelection(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
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
        ),
      ),
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
              Text('Pick-Up Date & Time'),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
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
              Text('Return Date & Time'),
            ],
          ),
        ),
      ],
    );
  }

  // Purpose text field
  Widget _buildPurposeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purpose of Booking',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter purpose (e.g. official meeting, site visit)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
          ),
        ),
      ],
    );
  }

  // Submit Button widget
  Widget _buildSubmitButton() {
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
            print('Submit Vehicle Booking');
          },
          borderRadius: BorderRadius.circular(10.0),
          child: const Center(
            child: Text(
              'Submit Booking',
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
