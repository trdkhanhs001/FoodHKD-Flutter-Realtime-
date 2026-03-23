# 🎯 Frontend Implementation Guide - Fix Ảnh Không Hiển Thị

**Tình huống:** Backend upload ảnh OK, database nhận ảnh, nhưng ảnh không hiển thị  
**Root Cause:** Frontend không gửi `anh` field khi create/update product  
**Solution:** 2-step process: Upload → Create Product with imageUrl

---

## ❌ CURRENT FLOW (WRONG)

```
Frontend:
  1. Create Product form
  2. User picks image
  3. Click "Save" → Gửi product data lên backend
  ❌ PROBLEM: Ảnh không được upload!
```

---

## ✅ CORRECT FLOW (NEW)

```
Frontend:
  1. Create Product form
  2. User picks image
  3. Click image button → Upload ảnh ngay (STEP 1)
     POST /api/admin/foods/upload-image
     ← Response: imageUrl = "/api/admin/foods/image/uuid.jpg"
  4. Show preview ảnh + "Save Product" button
  5. Click "Save" → Gửi product WITH imageUrl (STEP 2)
     POST /api/admin/foods
     Body: { name, price, anh: "/api/admin/foods/image/uuid.jpg", ... }
     ← Product lưu vào database với anh field!
```

---

## 📝 Code Implementation

### STEP 1: Create Dart Model

**File:** `lib/models/food_item.dart`

```dart
class FoodItem {
  final int? foodID;
  final String name;
  final String description;
  final double price;
  final String? anh;  // ⚠️ IMPORTANT: This field MUST be named 'anh'
  final int quantity;
  final int? categoryID;

  FoodItem({
    this.foodID,
    required this.name,
    required this.description,
    required this.price,
    this.anh,
    required this.quantity,
    this.categoryID,
  });

  // JSON serialization - MUST map to backend field names
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodID: json['foodID'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      anh: json['anh'],  // ⚠️ Use 'anh' not 'imageUrl'
      quantity: json['quantity'] ?? 0,
      categoryID: json['categoryID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'anh': anh,  // ⚠️ Send 'anh' to backend
      'quantity': quantity,
      'categoryID': categoryID,
    };
  }
}
```

---

### STEP 2: Create Image Service

**File:** `lib/services/image_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ImageService {
  // ⚠️ CHANGE THIS TO YOUR IP OR NGROK URL
  static const String baseUrl = 'http://192.168.1.100:8080';
  // For ngrok: 'https://your-ngrok-url.ngrok-free.dev'
  
  // ✅ STEP 1: Upload image file
  static Future<String> uploadImage(File imageFile) async {
    try {
      print('🚀 [IMAGE_SERVICE] Starting upload...');
      print('📁 File: ${imageFile.path}');
      print('📊 Size: ${imageFile.lengthSync()} bytes');
      
      final uri = Uri.parse('$baseUrl/api/admin/foods/upload-image');
      print('🌐 Uploading to: $uri');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      // Send
      print('📤 Sending request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📥 Response Status: ${response.statusCode}');
      print('📊 Response Body: $responseBody');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          final imageUrl = data['imageUrl'];
          print('✅ Upload successful! URL: $imageUrl');
          return imageUrl;  // e.g., "/api/admin/foods/image/uuid.jpg"
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }
  
  // ✅ Helper: Get full URL for Image widget
  static String getFullImageUrl(String? anhValue) {
    if (anhValue == null || anhValue.isEmpty) {
      return ''; // Empty URL if no image
    }
    if (anhValue.startsWith('http')) {
      return anhValue; // Already full URL
    }
    return '$baseUrl$anhValue';  // Combine: baseUrl + anhValue
  }
}
```

---

### STEP 3: Create Food Service

