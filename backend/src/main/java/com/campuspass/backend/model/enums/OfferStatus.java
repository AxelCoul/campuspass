package com.campuspass.backend.model.enums;

public enum OfferStatus {
    /** Proposition commerçant, en attente de validation admin (n'est pas publiée aux étudiants). */
    PROPOSED,
    /** @deprecated préférer PROPOSED ; conservé pour données existantes. */
    @Deprecated
    PENDING,
    ACTIVE,
    INACTIVE,
    EXPIRED,
    DELETED
}
