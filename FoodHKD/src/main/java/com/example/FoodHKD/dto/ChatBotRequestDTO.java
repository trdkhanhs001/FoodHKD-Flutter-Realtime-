package com.example.FoodHKD.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatBotRequestDTO {
    private String message;
    private Long userId;
    private Long sessionId;
    private String preferences; // preferences nhập vào từ người dùng
}
