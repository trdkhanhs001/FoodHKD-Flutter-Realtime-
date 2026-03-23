# Image Upload API Documentation

## Overview
Backend cung cấp API để upload và lấy hình ảnh sản phẩm. Giải pháp này hỗ trợ ngrok tunnel.

---

## 1. Upload Image

### Endpoint
```
POST /api/admin/foods/upload-image
```

### Base URL
- **Development (Local):** `http://localhost:8080`
- **Production (Ngrok):** `https://unmalted-alphonso-unpreponderated.ngrok-free.dev`

### Request

**Method:** POST  
**Content-Type:** multipart/form-data

**Form Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File (MultipartFile) | Yes | Hình ảnh (jpg, jpeg, png, gif, bmp, webp) |

**Max File Size:** 5 MB

### Request Example (cURL)
```bash
curl -X POST "http://localhost:8080/api/admin/foods/upload-image" \
  -F "file=@/path/to/image.jpg"
```

### Request Example (Dart/Flutter)
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, dynamic>> uploadImage(File imageFile) async {
  final uri = Uri.parse('https://ngrok-url/api/admin/foods/upload-image');
  
  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  
  return jsonDecode(responseBody);
}
```

### Success Response

**Status Code:** 201 Created

```json
{
  "success": true,
  "message": "Upload hình ảnh thành công",
  "imageUrl": "/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg",
  "imagePath": "D:\\DACN\\FoodHKD\\uploads\\foods\\550e8400-e29b-41d4-a716-446655440000.jpg",
  "filename": "550e8400-e29b-41d4-a716-446655440000.jpg"
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Upload có thành công hay không |
| `message` | string | Thông báo về kết quả |
| `imageUrl` | string | **URL để lấy ảnh** - dùng cái này! |
| `imagePath` | string | Đường dẫn file trên server |
| `filename` | string | Tên file được lưu |

---

## Error Responses

### 400 Bad Request - File không được để trống
```json
{
  "success": false,
  "message": "File không được để trống"
}
```

### 400 Bad Request - Không thể xác định tên file
```json
{
  "success": false,
  "message": "Không thể xác định tên file"
}
```

### 400 Bad Request - Invalid extension
```json
{
  "success": false,
  "message": "Chỉ chấp nhận file hình ảnh (jpg, jpeg, png, gif, bmp, webp)"
}
```

**Allowed Extensions:** jpg, jpeg, png, gif, bmp, webp

### 400 Bad Request - File quá lớn
```json
{
  "success": false,
  "message": "Kích thước file không được vượt quá 5MB"
}
```

### 500 Internal Server Error - IO Exception
```json
{
  "success": false,
  "message": "Lỗi khi lưu file: [error details]"
}
```

### 500 Internal Server Error - General Exception
```json
{
  "success": false,
  "message": "Lỗi upload hình: [error details]"
}
```

---

## 2. Get Image (Serve Image)

### Endpoint
```
GET /api/admin/foods/image/{filename}
```

### Base URL
- **Development (Local):** `http://localhost:8080`
- **Production (Ngrok):** `https://unmalted-alphonso-unpreponderated.ngrok-free.dev`

### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filename` | string | Yes | Tên file được trả về từ upload endpoint (ví dụ: `550e8400-e29b-41d4-a716-446655440000.jpg`) |

### Security
- Tên file được validate để tránh path traversal attacks
- Chỉ chấp nhận alphanumeric, dots, hyphens, underscores trong filename

### Response

**Status Code:** 200 OK

**Content-Type:** 
- `image/jpeg` - nếu file là .jpg/.jpeg
- `image/png` - nếu file là .png
- `image/gif` - nếu file là .gif
- `image/bmp` - nếu file là .bmp
- `image/webp` - nếu file là .webp

**Body:** Binary image data

### Success Example
```
GET /api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg
→ Returns: Binary JPEG image data
```

### Error Responses

**400 Bad Request - Invalid filename**
```
Status: 400
Body: (empty)
```

**404 Not Found - File không tồn tại**
```
Status: 404
Body: (empty)
```

---

## 3. Complete Workflow Example

### Dart/Flutter Example
```dart
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ImageService {
  final String baseUrl = 'https://unmalted-alphonso-unpreponderated.ngrok-free.dev';
  
  // Upload image
  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/admin/foods/upload-image');
      final request = http.MultipartRequest('POST', uri);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          // Return imageUrl for fetching later
          return data['imageUrl']; // e.g., "/api/admin/foods/image/uuid.jpg"
        } else {
          throw Exception(data['message']);
        }
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message']);
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
  
  // Get image URL - to display in UI
  String getImageUrl(String imagePathFromResponse) {
    // imagePathFromResponse is the imageUrl returned from upload
    // e.g., "/api/admin/foods/image/uuid.jpg"
    return '$baseUrl$imagePathFromResponse';
  }
  
  // Example usage
  void example() async {
    File imageFile = File('/path/to/image.jpg');
    
    // 1. Upload image
    String imageUrl = await uploadImage(imageFile);
    // imageUrl = "/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg"
    
    // 2. Get full URL for display
    String fullUrl = getImageUrl(imageUrl);
    // fullUrl = "https://ngrok-url/api/admin/foods/image/550e8400-e29b-41d4-a716-446655440000.jpg"
    
    // 3. Use in Image widget
    // Image.network(fullUrl)
  }
}
```

### API Call Flow
```
1. User selects image file
   ↓
2. Frontend calls: POST /api/admin/foods/upload-image
   ├─ Send: multipart/form-data with file
   └─ Receive: { imageUrl: "/api/admin/foods/image/uuid.jpg" }
   ↓
3. Store imageUrl in database or state
   ↓
4. When displaying image:
   - Convert to full URL: baseUrl + imageUrl
   - Call: GET /api/admin/foods/image/uuid.jpg
   - Display binary image data
```

---

## 4. Important Notes

### ⚠️ CRITICAL: Use imageUrl from Upload Response
When uploading, backend returns:
```json
{
  "imageUrl": "/api/admin/foods/image/uuid.jpg",
  ...
}
```

**DO NOT** use `/uploads/foods/` path directly:
- ❌ WRONG: `/uploads/foods/uuid.jpg` (won't work with ngrok)
- ✅ CORRECT: `/api/admin/foods/image/uuid.jpg` (works with ngrok)

### Image Serving
- Images are served via API endpoint `/api/admin/foods/image/{filename}`
- This works with ngrok tunnel (static files from `/uploads/` don't)
- No authentication required for image retrieval
- Content-Type is automatically detected from file extension

### File Validation
- Extension check: jpg, jpeg, png, gif, bmp, webp
- Size limit: 5 MB
- Empty files rejected
- Path traversal attacks prevented

### Content-Type Handling
- If client doesn't send Content-Type, backend accepts it
- File extension is the primary validation method
- Content-Type is optional but supported

---

## 5. Troubleshooting

### Error: "File phải là hình ảnh"
**Cause:** Invalid file extension or no file provided
**Solution:** 
- Verify file has correct extension (.jpg, .png, etc.)
- Check file is not empty
- Ensure form parameter name is "file"

### Error: "Kích thước file không được vượt quá 5MB"
**Cause:** File is larger than 5 MB
**Solution:** Compress image or use smaller file

### Error: "Không thể lấy dữ liệu từ server"
**Cause:** 
- ngrok tunnel is down
- Wrong base URL
- Network connection issue
**Solution:**
- Check ngrok is running: `ngrok http 8080`
- Verify base URL is correct
- Check network connectivity

### Image displays as 404
**Cause:** Using wrong image path
**Solution:**
- Use imageUrl from upload response
- Don't use `/uploads/foods/` path directly
- Use full URL: `baseUrl + imageUrl`

---

## 6. Environment Configuration

### Development
```dart
const String API_BASE_URL = 'http://localhost:8080';
```

### Production (with ngrok)
```dart
const String API_BASE_URL = 'https://unmalted-alphonso-unpreponderated.ngrok-free.dev';
```

### Dynamic (from config)
```dart
class Config {
  static const String API_BASE_URL = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:8080');
}
```

---

## API Summary Table

| Operation | Method | Endpoint | Purpose |
|-----------|--------|----------|---------|
| Upload Image | POST | `/api/admin/foods/upload-image` | Upload hình ảnh mới |
| Get Image | GET | `/api/admin/foods/image/{filename}` | Lấy hình ảnh để display |

---

## Version
- **Version:** 1.0
- **Last Updated:** December 4, 2025
- **Backend:** Spring Boot 3.4.5 + Java 17
- **Framework:** Spring WebFlux + Multipart Upload

---

## Contact
For issues or questions about this API, contact backend team.
