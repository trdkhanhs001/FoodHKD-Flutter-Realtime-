package com.example.FoodHKD.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private Long id;
    private Long userId;
    private String messageContent;
    private Boolean isBotResponse;
    private LocalDateTime createdAt;
    private String messageType;
}
