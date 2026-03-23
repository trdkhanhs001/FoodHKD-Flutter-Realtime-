# 🤖 FoodHKD AI Chatbot - Complete Documentation

## 📚 Overview

Hệ thống AI Chatbot gợi ý món ăn cho FoodHKD bao gồm:
- **Backend**: Java Spring Boot REST API + WebSocket
- **Frontend**: Flutter App
- **Features**: AI-powered food recommendations, real-time chat, multi-session support

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│      Flutter Mobile App (FE)        │
│  - Chat UI                          │
│  - Recommendations Display          │
│  - Local Storage (Hive)             │
└────────────┬────────────────────────┘
             │
             │ REST API + WebSocket
             │
┌────────────▼────────────────────────┐
│   Spring Boot Backend (Java)        │
│  - ChatBotService (AI Logic)        │
│  - ChatMessage & ChatSession Models │
│  - REST Controllers                 │
│  - WebSocket Handlers               │
│  - MySQL Database                   │
└─────────────────────────────────────┘
```

---

## 📁 Backend Structure

```
src/main/java/com/example/FoodHKD/
├── model/
│   ├── ChatMessage.java           ✅ Lưu tin nhắn
│   ├── ChatSession.java           ✅ Quản lý session chat
│   ├── FoodItem.java              ✅ (existing)
│   ├── User.java                  ✅ (existing)
│   └── Category.java              ✅ (existing)
│
├── dto/
│   ├── ChatMessageDTO.java        ✅ Transfer data
│   ├── ChatSessionDTO.java        ✅ Transfer data
│   ├── ChatBotRequestDTO.java     ✅ Request format
│   └── FoodRecommendationDTO.java ✅ Gợi ý món ăn
│
├── repository/
│   ├── ChatMessageRepository.java ✅ Query tin nhắn
│   └── ChatSessionRepository.java ✅ Query sessions
│
├── service/
│   ├── ChatBotService.java        ✅ Xử lý AI logic
│   └── FoodItemService.java       ✅ (existing)
│
├── rest/
│   └── chatbot/
│       └── ChatBotController.java ✅ REST endpoints
│
├── websocket/
│   ├── ChatBotWebSocketHandler.java ✅ WebSocket handler
│   └── OrderWebSocketHandler.java   ✅ (existing)
│
└── config/
    ├── WebSocketConfig.java         ✅ WebSocket configuration
    └── SecurityConfig.java          ✅ (existing)
```

---

## 🗄️ Database Schema

### chat_sessions table
```sql
CREATE TABLE chat_sessions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  session_name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (user_id) REFERENCES Users(UserID)
);
```

### chat_messages table
```sql
CREATE TABLE chat_messages (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  chat_session_id BIGINT NOT NULL,
  message_content LONGTEXT,
  is_bot_response BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  message_type VARCHAR(50), -- 'user', 'bot', 'recommendation'
  FOREIGN KEY (user_id) REFERENCES Users(UserID),
  FOREIGN KEY (chat_session_id) REFERENCES chat_sessions(id)
);
```

---

## 🔌 API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/chatbot/session/create` | Tạo session chat mới |
| POST | `/api/chatbot/message` | Gửi tin nhắn & nhận response |
| GET | `/api/chatbot/session/{id}/history` | Lấy lịch sử chat |
| GET | `/api/chatbot/user/{id}/sessions` | Lấy danh sách sessions |
| POST | `/api/chatbot/recommendations` | Lấy gợi ý món ăn |
| POST | `/api/chatbot/session/{id}/close` | Đóng session |
| GET | `/api/chatbot/health` | Health check |
| WS | `/ws/chatbot` | WebSocket real-time chat |

📖 **Chi tiết**: Xem `API_CHATBOT_DOCUMENTATION.md`

---

## 🤖 AI Logic (ChatBotService)

### Key Features

1. **Natural Language Processing**
   - Phân tích từ khóa từ tin nhắn người dùng
   - Nhận diện ý định (gợi ý, hỏi menu, cảm ơn, v.v.)

2. **Smart Recommendation**
   - Tính điểm phù hợp (match score) cho mỗi món ăn
   - Dựa trên: tên món, danh mục, mô tả, sở thích
   - Trả về top 3-5 gợi ý tốt nhất

