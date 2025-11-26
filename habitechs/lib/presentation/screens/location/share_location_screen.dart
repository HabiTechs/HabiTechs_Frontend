import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:habitechs/main.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' show cos, sqrt, asin;

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _selectedTransport = 'car';
  double? _distance;
  String? _duration;
  bool _isLoadingLocation = true;

  // 📍📍📍 COORDENADAS DEL CONDOMINIO - CAMBIAR POR LAS REALES 📍📍📍
  static const LatLng _condominioLocation = LatLng(-17.783333, -63.182222);
  static const String _condominioName = 'Condominio Las Palmas';
  static const String _condominioAddress =
      'Av. San Martín #1234, Santa Cruz de la Sierra, Bolivia';

  final List<NearbyPlace> _nearbyPlaces = [
    NearbyPlace(
      name: 'Hospital San Juan de Dios',
      location: const LatLng(-17.781, -63.180),
      type: PlaceType.hospital,
      distance: 0.8,
      rating: 4.2,
    ),
    NearbyPlace(
      name: 'Hipermaxi',
      location: const LatLng(-17.785, -63.184),
      type: PlaceType.supermarket,
      distance: 1.2,
      rating: 4.5,
    ),
    NearbyPlace(
      name: 'Farmacia Chávez',
      location: const LatLng(-17.782, -63.181),
      type: PlaceType.pharmacy,
      distance: 0.3,
      rating: 4.8,
    ),
    NearbyPlace(
      name: 'Banco Sol',
      location: const LatLng(-17.784, -63.183),
      type: PlaceType.bank,
      distance: 0.5,
      rating: 3.9,
    ),
    NearbyPlace(
      name: 'Colegio San Ignacio',
      location: const LatLng(-17.786, -63.185),
      type: PlaceType.school,
      distance: 1.5,
      rating: 4.6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _requestLocationPermission();
    await _getUserLocation();
    _addMarkers();
    _calculateDistance();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Los servicios de ubicación están deshabilitados');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Permiso de ubicación denegado');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Los permisos de ubicación están permanentemente denegados');
      return;
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
        _isLoadingLocation = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _calculateBounds(),
            100,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      _showError('Error al obtener ubicación: $e');
    }
  }

  LatLngBounds _calculateBounds() {
    if (_userPosition == null) {
      return LatLngBounds(
        southwest: _condominioLocation,
        northeast: _condominioLocation,
      );
    }

    final userLatLng =
        LatLng(_userPosition!.latitude, _userPosition!.longitude);

    double southLat = _condominioLocation.latitude < userLatLng.latitude
        ? _condominioLocation.latitude
        : userLatLng.latitude;
    double northLat = _condominioLocation.latitude > userLatLng.latitude
        ? _condominioLocation.latitude
        : userLatLng.latitude;
    double westLng = _condominioLocation.longitude < userLatLng.longitude
        ? _condominioLocation.longitude
        : userLatLng.longitude;
    double eastLng = _condominioLocation.longitude > userLatLng.longitude
        ? _condominioLocation.longitude
        : userLatLng.longitude;

    return LatLngBounds(
      southwest: LatLng(southLat - 0.002, westLng - 0.002),
      northeast: LatLng(northLat + 0.002, eastLng + 0.002),
    );
  }

  void _addMarkers() {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId('condominio'),
        position: _condominioLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: _condominioName,
          snippet: _condominioAddress,
        ),
      ),
    );

    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Estás aquí',
          ),
        ),
      );
    }

    for (var i = 0; i < _nearbyPlaces.length; i++) {
      final place = _nearbyPlaces[i];
      markers.add(
        Marker(
          markerId: MarkerId('place_$i'),
          position: place.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(place.type),
          ),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.distance} km • ⭐ ${place.rating}',
          ),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  double _getMarkerColor(PlaceType type) {
    switch (type) {
      case PlaceType.hospital:
        return BitmapDescriptor.hueGreen;
      case PlaceType.supermarket:
        return BitmapDescriptor.hueOrange;
      case PlaceType.pharmacy:
        return BitmapDescriptor.hueCyan;
      case PlaceType.bank:
        return BitmapDescriptor.hueYellow;
      case PlaceType.school:
        return BitmapDescriptor.hueMagenta;
    }
  }

  void _calculateDistance() {
    if (_userPosition == null) return;

    final distance = _calculateDistanceInKm(
      _userPosition!.latitude,
      _userPosition!.longitude,
      _condominioLocation.latitude,
      _condominioLocation.longitude,
    );

    setState(() {
      _distance = distance;
      _duration = _estimateDuration(distance, _selectedTransport);
    });

    _drawRoute();
  }

  double _calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String _estimateDuration(double distanceKm, String transport) {
    double speedKmh;
    switch (transport) {
      case 'car':
        speedKmh = 40;
        break;
      case 'walk':
        speedKmh = 5;
        break;
      case 'bus':
        speedKmh = 25;
        break;
      case 'taxi':
        speedKmh = 45;
        break;
      default:
        speedKmh = 40;
    }

    final hours = distanceKm / speedKmh;
    final minutes = (hours * 60).round();

    if (minutes < 60) {
      return '$minutes min';
    } else {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '$h h $m min';
    }
  }

  void _drawRoute() {
    if (_userPosition == null) return;

    final userLatLng =
        LatLng(_userPosition!.latitude, _userPosition!.longitude);

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [userLatLng, _condominioLocation],
      color: kTeal,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  void _changeTransport(String transport) {
    setState(() {
      _selectedTransport = transport;
      if (_distance != null) {
        _duration = _estimateDuration(_distance!, transport);
      }
    });
  }

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${_condominioLocation.latitude},${_condominioLocation.longitude}&travelmode=driving');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('No se pudo abrir Google Maps');
    }
  }

  void _shareLocation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareModal(),
    );
  }

  Widget _buildShareModal() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Compartir Ubicación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: Iconsax.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareViaWhatsApp(),
              ),
              _buildShareOption(
                icon: Iconsax.copy,
                label: 'Copiar',
                color: kTeal,
                onTap: () => _copyToClipboard(),
              ),
              _buildShareOption(
                icon: Iconsax.sms,
                label: 'SMS',
                color: Colors.blue,
                onTap: () => _shareViaSMS(),
              ),
              _buildShareOption(
                icon: Iconsax.share,
                label: 'Otros',
                color: Colors.orange,
                onTap: () => _shareGeneric(),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _shareViaWhatsApp() async {
    final text = '$_condominioName\n'
        '$_condominioAddress\n\n'
        '📍 Ver en Google Maps:\n'
        'https://maps.google.com/?q=${_condominioLocation.latitude},${_condominioLocation.longitude}';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('No se pudo abrir WhatsApp');
    }
  }

  void _copyToClipboard() {
    final text = '$_condominioName\n'
        '$_condominioAddress\n'
        'Coordenadas: ${_condominioLocation.latitude}, ${_condominioLocation.longitude}\n'
        'Google Maps: https://maps.google.com/?q=${_condominioLocation.latitude},${_condominioLocation.longitude}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Ubicación copiada al portapapeles'),
        backgroundColor: kTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareViaSMS() async {
    final text = '$_condominioName - $_condominioAddress\n'
        'https://maps.google.com/?q=${_condominioLocation.latitude},${_condominioLocation.longitude}';

    final url = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('No se pudo abrir SMS');
    }
  }

  void _shareGeneric() {
    final text = '$_condominioName\n'
        '$_condominioAddress\n\n'
        'Ver en Google Maps:\n'
        'https://maps.google.com/?q=${_condominioLocation.latitude},${_condominioLocation.longitude}';

    Share.share(text);
  }

  void _saveToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⭐ Ubicación guardada en favoritos'),
        backgroundColor: kTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Emergencias'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyItem('Policía', '110'),
            _buildEmergencyItem('Bomberos', '119'),
            _buildEmergencyItem('Ambulancia', '118'),
            _buildEmergencyItem('Seguridad Condominio', '3-345-6789'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String label, String number) {
    return InkWell(
      onTap: () => _callNumber(number),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Iconsax.call, size: 20, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    number,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _callNumber(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Condominio'),
        backgroundColor: kOxfordBlue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _condominioLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_userPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
                );
              }
            },
          ),
          if (_isLoadingLocation)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: kTeal),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.building,
                              color: kTeal, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                _condominioName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kOxfordBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _condominioAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_distance != null && _duration != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              icon: Iconsax.routing,
                              label: 'Distancia',
                              value: '${_distance!.toStringAsFixed(1)} km',
                            ),
                            Container(
                                width: 1, height: 40, color: Colors.grey[300]),
                            _buildInfoItem(
                              icon: Iconsax.clock,
                              label: 'Tiempo',
                              value: _duration!,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openGoogleMaps,
                            icon: const Icon(Iconsax.routing_2),
                            label: const Text('Cómo llegar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareLocation,
                            icon: const Icon(Iconsax.share),
                            label: const Text('Compartir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kTeal,
                              side: const BorderSide(color: kTeal),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _saveToFavorites,
                          icon: const Icon(Iconsax.star),
                          color: kTeal,
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Modo de Transporte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kOxfordBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTransportButton('car', '🚗', 'Auto'),
                        const SizedBox(width: 10),
                        _buildTransportButton('walk', '🚶', 'Caminar'),
                        const SizedBox(width: 10),
                        _buildTransportButton('bus', '🚌', 'Bus'),
                        const SizedBox(width: 10),
                        _buildTransportButton('taxi', '🚕', 'Taxi'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lugares Cercanos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kOxfordBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._nearbyPlaces
                        .map((place) => _buildNearbyPlaceItem(place)),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showEmergencyDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.emergency, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: kTeal, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kOxfordBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTransportButton(String type, String emoji, String label) {
    final isSelected = _selectedTransport == type;
    return Expanded(
      child: InkWell(
        onTap: () => _changeTransport(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kTeal : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kTeal : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPlaceItem(NearbyPlace place) {
    return InkWell(
      onTap: () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(place.location, 16),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getPlaceEmoji(place.type),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kOxfordBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${place.distance} km • ${_estimateWalkingTime(place.distance)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getPlaceEmoji(PlaceType type) {
    switch (type) {
      case PlaceType.hospital:
        return '🏥';
      case PlaceType.supermarket:
        return '🛒';
      case PlaceType.pharmacy:
        return '💊';
      case PlaceType.bank:
        return '🏦';
      case PlaceType.school:
        return '🏫';
    }
  }

  String _estimateWalkingTime(double distanceKm) {
    final minutes = (distanceKm / 5 * 60).round();
    return '$minutes min caminando';
  }
}

class NearbyPlace {
  final String name;
  final LatLng location;
  final PlaceType type;
  final double distance;
  final double rating;

  NearbyPlace({
    required this.name,
    required this.location,
    required this.type,
    required this.distance,
    required this.rating,
  });
}

enum PlaceType {
  hospital,
  supermarket,
  pharmacy,
  bank,
  school,
}
