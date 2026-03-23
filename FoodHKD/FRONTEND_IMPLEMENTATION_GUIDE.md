# 🤖 AI ChatBot - Gợi ý Món Ăn

## 📋 Tóm Tắt Hệ Thống Chatbot

### ✅ Đã Hoàn Thành - Backend (Java Spring Boot)

#### 1. **Models**
- ✅ `ChatMessage` - Lưu trữ tin nhắn
- ✅ `ChatSession` - Lưu trữ phiên chat
- ✅ DTOs - Để transfer data

#### 2. **Repositories**
- ✅ `ChatMessageRepository` - Truy vấn tin nhắn
- ✅ `ChatSessionRepository` - Truy vấn phiên chat

#### 3. **Services**
- ✅ `ChatBotService` - Logic chính
  - Tạo session
  - Xử lý tin nhắn
  - Gợi ý món ăn
  - Quản lý lịch sử chat

#### 4. **Controllers**
- ✅ `ChatBotController` - REST API endpoints
  - POST `/api/chatbot/session/create` - Tạo session
  - POST `/api/chatbot/message` - Gửi tin nhắn
  - GET `/api/chatbot/session/{id}/history` - Lấy lịch sử
  - GET `/api/chatbot/user/{id}/sessions` - Lấy sessions
  - POST `/api/chatbot/session/{id}/close` - Đóng session
  - POST `/api/chatbot/recommendations` - Lấy gợi ý

#### 5. **WebSocket**
- ✅ `ChatBotWebSocketHandler` - Real-time chat
  - Endpoint: `/api/ws/chatbot`

---

## 🎯 CẦN LÀM - Frontend (Flutter)

### 📝 PROMPT MẪU CHO CHATCOPILOT

Copy toàn bộ text dưới đây và paste vào ChatCopilot:

```
I need to create a Flutter frontend for a Food Ordering App with an AI ChatBot feature.

The backend is already built with Java Spring Boot and provides these APIs:

## Backend API Endpoints:

1. POST /api/chatbot/session/create
   - Parameters: userId (Integer), sessionName (String optional)
   - Response: {id, userId, sessionName, createdAt, updatedAt, isActive, messageCount}

2. POST /api/chatbot/message
   - Body: {message, userId, sessionId, preferences}
   - Response: {id, messageContent, isBotResponse, createdAt, messageType}

3. GET /api/chatbot/session/{sessionId}/history
   - Response: Array of {id, messageContent, isBotResponse, createdAt, messageType}

4. GET /api/chatbot/user/{userId}/sessions
   - Response: Array of {id, userId, sessionName, createdAt, updatedAt, isActive, messageCount}

5. POST /api/chatbot/session/{sessionId}/close
   - Response: {id, userId, sessionName, isActive}

6. POST /api/chatbot/recommendations
   - Body: {message, preferences}
   - Response: {recommendations: Array, count}

7. WebSocket: ws://localhost:8080/api/ws/chatbot
   - Send: {message, userId, sessionId, preferences}
   - Receive: {id, messageContent, isBotResponse, createdAt, messageType}

## Requirements:

Please generate production-ready Flutter code with:

1. **Data Models**:
   - ChatMessage (id, messageContent, isBotResponse, createdAt, messageType)
   - ChatSession (id, userId, sessionName, createdAt, updatedAt, isActive, messageCount)

2. **ChatBotService** (API Integration):
   - createSession(userId, sessionName)
   - sendMessage(sessionId, userId, message, preferences)
   - getChatHistory(sessionId)
   - getUserSessions(userId)
   - closeSession(sessionId)
   - connectWebSocket()
   - sendWebSocketMessage()

3. **ChatBotWidget** (Main UI):
   - FloatingActionButton to open chat
   - Message list with auto-scroll
   - Input field with send button
   - Message bubbles (left for bot, right for user)
   - Loading states
   - Error handling
   - Timestamps for messages

4. **Features**:
   - Create new chat session on open
   - Send messages and get bot responses
   - Display food recommendations
   - Load chat history
   - Session management
   - Real-time WebSocket support (optional)

5. **Code Quality**:
   - Proper error handling
   - Null safety
   - Code comments
   - Clean code structure
   - Production-ready

6. **Dependencies** (pubspec.yaml):
   - http: ^1.1.0
   - web_socket_channel: ^2.4.0
   - flutter_dotenv (for API URL configuration)

Please provide:
1. Complete chatbot_service.dart
2. Complete models (chat_message.dart, chat_session.dart)
3. Complete chatbot_widget.dart or main screen
4. pubspec.yaml with all dependencies
5. Integration guide for the main app
```

---

## 🚀 CÁC BƯỚC TRIỂN KHAI FRONTEND

### Step 1: Copy Prompt vào ChatCopilot
1. Mở VS Code
2. Mở ChatCopilot extension
3. Copy toàn bộ prompt ở trên
4. Paste vào ChatCopilot
5. Nhấn Enter

