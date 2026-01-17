package com.HomeHero.demo.controller.DebugController;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
public class DbDebugController {

    @Value("${spring.datasource.url}")
    private String jdbcUrl;

    /**
     * Debug endpoint to help diagnose "psql works but JVM times out" problems.
     *
     * Accessible at: /homeHero/debug/db  (because of server.servlet.context-path)
     */
    @GetMapping(value = "/debug/db", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> debugDbConnectivity() {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("timestamp", Instant.now().toString());

        out.put("java.net.preferIPv4Stack", System.getProperty("java.net.preferIPv4Stack"));
        out.put("java.net.preferIPv4Addresses", System.getProperty("java.net.preferIPv4Addresses"));

        out.put("http.proxyHost", System.getProperty("http.proxyHost"));
        out.put("http.proxyPort", System.getProperty("http.proxyPort"));
        out.put("https.proxyHost", System.getProperty("https.proxyHost"));
        out.put("https.proxyPort", System.getProperty("https.proxyPort"));
        out.put("socksProxyHost", System.getProperty("socksProxyHost"));
        out.put("socksProxyPort", System.getProperty("socksProxyPort"));

        Map<String, Object> parsed = parsePostgresHostPort(jdbcUrl);
        out.put("jdbc", parsed);

        String host = (String) parsed.get("host");
        Integer port = (Integer) parsed.get("port");
        if (host == null || port == null) {
            out.put("error", "Could not parse host/port from spring.datasource.url");
            return out;
        }

        try {
            InetAddress[] addrs = InetAddress.getAllByName(host);
            List<Map<String, Object>> results = new ArrayList<>();
            for (InetAddress addr : addrs) {
                results.add(testTcp(addr, port, 2000));
            }
            out.put("dns", results);
        } catch (Exception e) {
            out.put("dnsError", e.getClass().getName() + ": " + e.getMessage());
        }

        return out;
    }

    private static Map<String, Object> parsePostgresHostPort(String url) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("url", redactJdbcUrl(url));

        if (url == null) return out;
        String prefix = "jdbc:postgresql://";
        int idx = url.indexOf(prefix);
        if (idx < 0) return out;

        String rest = url.substring(idx + prefix.length());
        int slash = rest.indexOf('/');
        String hostPortAndMaybeMore = (slash >= 0) ? rest.substring(0, slash) : rest;

        // Handle multi-host URLs by taking the first host.
        String firstHostPort = hostPortAndMaybeMore.split(",")[0].trim();
        if (firstHostPort.isEmpty()) return out;

        String host;
        int port = 5432;

        // Bracketed IPv6 [::1]:5432
        if (firstHostPort.startsWith("[")) {
            int close = firstHostPort.indexOf(']');
            if (close < 0) return out;
            host = firstHostPort.substring(1, close);
            if (firstHostPort.length() > close + 1 && firstHostPort.charAt(close + 1) == ':') {
                port = Integer.parseInt(firstHostPort.substring(close + 2));
            }
        } else {
            String[] hp = firstHostPort.split(":");
            host = hp[0];
            if (hp.length >= 2) {
                port = Integer.parseInt(hp[1]);
            }
        }

        out.put("host", host);
        out.put("port", port);
        return out;
    }

    private static Map<String, Object> testTcp(InetAddress addr, int port, int timeoutMs) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ip", addr.getHostAddress());
        out.put("family", (addr.getAddress().length == 16) ? "IPv6" : "IPv4");

        long start = System.currentTimeMillis();
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(addr, port), timeoutMs);
            out.put("connect", "ok");
        } catch (Exception e) {
            out.put("connect", "fail");
            out.put("error", e.getClass().getName() + ": " + e.getMessage());
        }
        out.put("durationMs", System.currentTimeMillis() - start);
        return out;
    }

    private static String redactJdbcUrl(String url) {
        if (url == null) return null;
        // Redact common credential patterns in the query string.
        return url
                .replaceAll("(?i)(password=)[^&]*", "$1***")
                .replaceAll("(?i)(user=)[^&]*", "$1***");
    }
}
