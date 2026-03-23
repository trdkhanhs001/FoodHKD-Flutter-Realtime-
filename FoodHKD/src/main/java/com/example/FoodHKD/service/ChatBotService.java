package com.example.FoodHKD.service;

import com.example.FoodHKD.dto.ChatBotRequestDTO;
import com.example.FoodHKD.dto.ChatMessageDTO;
import com.example.FoodHKD.dto.FoodRecommendationDTO;
import com.example.FoodHKD.model.ChatMessage;
import com.example.FoodHKD.model.ChatSession;
import com.example.FoodHKD.model.FoodItem;
import com.example.FoodHKD.model.User;
import com.example.FoodHKD.repository.ChatMessageRepository;
import com.example.FoodHKD.repository.ChatSessionRepository;
import com.example.FoodHKD.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ChatBotService {

    @Autowired
    private ChatSessionRepository chatSessionRepository;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FoodItemService foodItemService;

    /**
     * Tạo một session chat mới cho user
     */
    public ChatSession createChatSession(Integer userId, String sessionName) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        ChatSession session = new ChatSession();
        session.setUser(user);
        session.setSessionName(sessionName != null ? sessionName : "Chat Session - " + LocalDateTime.now());
        session.setIsActive(true);

        return chatSessionRepository.save(session);
    }

    /**
     * Xử lý tin nhắn từ user và trả về response từ bot
     */
    public ChatMessageDTO processUserMessage(ChatBotRequestDTO request) {
        ChatSession session = chatSessionRepository.findById(request.getSessionId())
                .orElseThrow(() -> new RuntimeException("Chat session not found"));

        // Lưu tin nhắn từ user
        ChatMessage userMessage = new ChatMessage();
        userMessage.setChatSession(session);
        userMessage.setMessageContent(request.getMessage());
        userMessage.setIsBotResponse(false);
        userMessage.setMessageType("user");
        chatMessageRepository.save(userMessage);

        // Xử lý và tạo response từ bot
        String botResponse = generateBotResponse(request.getMessage(), request.getPreferences());

        // Lưu tin nhắn từ bot
        ChatMessage botMessage = new ChatMessage();
        botMessage.setChatSession(session);
        botMessage.setMessageContent(botResponse);
        botMessage.setIsBotResponse(true);
        botMessage.setMessageType("bot");
        chatMessageRepository.save(botMessage);

        // Chuyển đổi sang DTO
        ChatMessageDTO responseDTO = new ChatMessageDTO();
        responseDTO.setId(botMessage.getId());
        responseDTO.setMessageContent(botResponse);
        responseDTO.setIsBotResponse(true);
        responseDTO.setCreatedAt(botMessage.getCreatedAt());

        return responseDTO;
    }

    /**
     * Tạo response từ bot dựa trên tin nhắn của user
     */
    private String generateBotResponse(String userMessage, String preferences) {
        String lowerMessage = userMessage.toLowerCase();

        // Kiểm tra các từ khóa để xác định ý định của user
        if (lowerMessage.contains("recommend") || lowerMessage.contains("gợi ý") || 
            lowerMessage.contains("suggest") || lowerMessage.contains("what should")) {
            return generateRecommendationResponse(userMessage, preferences);
        } else if (lowerMessage.contains("hello") || lowerMessage.contains("hi") || 
                   lowerMessage.contains("xin chào") || lowerMessage.contains("chào")) {
            return "Chào bạn! 👋 Tôi là trợ lý AI của FoodHKD. Tôi có thể giúp bạn gợi ý các món ăn phù hợp. " +
                   "Hãy cho tôi biết bạn thích ăn gì hoặc bạn đang tìm gì?";
        } else if (lowerMessage.contains("menu") || lowerMessage.contains("danh sách") || 
                   lowerMessage.contains("all food") || lowerMessage.contains("tất cả")) {
            return generateMenuResponse();
        } else if (lowerMessage.contains("thanks") || lowerMessage.contains("thank you") || 
                   lowerMessage.contains("cảm ơn")) {
            return "Không có gì! 😊 Hãy ghé lại nếu bạn cần thêm gợi ý. Enjoy your meal! 🍽️";
        } else {
            return generateSmartResponse(userMessage, preferences);
        }
    }

    /**
     * Tạo response gợi ý dựa trên sở thích của user
     */
    private String generateRecommendationResponse(String userMessage, String preferences) {
        List<FoodRecommendationDTO> recommendations = getRecommendedFoods(userMessage, preferences);

        if (recommendations.isEmpty()) {
            return "Xin lỗi, tôi không tìm thấy món ăn phù hợp với yêu cầu của bạn. " +
                   "Hãy thử mô tả lại hoặc cho tôi biết bạn thích ăn gì? 😊";
        }

        StringBuilder response = new StringBuilder("Dựa trên sở thích của bạn, tôi gợi ý:\n\n");

        for (int i = 0; i < Math.min(3, recommendations.size()); i++) {
            FoodRecommendationDTO food = recommendations.get(i);
            response.append(String.format("%d. **%s** (%.0f đ)\n", 
                i + 1, food.getFoodName(), food.getPrice()));
            response.append(String.format("   📍 %s\n", food.getCategory()));
            response.append(String.format("   💭 %s\n\n", food.getReason()));
        }

        response.append("Bạn có thích các gợi ý này không? 😋");
        return response.toString();
    }

    /**
     * Tạo response thông minh dựa trên nội dung tin nhắn
     */
    private String generateSmartResponse(String userMessage, String preferences) {
        // Phân tích tin nhắn để tìm các từ khóa liên quan đến thực phẩm
        List<String> keywords = extractFoodKeywords(userMessage);

        if (!keywords.isEmpty()) {
            List<FoodRecommendationDTO> recommendations = searchFoodsByKeywords(keywords);
            if (!recommendations.isEmpty()) {
                return generateRecommendationMessage(recommendations, keywords);
            }
        }

        // Nếu không tìm thấy từ khóa thực phẩm, trả lời một cách thân thiện
        return "Tôi chưa hiểu rõ bạn muốn gì. 🤔 Bạn có thể:\n" +
               "• Gợi ý cho tôi một loại thức ăn mà bạn thích\n" +
               "• Cho tôi biết bạn đang tìm gì (cay, mặn, ngọt, ...)\n" +
               "• Hỏi tôi về thực đơn của chúng tôi\n\n" +
               "Ví dụ: 'gợi ý cho tôi một món cay' hoặc 'tôi muốn ăn hải sản'";
    }

    /**
     * Tạo response với danh sách menu
     */
    private String generateMenuResponse() {
        try {
            List<FoodItem> allFoods = foodItemService.getAllFoodItems();
            
            if (allFoods.isEmpty()) {
                return "Hiện tại, thực đơn chưa có sẵn. Vui lòng quay lại sau! 📋";
            }

            // Nhóm theo danh mục
            Map<String, List<FoodItem>> foodByCategory = allFoods.stream()
                    .collect(Collectors.groupingBy(f -> f.getCategory().getName()));

            StringBuilder response = new StringBuilder("📋 **THỰC ĐƠN CỦA CHÚNG TÔI**\n\n");

            foodByCategory.forEach((category, foods) -> {
                response.append(String.format("**%s**\n", category));
                foods.forEach(food -> {
                    response.append(String.format("  • %s - %.0f đ\n", 
                        food.getName(), food.getPrice().doubleValue()));
                });
                response.append("\n");
            });

            response.append("Bạn thích món nào? 😋");
            return response.toString();
        } catch (Exception e) {
            log.error("Error generating menu response", e);
            return "Xin lỗi, tôi không thể tải danh sách thực đơn lúc này. Vui lòng thử lại sau!";
        }
    }

    /**
     * Lấy danh sách gợi ý thực phẩm dựa trên tin nhắn và sở thích
     */
    public List<FoodRecommendationDTO> getRecommendedFoods(String userMessage, String preferences) {
        try {
            List<FoodItem> allFoods = foodItemService.getAllFoodItems();

            // Tính điểm phù hợp cho mỗi món ăn
            List<FoodRecommendationDTO> recommendations = allFoods.stream()
                    .map(food -> calculateFoodScore(food, userMessage, preferences))
                    .filter(rec -> rec.getMatchScore() > 0)
                    .sorted((a, b) -> Double.compare(b.getMatchScore(), a.getMatchScore()))
                    .limit(5)
                    .collect(Collectors.toList());

            return recommendations;
        } catch (Exception e) {
            log.error("Error getting recommended foods", e);
            return new ArrayList<>();
        }
    }

    /**
     * Tính điểm phù hợp của một món ăn dựa trên input của user
     */
    private FoodRecommendationDTO calculateFoodScore(FoodItem food, String userMessage, String preferences) {
        FoodRecommendationDTO dto = new FoodRecommendationDTO();
        dto.setFoodId(food.getFoodID().longValue());
        dto.setFoodName(food.getName());
        dto.setDescription(food.getDescription());
        dto.setPrice(food.getPrice().doubleValue());
        dto.setImagePath(food.getAnh());
        dto.setCategory(food.getCategory().getName());

        double score = 0;
        String reason = "";

        String lowerMessage = userMessage.toLowerCase();
        String lowerFoodName = food.getName().toLowerCase();
        String lowerCategory = food.getCategory().getName().toLowerCase();
        String lowerDescription = food.getDescription() != null ? food.getDescription().toLowerCase() : "";

        // Kiểm tra tên món ăn
        if (lowerFoodName.contains(lowerMessage) || lowerMessage.contains(lowerFoodName)) {
            score += 50;
            reason = "Khớp với tên món bạn tìm";
        }

        // Kiểm tra danh mục
        if (lowerCategory.contains(lowerMessage)) {
            score += 30;
            reason = "Thuộc danh mục bạn muốn";
        }

        // Kiểm tra các từ khóa
        if (lowerMessage.contains("cay") && lowerDescription.contains("cay")) {
            score += 25;
            reason = "Là món ăn cay như bạn yêu thích";
        }

        if (lowerMessage.contains("mặn") && lowerDescription.contains("mặn")) {
            score += 25;
            reason = "Là món ăn mặn";
        }

        if (lowerMessage.contains("ngọt") && lowerDescription.contains("ngọt")) {
            score += 25;
            reason = "Là món ăn ngọt";
        }

        if (lowerMessage.contains("đặc biệt") && food.getPrice().doubleValue() > 100000) {
            score += 20;
            reason = "Là một món ăn đặc biệt";
        }

        // Nếu không có điểm nào, gợi ý ngẫu nhiên
        if (score == 0) {
            score = Math.random() * 10;
            reason = "Một lựa chọn ngon lành";
        }

        dto.setMatchScore(score);
        dto.setReason(reason);

        return dto;
    }

    /**
     * Trích xuất các từ khóa thực phẩm từ tin nhắn
     */
    private List<String> extractFoodKeywords(String message) {
        List<String> keywords = new ArrayList<>();
        String[] words = message.toLowerCase().split("\\s+");

        // Danh sách các từ khóa phổ biến liên quan đến thực phẩm
        Set<String> foodKeywords = new HashSet<>(Arrays.asList(
            "cơm", "mì", "phở", "bánh", "nước", "canh", "soup", "salad",
            "thịt", "gà", "cá", "hải sản", "tôm", "cua", "mực",
            "rau", "cải", "bông cải", "ngoại", "ăn", "thử", "muốn",
            "thích", "cay", "mặn", "ngọt", "chua", "đặc biệt"
        ));

        for (String word : words) {
            if (foodKeywords.contains(word)) {
                keywords.add(word);
            }
        }

        return keywords;
    }

    /**
     * Tìm kiếm thực phẩm theo từ khóa
     */
    private List<FoodRecommendationDTO> searchFoodsByKeywords(List<String> keywords) {
        try {
            List<FoodItem> allFoods = foodItemService.getAllFoodItems();

            return allFoods.stream()
                    .filter(food -> keywords.stream().anyMatch(keyword ->
                            food.getName().toLowerCase().contains(keyword) ||
                            (food.getDescription() != null && 
                             food.getDescription().toLowerCase().contains(keyword)) ||
                            food.getCategory().getName().toLowerCase().contains(keyword)))
                    .map(food -> {
                        FoodRecommendationDTO dto = new FoodRecommendationDTO();
                        dto.setFoodId(food.getFoodID().longValue());
                        dto.setFoodName(food.getName());
                        dto.setPrice(food.getPrice().doubleValue());
                        dto.setCategory(food.getCategory().getName());
                        dto.setMatchScore(50.0);
                        dto.setReason("Khớp với tìm kiếm của bạn");
                        return dto;
                    })
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Error searching foods by keywords", e);
            return new ArrayList<>();
        }
    }

    /**
     * Tạo thông báo gợi ý dựa trên kết quả tìm kiếm
     */
    private String generateRecommendationMessage(List<FoodRecommendationDTO> recommendations, List<String> keywords) {
        StringBuilder response = new StringBuilder("Tôi tìm thấy một số món ăn liên quan đến '")
                .append(String.join(", ", keywords)).append("':\n\n");

        for (int i = 0; i < Math.min(3, recommendations.size()); i++) {
            FoodRecommendationDTO food = recommendations.get(i);
            response.append(String.format("%d. **%s** - %.0f đ\n", 
                i + 1, food.getFoodName(), food.getPrice().doubleValue()));
        }

        response.append("\nBạn có quan tâm đến các món này không? 😋");
        return response.toString();
    }

    /**
     * Lấy lịch sử chat của một session
     */
    public List<ChatMessageDTO> getChatHistory(Long sessionId) {
        return chatMessageRepository.findByChatSessionIdOrderByCreatedAtDesc(sessionId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Chuyển đổi ChatMessage thành DTO
     */
    private ChatMessageDTO convertToDTO(ChatMessage message) {
        ChatMessageDTO dto = new ChatMessageDTO();
        dto.setId(message.getId());
        dto.setUserId(message.getUser().getUserID().longValue());
        dto.setMessageContent(message.getMessageContent());
        dto.setIsBotResponse(message.getIsBotResponse());
        dto.setCreatedAt(message.getCreatedAt());
        dto.setMessageType(message.getMessageType());
        return dto;
    }

    /**
     * Lấy danh sách các session chat của user
     */
    public List<ChatSession> getUserChatSessions(Integer userId) {
        return chatSessionRepository.findByUserUserIDAndIsActiveOrderByCreatedAtDesc(userId, true);
    }

    /**
     * Đóng session chat
     */
    public ChatSession closeChatSession(Long sessionId) {
        ChatSession session = chatSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Chat session not found"));
        session.setIsActive(false);
        return chatSessionRepository.save(session);
    }
}
