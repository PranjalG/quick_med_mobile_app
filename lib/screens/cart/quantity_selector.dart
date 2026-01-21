import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(Icons.remove, onRemove, disabled: quantity == 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "$quantity",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _button(Icons.add, onAdd),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap,
      {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}
