# 🔌 API Documentation - AI Chatbot Food Recommendation

## Base URL
```
http://your-api-server.com
```

## 📡 Endpoints

### 1. Create Chat Session
```
POST /api/chatbot/session/create

Query Parameters:
- userId: Integer (required) - User ID
- sessionName: String (optional) - Session name, default: "Chat Session - [timestamp]"

Response (200 OK):
{
  "id": 1,
  "userId": 1,
  "sessionName": "Chat Session - 2024-12-07T10:30:00",
  "createdAt": "2024-12-07T10:30:00",
  "updatedAt": "2024-12-07T10:30:00",
  "isActive": true,
  "messageCount": 0
}

Error (400):
{
  "error": "User not found"
}
```

### 2. Send Chat Message & Get Bot Response
```
POST /api/chatbot/message

Request Body:
{
  "message": "Gợi ý cho tôi một món cay",
  "userId": 1,
  "sessionId": 1,
  "preferences": "Tôi thích ăn cay" (optional)
}

Response (200 OK):
{
  "id": 1,
  "userId": 1,
  "messageContent": "Dựa trên sở thích của bạn, tôi gợi ý:\n\n1. **Mì cay Thái** (120000 đ)\n   📍 Mì/Pasta\n   💭 Là món ăn cay như bạn yêu thích\n\nBạn có thích các gợi ý này không? 😋",
  "isBotResponse": true,
  "createdAt": "2024-12-07T10:30:05",
  "messageType": "bot"
}

Error (400):
{
  "error": "Session ID and message are required"
}
```

### 3. Get Chat History
```
GET /api/chatbot/session/{sessionId}/history

Path Parameters:
- sessionId: Long (required) - Chat session ID

Response (200 OK):
[
  {
    "id": 2,
    "userId": 1,
    "messageContent": "Dựa trên sở thích của bạn...",
    "isBotResponse": true,
    "createdAt": "2024-12-07T10:30:05",
    "messageType": "bot"
  },
  {
    "id": 1,
    "userId": 1,
    "messageContent": "Gợi ý cho tôi một món cay",
    "isBotResponse": false,
    "createdAt": "2024-12-07T10:30:00",
    "messageType": "user"
  }
]

Error (500):
{
  "error": "Failed to get chat history: [error message]"
}
```

### 4. Get User's Chat Sessions
```
GET /api/chatbot/user/{userId}/sessions

Path Parameters:
- userId: Integer (required) - User ID

Response (200 OK):
[
  {
    "id": 1,
    "userId": 1,
    "sessionName": "Chat with AI",
    "createdAt": "2024-12-07T09:00:00",
    "updatedAt": "2024-12-07T10:30:00",
    "isActive": true,
    "messageCount": 15
  },
  {
    "id": 2,
    "userId": 1,
    "sessionName": "Food Recommendations",
    "createdAt": "2024-12-07T10:00:00",
    "updatedAt": "2024-12-07T10:45:00",
    "isActive": true,
    "messageCount": 8
  }
]

Error (500):
{
  "error": "Failed to get sessions: [error message]"
}
```

### 5. Get Food Recommendations
```
POST /api/chatbot/recommendations

Request Body:
{
  "message": "Tôi muốn ăn hải sản",
  "userId": 1,
  "preferences": "Không cay, tươi ngon" (optional)
}

Response (200 OK):
{
  "recommendations": [
    {
      "foodId": 5,
      "foodName": "Tôm nước dừa",
      "description": "Tôm tươi nấu trong nước dừa...",
      "price": 180000,
      "imagePath": "/uploads/foods/tom_nuoc_dua.jpg",
      "category": "Hải sản",
      "reason": "Khớp với tìm kiếm của bạn",
      "matchScore": 95.0
    },
    {
      "foodId": 6,
      "foodName": "Cua hấp bia",
      "description": "Cua tươi hấp với bia...",
      "price": 250000,
      "imagePath": "/uploads/foods/cua_hap_bia.jpg",
      "category": "Hải sản",
      "reason": "Món ăn đặc biệt",
      "matchScore": 85.0
    }
  ],
  "count": 2
}

Error (500):
{
  "error": "Failed to get recommendations: [error message]"
}
```

### 6. Close Chat Session
```
POST /api/chatbot/session/{sessionId}/close

Path Parameters:
- sessionId: Long (required) - Chat session ID

Response (200 OK):
{
  "id": 1,
  "userId": 1,
  "sessionName": "Chat Session",
  "createdAt": "2024-12-07T10:30:00",
  "updatedAt": "2024-12-07T10:45:00",
  "isActive": false,
  "messageCount": 5
}

Error (500):
{
  "error": "Failed to close session: [error message]"
}
```

### 7. ChatBot Health Check
```
GET /api/chatbot/health

Response (200 OK):
{
  "status": "ChatBot Service is running"
}
```

