package com.example.FoodHKD.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatSessionDTO {
    private Long id;
    private Long userId;
    private String sessionName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isActive;
    private List<ChatMessageDTO> messages;
    private Integer messageCount;
}
