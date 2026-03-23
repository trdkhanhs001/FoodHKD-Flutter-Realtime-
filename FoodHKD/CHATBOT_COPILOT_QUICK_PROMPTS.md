# 🎯 Copy-Paste Prompts for ChatCopilot (Vietnamese)

## Prompt 1: Tạo Project Structure & Dependencies

```
Tôi đang xây dựng một ứng dụng Flutter cho AI Chatbot gợi ý món ăn.

Requirements:
1. Tạo structure thư mục:
   lib/
   ├── models/
   ├── services/
   ├── providers/
   ├── screens/
   ├── widgets/
   └── config/

2. Tạo pubspec.yaml với dependencies:
   - dio: ^5.3.0 (HTTP client)
   - provider: ^6.0.0 (state management)
   - web_socket_channel: ^2.4.0 (WebSocket)
   - hive_flutter: ^1.1.0 (local storage)
   - flutter_animate: ^4.1.0 (animations)
   - intl: ^0.19.0 (localization)

3. Tạo README.md với project description

Backend API Base URL: http://your-api-server.com
WebSocket URL: ws://your-api-server.com/ws/chatbot
```

---

## Prompt 2: Tạo Models

```
Tạo Dart models cho app chatbot:

1. ChatMessage model:
   - id: int
   - messageContent: String
   - isBotResponse: bool
   - createdAt: DateTime
   - messageType: String ("user", "bot", "recommendation")

2. ChatSession model:
   - id: int
   - sessionName: String
   - createdAt: DateTime
   - updatedAt: DateTime
   - isActive: bool
   - messageCount: int

3. FoodRecommendation model:
   - foodId: int
   - foodName: String
   - price: double
   - category: String
   - imagePath: String
   - reason: String
   - matchScore: double

Mỗi model cần có:
- fromJson(Map<String, dynamic> json) constructor
- toJson() method
- copyWith() method
- toString() method

Dùng freezed package nếu có thể, hoặc generate manually.
```

---

## Prompt 3: Tạo ChatService

```
Tạo ChatService class trong lib/services/chat_service.dart:

Endpoints cần implement:
1. createSession(int userId, String? sessionName)
   POST /api/chatbot/session/create

2. sendMessage(int userId, int sessionId, String message, String? preferences)
   POST /api/chatbot/message

3. getChatHistory(int sessionId)
   GET /api/chatbot/session/{sessionId}/history

4. getUserSessions(int userId)
   GET /api/chatbot/user/{userId}/sessions

5. getRecommendations(String message, int userId, String? preferences)
   POST /api/chatbot/recommendations

6. closeSession(int sessionId)
   POST /api/chatbot/session/{sessionId}/close

Dùng Dio package. Thêm:
- Error handling
- Timeout (30 seconds)
- Request logging
- Response parsing to models
```

---

## Prompt 4: Tạo WebSocketService

```
Tạo WebSocketService class trong lib/services/websocket_service.dart:

Features:
1. Kết nối tới ws://your-api-server.com/ws/chatbot
2. Send message: {"message": "...", "userId": 1, "sessionId": 1}
3. Listen to responses (Stream<ChatMessage>)
4. Handle disconnect/reconnect
5. Auto reconnect after 5 seconds
6. Connection status tracking (connected, disconnected, error)

Methods:
- connect()
- disconnect()
- sendMessage(ChatBotRequest)
- messageStream() -> Stream<ChatMessage>
- isConnected() -> bool

Dùng web_socket_channel package.
```

---

## Prompt 5: Tạo LocalStorageService

```
Tạo LocalStorageService class trong lib/services/local_storage_service.dart:

Dùng Hive package để:
1. Lưu messages locally: saveChatMessages(int sessionId, List<ChatMessage>)
2. Load messages: getChatMessages(int sessionId) -> List<ChatMessage>
3. Lưu sessions: saveSessions(List<ChatSession>)
4. Load sessions: getSessions() -> List<ChatSession>
5. Xóa old messages: clearOldMessages(days)
6. Search messages: searchMessages(String query) -> List<ChatMessage>

Initialize Hive trong main.dart trước khi runApp.
```