---

## 🔌 WebSocket Connection

### Connection URL
```
WS ws://your-api-server.com/ws/chatbot
WSS wss://your-api-server.com/ws/chatbot (for production)
```

### Message Format
```
Send (Client to Server):
{
  "message": "Gợi ý cho tôi một món",
  "userId": 1,
  "sessionId": 1,
  "preferences": "Tôi yêu thích hải sản" (optional)
}

Receive (Server to Client):
{
  "id": 1,
  "userId": 1,
  "messageContent": "Dựa trên sở thích của bạn...",
  "isBotResponse": true,
  "createdAt": "2024-12-07T10:30:05",
  "messageType": "bot"
}

Error:
{
  "error": "Error message here",
  "timestamp": 1701934205000
}
```

### WebSocket Lifecycle
```
1. Client connects to /ws/chatbot
2. Client sends first message with sessionId
3. Server processes and sends response
4. Client & Server keep connection open for real-time updates
5. Client can send multiple messages
6. Client closes connection when session ends
```

---

## 🔐 Authentication (Optional)

Nếu backend yêu cầu authentication, thêm header:
```
Authorization: Bearer <token>
Content-Type: application/json
```

---

## 📊 Data Types

### ChatMessage
```dart
{
  "id": Long,
  "userId": Integer,
  "messageContent": String,
  "isBotResponse": Boolean,
  "createdAt": DateTime (ISO 8601),
  "messageType": String ("user" | "bot" | "recommendation")
}
```

### ChatSession
```dart
{
  "id": Long,
  "userId": Integer,
  "sessionName": String,
  "createdAt": DateTime (ISO 8601),
  "updatedAt": DateTime (ISO 8601),
  "isActive": Boolean,
  "messageCount": Integer
}
```

### FoodRecommendation
```dart
{
  "foodId": Long,
  "foodName": String,
  "description": String,
  "price": Double,
  "imagePath": String,
  "category": String,
  "reason": String,
  "matchScore": Double (0-100)
}
```

---

## 🧪 Testing APIs

### Using cURL

#### Create Session
```bash
curl -X POST "http://localhost:8080/api/chatbot/session/create?userId=1&sessionName=My%20Chat" \
  -H "Content-Type: application/json"
```

#### Send Message
```bash
curl -X POST "http://localhost:8080/api/chatbot/message" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Gợi ý cho tôi một món cay",
    "userId": 1,
    "sessionId": 1,
    "preferences": "Tôi thích ăn cay"
  }'
```

#### Get Chat History
```bash
curl -X GET "http://localhost:8080/api/chatbot/session/1/history" \
  -H "Content-Type: application/json"
```

#### Get User Sessions
```bash
curl -X GET "http://localhost:8080/api/chatbot/user/1/sessions" \
  -H "Content-Type: application/json"
```

#### Get Recommendations
```bash
curl -X POST "http://localhost:8080/api/chatbot/recommendations" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Tôi muốn ăn hải sản",
    "userId": 1
  }'
```

#### Close Session
```bash
curl -X POST "http://localhost:8080/api/chatbot/session/1/close" \
  -H "Content-Type: application/json"
```

### Using Postman
1. Import collection từ backend (nếu có)
2. Set environment variables: `base_url`, `userId`, `sessionId`
3. Test từng endpoint theo thứ tự
4. Kiểm tra response format

### Using Dio (Flutter)
```dart
final dio = Dio(BaseOptions(baseUrl: 'http://your-api.com'));

// POST request
final response = await dio.post('/api/chatbot/message', data: {
  'message': 'Gợi ý cho tôi',
  'userId': 1,
  'sessionId': 1,
});

// GET request
final response = await dio.get('/api/chatbot/user/1/sessions');
```

---

## ⚠️ Common Errors

| Error Code | Message | Solution |
|-----------|---------|----------|
| 400 | "Session ID and message are required" | Ensure sessionId và message in request |
| 400 | "User not found" | Kiểm tra userId có tồn tại |
| 500 | "Failed to process message" | Check backend logs |
| WebSocket | Connection refused | Check WebSocket server running |
| WebSocket | Message format error | Check JSON format của message |

---

## 🚀 Rate Limiting & Best Practices

- Max requests: 100 per minute
- WebSocket: 1 connection per user
- Message size: Max 5000 characters
- Retry failed requests với exponential backoff
- Cache responses khi possible
- Implement request timeout: 30 seconds

---

## 📝 Notes

- Timestamps sử dụng ISO 8601 format
- Tất cả prices tính bằng VND (Việt Nam Đồng)
- Images served từ `/uploads/foods/` directory
- Bot responses có thể chứa Markdown formatting
- Tất cả user IDs phải valid trong database

---

**Last Updated:** December 7, 2024
**Version:** 1.0
**Author:** Backend Team
