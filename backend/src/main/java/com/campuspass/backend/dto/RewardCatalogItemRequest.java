package com.campuspass.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class RewardCatalogItemRequest {
    @NotBlank
    private String title;

    @NotBlank
    private String description;

    @NotNull
    @Min(1)
    private Integer pointsCost;

    @NotNull
    private Boolean active;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getPointsCost() { return pointsCost; }
    public void setPointsCost(Integer pointsCost) { this.pointsCost = pointsCost; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
