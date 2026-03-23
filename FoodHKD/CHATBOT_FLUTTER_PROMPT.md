# AI Chatbot Frontend Flutter - Prompt cho GitHub Copilot

## 📋 Mô tả dự án
Xây dựng giao diện Flutter cho hệ thống AI Chatbot gợi ý món ăn. Frontend sẽ tích hợp với Backend Java thông qua REST API và WebSocket.

## 🎯 Yêu cầu chính

### 1. **Thiết kế UI/UX**
- Chat screen với giao diện modern và thân thiện
- Hiển thị lịch sử chat
- Input field để nhập tin nhắn
- Hiển thị suggestions từ Bot (Recommendations)
- Animation cho message (slide in, fade in)
- Support Dark/Light theme

### 2. **Core Features**
- Tạo session chat mới
- Gửi/nhận tin nhắn (REST API)
- Real-time chat với WebSocket
- Hiển thị danh sách gợi ý món ăn
- Lưu lịch sử chat
- Quản lý multiple chat sessions

### 3. **Backend Integration**
API Endpoints cần tích hợp:
```
POST   /api/chatbot/session/create                 - Tạo session mới
POST   /api/chatbot/message                        - Gửi tin nhắn
GET    /api/chatbot/session/{sessionId}/history   - Lấy lịch sử
GET    /api/chatbot/user/{userId}/sessions        - Lấy danh sách sessions
POST   /api/chatbot/recommendations               - Lấy gợi ý
POST   /api/chatbot/session/{sessionId}/close     - Đóng session
WS     /ws/chatbot                                 - WebSocket connection
```

### 4. **Data Models**
```dart
// ChatMessage
- id: int
- messageContent: String
- isBotResponse: bool
- createdAt: DateTime
- messageType: String

// ChatSession
- id: int
- sessionName: String
- createdAt: DateTime
- updatedAt: DateTime
- isActive: bool
- messageCount: int

// FoodRecommendation
- foodId: int
- foodName: String
- price: double
- category: String
- imagePath: String
- reason: String
- matchScore: double
```

### 5. **Technical Stack**
- **Framework**: Flutter 3.x+
- **State Management**: Provider hoặc Riverpod
- **HTTP Client**: Dio
- **WebSocket**: web_socket_channel
- **Database**: Hive (local caching)
- **Animation**: flutter_animate
- **UI**: Material Design 3

### 6. **Features Chi Tiết**

#### Screen 1: Chat List Screen
- Danh sách tất cả sessions
- Nút "New Chat"
- Xóa session
- Tìm kiếm sessions
- Hiển thị message preview

#### Screen 2: Chat Detail Screen
- Messages ListView
- User message bubble (align right)
- Bot message bubble (align left)
- Typing indicator khi bot đang trả lời
- Input field với buttons (send, attach file - optional)
- Show recommendations trong chat
- Pull to refresh

#### Screen 3: Recommendations Detail
- Grid hoặc List view các gợi ý
- Food card với:
  - Hình ảnh
  - Tên món ăn
  - Giá
  - Danh mục
  - Điểm phù hợp
  - Nút "Add to order" hoặc "View details"

### 7. **Local Features**
- Lưu draft messages
- Offline message queue
- Sync khi online lại
- Cache messages
- Search in chat history

### 8. **Error Handling**
- Connection error handling
- Retry logic
- Loading states
- Empty states
- Error snackbars

### 9. **Performance**
- Lazy load messages (pagination)
- Image caching
- State preservation
- Memory optimization

### 10. **Testing**
- Unit tests cho services
- Widget tests cho screens
- Integration tests cho APIs

## 📝 Prompt cho ChatCopilot

```
Tôi đang xây dựng một ứng dụng Flutter cho hệ thống AI Chatbot gợi ý món ăn.

**Backend:**
- REST API tại /api/chatbot/*
- WebSocket tại /ws/chatbot
- User ID: Integer
- Base URL: http://your-api.com

**Requirements:**
1. Tạo structure thư mục: lib/screens, lib/models, lib/services, lib/widgets, lib/providers
2. Implement ChatService để kết nối với backend
3. Tạo ChatMessage model mapping với API response
4. Tạo ChatSession model
5. Tạo FoodRecommendation model
6. Tạo ChatListScreen - danh sách các sessions
7. Tạo ChatDetailScreen - chi tiết 1 session
8. Implement StateManagement với Provider
9. Tạo RecommendationWidget để hiển thị gợi ý
10. Implement WebSocket cho real-time chat

**UI/UX:**
- Modern Material Design 3
- Animated messages
- Dark mode support
- Responsive layout

Bắt đầu từ project structure và models. Sau đó services, rồi providers, cuối cùng screens.
```

## 🔗 API Integration Details

### POST /api/chatbot/session/create
```dart
Request:
- userId: int (query param)
- sessionName: String (query param, optional)

Response:
{
  "id": 1,
  "userId": 1,
  "sessionName": "Chat Session",
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00",
  "isActive": true,
  "messageCount": 0
}
```

### POST /api/chatbot/message
```dart
Request:
{
  "message": "Gợi ý cho tôi một món cay",
  "userId": 1,
  "sessionId": 1,
  "preferences": "Tôi thích ăn cay"
}

Response:
{
  "id": 1,
  "userId": 1,
  "messageContent": "Dựa trên sở thích của bạn...",
  "isBotResponse": true,
  "createdAt": "2024-01-01T10:00:00",
  "messageType": "bot"
}
```

### POST /api/chatbot/recommendations
```dart
Request:
{
  "message": "Tôi muốn ăn hải sản",
  "userId": 1,
  "preferences": "Hải sản, không cay"
}

Response:
{
  "recommendations": [
    {
      "foodId": 1,
      "foodName": "Tôm nước dừa",
      "price": 150000,
      "category": "Hải sản",
      "imagePath": "/uploads/foods/1.jpg",
      "reason": "Khớp với tìm kiếm của bạn",
      "matchScore": 95.0
    }
  ],
  "count": 3
}
```

### WebSocket /ws/chatbot
```dart
// Send
{
  "message": "Gợi ý cho tôi",
  "userId": 1,
  "sessionId": 1
}

// Receive (same as REST response)
{
  "id": 1,
  "messageContent": "...",
  "isBotResponse": true,
  ...
}
```

## 📦 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.3.0
  provider: ^6.0.0
  web_socket_channel: ^2.4.0
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  flutter_animate: ^4.1.0
  intl: ^0.19.0
  
dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

## 🚀 Implementation Steps
1. Setup project structure
2. Create models
3. Create services (API, WebSocket, Local Storage)
4. Create providers (State management)
5. Create widgets (Custom UI components)
6. Create screens (ChatList, ChatDetail, Recommendations)
7. Implement routing
8. Add animations
9. Test integration
10. Handle error cases

## 💡 Tips
- Use `.copyWith()` methods trong models cho immutability
- Implement proper error handling và logging
- Cache API responses locally
- Handle WebSocket reconnection
- Implement proper pagination cho chat history
- Add proper loading/empty states
- Test offline scenarios
