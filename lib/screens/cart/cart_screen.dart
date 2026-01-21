import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  GoogleMapController? _mapController;
  LatLng deliveryPartnerLocation = const LatLng(25.2138, 75.8648);
  LatLng customerLocation = const LatLng(25.2155, 75.8700);

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<CartItem> cartItems = [
    CartItem(name: "Paracetamol 650mg", quantity: 1, price: 50),
    CartItem(name: "Vitamin C Tablets", quantity: 2, price: 120),
    CartItem(name: "Zinc Syrup", quantity: 1, price: 90),
  ];

  void simulateLiveTracking() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      deliveryPartnerLocation = const LatLng(25.2148, 75.8670); // new position
      _loadMapData();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(deliveryPartnerLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🔴 TOP HALF — LIVE MAP
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                _googleMapView(),
                _mapHeader(),
              ],
            ),
          ),

          // 🟢 BOTTOM HALF — ORDER DETAILS
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _deliveryPartnerInfo(),
                    const SizedBox(height: 16),

                    // 🛒 CART ITEMS
                    const Text(
                      "Items in your cart",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(
                      cartItems.length,
                      (index) => CartItemCard(
                        item: cartItems[index],
                        onIncrement: () {
                          setState(() {
                            cartItems[index].quantity++;
                          });
                        },
                        onDecrement: () {
                          setState(() {
                            if (cartItems[index].quantity > 1) {
                              cartItems[index].quantity--;
                            }
                          });
                        },
                        onDelete: () {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    _billSummary(),
                    const SizedBox(height: 16),
                    _deliveryAddress(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAP HEADER =================

  Widget _mapHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerChip("Order #QM1021"),
            _headerChip("₹349"),
          ],
        ),
      ),
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // ================= DELIVERY PARTNER =================

  Widget _deliveryPartnerInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green,
            child: Icon(Icons.delivery_dining, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ramesh Kumar",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "Delivery Partner",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= DELIVERY ADDRESS =================

  Widget _deliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Flat 302, Shanti Apartments\nNayapura, Kota",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _googleMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: deliveryPartnerLocation,
        zoom: 15,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController = controller;
        _loadMapData();
      },
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  void _loadMapData() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("delivery"),
          position: deliveryPartnerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: "Delivery Partner"),
        ),
        Marker(
          markerId: const MarkerId("customer"),
          position: customerLocation,
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.green,
          width: 5,
          points: [
            deliveryPartnerLocation,
            customerLocation,
          ],
        ),
      };
    });
  }

  Widget _billSummary() {
    return Column(
      children: [
        _billRow("Item Total", totalAmount),
        _billRow("Delivery Fee", 20),
        _billRow("Platform Fee", 5),
        const Divider(),
        _billRow(
          "To Pay",
          (totalAmount + 25),
          isBold: true,
        ),
      ],
    );
  }

  double get totalAmount {
    return cartItems.fold(
      0,
          (sum, item) => sum + (item.price * item.quantity),
    );
  }


  Widget _billRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "₹${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
