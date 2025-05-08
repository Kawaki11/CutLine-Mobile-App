import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng userLocation = const LatLng(14.7036, 121.1411); // fallback
  LatLng barbershopLocation = const LatLng(14.7036, 121.1411); // Supremo Concept Barbershop

  String ticketNumber = '#W001';
  bool isPaid = false;
  String queueStatus = 'waiting...';

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    final locData = await location.getLocation();
    setState(() {
      userLocation = LatLng(locData.latitude!, locData.longitude!);
    });
  }

  void getQueueNumber() async {
    final ticket = 'W${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    setState(() {
      ticketNumber = '#$ticket';
      queueStatus = 'In Queue';
    });

    await FirebaseFirestore.instance.collection('queues').doc(ticket).set({
      'status': 'pending',
      'paid': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Queue number generated! Please proceed with payment.')),
    );
  }

  void confirmPayment() async {
    await FirebaseFirestore.instance.collection('queues').doc(ticketNumber.replaceAll('#', '')).update({
      'paid': true,
      'status': 'confirmed',
    });

    setState(() {
      isPaid = true;
      queueStatus = 'Confirmed';
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Confirmed'),
        content: const Text('Thank you! Your queue is now confirmed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text(
                'QUEUEING',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(queueStatus, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: barbershopLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(markerId: const MarkerId('barbershop'), position: barbershopLocation),
                    Marker(markerId: const MarkerId('user'), position: userLocation),
                  },
                  onMapCreated: (controller) => mapController = controller,
                  myLocationEnabled: true,
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Your ticket number is', style: TextStyle(color: Colors.white)),
                    Text(ticketNumber, style: const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 12),
                    const Text('Supremo Haircut', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Estimated wait time: 2 mins', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Estimated Arrival Time: ${DateTime.now().add(const Duration(minutes: 5)).toLocal()}',
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: getQueueNumber,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Get Queue Number'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isPaid ? null : confirmPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Confirm Payment'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Cancel logic
                    setState(() {
                      ticketNumber = '#';
                      queueStatus = 'Cancelled';
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel Queue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
