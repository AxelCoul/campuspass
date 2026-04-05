package com.campuspass.backend.controller;

import com.campuspass.backend.util.FileUploadService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/upload")
public class UploadController {

    private final FileUploadService fileUploadService;

    public UploadController(FileUploadService fileUploadService) {
        this.fileUploadService = fileUploadService;
    }

    @PostMapping("/offer-image")
    public ResponseEntity<Map<String, String>> uploadOfferImage(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        try {
            String url = fileUploadService.saveOfferImage(file);
            if (url == null) {
                return ResponseEntity.badRequest().build();
            }
            return ResponseEntity.ok(Map.of("url", url));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/student-card")
    public ResponseEntity<Map<String, String>> uploadStudentCard(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        try {
            String url = fileUploadService.saveFile(file, "student-cards");
            if (url == null) {
                return ResponseEntity.badRequest().build();
            }
            return ResponseEntity.ok(Map.of("url", url));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/advertisement-video")
    public ResponseEntity<Map<String, String>> uploadAdvertisementVideo(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        try {
            // Validation simple côté backend (évite d'uploader un fichier non vidéo).
            String originalName = file.getOriginalFilename();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase();
            }

            String contentType = file.getContentType(); // peut être null selon le navigateur
            boolean contentLooksLikeVideo = contentType != null && contentType.startsWith("video/");
            boolean extIsAllowed = ext != null && !ext.isBlank() && (
                    ext.equals("mp4") || ext.equals("webm") || ext.equals("ogg") || ext.equals("mov")
                            || ext.equals("m4v") || ext.equals("avi") || ext.equals("mkv")
            );

            if (!contentLooksLikeVideo && !extIsAllowed) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message",
                        "Format vidéo non autorisé. Formats supportés : mp4, webm, ogg, mov, m4v, avi, mkv."
                ));
            }

            String url = fileUploadService.saveAdvertisementVideo(file);
            if (url == null) {
                return ResponseEntity.badRequest().build();
            }
            return ResponseEntity.ok(Map.of("url", url));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