---

## Prompt 6: Tạo State Management Providers

```
Tạo các providers trong lib/providers/:

1. chat_provider.dart:
   - currentSession: ChatSession?
   - messages: List<ChatMessage>
   - isLoading: bool
   - error: String?
   - Methods: createSession(), sendMessage(), loadHistory()

2. sessions_provider.dart:
   - sessions: List<ChatSession>
   - Methods: loadSessions(), deleteSession(), closeSession()

3. recommendations_provider.dart:
   - recommendations: List<FoodRecommendation>
   - Methods: getRecommendations(), clearRecommendations()

4. chat_websocket_provider.dart:
   - isConnected: bool
   - Methods: connect(), disconnect()

Dùng ChangeNotifier pattern hoặc Provider hooks.
```

---

## Prompt 7: Tạo Custom Widgets

```
Tạo widgets trong lib/widgets/:

1. message_bubble.dart:
   - Hiển thị user message (align right, blue background)
   - Hiển thị bot message (align left, gray background)
   - Animate entry (slide in từ bottom)
   - Timestamp

2. recommendation_card.dart:
   - Hình ảnh món ăn
   - Tên, giá, danh mục
   - Match score dưới dạng progress bar
   - Lý do gợi ý
   - "Add to order" button

3. chat_input_field.dart:
   - TextField để nhập tin nhắn
   - Send button
   - Auto focus
   - Auto clear sau khi gửi
   - Character counter (max 500)

4. typing_indicator.dart:
   - 3 dots animation
   - "Bot is typing..."
   - Smooth animation

5. food_recommendation_list.dart:
   - GridView hoặc ListView các recommendation cards
```

---

## Prompt 8: Tạo ChatListScreen

```
Tạo ChatListScreen trong lib/screens/chat_list_screen.dart:

Features:
1. Danh sách tất cả chat sessions
2. Mỗi session hiển thị:
   - Session name
   - Preview tin nhắn cuối
   - Last updated time
   - Message count
3. "New Chat" floating action button
4. Swipe to delete session
5. Tap để mở chi tiết
6. Pull to refresh

Dùng ListView.builder, RefreshIndicator.
Integrate ChatProvider để load sessions.
```

---

## Prompt 9: Tạo ChatDetailScreen

```
Tạo ChatDetailScreen trong lib/screens/chat_detail_screen.dart:

Features:
1. Messages ListView (newest at bottom)
2. Message bubbles (user right, bot left)
3. Typing indicator khi bot đang trả lời
4. Chat input field ở dưới
5. AppBar hiển thị session name
6. Pull to refresh load more messages
7. Jump to bottom button nếu scroll up

Dùng:
- ListView.builder (lazy loading)
- ScrollController
- AnimatedList (optional)
- Lottie animation cho typing indicator

Integrate ChatProvider & WebSocketProvider.
```

---

## Prompt 10: Tạo RecommendationsScreen

```
Tạo RecommendationsScreen trong lib/screens/recommendations_screen.dart:

Features:
1. GridView (2 columns) hoặc ListView recommendations
2. Mỗi card show:
   - Hình ảnh
   - Tên món
   - Giá
   - Danh mục badge
   - Match score bar
   - Lý do gợi ý

3. Load more khi scroll to bottom
4. Refresh button
5. Empty state nếu không có gợi ý
6. Loading skeleton

Dùng GridView.builder, CachedNetworkImage.
Integrate RecommendationsProvider.
```

---

## Prompt 11: Tạo Theme & Styling

```
Tạo lib/config/theme.dart:

Features:
1. AppTheme class với:
   - lightTheme (ThemeData)
   - darkTheme (ThemeData)

2. Color scheme:
   - Primary: Blue (#2196F3)
   - Secondary: Green (#4CAF50)
   - Error: Red (#F44336)
   - Background: White/Dark gray

3. Text styles:
   - headingLarge
   - bodyMedium
   - labelSmall
   - etc.

4. Component themes:
   - Button theme
   - Input field theme
   - Card theme
   - App bar theme

5. Dark mode toggle capability

Dùng Material Design 3 colors.
```

