# API Documentation - FoodHKD

## Base URL
```
http://localhost:8080/api
```

---

## 📋 Authentication Endpoints

### 1. Login
**Endpoint:** `POST /client/auth/login`

**Description:** Đăng nhập tài khoản khách hàng

**Request Body:**
```json
{
  "username": "user123",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": 1,
  "username": "user123",
  "role": "Customer",
  "fullName": "John Doe",
  "createdAt": "2025-12-04T10:30:00"
}
```

**Response (Error - 401):**
```json
{
  "error": "Tài khoản không tồn tại"
}
```

---

### 2. Register
**Endpoint:** `POST /client/auth/register`

**Description:** Đăng ký tài khoản khách hàng mới

**Request Body:**
```json
{
  "username": "newuser",
  "password": "password123",
  "fullName": "Jane Doe"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "userId": 2,
  "username": "newuser",
  "role": "Customer",
  "fullName": "Jane Doe",
  "createdAt": "2025-12-04T10:30:00"
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "message": "Username đã tồn tại"
}
```

---

## 🍕 Menu/Food Endpoints

### 1. Get All Food Items
**Endpoint:** `GET /foods` hoặc `GET /client/menu`

**Description:** Lấy danh sách tất cả món ăn

**Response (Success - 200):**
```json
{
  "success": true,
  "foods": [
    {
      "foodId": 1,
      "name": "Pizza Margherita",
      "description": "Bánh pizza kinh điển",
      "price": 150000,
      "quantity": 50,
      "category": "Pizza",
      "imageUrl": "https://example.com/pizza.jpg"
    }
  ]
}
```

---

### 2. Get Food by ID
**Endpoint:** `GET /foods/{foodId}`

**Response (Success - 200):**
```json
{
  "foodId": 1,
  "name": "Pizza Margherita",
  "description": "Bánh pizza kinh điển",
  "price": 150000,
  "quantity": 50,
  "category": "Pizza",
  "imageUrl": "https://example.com/pizza.jpg"
}
```

---

## 🎟️ Coupon Endpoints

### 1. Validate Coupon (WITHOUT creating order)
**Endpoint:** `POST /coupons/validate`

**Description:** Validate mã giảm giá và kiểm tra điều kiện (KHÔNG tạo đơn hàng)

**Request Body:**
```json
{
  "code": "SALE20"
}
```

**Response (Valid - 200):**
```json
{
  "valid": true,
  "message": "Mã giảm giá hợp lệ",
  "discountPercent": 20,
  "couponId": 1,
  "code": "SALE20",
  "expiryDate": "2025-12-31T23:59:59"
}
```

**Response (Invalid - 200):**
```json
{
  "valid": false,
  "message": "Mã giảm giá đã hết hạn",
  "discountPercent": 0
}
```

**Lỗi có thể trả về:**
- `"Mã giảm giá không được để trống"`
- `"Mã giảm giá không tồn tại"`
- `"Mã giảm giá không còn hiệu lực"`
- `"Mã giảm giá đã hết hạn"`
- `"Mã giảm giá đã hết lượt sử dụng"`

---

## 🛒 Order Endpoints

### 1. Calculate Order Total (WITH coupon)
**Endpoint:** `POST /orders/calculate`

**Description:** Tính toán tổng giá đơn hàng và áp dụng mã giảm giá (KHÔNG tạo đơn hàng)
**Use Case:** Khi khách nhấn nút "Áp dụng mã giảm giá"

**Request Body:**
```json
{
  "items": [
    {
      "foodId": 1,
      "foodName": "Pizza Margherita",
      "quantity": 2,
      "priceAtOrderTime": 150000,
      "imageUrl": "https://example.com/pizza.jpg"
    },
    {
      "foodId": 2,
      "foodName": "Coca Cola",
      "quantity": 2,
      "priceAtOrderTime": 25000,
      "imageUrl": "https://example.com/coca.jpg"
    }
  ],
  "couponCode": "SALE20"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Tính toán đơn hàng thành công",
  "subtotal": 350000,
  "discountPercent": 20,
  "discountAmount": 70000,
  "total": 280000,
  "couponCode": "SALE20"
}
```

