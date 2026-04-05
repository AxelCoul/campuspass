package com.campuspass.backend.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * Convertit {@code DATABASE_URL} (format Render/Heroku : {@code postgres://...})
 * en propriétés {@code spring.datasource.*} JDBC pour Spring Boot.
 */
public class DatabaseUrlEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    private static final String SOURCE_NAME = "renderDatabaseUrl";

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        String databaseUrl = firstNonBlank(
                environment.getProperty("DATABASE_URL"),
                System.getenv("DATABASE_URL"));
        if (databaseUrl == null || databaseUrl.isBlank()) {
            return;
        }
        if (!databaseUrl.startsWith("postgres")) {
            return;
        }
        if (environment.getPropertySources().contains(SOURCE_NAME)) {
            return;
        }
        try {
            // java.net.URI parse mal certains schémas postgres:// ; astuce Heroku/Render : parser comme http://
            String forParsing = databaseUrl.replaceFirst("^postgres(ql)?://", "http://");
            URI uri = URI.create(forParsing);
            String userInfo = uri.getUserInfo();
            if (userInfo == null) {
                return;
            }
            String[] parts = userInfo.split(":", 2);
            String username = URLDecoder.decode(parts[0], StandardCharsets.UTF_8);
            String password = parts.length > 1 ? URLDecoder.decode(parts[1], StandardCharsets.UTF_8) : "";

            if (uri.getHost() == null || uri.getHost().isBlank()) {
                return;
            }
            int port = uri.getPort() > 0 ? uri.getPort() : 5432;
            String path = uri.getPath();
            if (path != null && path.startsWith("/")) {
                path = path.substring(1);
            }
            // Render / cloud PostgreSQL : SSL requis pour que la connexion JDBC réussisse
            String jdbcUrl = String.format(
                    "jdbc:postgresql://%s:%d/%s?sslmode=require",
                    uri.getHost(), port, path);

            Map<String, Object> map = new HashMap<>();
            map.put("spring.datasource.url", jdbcUrl);
            map.put("spring.datasource.username", username);
            map.put("spring.datasource.password", password);
            environment.getPropertySources().addFirst(new MapPropertySource(SOURCE_NAME, map));
        } catch (Exception ignored) {
            // laisser la config par défaut (application.properties)
        }
    }

    private static String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) {
            return a;
        }
        if (b != null && !b.isBlank()) {
            return b;
        }
        return null;
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
