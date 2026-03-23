package com.example.FoodHKD.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FoodRecommendationDTO {
    private Long foodId;
    private String foodName;
    private String description;
    private Double price;
    private String imagePath;
    private String category;
    private String reason;
    private Double matchScore;
}
