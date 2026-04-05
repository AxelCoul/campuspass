package com.campuspass.backend.dto;

import jakarta.validation.constraints.*;

public class ReviewRequest {

    @NotNull
    private Long merchantId;

    @Min(1) @Max(5)
    private Integer rating;

    @Size(max = 1000)
    private String comment;

    public Long getMerchantId() { return merchantId; }
    public void setMerchantId(Long merchantId) { this.merchantId = merchantId; }
    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
