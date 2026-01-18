package com.HomeHero.demo.util;

import java.util.UUID;

/**
 * Temporary current-user shim until auth is wired end-to-end.
 */
public final class CurrentUser {
    private CurrentUser() {}

    /**
     * DEV MODE: if callers provide a profile id (ex: via the {@code X-Profile-Id} header),
     * use it; otherwise fall back to {@link #PROFILE_ID}.
     */
    public static final UUID PROFILE_ID = UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f");

    public static UUID resolveProfileId(String raw) {
        if (raw == null) return PROFILE_ID;
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) return PROFILE_ID;
        try {
            return UUID.fromString(trimmed);
        } catch (IllegalArgumentException ignored) {
            return PROFILE_ID;
        }
    }
}

