import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // For getting user location

// --- Brand Guideline Colors (Refined) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

// --- IMPORTANT: REPLACE WITH YOUR API KEY ---
const String kGoogleMapsApiKey = 'AIzaSyCARTrKnNBreG5gSj6ObaatLEaxZ9a0rek';

class VBookingPage extends StatefulWidget {
  const VBookingPage({super.key});

  @override
  State<VBookingPage> createState() => _VBookingPageState();
}

class _VBookingPageState extends State<VBookingPage> {
  // ... (No changes in this class, it remains the same)
  final List<Map<String, String>> _availableVehicles = [
    {'plate': 'WPC1234', 'type': 'Car', 'model': 'Toyota Vios'},
    {'plate': 'VAN9988', 'type': 'Van', 'model': 'Toyota Hiace'},
    {'plate': 'BUS1122', 'type': 'Bus', 'model': 'Isuzu Bus'},
    {'plate': 'CAR7788', 'type': 'Car', 'model': 'Proton Persona'},
  ];

  final Map<String, int> _baseCapacityByType = const {
    'Car': 4,
    'Van': 12,
    'Bus': 40,
  };

  String? _selectedVehicleType;
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _returnLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _paxController = TextEditingController();

  DateTime? _pickupDateTime;
  DateTime? _returnDateTime;
  bool _sameLocation = false;
  int _pax = 1;
  bool _requireDriver = false;
  String? _uploadedDocName;
  String? _purpose;

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
    if (type == null) return 1;
    return _baseCapacityByType[type] ?? 1;
  }

  int _effectiveMaxPax() {
    final base = _baseCapacityForSelected();
    final max = _requireDriver ? (base - 1) : base;
    return max.clamp(1, base);
  }

  void _ensurePaxWithinLimit() {
    final max = _effectiveMaxPax();
    if (_pax > max) {
      setState(() {
        _pax = max;
        _paxController.text = _pax.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pax adjusted to $max (max allowed for current vehicle/driver).')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _paxController.text = _pax.toString();
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _returnLocationController.dispose();
    _destinationController.dispose();
    _paxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _plates = _availableVehicles.map((v) => v['plate'] ?? '').toList();
    final _selectedPlate = _plates.contains(_selectedVehicleType) ? _selectedVehicleType : null;

    final typeName = _selectedVehicleTypeName();
    final effMax = _effectiveMaxPax();
    final withDriverNote = _requireDriver ? ' (driver counted)' : '';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
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
                initialValue: _selectedPlate,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Select vehicle'),
                items: _availableVehicles.map((v) {
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
              _buildDateTimeSelection(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Pax *:', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(width: 8),
                      _buildPaxControl(),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Require Driver', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(width: 8),
                      Switch(
                        value: _requireDriver,
                        onChanged: (v) {
                          setState(() {
                            _requireDriver = v;
                            _ensurePaxWithinLimit();
                          });
                        },
                        activeThumbColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                (typeName == null)
                    ? 'Select a vehicle to see capacity.'
                    : 'Max pax for $typeName$withDriverNote: $effMax',
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text('Destination *', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _destinationController,
                readOnly: true,
                onTap: () async {
                  final loc = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapPickerPage()));
                  if (loc != null && loc is Map<String, dynamic>) {
                    setState(() => _destinationController.text = loc['address'] ?? '');
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select on map',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  suffixIcon: const Icon(Icons.map, color: kPrimaryColor),
                ),
              ),
              const SizedBox(height: 16),
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
                    activeColor: kPrimaryColor,
                    onChanged: (v) {
                      setState(() {
                        _sameLocation = v ?? false;
                        if (_sameLocation) {
                          _returnLocationController.text = _pickupLocationController.text;
                        }
                      });
                    },
                  ),
                  const Text('Return location same as pickup', style: TextStyle(color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 12),
              _buildPurposeField(isRequired: true),
              const SizedBox(height: 16),
              const Text('Supported Document (optional)', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    onPressed: () async {
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
                    label: const Text('Upload Document', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  if (_uploadedDocName != null) Expanded(child: Text(_uploadedDocName!, style: const TextStyle(color: Colors.black54))),
                ],
              ),
              const SizedBox(height: 22),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onBookingSubmitted() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.green.shade100,
        title: const Text('Booking Submitted'),
        content: const Text('Your booking request has been successfully submitted.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamed(context, '/myBookingPage');
            },
            child: const Text('OK', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () {
          if (_selectedVehicleType == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
            return;
          }
          if (_pickupDateTime == null || _returnDateTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select pickup and return date/time')));
            return;
          }
          if (_purpose == null || _purpose!.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the purpose of booking')));
            return;
          }
          final effMax = _effectiveMaxPax();
          if (_pax > effMax) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pax exceeds limit ($effMax). Please reduce pax or change vehicle/driver.')),
            );
            return;
          }
          if (_pax < 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pax must be at least 1.')),
            );
            return;
          }

          _onBookingSubmitted();
        },
        child: const Text(
          'Submit Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          onTap: enabled
              ? () async {
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
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            suffixIcon: Icon(Icons.location_on, color: enabled ? kPrimaryColor : Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPaxControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDDDDDD)), color: Colors.white),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _pax = (_pax > 1) ? _pax - 1 : 1;
                _paxController.text = _pax.toString();
              });
            },
            icon: const Icon(Icons.remove, color: kPrimaryColor),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 40,
            child: TextField(
              controller: _paxController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              onChanged: (value) {
                setState(() {
                  _pax = int.tryParse(value) ?? 1;
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              final max = _effectiveMaxPax();
              if (_pax >= max) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Max pax reached ($max).')),
                );
                return;
              }
              setState(() {
                _pax = _pax + 1;
                _paxController.text = _pax.toString();
              });
            },
            icon: const Icon(Icons.add, color: kPrimaryColor),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime({required bool isPickup}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );
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

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick-Up & Return Date & Time *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8.0),
        _buildDateTimePickerField(
          isPickup: true,
          dateTime: _pickupDateTime,
          label: 'Pick-Up Date & Time',
        ),
        const SizedBox(height: 10.0),
        _buildDateTimePickerField(
          isPickup: false,
          dateTime: _returnDateTime,
          label: 'Return Date & Time',
        ),
      ],
    );
  }

  Widget _buildDateTimePickerField({required bool isPickup, required DateTime? dateTime, required String label}) {
    return InkWell(
      onTap: () => _pickDateTime(isPickup: isPickup),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: const Color(0xFFDDDDDD))),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: kPrimaryColor),
            const SizedBox(width: 12.0),
            Text(
              dateTime != null ? _formatDateTime(dateTime) : label,
              style: TextStyle(color: dateTime != null ? Colors.black87 : Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeField({bool isRequired = false}) {
    final label = isRequired ? 'Purpose of Booking *' : 'Purpose of Booking (optional)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
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


// --- UPDATED Map Picker Page ---
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

  bool _isLoading = false;
  String? _errorMessage;

  // --- NEW: State variable for the current location suggestion ---
  String? _currentLocationSuggestion;

  static const LatLng _initialCenter = LatLng(3.1576, 101.7122); // Fallback center

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndSetMarker() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions were denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final userLocation = LatLng(position.latitude, position.longitude);

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 16.0));
      // --- MODIFIED: Don't auto-fill search bar initially ---
      await _reverseGeocode(userLocation, updateSearchText: false);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    }
  }

  Future<void> _searchPlaces(String input) async {
    // ... (search logic is unchanged)
    if (input.trim().length < 2) {
      setState(() => _predictions = []);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final biasLat = _selectedMarker?.position.latitude ?? _initialCenter.latitude;
      final biasLng = _selectedMarker?.position.longitude ?? _initialCenter.longitude;
      final locationBias = 'circle:20000@$biasLat,$biasLng';
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeQueryComponent(input)}&key=$kGoogleMapsApiKey&sessiontoken=$_sessionToken&locationbias=${Uri.encodeQueryComponent(locationBias)}&components=country:MY');
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final jsonResp = json.decode(resp.body) as Map<String, dynamic>;
        final status = jsonResp['status'] as String?;
        if (status == 'OK') {
          final preds = (jsonResp['predictions'] as List<dynamic>?) ?? [];
          setState(() {
            _predictions = preds.map((p) {
              final s = p as Map<String, dynamic>;
              final structured = s['structured_formatting'] as Map<String, dynamic>?;
              final primary = structured?['main_text'] as String? ?? (s['description'] as String? ?? '');
              final secondary = structured?['secondary_text'] as String? ?? '';
              return {'description': s['description'] as String? ?? primary, 'place_id': s['place_id'] as String? ?? '', 'primary': primary, 'secondary': secondary};
            }).toList();
            if (_predictions.isEmpty) _errorMessage = 'No results found.';
          });
        } else {
          _errorMessage = jsonResp['error_message'] ?? 'Error fetching places: $status';
        }
      } else {
        _errorMessage = 'Server error. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Could not connect. Please check your network.';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPrediction(Map<String, String> pred) async {
    // ... (prediction selection logic is unchanged)
    final placeId = pred['place_id'];
    if (placeId == null || placeId.isEmpty) return;
    
    final currentSessionToken = _sessionToken;
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleMapsApiKey&sessiontoken=$currentSessionToken');
    try {
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
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
      await _reverseGeocode(pos);
    } catch (e) {
      // Handle error
    }
  }

  // --- MODIFIED: `reverseGeocode` now conditionally updates the search text ---
  Future<void> _reverseGeocode(LatLng pos, {bool updateSearchText = true}) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$kGoogleMapsApiKey');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return;
    final jsonResp = json.decode(resp.body) as Map<String, dynamic>?;
    final results = (jsonResp?['results'] as List<dynamic>?) ?? [];
    if (results.isEmpty) return;
    final formatted = results.first['formatted_address'] as String? ?? '';
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected'),
        position: pos,
        infoWindow: InfoWindow(title: formatted),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      _selectedAddress = formatted; // Always update the selected address
      _predictions = [];

      if (updateSearchText) {
        _searchController.text = formatted;
        _currentLocationSuggestion = null; // Hide suggestion once a selection is made
      } else {
        // This is the initial load, so set the suggestion text
        _currentLocationSuggestion = formatted;
      }
    });
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700))));
    
    // Show search predictions if user is typing
    if (_predictions.isNotEmpty) {
      return ListView.separated(
        itemCount: _predictions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final p = _predictions[i];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined, color: kPrimaryColor),
            title: Text(p['primary'] ?? p['description'] ?? ''),
            subtitle: (p['secondary'] != null && (p['secondary'] ?? '').isNotEmpty) ? Text(p['secondary']!) : null,
            onTap: () => _selectPrediction(p),
          );
        },
      );
    }
    
    // Default view is the map
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: _initialCenter, zoom: 12),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _getCurrentLocationAndSetMarker(); // Detect user location on map load
      },
      markers: _selectedMarker != null ? {_selectedMarker!} : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onTap: (latlng) async {
        await _reverseGeocode(latlng);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Destination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search places...',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                // When user starts typing, hide the current location suggestion
                if (_currentLocationSuggestion != null) {
                  setState(() {
                    _currentLocationSuggestion = null;
                  });
                }
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () => _searchPlaces(v));
              },
            ),
          ),

          // --- NEW: Current Location Suggestion Widget ---
          if (_currentLocationSuggestion != null)
            Material(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.my_location, color: kPrimaryColor),
                title: const Text('Use current location', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_currentLocationSuggestion!, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  // When tapped, populate the search bar and select the location
                  setState(() {
                    _searchController.text = _currentLocationSuggestion!;
                    _currentLocationSuggestion = null; // Hide the suggestion
                  });
                },
              ),
            ),
            
          Expanded(child: _buildBody()),
          if (_selectedAddress != null)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))]),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: kPrimaryColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_selectedAddress!, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    onPressed: () => Navigator.of(context).pop({'address': _selectedAddress, 'lat': _selectedMarker?.position.latitude, 'lng': _selectedMarker?.position.longitude}),
                    child: const Text('Select', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}