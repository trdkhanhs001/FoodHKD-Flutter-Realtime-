# Fix Ngrok Cache Issue - Hướng dẫn Chi Tiết

## 🔴 Vấn đề
Khi update code và chạy lại, Ngrok vẫn đưa ứng dụng cũ, không có update mới.

**Nguyên nhân:**
1. Java process cũ vẫn chạy ở background
2. Spring Boot cache hay artifact cũ
3. Browser cache phản ánh code cũ
4. Ngrok tunnel giữ kết nối cũ

---

## ✅ Giải pháp - Step by Step

### **Step 1: Dừng tất cả Process Hiện Tại**

#### Bước 1a: Tìm và Kill Java Process

**PowerShell Command:**
```powershell
# Xem tất cả Java processes
Get-Process | Where-Object { $_.ProcessName -like "*java*" }

# Nếu thấy nhiều process Java, kill chúng
Get-Process java | Stop-Process -Force
```

**Hoặc nếu dùng Windows GUI:**
1. Mở **Task Manager** (Ctrl + Shift + Esc)
2. Tìm **java.exe** hoặc **javaw.exe**
3. Click chuột phải → **End Task**

---

#### Bước 1b: Dừng Ngrok Tunnel

**PowerShell Command:**
```powershell
# Tìm Ngrok process
Get-Process | Where-Object { $_.ProcessName -like "*ngrok*" }

# Kill Ngrok
Get-Process ngrok | Stop-Process -Force
```

**Hoặc:**
- Tìm cửa sổ PowerShell/CMD chạy Ngrok
- Nhấn **Ctrl + C** để dừng

---

### **Step 2: Clean Build Artifacts**

**Command (PowerShell):**
```powershell
# Di chuyển đến thư mục project
cd d:\DACN\FoodHKD

# Xóa folder target (toàn bộ compiled files)
Remove-Item -Path ".\target" -Recurse -Force

# Xóa Spring Boot cache
Remove-Item -Path "$env:UserProfile\.m2\repository\com\example\FoodHKD" -Recurse -Force
```

**Hoặc dùng CMD:**
```cmd
cd d:\DACN\FoodHKD
rmdir /s /q target
```

---

### **Step 3: Rebuild Project**

**PowerShell Command:**
```powershell
# Rebuild từ đầu
mvn clean install -DskipTests
```

**Hoặc nếu dùng IDE (VS Code / IntelliJ):**
1. Mở Terminal in IDE
2. Chạy: `mvn clean install -DskipTests`
3. Chờ build xong (3-5 phút)

---

### **Step 4: Clear Browser Cache**

**Chrome/Edge:**
- Nhấn **Ctrl + Shift + Delete**
- Chọn **All time** → **Clear data**
- Reload trang hoặc Ctrl + F5

**Firefox:**
- Nhấn **Ctrl + Shift + Delete**
- Chọn **Everything** → **Clear Now**

---

### **Step 5: Khởi Động Spring Boot Application Mới**

**PowerShell Command:**
```powershell
# Chạy Spring Boot app
mvn spring-boot:run
```

**Hoặc chạy JAR file:**
```powershell
java -jar target/FoodHKD-0.0.1-SNAPSHOT.jar
```

**Chờ đến khi thấy:**
```
Tomcat started on port(s): 8080 (http)
Started FoodHkdApplication in X seconds
```

---

### **Step 6: Khởi Động Ngrok Tunnel Mới**

**PowerShell Command (mở window mới):**
```powershell
# Tạo Ngrok tunnel trỏ đến localhost:8080
ngrok http 8080
```

**Bạn sẽ thấy:**
```
ngrok (v3.x.x)

Session Status                online
Account                       <your_account>
Version                       3.x.x
Region                        us (United States)
Forwarding                    https://unmalted-alphonso-unpreponderated.ngrok-free.dev -> http://localhost:8080
```

---

## 🔄 Tóm tắt Flow (Dùng từng lần update code):