**Response (Invalid Coupon - 400):**
```json
{
  "success": false,
  "message": "Mã giảm giá không tồn tại",
  "subtotal": 350000,
  "discountAmount": 0,
  "total": 350000
}
```

**Notes:**
- `couponCode` là optional
- Nếu không có `couponCode`, `discountPercent` = 0, `discountAmount` = 0
- Phản hồi trước khi tạo đơn hàng, để frontend hiển thị thông tin

---

### 2. Create Order
**Endpoint:** `POST /orders`

**Description:** Tạo đơn hàng mới (CHỈ gọi sau khi khách xác nhận)
**Use Case:** Khi khách nhấn nút "Xác nhận đơn hàng"

**Request Body:**
```json
{
  "customerId": 1,
  "customerName": "John Doe",
  "phone": "0123456789",
  "items": [
    {
      "foodId": 1,
      "foodName": "Pizza Margherita",
      "quantity": 2,
      "priceAtOrderTime": 150000,
      "imageUrl": "https://example.com/pizza.jpg"
    }
  ],
  "couponCode": "SALE20",
  "notes": "Vui lòng cắt nhỏ thành từng miếng"
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "Đơn hàng được tạo thành công",
  "orderId": 5,
  "order": {
    "orderId": 5,
    "customerId": 1,
    "customerName": "John Doe",
    "phone": "0123456789",
    "notes": "Vui lòng cắt nhỏ thành từng miếng",
    "total": 280000,
    "status": "Pending",
    "couponCode": "SALE20",
    "discountAmount": 70000,
    "discountPercent": 20,
    "createdAt": "2025-12-04T15:45:30",
    "updatedAt": "2025-12-04T15:45:30",
    "items": [
      {
        "itemId": 10,
        "foodId": 1,
        "foodName": "Pizza Margherita",
        "quantity": 2,
        "priceAtOrderTime": 150000,
        "status": "Active",
        "imageUrl": "https://example.com/pizza.jpg"
      }
    ]
  }
}
```

---

### 3. Get All Orders
**Endpoint:** `GET /orders`

**Description:** Lấy danh sách tất cả đơn hàng

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Danh sách tất cả đơn hàng",
  "orders": [
    {
      "orderId": 5,
      "customerId": 1,
      "customerName": "John Doe",
      "phone": "0123456789",
      "total": 280000,
      "status": "Pending",
      "createdAt": "2025-12-04T15:45:30"
    }
  ],
  "total": 1
}
```

---

### 4. Get Order by ID
**Endpoint:** `GET /orders/{orderId}`

**Description:** Lấy chi tiết đơn hàng

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Chi tiết đơn hàng",
  "order": {
    "orderId": 5,
    "customerId": 1,
    "customerName": "John Doe",
    "phone": "0123456789",
    "notes": "Vui lòng cắt nhỏ thành từng miếng",
    "total": 280000,
    "status": "Pending",
    "couponCode": "SALE20",
    "discountAmount": 70000,
    "discountPercent": 20,
    "items": [...]
  }
}
```

---

### 5. Get Orders by Customer ID
**Endpoint:** `GET /orders/customer/{customerId}`

**Description:** Lấy tất cả đơn hàng của một khách hàng

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Danh sách đơn hàng của khách hàng",
  "orders": [...],
  "total": 3
}
```

---

### 6. Get Orders by Status
**Endpoint:** `GET /orders/status/{status}`

**Description:** Lọc đơn hàng theo trạng thái

**Status Values:** `Pending`, `Preparing`, `Ready`, `Served`, `Cancelled`

**Example:** `GET /orders/status/Pending`

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Đơn hàng theo trạng thái: Pending",
  "orders": [...],
  "total": 2
}
```

---

### 7. Cancel Order Item
**Endpoint:** `PUT /orders/{orderId}/items/{itemId}/cancel`

**Description:** Hủy một sản phẩm trong đơn hàng

**Request Body:**
```json
{
  "reason": "Đổi ý"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Item được hủy thành công",
  "item": {
    "itemId": 10,
    "foodId": 1,
    "foodName": "Pizza Margherita",
    "status": "Cancelled",
    "cancelReason": "Đổi ý"
  },
  "order": {...}
}
```