3. **Conversational Response**
   - Trả lời theo ngữ cảnh
   - Hỗ trợ cả Tiếng Việt và Tiếng Anh
   - Emoji & formatting để tăng trải nghiệm

4. **Multi-Session Management**
   - Mỗi user có thể có nhiều sessions
   - Lịch sử được lưu vĩnh viễn
   - Support session archiving

### Example Prompts & Responses

```
User: "Gợi ý cho tôi một món cay"
Bot: "Dựa trên sở thích của bạn, tôi gợi ý:
     1. **Mì cay Thái** (120000 đ)
        📍 Mì/Pasta
        💭 Là món ăn cay như bạn yêu thích
     ..."

User: "Xin chào"
Bot: "Chào bạn! 👋 Tôi là trợ lý AI của FoodHKD. 
     Tôi có thể giúp bạn gợi ý các món ăn phù hợp..."

User: "Có gì ngon?"
Bot: "Bạn thích ăn gì? Tôi có thể:
     • Gợi ý một loại thức ăn mà bạn thích
     • Cho tôi biết bạn đang tìm gì
     • Hỏi tôi về thực đơn của chúng tôi"
```

---

## 🎯 Frontend (Flutter)

### Screens & Widgets

| Screen/Widget | Purpose |
|---|---|
| **ChatListScreen** | Danh sách tất cả chat sessions |
| **ChatDetailScreen** | Chi tiết 1 session với messages |
| **RecommendationsScreen** | Hiển thị danh sách gợi ý |
| **ChatInputField** | Input tin nhắn |
| **MessageBubble** | Hiển thị user/bot messages |
| **RecommendationCard** | Thẻ hiển thị 1 gợi ý |
| **TypingIndicator** | Animation bot đang trả lời |

### State Management
- **Provider** package để quản lý state
- **Providers**: ChatProvider, SessionsProvider, RecommendationsProvider

### Local Storage
- **Hive** để cache messages & sessions
- Offline-first approach

📖 **Hướng dẫn**: Xem `CHATBOT_FLUTTER_GUIDE.md` & `CHATBOT_FLUTTER_PROMPT.md`

---

## 🚀 Setup & Installation

### Backend Setup

1. **Database**
   ```bash
   # Chạy migration script để tạo tables
   mysql -u root -p < database_migrations.sql
   ```

2. **Build & Run**
   ```bash
   cd FoodHKD
   mvn clean install
   mvn spring-boot:run
   ```

3. **Verify**
   ```bash
   curl http://localhost:8080/api/chatbot/health
   ```

### Frontend Setup

1. **Create Flutter Project**
   ```bash
   flutter create foodhkd_chatbot
   cd foodhkd_chatbot
   ```

2. **Add Dependencies**
   ```bash
   flutter pub add dio web_socket_channel provider hive hive_flutter
   ```

3. **Generate Models**
   ```bash
   # Nếu dùng freezed
   flutter pub run build_runner build
   ```

4. **Run App**
   ```bash
   flutter run
   ```

---

## 📝 Configuration

### Backend (application.properties)
```properties
# API Configuration
server.port=8080
server.servlet.context-path=/

# Database
spring.datasource.url=jdbc:mysql://localhost:3306/foodhkd
spring.datasource.username=root
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update

# CORS
server.compression.enabled=true
spring.web.cors.allowed-origins=*
```

### Frontend (main.dart)
```dart
const String API_BASE_URL = 'http://your-api-server.com';
const String WS_URL = 'ws://your-api-server.com';
const int API_TIMEOUT = 30; // seconds
```

---

## 🧪 Testing

### Backend Unit Tests
```bash
mvn test
```

### API Testing
```bash
# Sử dụng Postman hoặc curl (xem API_CHATBOT_DOCUMENTATION.md)
curl -X POST http://localhost:8080/api/chatbot/session/create?userId=1
```

### Flutter Testing
```bash
flutter test
```

---

## 🔒 Security

### Backend
- ✅ Validation cho tất cả inputs
- ✅ SQL Injection prevention (JPA)
- ✅ XSS protection
- ✅ CORS configuration
- ✅ Rate limiting (tùy chọn)

