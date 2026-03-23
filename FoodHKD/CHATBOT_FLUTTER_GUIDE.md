# 🚀 Hướng dẫn sử dụng ChatCopilot cho Flutter Frontend

## 📌 Cách sử dụng Prompt

### Cách 1: Copy-Paste trực tiếp vào ChatCopilot
1. Mở file `CHATBOT_FLUTTER_PROMPT.md` trong editor
2. Copy toàn bộ phần **"Prompt cho ChatCopilot"** (đoạn từ ```Tôi đang xây dựng...``` đến cuối)
3. Paste vào ChatCopilot chat interface
4. ChatCopilot sẽ hiểu các yêu cầu và giúp bạn code

### Cách 2: Sử dụng từng phần nhỏ
Nếu bạn muốn ChatCopilot sinh code từng phần một (khuyến nghị):

```
Phase 1: Project Structure
"Tạo structure thư mục: lib/screens, lib/models, lib/services, lib/widgets, lib/providers 
cho dự án Flutter chatbot. Tạo các file pubspec.yaml với dependencies cần thiết."

Phase 2: Models
"Tạo các model classes: ChatMessage, ChatSession, FoodRecommendation, ChatBotRequest
với các fields như spec trong tài liệu. Thêm fromJson/toJson methods."

Phase 3: Services
"Tạo ChatService class để kết nối REST API /api/chatbot/*
Tạo WebSocketService để kết nối /ws/chatbot
Tạo LocalStorageService để lưu dữ liệu cục bộ bằng Hive"

Phase 4: Providers
"Tạo ChatProvider, ChatSessionProvider dùng package provider 
để quản lý state của chat, messages, sessions"

Phase 5: Widgets
"Tạo các custom widgets: MessageBubble, RecommendationCard, 
ChatInputField, TypingIndicator"

Phase 6: Screens
"Tạo ChatListScreen hiển thị danh sách sessions
Tạo ChatDetailScreen với messages list và input field"

Phase 7: Integration
"Implement routing, theme, animations cho toàn app"
```

## 🎯 Chiến lược tối ưu

### ✅ ĐÚNG - Chia nhỏ thành nhiều request
```
1. "Tạo ChatMessage model với Dart"
2. "Thêm ChatService để call API /api/chatbot/message"
3. "Tạo ChatListScreen để hiển thị danh sách"
```

### ❌ SAI - Yêu cầu quá lớn trong 1 request
```
"Xây dựng toàn bộ app Flutter với chat, recommendations, 
WebSocket, animation, offline support..."
```

## 💬 Ví dụ Prompts cụ thể

### 1. Tạo Models
```
Tôi đang xây dựng Flutter app cho chatbot. 
Tạo Dart models cho:
- ChatMessage (id, messageContent, isBotResponse, createdAt, messageType)
- ChatSession (id, sessionName, createdAt, updatedAt, isActive, messageCount)
- FoodRecommendation (foodId, foodName, price, category, imagePath, reason, matchScore)

Thêm fromJson, toJson methods và copyWith methods cho immutability.
Dùng freezed package nếu có thể.
```

### 2. Tạo Service
```
Tạo ChatService class trong Flutter để:
- POST /api/chatbot/session/create (tạo session mới)
- POST /api/chatbot/message (gửi tin nhắn)
- GET /api/chatbot/session/{sessionId}/history (lấy lịch sử)
- GET /api/chatbot/user/{userId}/sessions (lấy danh sách sessions)
- POST /api/chatbot/recommendations (lấy gợi ý)

Dùng Dio package. Base URL: http://your-api-server.com
```

### 3. Tạo Widget Chat Input
```
Tạo ChatInputField widget cho phép:
- Nhập text tin nhắn
- Nút gửi (send button)
- Hiệu ứng focus
- Auto clear sau khi gửi
- Tính năng reply (optional)

Dùng TextField, custom styling, animations
```

### 4. Tạo Screen Chat
```
Tạo ChatDetailScreen hiển thị:
- ListView các ChatMessage
- User messages align right với background màu xanh
- Bot messages align left với background màu xám
- Typing indicator khi bot đang trả lời
- Input field ở dưới
- Pull to refresh để load more messages

Tối ưu performance cho large lists
```

### 5. Tạo Recommendations Widget
```
Tạo FoodRecommendationCard widget hiển thị:
- Ảnh món ăn (từ imagePath)
- Tên món
- Giá
- Danh mục
- Điểm phù hợp dưới dạng progress bar
- Lý do gợi ý
- Nút "Add to order"

Dùng GridView hoặc ListView tùy context
```

