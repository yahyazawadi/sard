import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../custom/app_theme.dart';
import 'sard_primary_button.dart';

class LocationPopup {
  static void show(
    BuildContext context, {
    required Function(String) onAddressChanged,
    String? currentAddress,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _LocationSelectionDialog(
          onAddressChanged: onAddressChanged,
          currentAddress: currentAddress,
        );
      },
    );
  }
}

class _LocationSelectionDialog extends StatelessWidget {
  final Function(String) onAddressChanged;
  final String? currentAddress;

  const _LocationSelectionDialog({
    required this.onAddressChanged,
    this.currentAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius + 16),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Delivery Location', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Select how you\'d like to set your address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SardPrimaryButton(
                label: 'Use Current Location',
                icon: Icons.my_location_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _fetchAndSetLocation(context, onAddressChanged);
                },
              ),
              const SizedBox(height: 12),
              _buildSheetButton(
                theme,
                'Type Address Manually',
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.onSurface,
                Icons.edit_location_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _showManualAddressSheet(context, onAddressChanged, currentAddress);
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'NOT NOW',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetButton(
    ThemeData theme,
    String label,
    Color color,
    Color textColor,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAndSetLocation(BuildContext context, Function(String) onAddressChanged) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services are disabled. Please enable GPS.")),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permissions are denied")),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are permanently denied.")),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String? street = place.street;
        if (street != null && street.contains('+') && !street.contains(' ')) {
          street = (place.thoroughfare?.isNotEmpty ?? false) ? place.thoroughfare : place.name;
        }
        String line1 = street ?? place.name ?? "Current Location";
        String city = place.locality ?? place.subAdministrativeArea ?? "";
        String area = place.subLocality ?? "";
        String line2 = [area, city].where((s) => s.isNotEmpty).join(", ");
        if (line2.isEmpty) line2 = place.administrativeArea ?? "";
        String country = place.country ?? "";

        onAddressChanged("$line1\n$line2, $country");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
      }
    }
  }

  void _showManualAddressSheet(BuildContext context, Function(String) onAddressChanged, String? initialAddress) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: initialAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Enter Address', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter your full delivery address...",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                if (controller.text.isNotEmpty) {
                  onAddressChanged(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.getCardGradient(theme),
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(color: AppTheme.accentGold, width: 1.5),
                  boxShadow: AppTheme.goldShadow,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SAVE ADDRESS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }
}
