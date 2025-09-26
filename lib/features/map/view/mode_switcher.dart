import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import '../../../core/models/transport_mode.dart';

class ModeSwitcher extends ConsumerWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(transportModeProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ToggleButtons(
        isSelected: [
          mode == TransportMode.walking,
          mode == TransportMode.driving,
          mode == TransportMode.transit,
        ],
        borderRadius: BorderRadius.circular(12),
        onPressed: (index) {
          final next = [TransportMode.walking, TransportMode.driving, TransportMode.transit][index];
          ref.read(transportModeProvider.notifier).state = next;
        },
        children: const [
          Padding(padding: EdgeInsets.all(8), child: Icon(Icons.directions_walk)),
          Padding(padding: EdgeInsets.all(8), child: Icon(Icons.directions_car)),
          Padding(padding: EdgeInsets.all(8), child: Icon(Icons.directions_transit)),
        ],
      ),
    );
  }
}