### 6. Tạo WebSocket Connection
```
Tạo WebSocketChatService trong Flutter:
- Connect tới /ws/chatbot
- Send messages: {"message": "...", "userId": 1, "sessionId": 1}
- Listen to responses
- Handle disconnect/reconnect
- Stream messages để update UI real-time

Dùng web_socket_channel package
```

### 7. Setup State Management
```
Tạo Providers (dùng provider package):
- chatSessionProvider (hiện tại active session)
- chatMessagesProvider (tin nhắn trong session)
- chatHistoryProvider (lịch sử sessions)
- recommendationsProvider (danh sách gợi ý)
- loadingProvider (loading states)
- errorProvider (error messages)
```

### 8. Tạo Theme
```
Tạo AppTheme với:
- Color scheme (primary, secondary, accent)
- Text styles
- Component themes (button, input, etc)
- Dark mode support
- Animated theme switching
```

## 🔧 Best Practices khi sử dụng ChatCopilot

### 1. Cung cấp Context đầy đủ
```
❌ SAI: "Tạo chat screen"
✅ ĐÚNG: "Tạo Flutter ChatDetailScreen để hiển thị:
         - ListView messages
         - User messages align right, bot messages align left
         - Input field ở dưới
         - Typing indicator
         Dùng Provider untuk state management"
```

### 2. Chỉ định công nghệ/package
```
❌ SAI: "Quản lý state"
✅ ĐÚNG: "Quản lý state dùng package provider"
```

### 3. Đưa examples/specs
```
❌ SAI: "API integration"
✅ ĐÚNG: "POST /api/chatbot/message với request:
         {\"message\": \"...\", \"userId\": 1, \"sessionId\": 1}
         Response: {\"id\": 1, \"messageContent\": \"...\", \"isBotResponse\": true}"
```

### 4. Yêu cầu refactoring sau khi code
```
"ChatListScreen code vừa tạo quá dài. 
Extract MessageBubble thành widget riêng. 
Tối ưu performance cho large lists bằng ListView.builder"
```

## 📱 Recommended Development Order

```
1. Setup Flutter project
   ↓
2. Create models (ChatMessage, ChatSession, FoodRecommendation)
   ↓
3. Create services (API, WebSocket, LocalStorage)
   ↓
4. Create providers (State management)
   ↓
5. Create basic widgets (MessageBubble, InputField, etc)
   ↓
6. Create ChatListScreen
   ↓
7. Create ChatDetailScreen
   ↓
8. Create RecommendationsScreen
   ↓
9. Implement routing & navigation
   ↓
10. Add animations & polish UI
    ↓
11. Error handling & edge cases
    ↓
12. Testing & optimization
```

## 🐛 Khi gặp lỗi

### Hỏi ChatCopilot cách này:
```
"Khi chạy app Flutter tôi gặp lỗi:
[ERROR] Failed to connect to API: SocketException

Code của tôi:
[paste code here]

Cách fix?"
```

### Hoặc:
```
"Code dưới đây rebuild lại quá nhiều lần:
[paste code]

Cách optimize?"
```

## 💾 Git Workflow

```bash
# Sau khi ChatCopilot tạo code
git add .
git commit -m "feat: implement chatbot UI with [feature_name]"

# Nếu cần sửa
git commit -m "fix: [describe_fix]"

# Nếu refactor
git commit -m "refactor: [describe_change]"
```

## 🎓 Lời khuyên

1. **Đọc code ChatCopilot tạo trước khi sử dụng**
   - Hiểu logic
   - Check có lỗi không
   - Hỏi lại nếu không hiểu

2. **Test tính năng từng phần**
   - Không chờ cả app xong
   - Kiểm tra API integration
   - Check animation/UI

3. **Yêu cầu comments trong code**
   ```
   "Thêm comments Tiếng Anh để giải thích logic trong code trên"
   ```

4. **Tích hợp Backend từ từ**
   ```
   Phase 1: Mock data
   Phase 2: REST API
   Phase 3: WebSocket real-time
   ```

5. **Làm theo best practices**
   ```
   "Code theo Flutter best practices:
    - Use const constructors
    - Proper error handling
    - Null safety
    - Performance optimization"
   ```

## 📚 Tài liệu tham khảo

- Flutter Docs: https://flutter.dev/docs
- Provider Package: https://pub.dev/packages/provider
- Dio Package: https://pub.dev/packages/dio
- WebSocket: https://pub.dev/packages/web_socket_channel
- Material Design 3: https://m3.material.io/

---

**Chúc bạn code vui vẻ! 🚀**

Nếu cần giúp thêm, hãy copy prompt từ CHATBOT_FLUTTER_PROMPT.md vào ChatCopilot.