### Frontend
- ✅ Secure storage cho tokens (flutter_secure_storage)
- ✅ HTTPS enforcement
- ✅ Input validation trước gửi

### Future Enhancements
- [ ] JWT Authentication
- [ ] API Key management
- [ ] Role-based access control
- [ ] Encryption cho sensitive data

---

## 📊 Performance Optimization

### Backend
- ✅ Lazy loading relationships (Fetch.LAZY)
- ✅ Database indexing trên frequently-queried fields
- ✅ Connection pooling
- ✅ Pagination cho chat history

### Frontend
- ✅ ListView.builder cho messages (lazy loading)
- ✅ Image caching
- ✅ Debouncing cho input
- ✅ Memory optimization

---

## 🐛 Troubleshooting

### Backend Issues

**Error**: `Failed to connect to database`
```
Solution: Kiểm tra MySQL running, credentials, port 3306
```

**Error**: `CORS error when calling from Frontend`
```
Solution: Thêm Frontend domain vào allowed-origins trong WebSocketConfig
```

**Error**: `WebSocket connection failed`
```
Solution: Kiểm tra /ws/chatbot endpoint registered, firewall settings
```

### Frontend Issues

**Error**: `Connection refused to API`
```
Solution: Kiểm tra API_BASE_URL correct, backend running on port 8080
```

**Error**: `Images not displaying`
```
Solution: Kiểm tra imagePath format, /uploads/foods/ directory accessible
```

**Error**: `Memory leak khi scroll messages`
```
Solution: Implement proper disposal của controllers, use ListView.builder
```

---

## 📚 Documentation Files

| File | Content |
|------|---------|
| `CHATBOT_FLUTTER_PROMPT.md` | Comprehensive prompt cho ChatCopilot |
| `CHATBOT_FLUTTER_GUIDE.md` | Hướng dẫn chi tiết sử dụng ChatCopilot |
| `API_CHATBOT_DOCUMENTATION.md` | API endpoints & testing |
| `README.md` | File này - Overview & setup |

---

## 🎓 Learning Path

1. **Understand Architecture**
   - Đọc Overview ở trên
   - Xem database schema

2. **Backend Development**
   - Xem code trong `service/ChatBotService.java`
   - Test APIs sử dụng curl/Postman
   - Modify AI logic nếu cần

3. **Frontend Development**
   - Follow `CHATBOT_FLUTTER_GUIDE.md`
   - Sử dụng `CHATBOT_FLUTTER_PROMPT.md` với ChatCopilot
   - Build screens từng cái một

4. **Integration Testing**
   - Test full flow: create session → send message → get recommendations
   - Test WebSocket real-time chat
   - Test offline scenarios

5. **Deployment**
   - Deploy backend (AWS/Azure/VPS)
   - Update API_BASE_URL
   - Deploy Flutter app (Play Store/App Store)

---

## 📞 Support & Contribution

Nếu gặp vấn đề:
1. Check troubleshooting section
2. Review API documentation
3. Check database connectivity
4. Look at server logs

Để contribute:
1. Fork project
2. Create feature branch
3. Make changes & test
4. Submit pull request

---

## 📜 License

Private project - FoodHKD Team

---

## 🎉 Next Steps

### Immediate (This Week)
- [ ] Setup backend completely
- [ ] Test all API endpoints
- [ ] Create database tables
- [ ] Deploy backend to server

### Short-term (Next 2 weeks)
- [ ] Build Flutter UI screens
- [ ] Integrate REST APIs
- [ ] Setup WebSocket connection
- [ ] Implement local storage

### Medium-term (Next month)
- [ ] Add advanced AI features
- [ ] Implement user preferences learning
- [ ] Add analytics & logging
- [ ] Performance optimization
- [ ] User testing & feedback

### Long-term
- [ ] Multi-language support
- [ ] Voice chat support
- [ ] Advanced recommendation algorithm
- [ ] Integration với order system
- [ ] Mobile app deployment

---

**Last Updated**: December 7, 2024
**Version**: 1.0
**Status**: ✅ Backend Complete | 🔄 Frontend In Progress

Enjoy building! 🚀
