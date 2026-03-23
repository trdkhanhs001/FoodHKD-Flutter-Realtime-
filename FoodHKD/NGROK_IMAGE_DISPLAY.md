# 🌐 Ngrok + Image Display - Complete Guide

**Tình huống:** Dùng ngrok tunnel để test, nhưng lo lắng ảnh sẽ mất khi đổi mạng  
**Ngày:** 04/12/2025

---

## 🔍 Hiểu Rõ Ngrok Architecture

### Cách Ngrok Hoạt Động

```
┌─────────────────────────────────────────────────────────────┐
│ NGROK TUNNEL                                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Your Computer (Local)        Ngrok Servers (Cloud)        │
│  ┌──────────────────┐         ┌───────────────────┐        │
│  │ Spring Boot      │◄───────►│ https://your-url  │        │
│  │ :8080            │ Tunnel  │ .ngrok-free.dev  │        │
│  │                  │         │                   │        │
│  │ uploads/foods/   │         │ (Proxy to local)  │        │
│  │ ├─ uuid1.jpg     │         │                   │        │
│  │ ├─ uuid2.jpg     │         │                   │        │
│  │ └─ uuid3.jpg     │         │                   │        │
│  └──────────────────┘         └───────────────────┘        │
│       ▲                               ▲                     │
│       │                               │                     │
│   Real Device (Firebase/Device)       │                     │
│   Makes request to ngrok URL ────────┘                     │
│                                                              │
│   Request: GET https://your-url.ngrok-free.dev/api/...    │
│   Ngrok forwards to: GET http://localhost:8080/api/...    │
│   Response: Image data flows back through tunnel            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Key Points About Ngrok

### 1. **Ảnh Được Lưu LỬC NÀO?**
```
Khi upload ảnh:
  Frontend (Device) 
    → POST to ngrok URL (https://xxx.ngrok-free.dev/api/admin/foods/upload-image)
    → Ngrok tunnel forwards to (http://localhost:8080/api/admin/foods/upload-image)
    → Backend saves to disk: uploads/foods/uuid.jpg
    → Backend returns: imageUrl = "/api/admin/foods/image/uuid.jpg"

✅ Ảnh lưu TRÊN MÁY TÍNH CỦA BẠN (uploads/foods/ folder)
✅ KHÔNG lưu trên cloud, không phụ thuộc ngrok URL
```

### 2. **Khi Hiển Thị Ảnh**
```
Frontend requests image:
  GET https://xxx.ngrok-free.dev/api/admin/foods/image/uuid.jpg
    → Ngrok tunnel forwards to:
  GET http://localhost:8080/api/admin/foods/image/uuid.jpg
    → Backend reads from disk: uploads/foods/uuid.jpg
    → Return binary image data
    → Image displays on device

✅ Ảnh vẫn được lấy từ MÁY TÍNH (upload/foods/)
✅ Miễn là máy tính vẫn chạy backend + ngrok tunnel
✅ Không phụ thuộc vào mạng WiFi của device
```

### 3. **Vậy Khi Đổi Mạng WiFi Sao?**

**Scenario A: Device đổi WiFi (device khác network)**
```
TRƯỚC:
  Device (WiFi A)
    → Ngrok URL (https://xxx.ngrok-free.dev)
    → Image loads ✅

SAU ĐỔI (Device WiFi B):
  Device (WiFi B)  
    → Ngrok URL (https://xxx.ngrok-free.dev) - VẪN HOẠT ĐỘNG ✅
    → Vì ngrok URL là INTERNET-BASED, không phụ thuộc vào local network

✅ KHÔNG mất ảnh - ngrok URL vẫn có hiệu lực
```

**Scenario B: Máy tính (backend) đổi mạng**
```
TRƯỚC:
  Backend chạy ngrok tunnel
    → Generate ngrok URL: https://xxx-123.ngrok-free.dev
    → Device connect tới URL này ✅

SAU ĐỔI MẠG (Computer khác WiFi):
  ❌ Ngrok connection mất
  ❌ Ngrok sẽ generate URL MỚI: https://xxx-456.ngrok-free.dev
  ❌ Old URL không hoạt động nữa
  ❌ Device phải update URL mới

✅ NHƯNG: Ảnh trên disk KHÔNG mất - vẫn ở uploads/foods/
✅ Chỉ cần update ngrok URL, tất cả ảnh cũ vẫn load được
```

---

## 🎯 Architecture Recommendation

### **BEST PRACTICE: Dùng Ngrok URL**

```dart
class ImageService {
  // ✅ BEST: Dùng ngrok (hoạt động qua mạng)
  static const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
  
  // ❌ NOT RECOMMENDED: IP local
  // static const String baseUrl = 'http://192.168.1.100:8080';
  // - Chỉ hoạt động khi device cùng WiFi
  // - Khi đổi WiFi: không connect được
}
```

### **Why Ngrok is Better:**
| Aspect | Local IP | Ngrok URL |
|--------|----------|-----------|
| **Device cùng WiFi** | ✅ Works | ✅ Works |
| **Device khác WiFi** | ❌ Fails | ✅ Works |
| **4G/Mobile Data** | ❌ Fails | ✅ Works |
| **Đổi mạng Wi-Fi** | ❌ Mất kết nối | ✅ Vẫn hoạt động |
| **URL ổn định** | N/A | ⚠️ Thay đổi khi restart |

---

## 🔧 How to Handle Ngrok URL Changes

### Problem: Ngrok URL thay đổi sau mỗi restart

```bash
# Lần 1 start ngrok
ngrok http 8080
# URL: https://abc-123-456.ngrok-free.dev

# Sau khi close/restart
ngrok http 8080
# URL: https://xyz-789-000.ngrok-free.dev ← URL MỚI!
```

### Solution 1: Use Ngrok Static Subdomain (PAID)
```
Ngrok Pro Account:
  $ ngrok config add-authtoken <token>
  $ ngrok http --domain=your-reserved-domain.ngrok-free.dev 8080
  
Result: URL KHÔNG THAY ĐỔI sau mỗi restart ✅
```

### Solution 2: Config File for Easy Update
```dart
// lib/config/api_config.dart

class ApiConfig {
  // ❌ WRONG: Hardcode URL
  // static const String baseUrl = 'https://abc-123.ngrok-free.dev';
  
  // ✅ BETTER: Store in file easy to update
  static const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
  
  // ✅ BEST: Read from config file (for production)
  // static String baseUrl = getBaseUrlFromConfig();
}

// Usage:
ImageService.baseUrl = ApiConfig.baseUrl;
```

### Solution 3: Store URL in Database
```
When device starts:
  1. Device requests: GET https://fixed-url/api/config
  2. Backend returns: { "imageBaseUrl": "https://current-ngrok-url.ngrok-free.dev" }
  3. Device stores in localStorage
  4. All image requests use this URL

Benefit: Automatic URL update after backend restart ✅
```

---

## 📱 Complete Dart Implementation

### For Ngrok Setup:

```dart
// lib/config/image_service.dart

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ImageService {
  // ✅ Use ngrok URL for cross-network support
  // ⚠️ Update this when ngrok URL changes
  static String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
  
  /// Set base URL dynamically (when ngrok URL changes)
  static void setBaseUrl(String url) {
    baseUrl = url;
    print('🌐 Base URL updated: $baseUrl');
  }
  
  /// Get base URL from backend config (RECOMMENDED)
  static Future<void> initializeBaseUrl() async {
    try {
      // This requires backend to have a config endpoint
      // GET /api/config → returns { baseUrl: "https://xxx.ngrok-free.dev" }
      final response = await http.get(
        Uri.parse('$baseUrl/api/config'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setBaseUrl(data['baseUrl']);
        print('✅ Base URL initialized from server');
      }
    } catch (e) {
      print('⚠️ Could not initialize base URL from server: $e');
      // Use hardcoded URL as fallback
    }
  }

  /// Upload image
  static Future<String> uploadImage(File imageFile) async {
    try {
      print('🚀 Starting upload to: $baseUrl');
      
      final uri = Uri.parse('$baseUrl/api/admin/foods/upload-image');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      final response = await request.send().timeout(Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          final imageUrl = data['imageUrl'];
          print('✅ Upload successful: $imageUrl');
          return imageUrl;
        }
      }
      throw Exception('Upload failed');
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  /// Get full image URL
  static String getFullImageUrl(String? anhValue) {
    if (anhValue == null || anhValue.isEmpty) return '';
    if (anhValue.startsWith('http')) return anhValue;
    return '$baseUrl$anhValue';
  }
}
```

### Initialize in main():

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize base URL when app starts
  await ImageService.initializeBaseUrl();
  
  runApp(MyApp());
}
```

---

## 🌐 Backend Config Endpoint (Optional)

**File:** `FoodAdminRest.java`

```java
@GetMapping("/config")
public ResponseEntity<Map<String, String>> getConfig() {
    try {
        Map<String, String> config = new HashMap<>();
        
        // Return current ngrok URL or server URL
        // You need to set this via environment variable or config file
        String baseUrl = System.getenv("API_BASE_URL");
        if (baseUrl == null) {
            baseUrl = "https://your-default-ngrok-url.ngrok-free.dev";
        }
        
        config.put("baseUrl", baseUrl);
        config.put("uploadDir", "uploads/foods/");
        
        return ResponseEntity.ok(config);
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}
```

---

## 📋 Workflow: Using Ngrok for Development

### Step 1: Start Backend
```bash
mvn spring-boot:run
# Backend runs on http://localhost:8080
```

### Step 2: Start Ngrok Tunnel
```bash
ngrok http 8080
# Ngrok generates URL: https://abc-123-456.ngrok-free.dev
```

### Step 3: Update Frontend BASE_URL
```dart
// lib/config/image_service.dart
static String baseUrl = 'https://abc-123-456.ngrok-free.dev';
```

### Step 4: Run Flutter App (on real device)
```bash
flutter run
# App connects via ngrok URL ✅
```

### Step 5: Upload & Display Images
```
Device (any network)
  → Upload image to: https://abc-123-456.ngrok-free.dev/api/admin/foods/upload-image
  → Backend saves to: D:\DACN\FoodHKD\uploads\foods\uuid.jpg
  → Database stores: anh = "/api/admin/foods/image/uuid.jpg"
  
Device displays:
  → GET https://abc-123-456.ngrok-free.dev/api/admin/foods/image/uuid.jpg
  → Ngrok forwards to backend
  → Backend reads from disk
  → Image displays ✅
```

---

## ⚠️ Important Notes About Images & Ngrok

### 1. **Images Persist Through Ngrok Restarts**
```
Scenario:
  Day 1: Upload 5 images via ngrok URL (v1)
  Restart Backend/Ngrok: New URL generated (v2)
  
Result:
  ✅ All 5 images still exist in uploads/foods/
  ✅ Database has records pointing to them
  ✅ Just update BASE_URL to new ngrok URL (v2)
  ✅ All old images display correctly
```

### 2. **Images Don't Depend on Ngrok URL**
```
Ngrok URL = Just a TUNNEL/PROXY
  - Forwards requests from internet to local backend
  - Doesn't store images
  - Doesn't affect stored images

Images are stored = On your computer disk
  - uploads/foods/uuid.jpg
  - Persist across ngrok restarts
  - Persist across URL changes
```

### 3. **When Do Images Get Lost?**
```
❌ When you DELETE the uploads/foods/ folder
❌ When you format/wipe computer
❌ When you move the entire project to different computer (without uploads/)

✅ They DO NOT get lost when:
  - Changing WiFi network (on device)
  - Restarting ngrok (generates new URL)
  - Restarting backend
  - Closing app and reopening
```

---

## 🔄 Switching Between Local IP and Ngrok

### When to Use Local IP:
```dart
// Inside home WiFi only
const baseUrl = 'http://192.168.1.100:8080';
```

### When to Use Ngrok:
```dart
// Need to test from outside WiFi
const baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
```

### Dynamic Switching:
```dart
class ImageService {
  static String baseUrl = '';
  
  static void initForLocalNetwork() {
    baseUrl = 'http://192.168.1.100:8080';
    print('🏠 Using local IP');
  }
  
  static void initForNgrok() {
    baseUrl = 'https://abc-123-456.ngrok-free.dev';
    print('🌐 Using ngrok');
  }
}

// Usage in main.dart
void main() {
  // Auto-detect or manual choice
  ImageService.initForNgrok();  // Use this for testing with device outside WiFi
  runApp(MyApp());
}
```

---

## ✅ Final Checklist

```
NGROK SETUP:
  ☐ Backend running: http://localhost:8080
  ☐ Ngrok tunnel started: ngrok http 8080
  ☐ Ngrok URL obtained: https://xxx.ngrok-free.dev
  
FRONTEND SETUP:
  ☐ ImageService.baseUrl = ngrok URL
  ☐ Model uses 'anh' field (not imageUrl)
  ☐ URL construction: baseUrl + anhValue
  ☐ Image.network has error handling
  
DATABASE:
  ☐ anh field stores: /api/admin/foods/image/uuid.jpg
  ☐ NOT full path like D:\...
  
TESTING:
  ☐ Upload image via device on WiFi A
  ☐ Device switches to WiFi B - images still display ✅
  ☐ Device uses 4G/mobile data - images still display ✅
  ☐ Backend restarts + ngrok generates new URL
    - Update ImageService.baseUrl
    - Old images still display ✅
```

---

## 🎯 Summary

| Question | Answer |
|----------|--------|
| **Ảnh có mất khi đổi mạng?** | ❌ KHÔNG - Ngrok URL vẫn hoạt động từ mạng khác |
| **Ảnh có mất khi restart backend?** | ❌ KHÔNG - Ảnh vẫn lưu trên disk |
| **Ảnh có mất khi ngrok URL thay đổi?** | ❌ KHÔNG - Chỉ cần update BASE_URL |
| **Nên dùng local IP hay ngrok?** | 🌐 **Ngrok** - Hoạt động từ bất kỳ mạng nào |
| **Cách update ngrok URL?** | 📝 Thay đổi `ImageService.baseUrl` hoặc dùng config endpoint |
| **Ảnh lưu ở đâu?** | 💾 `D:\DACN\FoodHKD\uploads\foods\` (máy tính) |

---

**Kết luận:** ✅ Dùng ngrok là safe choice. Ảnh sẽ KHÔNG mất dù device đổi mạng. Chỉ cần update BASE_URL khi ngrok URL thay đổi.

**Ngày:** 04/12/2025  
**Status:** ✅ Ready