```
1. Kill Java & Ngrok
   ↓
2. mvn clean install -DskipTests  (rebuild)
   ↓
3. mvn spring-boot:run            (start new app)
   ↓
4. ngrok http 8080                (new tunnel)
   ↓
5. Clear browser cache (Ctrl + F5)
   ↓
6. Test link Ngrok
```

---

## ⚡ Shortcut Script - PowerShell (Tự động)

**Tạo file `restart-app.ps1`:**

```powershell
# Dừng toàn bộ process
Write-Host "🔴 Stopping Java & Ngrok..." -ForegroundColor Red
Get-Process java, ngrok -ErrorAction SilentlyContinue | Stop-Process -Force

# Clean build
Write-Host "🧹 Cleaning build artifacts..." -ForegroundColor Yellow
cd d:\DACN\FoodHKD
Remove-Item -Path ".\target" -Recurse -Force -ErrorAction SilentlyContinue

# Rebuild
Write-Host "🔨 Building project..." -ForegroundColor Cyan
mvn clean install -DskipTests

# Start app
Write-Host "🚀 Starting Spring Boot app..." -ForegroundColor Green
mvn spring-boot:run
```

**Chạy script:**
```powershell
& ".\restart-app.ps1"
```

---

## 🧪 Verification - Kiểm tra Update

### Cách 1: Check version/log

**Thêm vào code để verify:**

```java
// Trong FoodHkdApplication.java hoặc controller nào đó
@RestController
@RequestMapping("/api")
public class HealthController {
    
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "timestamp", LocalDateTime.now(),
            "version", "1.0.0-UPDATED",  // Thay đổi version này
            "message", "App is running with latest code"
        ));
    }
}
```

**Test:**
```
GET https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/health
```

**Response:**
```json
{
  "status": "UP",
  "timestamp": "2025-12-04T16:30:00",
  "version": "1.0.0-UPDATED",
  "message": "App is running with latest code"
}
```

---

### Cách 2: Check Database

Thêm 1 record mới vào database và kiểm tra xem API có return không.

---

### Cách 3: Check Logs

**Trong VS Code Terminal:**
```
✅ Nếu thấy "Started FoodHkdApplication in X seconds"
→ App đã restart thành công

❌ Nếu không thấy hoặc lỗi
→ Kiểm tra error messages ở logs
```

---

## 🔍 Troubleshooting

### Problem: Port 8080 đang bị chiếm
**Solution:**
```powershell
# Tìm process dùng port 8080
netstat -ano | findstr :8080

# Kill process (thay XXX bằng PID)
taskkill /PID XXX /F
```

---

### Problem: Ngrok connection timeout
**Solution:**
1. Kiểm tra Spring Boot app đã start không
2. Confirm port là 8080
3. Restart Ngrok tunnel

---

### Problem: Browser vẫn thấy code cũ
**Solution:**
```
1. Clear browser cache: Ctrl + Shift + Delete
2. Hard refresh: Ctrl + F5
3. Mở Incognito mode: Ctrl + Shift + N
4. Thay browser: dùng Firefox hoặc Safari
```

---

## 📝 Ngrok Configuration (Optional)

**Cấu hình Ngrok trong file config:**

Tạo file `ngrok.yml` tại `~\.ngrok2\ngrok.yml`:

```yaml
version: "2"
authtoken: your_auth_token_here
tunnels:
  foodhkd:
    proto: http
    addr: 8080
    bind_tls: true
```

**Chạy Ngrok với config:**
```powershell
ngrok start foodhkd
```

---

## ✨ Best Practice

**Mỗi lần update code, làm theo thứ tự:**

1. **Save file** (Ctrl + S)
2. **Kill Java** (taskkill hoặc ps command)
3. **Clean & Build** (mvn clean install -DskipTests)
4. **Start App** (mvn spring-boot:run)
5. **Wait for "Started"** log message
6. **Restart Ngrok** (nếu cần)
7. **Clear browser cache** (Ctrl + F5)
8. **Test link**

---

**Version:** 1.0  
**Updated:** 2025-12-04