### Step 2: Copy Code từ ChatCopilot Output
ChatCopilot sẽ generate:
- `chatbot_service.dart`
- `models/chat_message.dart`
- `models/chat_session.dart`
- `screens/chatbot_screen.dart`
- `pubspec.yaml` updates

### Step 3: Tạo Folder Structure
```
lib/
├── models/
│   ├── chat_message.dart
│   └── chat_session.dart
├── services/
│   └── chatbot_service.dart
├── screens/
│   └── chatbot_screen.dart
├── widgets/
│   └── chat_bubble.dart (optional)
└── main.dart
```

### Step 4: Cập nhật pubspec.yaml
Thêm dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  web_socket_channel: ^2.4.0
  flutter_dotenv: ^5.1.0
```

Chạy:
```bash
flutter pub get
```

### Step 5: Intergrate vào Main App
Thêm vào navigation:
```dart
// Trong main.dart hoặc navigation file
FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatBotWidget(userId: currentUserId),
      ),
    );
  },
  child: const Icon(Icons.chat),
)
```

### Step 6: Test
```bash
flutter run
```

---

## ⚙️ BACKEND API URLs

**Development:**
- Base URL: `http://localhost:8080`
- WebSocket: `ws://localhost:8080`

**Production:**
- Update URLs trong chatbot_service.dart

---

## 📚 API EXAMPLES

### Tạo Session
```bash
POST http://localhost:8080/api/chatbot/session/create?userId=5&sessionName=My%20Chat

Response:
{
  "id": 1,
  "userId": 5,
  "sessionName": "My Chat",
  "createdAt": "2024-12-07T10:30:00",
  "updatedAt": "2024-12-07T10:30:00",
  "isActive": true,
  "messageCount": 0
}
```

### Gửi Tin Nhắn
```bash
POST http://localhost:8080/api/chatbot/message
Content-Type: application/json

{
  "message": "Gợi ý cho tôi một món cay",
  "userId": 5,
  "sessionId": 1,
  "preferences": ""
}

Response:
{
  "id": 1,
  "messageContent": "Dựa trên sở thích của bạn, tôi gợi ý...",
  "isBotResponse": true,
  "createdAt": "2024-12-07T10:30:15",
  "messageType": "bot"
}
```

---

## 🔧 TROUBLESHOOTING

### ❌ API Connection Failed
- Kiểm tra backend đang chạy: `http://localhost:8080/api/chatbot/health`
- Kiểm tra firewall
- Kiểm tra URL configuration trong code

### ❌ WebSocket Connection Failed
- Verify backend running
- Check firewall for port 8080
- Check CORS settings in backend

### ❌ JSON Parsing Error
- Verify API response format matches models
- Check Flutter null safety
- Rebuild app: `flutter clean && flutter pub get`

---

## 📱 USAGE EXAMPLE

```dart
// Mở chatbot
void openChatBot() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChatBotWidget(
        userId: 5, // Current user ID
        baseUrl: 'http://localhost:8080',
      ),
    ),
  );
}
```

---

## ✨ FEATURES CHECKLIST

- [ ] Models created
- [ ] Service created with API integration
- [ ] ChatBotWidget UI built
- [ ] Dependencies added to pubspec.yaml
- [ ] Folder structure organized
- [ ] Code tested with backend
- [ ] Error handling implemented
- [ ] Null safety enabled
- [ ] Chat history loading works
- [ ] Message sending works
- [ ] WebSocket connection (optional)

---

## 🎨 UI CUSTOMIZATION

### Theme Colors
Modify trong ChatBotWidget:
```dart
// User message color
Colors.deepPurple.shade400

// Bot message color
Colors.grey.shade300

// Button color
Colors.deepPurple

// App bar color
Colors.deepPurple
```

### Input Field Styling
```dart
// hintText
'Ask for food recommendations...'

// Border radius
BorderRadius.circular(24)

// Font sizes
fontSize: 15
```

---

## 🔐 SECURITY NOTES

1. **Use HTTPS** in production
2. **Use WSS** for WebSocket
3. **Validate** all inputs on backend
4. **Authentication** - Add JWT tokens if needed
5. **Rate limiting** - Implement on backend

---

## 📖 DOCUMENTATION FILES

Tất cả chi tiết đã được documented:
- `CHATBOT_API_DOCUMENTATION.md` - API reference
- `CHATBOT_IMPLEMENTATION_SUMMARY.md` - Implementation details
- `README.md` - Project overview

---

## 💡 NEXT STEPS

1. **Copy prompt** vào ChatCopilot
2. **Generate code** từ ChatCopilot
3. **Integrate** code vào Flutter project
4. **Test** với backend chạy
5. **Customize** UI theo design bạn muốn
6. **Deploy** khi ready

---

## 📞 SUPPORT

Nếu có vấn đề:
1. Kiểm tra logs
2. Verify backend APIs
3. Check Flutter dependencies
4. Re-run: `flutter pub get && flutter clean && flutter run`

---

**Happy Coding! 🚀**
