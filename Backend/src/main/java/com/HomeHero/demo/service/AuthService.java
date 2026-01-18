package com.HomeHero.demo.service;

import com.HomeHero.demo.util.CurrentUser;
import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Service
public class AuthService {
    private final SecretKey[] keys;

    public AuthService(@Value("${supabase.jwt.secret}") String supabaseJwtSecret) {
        SecretKey base64Key = null;
        SecretKey rawKey = null;

        try {
            // Supabase "JWT Secret" is commonly base64-encoded.
            byte[] decoded = Decoders.BASE64.decode(supabaseJwtSecret);
            base64Key = Keys.hmacShaKeyFor(decoded);
        } catch (Exception ignored) {
            // ignore
        }

        try {
            rawKey = Keys.hmacShaKeyFor(supabaseJwtSecret.getBytes(StandardCharsets.UTF_8));
        } catch (Exception ignored) {
            // ignore
        }

        // Try base64 key first (typical), then raw bytes fallback.
        if (base64Key != null && rawKey != null) {
            this.keys = new SecretKey[]{base64Key, rawKey};
        } else if (base64Key != null) {
            this.keys = new SecretKey[]{base64Key};
        } else if (rawKey != null) {
            this.keys = new SecretKey[]{rawKey};
        } else {
            throw new IllegalStateException("Invalid supabase.jwt.secret (could not construct HMAC key)");
        }
    }

    /**
     * Resolve the current profile id from Authorization header (Supabase access token).
     * Falls back to {@link CurrentUser#PROFILE_ID} when no header is present (dev convenience).
     */
    public UUID resolveProfileIdOrDefault(String authHeader) {
        if (authHeader == null || authHeader.isBlank()) {
            return CurrentUser.PROFILE_ID;
        }
        return requireProfileId(authHeader);
    }

    public UUID requireProfileId(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
        }

        String token = authHeader.substring("Bearer ".length()).trim();
        if (token.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
        }

        try {
            for (SecretKey key : keys) {
                try {
                    Jws<Claims> parsed = Jwts.parserBuilder()
                            .setSigningKey(key)
                            .build()
                            .parseClaimsJws(token);

                    String sub = parsed.getBody().getSubject();
                    if (sub == null || sub.isBlank()) {
                        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token: missing subject");
                    }
                    return UUID.fromString(sub);
                } catch (JwtException e) {
                    // try next key
                }
            }
            // Dev fallback: decode without verifying signature (useful when jwt secret mismatched).
            // NOTE: This is not secure for production; wire full auth properly before shipping.
            try {
                DecodedJWT decoded = JWT.decode(token);
                String sub = decoded.getSubject();
                if (sub == null || sub.isBlank()) {
                    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token: missing subject");
                }
                return UUID.fromString(sub);
            } catch (Exception ignored) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
            }
        } catch (IllegalArgumentException e) {
            // UUID parsing errors
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token subject");
        }
    }
}

