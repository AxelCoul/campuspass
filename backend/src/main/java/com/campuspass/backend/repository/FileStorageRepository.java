package com.campuspass.backend.repository;

import com.campuspass.backend.model.FileStorage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FileStorageRepository extends JpaRepository<FileStorage, Long> {

    List<FileStorage> findByUploadedByOrderByUploadedAtDesc(Long uploadedBy);
}
