package com.HomeHero.demo.util;

import java.util.UUID;

/**
 * Temporary current-user shim until auth is wired end-to-end.
 * Mirrors existing behavior in ProfileController (/getProfile is hardcoded).
 */
public final class CurrentUser {
    private CurrentUser() {}

    public static final UUID PROFILE_ID = UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f");
}

