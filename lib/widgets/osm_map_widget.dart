import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A pure Flutter interactive OpenStreetMap slippy-tile widget.
/// Supports panning, zooming, marker placement, attribution, and error fallbacks.
class OsmMapWidget extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final double height;
  final List<OsmMarker> markers;
  final ValueChanged<OsmMarker>? onMarkerTap;

  const OsmMapWidget({
    super.key,
    this.initialLat = 6.8404,
    this.initialLng = 80.0034,
    this.initialZoom = 13.0,
    this.minZoom = 10.0,
    this.maxZoom = 18.0,
    this.height = 280,
    this.markers = const [],
    this.onMarkerTap,
  });

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class OsmMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String label;
  final Color color;
  final String title;
  final String subtitle;

  const OsmMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.color,
    required this.title,
    this.subtitle = '',
  });
}

class _OsmMapWidgetState extends State<OsmMapWidget> {
  late double _centerLat;
  late double _centerLng;
  late double _zoom;
  bool _tileError = false;

  @override
  void initState() {
    super.initState();
    _centerLat = widget.initialLat;
    _centerLng = widget.initialLng;
    _zoom = widget.initialZoom;
  }

  // Slippy map projection formulas (Web Mercator EPSG:3857)
  static double _lngToPixel(double lng, double zoom) {
    return (lng + 180.0) / 360.0 * (256.0 * math.pow(2.0, zoom));
  }

  static double _latToPixel(double lat, double zoom) {
    final latRad = lat * math.pi / 180.0;
    return (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
        2.0 *
        (256.0 * math.pow(2.0, zoom));
  }

  static double _pixelToLng(double px, double zoom) {
    return px / (256.0 * math.pow(2.0, zoom)) * 360.0 - 180.0;
  }

  static double _pixelToLat(double py, double zoom) {
    final n = math.pi - 2.0 * math.pi * py / (256.0 * math.pow(2.0, zoom));
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1.0).clamp(widget.minZoom, widget.maxZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1.0).clamp(widget.minZoom, widget.maxZoom);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      final currentCenterPxX = _lngToPixel(_centerLng, _zoom);
      final currentCenterPxY = _latToPixel(_centerLat, _zoom);
      final newCenterPxX = currentCenterPxX - details.delta.dx;
      final newCenterPxY = currentCenterPxY - details.delta.dy;
      _centerLng = _pixelToLng(newCenterPxX, _zoom);
      _centerLat = _pixelToLat(newCenterPxY, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E9E1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE3D6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final centerPxX = _lngToPixel(_centerLng, _zoom);
          final centerPxY = _latToPixel(_centerLat, _zoom);

          final intZoom = _zoom.floor();
          final tileSize = 256.0 * math.pow(2.0, _zoom - intZoom);

          final minXTile = ((centerPxX - width / 2) / tileSize).floor();
          final maxXTile = ((centerPxX + width / 2) / tileSize).floor();
          final minYTile = ((centerPxY - height / 2) / tileSize).floor();
          final maxYTile = ((centerPxY + height / 2) / tileSize).floor();

          final numTiles = (1 << intZoom);

          return Stack(
            children: [
              // Slippy Map Tiles Layer
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    for (int x = minXTile; x <= maxXTile; x++)
                      for (int y = minYTile; y <= maxYTile; y++)
                        if (y >= 0 && y < numTiles)
                          Positioned(
                            left: (x * tileSize) - (centerPxX - width / 2),
                            top: (y * tileSize) - (centerPxY - height / 2),
                            width: tileSize + 0.5,
                            height: tileSize + 0.5,
                            child: Image.network(
                              'https://tile.openstreetmap.org/$intZoom/${(x % numTiles + numTiles) % numTiles}/$y.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                if (!_tileError) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) setState(() => _tileError = true);
                                  });
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EDE4),
                                    border: Border.all(color: const Color(0xFFD5DDD0), width: 0.5),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.map_outlined, color: Color(0xFF9EAFA2), size: 24),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),

              // Markers Layer
              for (final marker in widget.markers)
                Builder(builder: (context) {
                  final markerPxX = _lngToPixel(marker.longitude, _zoom);
                  final markerPxY = _latToPixel(marker.latitude, _zoom);
                  final posX = markerPxX - (centerPxX - width / 2);
                  final posY = markerPxY - (centerPxY - height / 2);

                  // Only render if within visible map viewport + padding
                  if (posX < -40 || posX > width + 40 || posY < -40 || posY > height + 40) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: posX - 22,
                    top: posY - 22,
                    child: GestureDetector(
                      onTap: () => widget.onMarkerTap?.call(marker),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: marker.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          marker.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Offline / Tile fallback message if network/tiles fail
              if (_tileError)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD0D7CC)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF65716A)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Map tiles offline \u00b7 Marker coordinates and outage list active',
                            style: TextStyle(fontSize: 11, color: Color(0xFF65716A), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Zoom controls (+ / -)
              Positioned(
                top: _tileError ? 50 : 12,
                right: 12,
                child: Column(
                  children: [
                    _ZoomButton(
                      icon: Icons.add,
                      onTap: _zoomIn,
                      tooltip: 'Zoom in',
                    ),
                    const SizedBox(height: 6),
                    _ZoomButton(
                      icon: Icons.remove,
                      onTap: _zoomOut,
                      tooltip: 'Zoom out',
                    ),
                  ],
                ),
              ),

              // OpenStreetMap Attribution (Required by OSM License)
              Positioned(
                left: 10,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '\u00a9 OpenStreetMap contributors',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF4A5550),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: const Color(0xFF17201D)),
        ),
      ),
    );
  }
}
