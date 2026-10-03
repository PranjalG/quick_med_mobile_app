import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_med/services/prescription_service.dart';

/// Camera/gallery picker + upload with shared UX across landing, cart, profile.
class PrescriptionUploadFlow {
  static Future<Prescription?> run(
    BuildContext context, {
    String? orderId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = PrescriptionService();

    final fromCamera = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
          ],
        ),
      ),
    );
    if (fromCamera == null) return null;

    XFile? file;
    try {
      file = await service.pick(fromCamera: fromCamera);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open picker: $error')),
      );
      return null;
    }
    if (file == null) return null;

    messenger.showSnackBar(
      const SnackBar(content: Text('Uploading prescription...')),
    );

    try {
      final rx = await service.upload(file: file, orderId: orderId);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderId != null
                  ? 'Prescription uploaded. Our doctors will review your order.'
                  : 'Prescription saved. It will be linked when you place an Rx order.',
            ),
          ),
        );
      return rx;
    } on PrescriptionException catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
      return null;
    } catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Upload failed: $error')));
      return null;
    }
  }

}
