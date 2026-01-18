package com.HomeHero.demo.util;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.RequestScope;

import java.util.UUID;

/**
 * Request-scoped bean that resolves the current user's profile ID from the X-Profile-Id header.
 */
@Component
@RequestScope
public class CurrentUser {

    private static final UUID DEFAULT_PROFILE_ID = UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f");
    private static final String PROFILE_ID_HEADER = "X-Profile-Id";

    private final UUID profileId;

    public CurrentUser(HttpServletRequest request) {
        String raw = request.getHeader(PROFILE_ID_HEADER);
        this.profileId = resolveProfileId(raw);
    }

    public UUID getProfileId() {
        return profileId;
    }

    /**
     * DEV MODE: if callers provide a profile id (ex: via the {@code X-Profile-Id} header),
     * use it; otherwise fall back to {@link #DEFAULT_PROFILE_ID}.
     */
    public static UUID resolveProfileId(String raw) {
        if (raw == null) return DEFAULT_PROFILE_ID;
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) return DEFAULT_PROFILE_ID;
        try {
            return UUID.fromString(trimmed);
        } catch (IllegalArgumentException ignored) {
            return DEFAULT_PROFILE_ID;
        }
    }
}

