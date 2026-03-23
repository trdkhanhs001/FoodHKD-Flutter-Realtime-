# 🍔 FoodHKD API Documentation - Ngrok Production

**Base URL:** `https://unmalted-alphonso-unpreponderated.ngrok-free.dev`

**Environment:** Production with Ngrok  
**Status:** ✅ Running  
**Version:** 1.0

---

## 📋 Table of Contents

1. [Authentication](#authentication)
2. [Coupons Management](#coupons-management)
3. [Online Orders](#online-orders)
4. [Payments (Momo)](#payments-momo)
5. [Error Handling](#error-handling)

---

## 🔐 Authentication

### POST /api/auth/login
**Login with username and password**

**Request:**
```json
{
  "username": "admin",
  "password": "123456"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "QuanLy",
  "userId": 1
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid username or password"
}
```

---

### POST /api/auth/register
**Register new user account**

**Request:**
```json
{
  "username": "newuser",
  "password": "password123",
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "KhachHang"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Registration successful",
  "userId": 5,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 🎫 Coupons Management

### GET /api/admin/coupons
**List all coupons (Admin only)**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "couponId": 1,
      "code": "SUMMER2025",
      "discountPercent": 20,
      "expiryDate": "2025-12-31",
      "usageLimit": 100,
      "usageCount": 15,
      "active": true
    },
    {
      "couponId": 2,
      "code": "WELCOME10",
      "discountPercent": 10,
      "expiryDate": "2025-12-25",
      "usageLimit": 50,
      "usageCount": 45,
      "active": true
    }
  ]
}
```

---

### POST /api/admin/coupons
**Create new coupon (Admin only)**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request:**
```json
{
  "code": "NEWYEAR2026",
  "discountPercent": 25,
  "expiryDate": "2026-01-31",
  "usageLimit": 200
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Coupon created successfully",
  "couponId": 3,
  "data": {
    "couponId": 3,
    "code": "NEWYEAR2026",
    "discountPercent": 25,
    "expiryDate": "2026-01-31",
    "usageLimit": 200,
    "usageCount": 0,
    "active": true
  }
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Coupon code already exists"
}
```

---

### PUT /api/admin/coupons/{couponId}
**Update existing coupon (Admin only)**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request:**
```json
{
  "discountPercent": 30,
  "expiryDate": "2026-02-15",
  "usageLimit": 250
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Coupon updated successfully",
  "data": {
    "couponId": 3,
    "code": "NEWYEAR2026",
    "discountPercent": 30,
    "expiryDate": "2026-02-15",
    "usageLimit": 250,
    "usageCount": 0,
    "active": true
  }
}
```

---

### DELETE /api/admin/coupons/{couponId}
**Delete coupon (Admin only)**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Coupon deleted successfully"
}
```

---

## 📦 Online Orders

### GET /api/online-orders
**List all online orders (Authenticated users)**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "orderId": 1,
      "userId": 2,
      "totalAmount": 450000,
      "discountAmount": 0,
      "finalAmount": 450000,
      "status": "Pending",
      "createdDate": "2025-12-03",
      "items": [
        {
          "itemId": 5,
          "quantity": 2,
          "price": 225000
        }
      ]
    }
  ]
}
```

---

### POST /api/online-orders
**Create new online order**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request:**
```json
{
  "items": [
    {
      "itemId": 5,
      "quantity": 2
    },
    {
      "itemId": 8,
      "quantity": 1
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Order created successfully",
  "orderId": 10,
  "totalAmount": 550000,
  "finalAmount": 550000
}
```

---

### POST /api/online-orders/{orderId}/apply-coupon
**Apply coupon code to order**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request:**
```json
{
  "couponCode": "SUMMER2025"
}
```

**Response (200 OK - Success):**
```json
{
  "success": true,
  "message": "Coupon applied successfully",
  "discountPercent": 20,
  "discountAmount": 90000,
  "originalAmount": 450000,
  "finalAmount": 360000
}
```

**Response (200 OK - Validation Error):**
```json
{
  "success": false,
  "message": "Coupon code not found",
  "discountAmount": 0,
  "finalAmount": 450000
}
```

**Possible Error Messages:**
- `"Coupon code not found"` - Code doesn't exist
- `"Coupon is expired"` - Coupon expiry date passed
- `"Coupon usage limit reached"` - All uses exhausted
- `"Coupon is inactive"` - Coupon disabled by admin

---

## 💳 Payments (Momo)

### POST /api/payments/momo/create-request
**Create Momo payment request**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request:**
```json
{
  "orderId": 10,
  "amount": 360000,
  "orderInfo": "Payment for order #10",
  "returnUrl": "https://yourapp.com/payment/callback",
  "notifyUrl": "https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/payments/momo/notify"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Payment request created",
  "paymentUrl": "https://payment.momo.vn/pay/...",
  "requestId": "1234567890",
  "amount": 360000,
  "transactionId": "TX_1234567890"
}
```

---

### POST /api/payments/momo/notify
**Webhook - Momo payment notification (DO NOT CALL DIRECTLY)**

*This endpoint is called by Momo service when payment is completed.*

**Response:**
```json
{
  "success": true,
  "message": "Payment notification processed"
}
```

---

### GET /api/payments/order/{orderId}
**Get payment information for order**

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orderId": 10,
    "amount": 360000,
    "paymentMethod": "Momo",
    "status": "Success",
    "transactionId": "TX_1234567890",
    "createdDate": "2025-12-03",
    "completedDate": "2025-12-03"
  }
}
```

---

## ❌ Error Handling

### Common HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| **200** | Success | Operation completed |
| **400** | Bad Request | Invalid input data |
| **401** | Unauthorized | Missing or invalid JWT token |
| **403** | Forbidden | User doesn't have permission |
| **404** | Not Found | Resource doesn't exist |
| **500** | Server Error | Internal server error |

### Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "error": "ErrorCode",
  "timestamp": 1764737782866
}
```

### Common Error Messages

```json
{
  "message": "Unauthorized - Invalid or expired token"
}
```

```json
{
  "message": "Forbidden - You don't have permission to access this resource"
}
```

```json
{
  "message": "User not found"
}
```

---

## 🔑 JWT Token Usage

All authenticated endpoints require JWT token in header:

```
Authorization: Bearer <your_jwt_token_here>
```

**Example with cURL:**
```bash
curl -X GET "https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/admin/coupons" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example with Flutter (Dart):**
```dart
final response = await http.get(
  Uri.parse('https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/admin/coupons'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
  },
);
```

---

## 🧪 Testing Endpoints

### Test Root Endpoint
```bash
curl -X GET "https://unmalted-alphonso-unpreponderated.ngrok-free.dev/"
```

### Test Login
```bash
curl -X POST "https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

### Test List Coupons (requires token)
```bash
curl -X GET "https://unmalted-alphonso-unpreponderated.ngrok-free.dev/api/admin/coupons" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📝 Notes for Frontend Development

1. **SSL Certificate:** Ngrok uses self-signed certificates. In Flutter, you need to bypass certificate validation (dev only):

```dart
class ApiService {
  static final HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  static Future<http.Response> get(String endpoint, String token) async {
    final request = http.Request('GET', Uri.parse('$baseUrl$endpoint'));
    request.headers['Authorization'] = 'Bearer $token';
    final streamedResponse = await httpClient.send(request);
    return http.Response.fromStream(streamedResponse);
  }
}
```

2. **Token Storage:** Store JWT token securely (flutter_secure_storage)

3. **Token Refresh:** Implement token refresh logic when expired

4. **Error Handling:** Always check `success` field in response

5. **Rate Limiting:** Be mindful of API rate limits

---

## 📞 Support

For issues or questions about the API:
- Check error messages returned in response
- Verify JWT token is valid
- Ensure required headers are present
- Check network connectivity

**API Status:** ✅ Running and ready for use!

---

**Generated:** December 3, 2025  
**Base URL:** https://unmalted-alphonso-unpreponderated.ngrok-free.dev  
**Version:** 1.0