---

## Prompt 12: Tạo Main App & Routing

```
Tạo main.dart:

Features:
1. Initialize Hive
2. Setup providers
3. Create MaterialApp
4. Setup routes (named routing):
   - /: ChatListScreen
   - /chat/:sessionId: ChatDetailScreen
   - /recommendations: RecommendationsScreen
   - /settings: SettingsScreen

5. Theme toggle (dark/light)
6. Error handler

Dùng GoRouter hoặc Navigator 2.0.
Initialize services sebelum runApp.
```

---

## Prompt 13: Implement Error Handling & Loading States

```
Tạo global error handling:

1. ErrorProvider (untuk manage app-wide errors)
2. LoadingProvider (untuk manage loading states)
3. ErrorDialog widget
4. SnackBar untuk notifications

Features:
- Graceful error messages
- Retry logic
- Offline detection
- Connection timeout handling
- Network error recovery

Tampilkan:
- Snackbar untuk errors
- Dialog untuk critical errors
- Shimmer/skeleton loading
- Empty states
```

---

## Prompt 14: Implement Animations

```
Tạo animations untuk:

1. Message entry animations (slide in)
2. Typing indicator (dots animation)
3. Food recommendation cards (fade in)
4. Page transitions
5. Button press animations
6. List item animations

Dùng:
- AnimationController
- flutter_animate package
- Lottie animations
- TweenAnimation
- Transition builders

Smooth 60fps animations, tidak blocking.
```

---

## Prompt 15: Testing & Optimization

```
Implement testing:

1. Unit tests:
   - Model serialization
   - Service methods
   - Provider logic

2. Widget tests:
   - Screen rendering
   - Button interactions
   - List scrolling

3. Integration tests:
   - Full user flow
   - API integration
   - WebSocket connection

Performance optimization:
- Lazy load messages
- Image caching
- Debounce input
- Memory management
- Minimize rebuilds

Dùng flutter test, integration_test packages.
```

---

## Quick Start Command

```bash
# 1. Create project
flutter create foodhkd_chatbot
cd foodhkd_chatbot

# 2. Add dependencies
flutter pub add dio provider web_socket_channel hive_flutter flutter_animate intl

# 3. Generate build files (jika pakai freezed)
flutter pub run build_runner build

# 4. Run app
flutter run
```

---

## Tips Saat Pakai ChatCopilot

1. **Specific Context**: Kasih context lengkap, bukan hanya "buat widget"
2. **Exact Requirements**: Sebutkan fields, colors, behaviors yang diinginkan
3. **Code Snippets**: Paste existing code jika ada yang perlu di-modify
4. **One Thing at a Time**: Jangan minta terlalu banyak dalam 1 prompt
5. **Ask for Refactoring**: Jika code terlalu panjang, minta split ke smaller components
6. **Testing**: Minta ChatCopilot buat unit tests untuk critical logic

---

## Execution Order (Recommended)

```
Phase 1: Setup
├── Prompt 1: Project structure
└── Quick start command

Phase 2: Core Logic
├── Prompt 2: Models
├── Prompt 3: ChatService
├── Prompt 4: WebSocketService
└── Prompt 5: LocalStorageService

Phase 3: State Management
└── Prompt 6: Providers

Phase 4: UI Components
├── Prompt 7: Custom widgets
└── Prompt 11: Theme

Phase 5: Screens
├── Prompt 8: ChatListScreen
├── Prompt 9: ChatDetailScreen
└── Prompt 10: RecommendationsScreen

Phase 6: Integration
├── Prompt 12: Main app & routing
└── Prompt 13: Error handling

Phase 7: Polish
├── Prompt 14: Animations
└── Prompt 15: Testing

Phase 8: Deployment
└── Build release, test on devices
```

---

**Happy Coding! Use these prompts with ChatCopilot untuk cepat build Flutter frontend! 🚀**
