import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';

class GalleryTab extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final List<GalleryImageModel> galleryImages;
  final VoidCallback? onRefresh;

  const GalleryTab({
    super.key, 
    required this.hotelId, 
    required this.hotelName,
    required this.galleryImages,
    this.onRefresh,
  });

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  static const _primaryColor = Color(0xFFC52031);
  
  String? _removingImageUrl;

  Future<bool> _addImages(List<Uint8List> imageBytes, String alt) async {
    try {
      final fileBytes = <String, Uint8List>{};
      for (int i = 0; i < imageBytes.length; i++) {
        fileBytes['images'] = imageBytes[i];
      }
      final response = await locator<ApiService>().invokeMultipartWithBytes(
        urlPath: ApiEndpoints.hotelGallery(widget.hotelId),
        type: RequestType.post,
        fields: {'alt': alt},
        fileBytes: fileBytes,
        fun: (data) => jsonDecode(data),
      );
      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _removeImage(String imageUrl) async {
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelGalleryImage(widget.hotelId),
        type: RequestType.post,
        params: {'imageUrl': imageUrl},
        fun: (data) => jsonDecode(data),
      );
      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAddModal() {
    List<Uint8List> selectedImages = [];
    final altController = TextEditingController(text: '${widget.hotelName} gallery image');
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_photo_alternate, color: _primaryColor),
                    const SizedBox(width: 12),
                    const Text('Add Gallery Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                // Image picker
                InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final files = await picker.pickMultiImage();
                    if (files.isNotEmpty) {
                      for (final file in files) {
                        final bytes = await file.readAsBytes();
                        selectedImages.add(bytes);
                      }
                      setModalState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Click to select images', style: TextStyle(color: Colors.grey[600])),
                        if (selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('${selectedImages.length} image(s) selected', style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                ),
                if (selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(selectedImages[index], width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => setModalState(() => selectedImages.removeAt(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Alt Text', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: altController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryColor, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isUploading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isUploading || selectedImages.isEmpty ? null : () async {
                        setModalState(() => isUploading = true);
                        final success = await _addImages(selectedImages, altController.text);
                        if (success) {
                          Navigator.pop(context);
                          _showToast('Images added successfully');
                          widget.onRefresh?.call();
                        } else {
                          setModalState(() => isUploading = false);
                          _showToast('Failed to upload images', isError: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isUploading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Upload Images'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmRemoveImage(GalleryImageModel image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Image'),
        content: const Text('Are you sure you want to remove this image? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _removingImageUrl = image.url);
              final success = await _removeImage(image.url);
              setState(() => _removingImageUrl = null);
              if (success) {
                _showToast('Image removed successfully');
                widget.onRefresh?.call();
              } else {
                _showToast('Failed to remove image', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text('Gallery Images', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddModal,
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Content
        if (widget.galleryImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No gallery images found. Add some images to showcase your restaurant.', style: TextStyle(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 400 ? 2 : (constraints.maxWidth < 600 ? 3 : 4);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.galleryImages.length,
                itemBuilder: (context, index) => _buildImageCard(widget.galleryImages[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildImageCard(GalleryImageModel image) {
    final isRemoving = _removingImageUrl == image.url;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: isRemoving ? null : () => _confirmRemoveImage(image),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                  child: isRemoving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

