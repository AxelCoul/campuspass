package com.campuspass.backend.config;

import com.campuspass.backend.security.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

import jakarta.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import org.springframework.http.MediaType;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final CorsConfigurationSource corsConfigurationSource;
    private final JwtAuthFilter jwtAuthFilter;

    public SecurityConfig(CorsConfigurationSource corsConfigurationSource, JwtAuthFilter jwtAuthFilter) {
        this.corsConfigurationSource = corsConfigurationSource;
        this.jwtAuthFilter = jwtAuthFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/api/subscription/yengapay/**").permitAll()
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/offers/**", "/api/merchants").hasAnyRole("MERCHANT", "ADMIN")
                        // Les étudiants doivent pouvoir uploader leur carte pour la vérification.
                        .requestMatchers(HttpMethod.POST, "/api/upload/student-card").hasRole("STUDENT")
                        // Uploads réservés aux commerçants/admins (images, vidéos, etc.)
                        .requestMatchers(HttpMethod.POST, "/api/upload/**").hasAnyRole("MERCHANT", "ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/offers/**", "/api/merchants/**").hasAnyRole("MERCHANT", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/offers/**", "/api/merchants/**").hasAnyRole("MERCHANT", "ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/advertisements").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/advertisements/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/advertisements/**").hasRole("ADMIN")
                        .requestMatchers("/api/coupons/**", "/api/favorites/**", "/api/notifications/**").authenticated()
                        .requestMatchers("/api/student/**", "/api/subscription/**").authenticated()
                        .requestMatchers("/api/**").permitAll()
                        .anyRequest().permitAll()
                )
                .exceptionHandling(ex -> ex.authenticationEntryPoint((req, res, e) -> {
                    res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    res.setCharacterEncoding(StandardCharsets.UTF_8.name());
                    res.getWriter().write("{\"error\":\"Non authentifié\"}");
                }))
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
