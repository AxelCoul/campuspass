package com.campuspass.backend.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * Stockage local des fichiers uploadés (images offres, logos, pubs).
 * En prod : remplacer par S3, Cloudinary, etc.
 */
@Service
public class FileUploadService {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    public String saveFile(MultipartFile file, String subFolder) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }
        String originalName = file.getOriginalFilename();
        String ext = originalName != null && originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.'))
                : "";
        String fileName = UUID.randomUUID().toString() + ext;
        Path dir = Paths.get(uploadDir, subFolder).toAbsolutePath().normalize();
        Files.createDirectories(dir);
        Path target = dir.resolve(fileName);
        file.transferTo(target.toFile());
        return "/" + uploadDir + "/" + subFolder + "/" + fileName;
    }

    public String saveOfferImage(MultipartFile file) throws IOException {
        return saveFile(file, "offers");
    }

    public String saveMerchantLogo(MultipartFile file) throws IOException {
        return saveFile(file, "merchants");
    }

    public String saveAdvertisementImage(MultipartFile file) throws IOException {
        return saveFile(file, "ads");
    }

    public String saveAdvertisementVideo(MultipartFile file) throws IOException {
        // Sous-dossier séparé pour éviter collision / garder l'organisation.
        return saveFile(file, "ads-videos");
    }
}
