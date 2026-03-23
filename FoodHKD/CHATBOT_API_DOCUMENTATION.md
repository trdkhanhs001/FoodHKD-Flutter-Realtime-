# AI ChatBot - Gợi ý Món Ăn

## Tổng Quan
AI ChatBot là một hệ thống trợ lý thông minh giúp khách hàng khám phá và gợi ý các món ăn phù hợp với sở thích của họ. Hệ thống này sử dụng xử lý ngôn ngữ tự nhiên để hiểu ý định của người dùng và cung cấp các gợi ý được cá nhân hóa.

## Tính Năng Chính

### 1. **Gợi ý Cá nhân Hóa**
- Phân tích sở thích của khách hàng dựa trên tin nhắn của họ
- Gợi ý các món ăn phù hợp với mức giá, loại thực phẩm, và hương vị
- Cung cấp lý do tại sao mỗi món ăn được gợi ý

### 2. **Chat History**
- Lưu lại lịch sử tất cả các cuộc trò chuyện
- Cho phép người dùng quay lại các cuộc trò chuyện trước đó
- Phân tích các cuộc trò chuyện để cải thiện gợi ý

### 3. **Real-time Communication**
- Hỗ trợ WebSocket cho chat real-time
- Tương tác ngay lập tức với bot
- Broadcast message cho nhiều người dùng

### 4. **Multi-Session Support**
- Mỗi người dùng có thể tạo nhiều session chat
- Quản lý các session một cách dễ dàng
- Đóng session khi không cần thiết nữa

## Kiến Trúc Hệ Thống

```
Frontend (Flutter/Web)
        |
        ├─ REST API (/api/chatbot/*)
        |
        └─ WebSocket (/api/ws/chatbot)
        
        |
        ├─ ChatBotController
        |
        ├─ ChatBotService
        |     ├─ createChatSession()
        |     ├─ processUserMessage()
        |     ├─ getRecommendedFoods()
        |     └─ getUserChatSessions()
        |
        ├─ ChatBotWebSocketHandler
        |     └─ Real-time message handling
        |
        ├─ Repository Layer
        |     ├─ ChatSessionRepository
        |     └─ ChatMessageRepository
        |
        └─ Database
              ├─ chat_sessions
              └─ chat_messages
```

## REST API Endpoints

### 1. **Tạo Session Chat Mới**
```
POST /api/chatbot/session/create
Parameters:
  - userId (Integer, required): ID của người dùng
  - sessionName (String, optional): Tên của session

Response:
{
  "id": 1,
  "userId": 5,
  "sessionName": "Chat Session - 2024-12-07T10:30:00",
  "createdAt": "2024-12-07T10:30:00",
  "updatedAt": "2024-12-07T10:30:00",
  "isActive": true,
  "messageCount": 0
}
```

### 2. **Gửi Tin Nhắn**
```
POST /api/chatbot/message
Body:
{
  "message": "Gợi ý cho tôi một món cay",
  "userId": 5,
  "sessionId": 1,
  "preferences": "cay, không cay quá"
}

Response:
{
  "id": 1,
  "messageContent": "Dựa trên sở thích của bạn, tôi gợi ý:...",
  "isBotResponse": true,
  "createdAt": "2024-12-07T10:30:15",
  "messageType": "bot"
}
```

### 3. **Lấy Lịch Sử Chat**
```
GET /api/chatbot/session/{sessionId}/history

Response:
[
  {
    "id": 1,
    "messageContent": "Gợi ý cho tôi một món cay",
    "isBotResponse": false,
    "createdAt": "2024-12-07T10:30:00",
    "messageType": "user"
  },
  {
    "id": 2,
    "messageContent": "Dựa trên sở thích của bạn, tôi gợi ý:...",
    "isBotResponse": true,
    "createdAt": "2024-12-07T10:30:15",
    "messageType": "bot"
  }
]
```

### 4. **Lấy Danh Sách Session của User**
```
GET /api/chatbot/user/{userId}/sessions

Response:
[
  {
    "id": 1,
    "userId": 5,
    "sessionName": "Chat Session - 2024-12-07T10:30:00",
    "createdAt": "2024-12-07T10:30:00",
    "updatedAt": "2024-12-07T10:35:00",
    "isActive": true,
    "messageCount": 5
  }
]
```

### 5. **Đóng Session**
```
POST /api/chatbot/session/{sessionId}/close

Response:
{
  "id": 1,
  "userId": 5,
  "sessionName": "Chat Session - 2024-12-07T10:30:00",
  "isActive": false
}
```