**File:** `lib/services/food_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food_item.dart';
import 'image_service.dart';

class FoodService {
  static const String baseUrl = ImageService.baseUrl;
  
  // ✅ STEP 2: Create food item WITH imageUrl
  static Future<FoodItem> createFoodItem(FoodItem foodItem) async {
    try {
      print('🍔 [FOOD_SERVICE] Creating food item...');
      print('📦 Data: ${foodItem.toJson()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/foods'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(foodItem.toJson()),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final createdItem = FoodItem.fromJson(data['data']);
          print('✅ Food item created: ${createdItem.foodID}');
          return createdItem;
        } else {
          throw Exception(data['message'] ?? 'Create failed');
        }
      } else {
        throw Exception('Failed to create food item');
      }
    } catch (e) {
      print('❌ Create error: $e');
      rethrow;
    }
  }
  
  // Get all food items
  static Future<List<FoodItem>> getAllFoodItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/foods'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> foodsJson = data['data'];
          return foodsJson.map((e) => FoodItem.fromJson(e)).toList();
        }
      }
      throw Exception('Failed to fetch food items');
    } catch (e) {
      print('❌ Fetch error: $e');
      rethrow;
    }
  }
}
```

---

### STEP 4: Create Product Form Screen

**File:** `lib/screens/product_form_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../services/image_service.dart';
import '../services/food_service.dart';

class ProductFormScreen extends StatefulWidget {
  final FoodItem? editingItem;

  ProductFormScreen({this.editingItem});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // Form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  // Image
  File? _selectedImage;
  String? _uploadedImageUrl;  // ⚠️ Store this!
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      _nameController.text = widget.editingItem!.name;
      _descriptionController.text = widget.editingItem!.description;
      _priceController.text = widget.editingItem!.price.toString();
      _quantityController.text = widget.editingItem!.quantity.toString();
      _uploadedImageUrl = widget.editingItem!.anh;
    }
  }

  // ✅ STEP 1: Pick and upload image
  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) return;
      
      setState(() {
        _selectedImage = File(image.path);
        _isUploadingImage = true;
      });
      
      print('📸 Image selected: ${_selectedImage!.path}');
      
      // Upload to backend
      final imageUrl = await ImageService.uploadImage(_selectedImage!);
      
      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploadingImage = false;
      });
      
      print('🖼️  Image URL saved: $_uploadedImageUrl');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Upload ảnh thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      print('❌ Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload ảnh thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ STEP 2: Save product WITH imageUrl
  Future<void> _saveProduct() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Vui lòng điền đầy đủ thông tin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ⚠️ Validate imageUrl is set
    if (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Vui lòng upload ảnh sản phẩm!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Create FoodItem with imageUrl
      final foodItem = FoodItem(
        foodID: widget.editingItem?.foodID,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        anh: _uploadedImageUrl,  // ✅ CRITICAL: Include imageUrl!
        categoryID: 1, // TODO: Let user select category
      );

      print('💾 Saving product: ${foodItem.toJson()}');
      
      await FoodService.createFoodItem(foodItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Lưu sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Sản Phẩm')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image Section
            Text('Ảnh Sản Phẩm *', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickAndUploadImage,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _uploadedImageUrl != null ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: _isUploadingImage
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang upload...'),
                          ],
                        ),
                      )
                    : _uploadedImageUrl != null
                        ? Stack(
                            children: [
                              Image.network(
                                ImageService.getFullImageUrl(_uploadedImageUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, size: 48, color: Colors.red),
                                        SizedBox(height: 8),
                                        Text('Không thể tải ảnh'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: FloatingActionButton(
                                  mini: true,
                                  onPressed: _pickAndUploadImage,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('Nhấn để upload ảnh'),
                              ],
                            ),
                          ),
              ),
            ),
            SizedBox(height: 32),

            // Form fields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên sản phẩm *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Giá (đ) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Số lượng *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 32),

            // ✅ Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving || _isUploadingImage ? null : _saveProduct,
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text('💾 Lưu Sản Phẩm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
```

---

### STEP 5: Display Products

