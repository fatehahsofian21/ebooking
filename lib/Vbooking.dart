import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  // available vehicle list (plate and type) - demo data
  final List<Map<String, String>> _availableVehicles = [
    {'plate': 'WPC1234', 'type': 'Car', 'model': 'Toyota Vios'},
    {'plate': 'VAN9988', 'type': 'Van', 'model': 'Toyota Hiace'},
    {'plate': 'BUS1122', 'type': 'Bus', 'model': 'Isuzu Bus'},
    {'plate': 'CAR7788', 'type': 'Car', 'model': 'Proton Persona'},
  ];

  // ---- NEW: base capacities by vehicle type (adjust anytime) ----
  final Map<String, int> _baseCapacityByType = const {
    'Car': 4,
    'Van': 12,
    'Bus': 40,
  };

  String? _selectedVehicleType; // stores selected plate number
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

  // Google Maps API key provided by the user
  static const String _kGoogleMapsApiKey = 'AIzaSyCARTrKnNBreG5gSj6ObaatLEaxZ9a0rek';

  // ---- NEW: helpers for capacity logic ----
  String? _selectedVehicleTypeName() {
    if (_selectedVehicleType == null) return null;
    final v = _availableVehicles.firstWhere(
      (e) => (e['plate'] ?? '') == _selectedVehicleType,
      orElse: () => const {},
    );
    return v['type'];
  }

  int _baseCapacityForSelected() {
    final type = _selectedVehicleTypeName();
    if (type == null) return 1; // safe default
    return _baseCapacityByType[type] ?? 1;
  }

  int _effectiveMaxPax() {
    final base = _baseCapacityForSelected();
    // If driver is required, driver occupies 1 seat
    final max = _requireDriver ? (base - 1) : base;
    return max.clamp(1, base); // ensure at least 1
  }

  void _ensurePaxWithinLimit() {
    final max = _effectiveMaxPax();
    if (_pax > max) {
      setState(() => _pax = max);
      // Optional toast/snackbar to inform user it was clamped
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pax adjusted to $max (max allowed for current vehicle/driver).')),
      );
    }
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _returnLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute available plates and ensure dropdown value is valid for current items
    final _plates = _availableVehicles.map((v) => v['plate'] ?? '').toList();
    final _selectedPlate = _plates.contains(_selectedVehicleType) ? _selectedVehicleType : null;

    final typeName = _selectedVehicleTypeName();
    final baseCap = _baseCapacityForSelected();
    final effMax = _effectiveMaxPax();
    final withDriverNote = _requireDriver ? ' (driver counted)' : '';

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

              // Vehicle Type Selection (dropdown of plate numbers)
              const Text(
                'Select Vehicle *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),

              DropdownButtonFormField<String>(
                value: _selectedPlate,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                hint: const Text('Select vehicle'),
                items: _availableVehicles.map((v) {
                  // show model name and plate in brackets, value is the plate (unique id)
                  final model = v['model'] ?? '${v['type']}';
                  final plate = v['plate'] ?? '';
                  return DropdownMenuItem(value: plate, child: Text('$model ($plate)'));
                }).toList(),
                onChanged: (s) {
                  setState(() {
                    _selectedVehicleType = s;
                    _ensurePaxWithinLimit();
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Date & Time Picker (moved directly under vehicle selection)
              _buildDateTimeSelection(),
              const SizedBox(height: 16),

              // Number of pax and driver requirement (directly after date/time)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Pax *: ', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        onChanged: (v) {
                          setState(() {
                            _requireDriver = v;
                            _ensurePaxWithinLimit();
                          });
                        },
                        activeColor: kPrimaryColorEnd,
                      ),
                    ],
                  ),
                ],
              ),

              // ---- NEW: capacity helper line (subtle, does not change design layout) ----
              const SizedBox(height: 6),
              Text(
                (typeName == null)
                    ? 'Select a vehicle to see capacity.'
                    : 'Max pax for $typeName$withDriverNote: $effMax',
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 16),

              // Destination (opens a simple Map picker placeholder)
              const Text('Destination *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _destinationController,
                readOnly: true,
                onTap: () async {
                  // Open the full map picker and receive a structured result
                  final loc = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapPickerPage()));
                  if (loc != null && loc is Map<String, dynamic>) {
                    setState(() => _destinationController.text = loc['address'] ?? '');
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 16),

              // Pick-Up & Return Location and same checkbox (moved after destination)
              Row(
                children: [
                  Expanded(child: _buildLocationField('Pick-Up Location *', _pickupLocationController, enabled: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildLocationField('Return Location *', _returnLocationController, enabled: !_sameLocation)),
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

              // Purpose of booking (make mandatory)
              _buildPurposeField(isRequired: true),
              const SizedBox(height: 16),

              // Supported document (optional) - moved below purpose
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
              return;
            }
            if (_pickupDateTime == null || _returnDateTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select pickup and return date/time')));
              return;
            }
            if (_purpose == null || _purpose!.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter purpose of booking')));
              return;
            }
            // ---- NEW: Final pax check against current max ----
            final effMax = _effectiveMaxPax();
            if (_pax > effMax) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pax exceeds limit ($effMax). Please reduce pax or change vehicle/driver.')),
              );
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
          onTap: enabled
              ? () async {
                  // Open the map picker for pickup/return location selection
                  final loc = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapPickerPage()));
                  if (loc != null && loc is Map<String, dynamic>) {
                    setState(() {
                      controller.text = loc['address'] ?? '';
                      if (_sameLocation) _returnLocationController.text = loc['address'] ?? '';
                    });
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Select location',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
          IconButton(
            onPressed: () => setState(() => _pax = (_pax > 1) ? _pax - 1 : 1),
            icon: const Icon(Icons.remove),
          ),
          Text('$_pax', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () {
              final max = _effectiveMaxPax();
              if (_pax >= max) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Max pax reached ($max).')),
                );
                return;
              }
              setState(() => _pax = _pax + 1);
            },
            icon: const Icon(Icons.add),
          ),
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
        const Text('Pick-Up & Return Date & Time *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
  Widget _buildPurposeField({bool isRequired = false}) {
    final label = isRequired ? 'Purpose of Booking *' : 'Purpose of Booking (optional)';
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

  // Simple placeholder page that simulates picking a location from a map.
  // Replace with a proper Google Maps picker integration when ready.
  // Returns a string location when popped.

}

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _predictions = [];
  GoogleMapController? _mapController;
  Marker? _selectedMarker;
  String? _selectedAddress;
  Timer? _debounce;
  String? _sessionToken;

  // Center map at KL by default
  static const LatLng _initialCenter = LatLng(3.1390, 101.6869);

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String input) async {
    if (input.trim().isEmpty) return;
    // Create a simple session token per autocomplete interaction to improve billing/accuracy
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    // bias results toward the current map center or a sensible default
    final biasLat = _selectedMarker?.position.latitude ?? _initialCenter.latitude;
    final biasLng = _selectedMarker?.position.longitude ?? _initialCenter.longitude;
    final locationBias = 'circle:20000@${biasLat},${biasLng}'; // 20km bias

    // Use autocomplete without forcing 'types=geocode' so we get a broader set of relevant suggestions.
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeQueryComponent(input)}&key=${_VBookingPageState._kGoogleMapsApiKey}&sessiontoken=${_sessionToken}&locationbias=${Uri.encodeQueryComponent(locationBias)}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return;
    final jsonResp = json.decode(resp.body) as Map<String, dynamic>;
    final preds = (jsonResp['predictions'] as List<dynamic>?) ?? [];
    setState(() {
      // parse structured_formatting for primary/secondary text to show a nicer suggestion list
      _predictions = preds.map((p) {
        final s = p as Map<String, dynamic>;
        final structured = s['structured_formatting'] as Map<String, dynamic>?;
        final primary = structured?['main_text'] as String? ?? (s['description'] as String? ?? '');
        final secondary = structured?['secondary_text'] as String? ?? '';
        return {
          'description': s['description'] as String? ?? primary,
          'place_id': s['place_id'] as String? ?? '',
          'primary': primary,
          'secondary': secondary,
        };
      }).toList();
    });
  }

  Future<void> _selectPrediction(Map<String, String> pred) async {
    final placeId = pred['place_id'];
    if (placeId == null || placeId.isEmpty) return;
    // include the same session token used for autocomplete if present
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${_VBookingPageState._kGoogleMapsApiKey}${_sessionToken != null ? '&sessiontoken=${_sessionToken}' : ''}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return;
    final jsonResp = json.decode(resp.body) as Map<String, dynamic>;
    final result = jsonResp['result'] as Map<String, dynamic>?;
    if (result == null) return;
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] as num?)?.toDouble() ?? _initialCenter.latitude;
    final lng = (location?['lng'] as num?)?.toDouble() ?? _initialCenter.longitude;
    final formatted = result['formatted_address'] as String? ?? pred['description']!;

    final pos = LatLng(lat, lng);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
    setState(() {
      _selectedMarker = Marker(markerId: const MarkerId('selected'), position: pos, infoWindow: InfoWindow(title: formatted));
      _predictions = [];
      _searchController.text = formatted;
      _selectedAddress = formatted; // keep selection until user confirms
      // clear session token so a new typing session will create a fresh one
      _sessionToken = null;
    });
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=${_VBookingPageState._kGoogleMapsApiKey}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return;
    final jsonResp = json.decode(resp.body) as Map<String, dynamic>?;
    final results = (jsonResp?['results'] as List<dynamic>?) ?? [];
    if (results.isEmpty) return;
    final formatted = results.first['formatted_address'] as String? ?? '';
    setState(() {
      _selectedMarker = Marker(markerId: const MarkerId('selected'), position: pos, infoWindow: InfoWindow(title: formatted));
      _searchController.text = formatted;
      _selectedAddress = formatted;
      _predictions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick destination')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Search places', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                    onChanged: (v) {
                      // Debounce user input to avoid too many network calls
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        if (v.trim().isEmpty) {
                          setState(() => _predictions = []);
                        } else {
                          _searchPlaces(v);
                        }
                      });
                    },
                    onSubmitted: (v) => _searchPlaces(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _searchPlaces(_searchController.text), child: const Text('Search')),
              ],
            ),
          ),
          if (_predictions.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final p = _predictions[i];
                  return ListTile(
                    title: Text(p['primary'] ?? p['description'] ?? ''),
                    subtitle: (p['secondary'] != null && (p['secondary'] ?? '').isNotEmpty) ? Text(p['secondary']!) : null,
                    onTap: () => _selectPrediction(p),
                  );
                },
              ),
            )
          else
            Expanded(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: _initialCenter, zoom: 12),
                onMapCreated: (c) => _mapController = c,
                markers: _selectedMarker != null ? {_selectedMarker!} : {},
                myLocationEnabled: false,
                onTap: (latlng) async {
                  // When user taps the map, reverse geocode and pin
                  await _reverseGeocode(latlng);
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 15));
                },
              ),
            ),
          // Show a persistent confirm bar when a location is selected
          if (_selectedAddress != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(child: Text(_selectedAddress!, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop({
                      'address': _selectedAddress,
                      'lat': _selectedMarker?.position.latitude,
                      'lng': _selectedMarker?.position.longitude,
                    }),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
