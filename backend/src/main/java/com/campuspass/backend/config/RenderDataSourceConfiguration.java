package com.campuspass.backend.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

/**
 * Sur Render, {@code DATABASE_URL} est fourni au runtime mais n'est pas toujours appliqué
 * assez tôt via {@code EnvironmentPostProcessor}. Ce bean construit la {@link DataSource}
 * après chargement complet de l'environnement (variables système incluses).
 */
@Configuration
public class RenderDataSourceConfiguration {

    @Bean
    @Primary
    public DataSource dataSource(Environment env, DataSourceProperties properties) {
        String databaseUrl = firstNonBlank(
                env.getProperty("DATABASE_URL"),
                System.getenv("DATABASE_URL"));

        if (databaseUrl != null && !databaseUrl.isBlank() && databaseUrl.startsWith("postgres")) {
            return buildFromDatabaseUrl(databaseUrl);
        }

        // Variables SPRING_DATASOURCE_* (saisies à la main sur Render) — déjà liées dans DataSourceProperties
        DataSource fromProps = buildFromProperties(properties);
        if (runningOnRender() && isLocalhostJdbcUrl(properties.getUrl())) {
            throw new IllegalStateException(
                    "Base PostgreSQL introuvable : définissez DATABASE_URL (URL interne copiée depuis campuspass-db) "
                            + "ou SPRING_DATASOURCE_URL + SPRING_DATASOURCE_USERNAME + SPRING_DATASOURCE_PASSWORD sur le Web Service campuspass-API.");
        }
        return fromProps;
    }

    private static boolean runningOnRender() {
        String serviceId = System.getenv("RENDER_SERVICE_ID");
        if (serviceId != null && !serviceId.isBlank()) {
            return true;
        }
        String render = System.getenv("RENDER");
        return render != null && "true".equalsIgnoreCase(render.trim());
    }

    private static boolean isLocalhostJdbcUrl(String url) {
        return url == null || url.contains("localhost") || url.contains("127.0.0.1");
    }

    private static DataSource buildFromProperties(DataSourceProperties properties) {
        return properties.initializeDataSourceBuilder().build();
    }

    private static DataSource buildFromDatabaseUrl(String databaseUrl) {
        String forParsing = databaseUrl.replaceFirst("^postgres(ql)?://", "http://");
        URI uri = URI.create(forParsing);
        String userInfo = uri.getUserInfo();
        if (userInfo == null || uri.getHost() == null || uri.getHost().isBlank()) {
            throw new IllegalStateException("DATABASE_URL invalide (hôte ou identifiants manquants)");
        }
        String[] parts = userInfo.split(":", 2);
        String username = URLDecoder.decode(parts[0], StandardCharsets.UTF_8);
        String password = parts.length > 1 ? URLDecoder.decode(parts[1], StandardCharsets.UTF_8) : "";

        int port = uri.getPort() > 0 ? uri.getPort() : 5432;
        String path = uri.getPath();
        if (path != null && path.startsWith("/")) {
            path = path.substring(1);
        }
        String jdbcUrl = String.format(
                "jdbc:postgresql://%s:%d/%s?sslmode=require",
                uri.getHost(), port, path);

        HikariDataSource ds = new HikariDataSource();
        ds.setJdbcUrl(jdbcUrl);
        ds.setUsername(username);
        ds.setPassword(password);
        ds.setDriverClassName("org.postgresql.Driver");
        return ds;
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
}