### 6. **Lấy Gợi ý**
```
POST /api/chatbot/recommendations
Body:
{
  "message": "cơm gà",
  "preferences": ""
}

Response:
{
  "recommendations": [
    {
      "foodId": 1,
      "foodName": "Cơm Gà Hainanese",
      "price": 85000,
      "category": "Cơm",
      "reason": "Khớp với tên món bạn tìm",
      "matchScore": 50
    }
  ],
  "count": 3
}
```

### 7. **Health Check**
```
GET /api/chatbot/health

Response:
{
  "status": "ChatBot Service is running"
}
```

## WebSocket API

### Kết Nối
```javascript
// JavaScript Example
const socket = new WebSocket('ws://localhost:8080/api/ws/chatbot');

socket.onopen = function(event) {
  console.log('Connected to chatbot');
};

socket.onmessage = function(event) {
  const message = JSON.parse(event.data);
  console.log('Bot response:', message);
};

socket.onclose = function(event) {
  console.log('Disconnected from chatbot');
};

socket.onerror = function(event) {
  console.error('WebSocket error:', event);
};
```

### Gửi Tin Nhắn
```javascript
const request = {
  message: "Gợi ý cho tôi một món cay",
  userId: 5,
  sessionId: 1,
  preferences: ""
};

socket.send(JSON.stringify(request));
```

## Cơ Sở Dữ Liệu

### Bảng `chat_sessions`
```sql
CREATE TABLE chat_sessions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  session_name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (user_id) REFERENCES Users(UserID)
);
```

### Bảng `chat_messages`
```sql
CREATE TABLE chat_messages (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  chat_session_id BIGINT NOT NULL,
  message_content TEXT,
  is_bot_response BOOLEAN DEFAULT FALSE,
  message_type VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(UserID),
  FOREIGN KEY (chat_session_id) REFERENCES chat_sessions(id)
);
```

## Sử Dụng trong Frontend

### Flutter Example
```dart
// Tạo session
final response = await http.post(
  Uri.parse('http://localhost:8080/api/chatbot/session/create'),
  queryParameters: {
    'userId': '5',
    'sessionName': 'My Chat'
  }
);

final sessionData = jsonDecode(response.body);
final sessionId = sessionData['id'];

// Gửi tin nhắn
final messageResponse = await http.post(
  Uri.parse('http://localhost:8080/api/chatbot/message'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'message': 'Gợi ý cho tôi một món cay',
    'userId': 5,
    'sessionId': sessionId,
    'preferences': ''
  })
);

final messageData = jsonDecode(messageResponse.body);
print('Bot: ${messageData['messageContent']}');
```

## Các Từ Khóa Được Hỗ Trợ

### Gợi Ý (Recommendation)
- "recommend", "gợi ý", "suggest", "what should"

### Chào Hỏi (Greeting)
- "hello", "hi", "xin chào", "chào"

### Menu
- "menu", "danh sách", "all food", "tất cả"

### Thích/Cảm Ơn
- "thanks", "thank you", "cảm ơn"

### Loại Thức Ăn
- "cơm", "mì", "phở", "bánh", "canh", "soup", "salad"

### Nguyên Liệu
- "thịt", "gà", "cá", "hải sản", "tôm", "cua", "mực"

### Hương Vị
- "cay", "mặn", "ngọt", "chua"

## Cải Tiến Trong Tương Lai

1. **AI Model Tích Hợp**: Tích hợp OpenAI API cho NLP tốt hơn
2. **Machine Learning**: Học từ lịch sử đặt hàng để cải thiện gợi ý
3. **Tích Hợp AI**: Sử dụng TensorFlow hoặc PyTorch cho personalization
4. **Phân Tích Cảm Xúc**: Phân tích tone của người dùng để cải thiện response
5. **Multi-language Support**: Hỗ trợ nhiều ngôn ngữ
6. **Tích Hợp CRM**: Lưu trữ lịch sử người dùng trong CRM

## Troubleshooting

### 1. WebSocket Connection Failed
- Kiểm tra firewall settings
- Đảm bảo server đang chạy
- Kiểm tra CORS configuration

### 2. No Recommendations Found
- Kiểm tra xem có food items trong database không
- Kiểm tra log để xem lỗi gì
- Thử gửi lại tin nhắn với từ khóa rõ ràng hơn

### 3. Session Not Found
- Tạo session mới trước khi gửi tin nhắn
- Kiểm tra sessionId có tồn tại không

## Liên Hệ & Hỗ Trợ
Để báo cáo bug hoặc yêu cầu tính năng, vui lòng liên hệ với team phát triển.
