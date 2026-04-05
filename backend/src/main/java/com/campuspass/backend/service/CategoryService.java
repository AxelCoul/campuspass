package com.campuspass.backend.service;

import com.campuspass.backend.dto.CategoryRequest;
import com.campuspass.backend.dto.CategoryResponse;
import com.campuspass.backend.model.Category;
import com.campuspass.backend.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<CategoryResponse> findAll() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public CategoryResponse create(CategoryRequest req) {
        Category c = new Category();
        c.setName(req.getName());
        c.setIcon(req.getIcon());
        c.setDescription(req.getDescription());
        c.setCreatedAt(LocalDateTime.now());
        c = categoryRepository.save(c);
        return toResponse(c);
    }

    public CategoryResponse update(Long id, CategoryRequest req) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Catégorie introuvable: " + id));
        if (req.getName() != null) c.setName(req.getName());
        if (req.getIcon() != null) c.setIcon(req.getIcon());
        if (req.getDescription() != null) c.setDescription(req.getDescription());
        c = categoryRepository.save(c);
        return toResponse(c);
    }

    public void delete(Long id) {
        if (!categoryRepository.existsById(id)) {
            throw new IllegalArgumentException("Catégorie introuvable: " + id);
        }
        categoryRepository.deleteById(id);
    }

    private CategoryResponse toResponse(Category c) {
        CategoryResponse r = new CategoryResponse();
        r.setId(c.getId());
        r.setName(c.getName());
        r.setIcon(c.getIcon());
        r.setDescription(c.getDescription());
        r.setCreatedAt(c.getCreatedAt());
        return r;
    }
}