**File:** `lib/screens/product_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/food_service.dart';
import '../services/image_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<FoodItem>> _foodItems;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _foodItems = FoodService.getAllFoodItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Sản Phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
        ],
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshProducts,
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có sản phẩm'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductFormScreen(),
                        ),
                      );
                      if (result == true) _refreshProducts();
                    },
                    child: Text('➕ Thêm Sản Phẩm'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  // ✅ Image thumbnail
                  leading: item.anh != null && item.anh!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            ImageService.getFullImageUrl(item.anh),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        ),
                  
                  // Product info
                  title: Text(item.name, fontWeight: FontWeight.bold),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${item.price}đ | Tồn: ${item.quantity}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductFormScreen(editingItem: item),
                        ),
                      );
                      if (result == true) _refreshProducts();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(),
            ),
          );
          if (result == true) _refreshProducts();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## ⚠️ Critical Points

### 1. **Field Name MUST be 'anh'**
```dart
// ❌ WRONG
"imageUrl": "/api/admin/foods/image/uuid.jpg"

// ✅ CORRECT
"anh": "/api/admin/foods/image/uuid.jpg"
```

### 2. **Value MUST be Relative Path (NOT full path)**
```dart
// ❌ WRONG
"anh": "D:\\DACN\\FoodHKD\\uploads\\foods\\uuid.jpg"

// ✅ CORRECT
"anh": "/api/admin/foods/image/uuid.jpg"
```

### 3. **BASE_URL Must Match Environment**
```dart
// ❌ Wrong for real device
const String baseUrl = 'http://localhost:8080';

// ✅ Correct for real device
const String baseUrl = 'http://192.168.1.100:8080';

// ✅ Correct for Ngrok
const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
```

### 4. **Upload Image BEFORE Create Product**
```dart
// ❌ WRONG ORDER
await FoodService.createFoodItem(foodItem);  // anh is null!

// ✅ CORRECT ORDER
String imageUrl = await ImageService.uploadImage(imageFile);  // First
foodItem.anh = imageUrl;                                       // Then
await FoodService.createFoodItem(foodItem);                    // Finally
```

### 5. **Always Combine BaseURL + anh for Display**
```dart
// ❌ WRONG
Image.network(product.anh)

// ✅ CORRECT
Image.network(ImageService.getFullImageUrl(product.anh))
```

---

## 🔍 Debugging Checklist

```
✅ BEFORE UPLOAD:
  ☐ ImageService.baseUrl = correct IP or ngrok URL
  ☐ Image file picked successfully
  ☐ File size < 5MB

✅ AFTER UPLOAD:
  ☐ Print: _uploadedImageUrl (should be "/api/admin/foods/image/uuid.jpg")
  ☐ Check backend logs: "✅ File saved successfully"
  ☐ File exists: uploads/foods/ folder

✅ BEFORE CREATE:
  ☐ foodItem.anh = _uploadedImageUrl (not null!)
  ☐ Print: foodItem.toJson() → verify "anh" field
  ☐ All required fields filled

✅ AFTER CREATE:
  ☐ Response status 201
  ☐ Database: SELECT * FROM food_items → anh field has value
  ☐ GET /api/admin/foods → response contains anh field

✅ DISPLAY:
  ☐ Print: ImageService.getFullImageUrl(product.anh)
  ☐ Test URL in browser first
  ☐ Image.network shows image or error clearly
```

---

## 🎬 Summary

**2-STEP PROCESS:**

1. **Upload Image**
   ```dart
   String imageUrl = await ImageService.uploadImage(imageFile);
   // imageUrl = "/api/admin/foods/image/uuid.jpg"
   ```

2. **Create Product WITH imageUrl**
   ```dart
   FoodItem foodItem = FoodItem(
     name: "Pizza",
     price: 50000,
     anh: imageUrl,  // ✅ Include this!
   );
   await FoodService.createFoodItem(foodItem);
   ```

3. **Display**
   ```dart
   String fullUrl = ImageService.getFullImageUrl(product.anh);
   Image.network(fullUrl);
   ```

---

**Ngày cập nhật:** 04/12/2025  
**Status:** ✅ Ready for Implementation
