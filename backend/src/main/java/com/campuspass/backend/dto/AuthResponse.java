package com.campuspass.backend.dto;

import lombok.Getter;
import lombok.Setter;
import com.campuspass.backend.model.enums.UserRole;
import com.campuspass.backend.model.enums.MerchantRole;

@Getter
@Setter
public class AuthResponse {

    private String token;
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private UserRole role;
    private String adminLevel;
    /** Commerce rattaché (propriétaire ou membre d'équipe MERCHANT). */
    private Long merchantId;
    private MerchantRole merchantRole;

    public AuthResponse() {}

    public AuthResponse(String token, Long id, String email, String firstName, String lastName, UserRole role) {
        this(token, id, email, firstName, lastName, role, null, null, null);
    }

    public AuthResponse(String token, Long id, String email, String firstName, String lastName,
                        UserRole role, String adminLevel, Long merchantId, MerchantRole merchantRole) {
        this.token = token;
        this.id = id;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.role = role;
        this.adminLevel = adminLevel;
        this.merchantId = merchantId;
        this.merchantRole = merchantRole;
    }
}
