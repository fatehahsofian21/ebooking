import 'package:flutter/material.dart';

// Use the same core color theme as the calendar page
// Primary dark (same as kPrimaryDark in Vcalendar)
const Color kPrimaryColorStart = Color.fromARGB(255, 24, 42, 94); // dark blue
const Color kPrimaryColorEnd = Color.fromARGB(255, 24, 42, 94);   // keep same for a solid look
// Background to match calendar page grey
const Color kBackgroundColor = Color(0xFFF2F3F7);

class VBookingPage extends StatefulWidget {
  const VBookingPage({super.key});

  @override
  State<VBookingPage> createState() => _VBookingPageState();
}

class _VBookingPageState extends State<VBookingPage> {
  String? _selectedVehicleType;
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _returnLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _pickupDateTime;
  DateTime? _returnDateTime;
  bool _sameLocation = false;
  int _pax = 1;
  bool _requireDriver = false;
  String? _uploadedDocName;
  String? _purpose;

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _returnLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColorEnd,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Vehicle Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6.0),

              // Vehicle Type Selection (Car, Van, MPV, Bus)
              const Text(
                'Select Vehicle Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),

              Row(
                children: [
                  Expanded(child: _buildVehicleTypeOption('Car', Icons.directions_car)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVehicleTypeOption('Van', Icons.local_taxi)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVehicleTypeOption('MPV', Icons.airport_shuttle)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVehicleTypeOption('Bus', Icons.directions_bus)),
                ],
              ),
              const SizedBox(height: 20.0),

              // Destination
              const Text('Destination', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: 'Enter destination',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 16),

              // Pick-Up & Return Location and same checkbox
              Row(
                children: [
                  Expanded(child: _buildLocationField('Pick-Up Location', _pickupLocationController, enabled: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildLocationField('Return Location', _returnLocationController, enabled: !_sameLocation)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _sameLocation,
                    onChanged: (v) {
                      setState(() {
                        _sameLocation = v ?? false;
                        if (_sameLocation) {
                          _returnLocationController.text = _pickupLocationController.text;
                        }
                      });
                    },
                  ),
                  const Text('Return location same as pickup'),
                ],
              ),
              const SizedBox(height: 12),

              // Date & Time Picker
              _buildDateTimeSelection(),
              const SizedBox(height: 16),

              // Number of pax and driver requirement
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Pax: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _buildPaxControl(),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Require driver', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Switch(
                        value: _requireDriver,
                        onChanged: (v) => setState(() => _requireDriver = v),
                        activeColor: kPrimaryColorEnd,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Supported document (optional)
              const Text('Supported Document (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColorEnd),
                    onPressed: () async {
                      // Mock device chooser: let user choose Files (PDF) or Photos (not supported)
                      final source = await showModalBottomSheet<String?>(context: context, builder: (ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: const Text('Files (PDF)'),
                                onTap: () => Navigator.of(ctx).pop('files'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Photos'),
                                onTap: () => Navigator.of(ctx).pop('photos'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.close),
                                title: const Text('Cancel'),
                                onTap: () => Navigator.of(ctx).pop(null),
                              ),
                            ],
                          ),
                        );
                      });

                      if (source == 'files') {
                        // Show a mock list of PDFs that might exist on the device
                        final pdf = await showDialog<String?>(context: context, builder: (ctx) {
                          return SimpleDialog(
                            title: const Text('Select PDF'),
                            children: [
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'surat_kebenaran.pdf'), child: const Text('surat_kebenaran.pdf')),
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'approval_letter.pdf'), child: const Text('approval_letter.pdf')),
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'travel_request.pdf'), child: const Text('travel_request.pdf')),
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
                            ],
                          );
                        });
                        if (pdf != null) setState(() => _uploadedDocName = pdf);
                      } else if (source == 'photos') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a PDF from Files (not photos)')));
                      }
                    },
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text('Upload document', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  if (_uploadedDocName != null) Expanded(child: Text(_uploadedDocName!)),
                ],
              ),
              const SizedBox(height: 22),

              // Purpose of booking
              _buildPurposeField(),
              const SizedBox(height: 22),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onBookingSubmitted() async {
    // Show success dialog with green popup
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.green.shade100, // Green background for success
        title: const Text('Booking Submitted'),
        content: const Text('Your booking request has been successfully submitted.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.pushNamed(context, '/myBookingPage'); // Navigate to MyBooking.dart
            },
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

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
            if (_selectedVehicleType == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle type')));
              return;
            }
            if (_pickupDateTime == null || _returnDateTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select pickup and return date/time')));
              return;
            }
            // Trigger booking submission
            _onBookingSubmitted();
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

  // Vehicle Type Option Button
  Widget _buildVehicleTypeOption(String vehicleType, IconData icon) {
    final selected = _selectedVehicleType == vehicleType;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? kPrimaryColorEnd : Colors.white,
          foregroundColor: selected ? Colors.white : kPrimaryColorEnd,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: kPrimaryColorEnd),
          ),
        ),
        onPressed: () => setState(() => _selectedVehicleType = vehicleType),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8.0),
            Text(vehicleType),
          ],
        ),
      ),
    );
  }

  // Location field with picker
  Widget _buildLocationField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Select location',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.location_on, color: Colors.black54),
              onPressed: enabled
                  ? () async {
                      final choice = await showDialog<String>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Choose location'),
                          children: [
                            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'PERKESO JALAN AMPANG'), child: const Text('PERKESO JALAN AMPANG')),
                            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'HQ KL'), child: const Text('HQ KL')),
                            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'Office A'), child: const Text('Office A')),
                          ],
                        ),
                      );
                      if (choice != null) {
                        setState(() {
                          controller.text = choice;
                          if (_sameLocation) _returnLocationController.text = choice;
                        });
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaxControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDDDDDD)), color: Colors.white),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => _pax = (_pax > 1) ? _pax - 1 : 1), icon: const Icon(Icons.remove)),
          Text('$_pax', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => setState(() => _pax = _pax + 1), icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Future<void> _pickDateTime({required bool isPickup}) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 9, minute: 0));
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isPickup) {
        _pickupDateTime = dt;
      } else {
        _returnDateTime = dt;
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Date and Time Picker widget
  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick-Up & Return Date & Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: () => _pickDateTime(isPickup: true),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: const Color(0xFFDDDDDD))),
            child: Row(children: [const Icon(Icons.calendar_today, color: Colors.black54), const SizedBox(width: 8.0), Text(_pickupDateTime != null ? '${_formatDateTime(_pickupDateTime!)}' : 'Pick-Up Date & Time')]),
          ),
        ),
        const SizedBox(height: 10.0),
        InkWell(
          onTap: () => _pickDateTime(isPickup: false),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: const Color(0xFFDDDDDD))),
            child: Row(children: [const Icon(Icons.calendar_today, color: Colors.black54), const SizedBox(width: 8.0), Text(_returnDateTime != null ? '${_formatDateTime(_returnDateTime!)}' : 'Return Date & Time')]),
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
          'Purpose of Booking (optional)',
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
          onChanged: (value) {
            setState(() {
              _purpose = value;
            });
          },
        ),
      ],
    );
  }
}