---

## 🔐 Authentication

**Tất cả endpoints (trừ `/auth/login` và `/auth/register`) cần Authorization Header:**

```
Authorization: Bearer <JWT_TOKEN>
```

**Ví dụ:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## ⚠️ Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Missing required fields"
}
```

### 401 Unauthorized
```json
{
  "error": "Tài khoản không tồn tại"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Đơn hàng không tìm thấy"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error: [error details]"
}
```

---

## 📊 Data Models

### Food Model
```json
{
  "foodId": 1,
  "name": "Pizza Margherita",
  "description": "Bánh pizza kinh điển",
  "price": 150000,
  "quantity": 50,
  "category": "Pizza",
  "imageUrl": "https://example.com/pizza.jpg"
}
```

### Coupon Model
```json
{
  "couponId": 1,
  "code": "SALE20",
  "discountPercent": 20,
  "expiryDate": "2025-12-31T23:59:59",
  "usageLimit": 100,
  "usageCount": 5,
  "isActive": true
}
```

### Order Model
```json
{
  "orderId": 5,
  "customerId": 1,
  "customerName": "John Doe",
  "phone": "0123456789",
  "notes": "Vui lòng cắt nhỏ thành từng miếng",
  "total": 280000,
  "status": "Pending",
  "couponCode": "SALE20",
  "discountAmount": 70000,
  "discountPercent": 20,
  "createdAt": "2025-12-04T15:45:30",
  "updatedAt": "2025-12-04T15:45:30",
  "items": [...]
}
```

### OrderItem Model
```json
{
  "itemId": 10,
  "foodId": 1,
  "foodName": "Pizza Margherita",
  "quantity": 2,
  "priceAtOrderTime": 150000,
  "status": "Active",
  "cancelReason": null,
  "imageUrl": "https://example.com/pizza.jpg"
}
```

---

## 🔄 Frontend Flow (Important!)

### **Scenario 1: Khách muốn áp dụng mã giảm giá**

1. Khách thêm sản phẩm vào giỏ hàng
2. Khách nhấn nút **"Áp dụng mã giảm giá"**
   - Call: `POST /orders/calculate`
   - Trả về: `subtotal`, `discountAmount`, `total`
   - **KHÔNG tạo đơn hàng**

3. Frontend hiển thị:
   - Tiền hàng: 350,000 ₫
   - Tiền giảm: -70,000 ₫
   - Tổng cộng: 280,000 ₫

4. Khách nhấn **"Xác nhận đơn hàng"**
   - Call: `POST /orders`
   - Trả về: `orderId` + chi tiết đơn hàng
   - **Lúc này mới tạo đơn hàng**

### **Scenario 2: Khách không sử dụng mã giảm giá**

1. Khách thêm sản phẩm vào giỏ hàng
2. Khách nhấn **"Xác nhận đơn hàng"** (bỏ qua bước áp dụng coupon)
   - Call: `POST /orders` (không có `couponCode`)
   - Trả về: `orderId` + chi tiết đơn hàng

---

## 🧪 Testing dengan Postman

### Import Collection
1. Mở Postman
2. Import file `FoodHKD_API.postman_collection.json`
3. Set `base_url` environment variable = `http://localhost:8080/api`
4. Set `token` environment variable sau khi login

### Test Sequence
```
1. POST /client/auth/register → Lấy user mới
2. POST /client/auth/login → Lấy JWT token
3. GET /foods → Xem menu
4. POST /orders/calculate → Tính toán với coupon
5. POST /orders → Tạo đơn hàng
6. GET /orders/{orderId} → Xem chi tiết đơn hàng
```

---

## 📝 Notes

- Tất cả thời gian sử dụng format ISO 8601: `YYYY-MM-DDTHH:mm:ss`
- Currency là VND (Việt Nam Đồng)
- `discountPercent` là số nguyên (0-100)
- `status` của order: `Pending`, `Preparing`, `Ready`, `Served`, `Cancelled`
- `status` của item: `Active`, `Cancelled`

---

## 📞 Support

Nếu có vấn đề, liên hệ backend team hoặc kiểm tra console log.

---

**Last Updated:** 2025-12-04  
**Version:** 1.0
