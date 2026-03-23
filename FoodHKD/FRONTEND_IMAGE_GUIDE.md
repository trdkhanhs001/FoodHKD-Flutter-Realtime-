# 🖼️ Hướng Dẫn Hiển Thị Ảnh Sản Phẩm - Frontend

**Phiên bản:** 2.0  
**Cập nhật:** 04/12/2025  
**Dành cho:** Flutter Frontend Team

---

## 📋 Mục Lục
1. [Tổng Quan](#tổng-quan)
2. [Quy Trình Upload & Hiển Thị](#quy-trình-upload--hiển-thị)
3. [API Endpoints](#api-endpoints)
4. [Hướng Dẫn Step-by-Step](#hướng-dẫn-step-by-step)
5. [Code Examples](#code-examples)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Tổng Quan

### Kiến Trúc Upload Ảnh

```
Frontend (Flutter)
    ↓
    ├─→ Pick Image từ Device
    ├─→ Upload to Backend
    └─→ GET Image URL từ Response
        ↓
    Backend (Spring Boot)
        ├─→ Validate File
        ├─→ Save to: uploads/foods/{UUID}.{ext}
        ├─→ Return: { imageUrl: "/api/admin/foods/image/{UUID}.{ext}" }
        └─→ GET /api/admin/foods/image/{filename}
            ↓
    Frontend
        ├─→ Combine: BASE_URL + imageUrl
        └─→ Display: Image.network(fullUrl)
```

---

## 🔄 Quy Trình Upload & Hiển Thị

### Step 1: Upload Ảnh
1. **Frontend** gửi file image tới `/api/admin/foods/upload-image`
2. **Backend** validate file (loại, kích thước, extension)
3. **Backend** lưu file vào `uploads/foods/{UUID}.{extension}`
4. **Backend** trả về: `imageUrl: "/api/admin/foods/image/{UUID}.{extension}"`

### Step 2: Hiển Thị Ảnh
1. **Frontend** nhận `imageUrl` từ response
2. **Frontend** tạo full URL: `BASE_URL + imageUrl`
3. **Frontend** dùng `Image.network(fullUrl)` để hiển thị

### Step 3: Persist Data
1. **Frontend** lưu `imageUrl` vào database cùng với product info
2. Khi hiển thị product: **Frontend** lấy lại `imageUrl` và hiển thị

---

## 🔗 API Endpoints

### 1️⃣ Upload Ảnh Sản Phẩm

#### Endpoint
```
POST /api/admin/foods/upload-image
```

#### Base URLs
- **Development (Local):** `http://localhost:8080`
- **Production (Ngrok):** `https://unmalted-alphonso-unpreponderated.ngrok-free.dev`

#### Request Headers
```
Content-Type: multipart/form-data
```

#### Request Body
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `file` | File (MultipartFile) | ✅ Bắt buộc | Loại: jpg, jpeg, png, gif, bmp, webp |

#### File Requirements
- **Max Size:** 5 MB
- **Allowed Extensions:** jpg, jpeg, png, gif, bmp, webp
- **Content Types Accepted:** image/*, application/octet-stream

#### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Upload hình ảnh thành công",
  "imageUrl": "/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg",
  "imagePath": "D:\\DACN\\FoodHKD\\uploads\\foods\\550e8400-e29b-41d4-a716-446655440000.jpg",
  "filename": "550e8400-e29b-41d4-a716-446655440000.jpg"
}
```

#### ⚠️ Error Responses

**400 - File không được để trống**
```json
{
  "success": false,
  "message": "File không được để trống"
}
```

**400 - Extension không hợp lệ**
```json
{
  "success": false,
  "message": "Chỉ chấp nhận file hình ảnh (jpg, jpeg, png, gif, bmp, webp)"
}
```

**400 - File quá lớn**
```json
{
  "success": false,
  "message": "Kích thước file không được vượt quá 5MB"
}
```

**500 - IO Exception**
```json
{
  "success": false,
  "message": "Lỗi khi lưu file: [error details]"
}
```

---

### 2️⃣ Lấy Ảnh Sản Phẩm

#### Endpoint
```
GET /api/admin/foods/image/{filename}
```

#### Path Parameters
| Parameter | Type | Required | Example |
|-----------|------|----------|---------|
| `filename` | string | ✅ Bắt buộc | `550e8400-e29b-41d4-a716-446655440000.jpg` |

#### Request Example
```
GET http://localhost:8080/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg
```

#### Success Response (200 OK)
```
Content-Type: image/jpeg (or image/png, image/gif, etc.)
Body: Binary image data
```

#### ⚠️ Error Responses

**400 - Invalid filename**
```
Status: 400 Bad Request
Body: (empty)
```

**404 - File không tồn tại**
```
Status: 404 Not Found
Body: (empty)
```

---

## 📝 Hướng Dẫn Step-by-Step

### ✅ Checklist để Hiển Thị Ảnh Thành Công

- [ ] Backend và Frontend cùng dùng **một** BASE_URL (local hoặc ngrok)
- [ ] Upload ảnh và nhận được `imageUrl` từ response
- [ ] Lưu `imageUrl` (không phải full path) vào database
- [ ] Khi hiển thị, combine: `BASE_URL + imageUrl`
- [ ] Dùng `Image.network()` với **full URL**
- [ ] Xử lý error cases (file empty, invalid extension, etc.)
- [ ] Test trên device/emulator thực

### 🐛 Debug Tips

1. **In ra console:**
   - URL được gửi đi (request)
   - Response từ backend
   - Full URL được tạo (BASE_URL + imageUrl)
   - NetworkImage/Image.network loading status

2. **Check Network:**
   - Mở DevTools hoặc Charles Proxy
   - Kiểm tra request/response headers
   - Verify content-type của response

3. **Check Backend:**
   - Xem logs: `=== DEBUG UPLOAD IMAGE ===` trong console
   - Kiểm tra folder: `uploads/foods/`
   - Confirm file được lưu thành công

---

## 💻 Code Examples

### Flutter/Dart - Complete Implementation

#### 1. Service Class (ImageService.dart)

```dart
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ImageService {
  // ⚠️ IMPORTANT: CHANGE THIS TO YOUR BASE_URL
  static const String baseUrl = 'http://localhost:8080';
  // For ngrok: 'https://your-ngrok-url.ngrok-free.dev'
  
  /// Upload image file
  /// Returns: imageUrl (e.g., "/api/admin/foods/image/uuid.jpg")
  static Future<String> uploadImage(File imageFile) async {
    try {
      print('🚀 Starting image upload...');
      print('📁 File: ${imageFile.path}');
      
      final uri = Uri.parse('$baseUrl/api/admin/foods/upload-image');
      print('🌐 Endpoint: ${uri.toString()}');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      // Send request
      print('📤 Sending request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📥 Response Status: ${response.statusCode}');
      print('📊 Response Body: $responseBody');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          final imageUrl = data['imageUrl'];
          print('✅ Upload successful!');
          print('🖼️  Image URL: $imageUrl');
          return imageUrl;
        } else {
          print('❌ Backend returned success:false');
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }
  
  /// Get full URL for Image widget
  /// Input: imageUrl (e.g., "/api/admin/foods/image/uuid.jpg")
  /// Output: full URL (e.g., "http://localhost:8080/api/admin/foods/image/uuid.jpg")
  static String getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return '$baseUrl$imageUrl';
  }
}
```

#### 2. Usage in Screen/Widget

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductFormScreen extends StatefulWidget {
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      // 1. Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) return;
      
      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });
      
      // 2. Upload image
      final imageUrl = await ImageService.uploadImage(_selectedImage!);
      
      // 3. Save imageUrl (not full path) to state/database
      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Upload thành công!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Sản Phẩm')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Preview
            if (_uploadedImageUrl != null)
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isUploading
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
                      : Image.network(
                          // ⚠️ IMPORTANT: Use full URL here!
                          ImageService.getImageUrl(_uploadedImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Failed to load image\n$error',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              )
            else
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('Nhấn để chọn ảnh sản phẩm'),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 32),
            // Other form fields...
          ],
        ),
      ),
    );
  }
}
```

#### 3. Displaying Product with Image

```dart
class ProductListScreen extends StatelessWidget {
  Future<List<FoodItem>> _getFoodItems() async {
    // Get food items from API
    // Each item has imageUrl field
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodItem>>(
      future: _getFoodItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: Row(
                  children: [
                    // ✅ Correct way to display image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 120,
                        height: 120,
                        child: item.imageUrl != null
                            ? Image.network(
                                // ⚠️ CRITICAL: Use getImageUrl to get FULL URL
                                ImageService.getImageUrl(item.imageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text(item.description ?? ''),
                            SizedBox(height: 8),
                            Text(
                              '${item.price}đ',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

---

## 🚨 Troubleshooting

### ❌ Vấn Đề: Ảnh Không Hiển Thị

#### Nguyên Nhân 1: BASE_URL Sai
```dart
// ❌ WRONG
const String baseUrl = 'http://localhost:8080'; // This won't work on device

// ✅ CORRECT for Emulator/Simulator
const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator

// ✅ CORRECT for Real Device
const String baseUrl = 'http://192.168.x.x:8080'; // Your computer's IP

// ✅ CORRECT for Ngrok (Both emulator and device)
const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
```

**Solution:** Verify BASE_URL matches your setup
```bash
# Test locally
curl http://localhost:8080/api/admin/foods/image/test.jpg

# On device, use your computer IP
# Find IP: ipconfig (Windows) or ifconfig (Mac/Linux)
```

#### Nguyên Nhân 2: Lưu Full Path Thay Vì imageUrl
```dart
// ❌ WRONG - Saved full path
String imagePath = "D:\\DACN\\FoodHKD\\uploads\\foods\\uuid.jpg";
Image.network(imagePath); // This won't work!

// ✅ CORRECT - Save only imageUrl
String imageUrl = "/api/admin/foods/image/uuid.jpg";
Image.network(ImageService.getImageUrl(imageUrl)); // Works!
```

#### Nguyên Nhân 3: Missing Frontend ImageUrl Khi Create/Update Product
```dart
// ❌ WRONG - Didn't save imageUrl
final foodItem = FoodItem(
  name: 'Pizza',
  price: 50000,
  // imageUrl is null!
);

// ✅ CORRECT - Save imageUrl from upload response
String uploadedImageUrl = await ImageService.uploadImage(imageFile);
final foodItem = FoodItem(
  name: 'Pizza',
  price: 50000,
  imageUrl: uploadedImageUrl, // "/api/admin/foods/image/uuid.jpg"
);
```

### ❌ Vấn Đề: Upload Thất Bại

#### Error: "Extension không hợp lệ"
- **Nguyên Nhân:** File extension không đúng
- **Solution:** Chỉ upload jpg, jpeg, png, gif, bmp, webp
```dart
// Check before upload
if (!['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(
    extension.toLowerCase())) {
  showError('Chỉ chấp nhận jpg, jpeg, png, gif, bmp, webp');
}
```

#### Error: "File quá lớn"
- **Nguyên Nhân:** File vượt quá 5MB
- **Solution:** Compress image trước khi upload
```dart
import 'package:image/image.dart' as img;

File compressImage(File imageFile) {
  final bytes = imageFile.readAsBytesSync();
  final image = img.decodeImage(bytes);
  final thumbnail = img.copyResize(image!,
      width: 1200, // Max width
      height: 1200, // Max height
  );
  return imageFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 85));
}

// Usage
File compressedImage = compressImage(_selectedImage!);
String imageUrl = await ImageService.uploadImage(compressedImage);
```

#### Error: "Network Error" / "Connection Refused"
- **Nguyên Nhân:** Server không chạy hoặc URL sai
- **Solution:**
  1. Verify server running: `http://BASE_URL/api/admin/foods`
  2. Check BASE_URL:
     - Local: `http://localhost:8080`
     - Emulator: `http://10.0.2.2:8080` (Android) hoặc `http://localhost:8080` (iOS)
     - Device: `http://192.168.x.x:8080` (Your computer's IP)
     - Ngrok: `https://your-ngrok-url.ngrok-free.dev`

### ❌ Vấn Đề: CORS Error

**Error Message:**
```
XMLHttpRequest error: Status 0: null
```

**Solution:** Không phải issue vì backend cho phép CORS

**But if still error:**
- Verify ngrok is running: `ngrok http 8080`
- Verify backend CORS config

### ❌ Vấn Đề: Image.network Widget Shows Error

```dart
// Add better error handling
Image.network(
  url,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    print('Error: $error');
    print('StackTrace: $stackTrace');
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error),
          SizedBox(height: 8),
          Text('Failed to load image'),
          SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  },
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
)
```

---

## 📚 Summary - Các Bước Chính

### Hiển Thị Ảnh Trong Trang Quản Lý Sản Phẩm:

1. **Upload Image** → POST `/api/admin/foods/upload-image`
   - Input: File từ device
   - Output: `imageUrl = "/api/admin/foods/image/{uuid}.jpg"`

2. **Lưu imageUrl** → Gửi tới backend create/update product
   - Save: `imageUrl` (NOT full path)
   - Example: `"/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg"`

3. **Get Product List** → GET `/api/admin/foods`
   - Backend trả về products với `imageUrl` field

4. **Display Image** → Image.network()
   ```dart
   final fullUrl = ImageService.getImageUrl(product.imageUrl);
   Image.network(fullUrl);
   ```

### ⚠️ Critical Points:

- ✅ **Always use `ImageService.getImageUrl()` để tạo FULL URL**
- ✅ **Save `imageUrl` (relative), not full path**
- ✅ **Change BASE_URL để match enviroment** (local, emulator, device, ngrok)
- ✅ **Handle loading & error states** trong Image widget
- ✅ **Test trên thực device, not just emulator**

---

## 🆘 Cần Giúp Đỡ?

**Backend Issues? Log Check:**
```
=== DEBUG UPLOAD IMAGE ===
File name: ...
File size: ...
Content type: ...
```

**Frontend Issues? Print Debug:**
```dart
print('URL: ${ImageService.getImageUrl(imageUrl)}');
print('BASE_URL: ${ImageService.baseUrl}');
```

**Network Issues? Use Charles/Fiddler:**
- Intercept requests
- Verify headers
- Check response body

---

**Ngày tạo:** 04/12/2025  
**Phiên bản:** 2.0  
**Status:** ✅ Ready for Implementation
