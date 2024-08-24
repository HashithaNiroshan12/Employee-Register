package com.example.employeeregiter.controller;

import com.example.employeeregiter.model.Employee;
import com.example.employeeregiter.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("api/employees")
@CrossOrigin(origins = "http://localhost:8080") // Allow the Flutter app's origin
public class EmployeeController {

    @Autowired
    EmployeeService employeeService;

    @PostMapping
    public ResponseEntity<Employee> createEmployee(@RequestBody Employee employee) {
        return ResponseEntity.ok(employeeService.save(employee));
    }

    @GetMapping
    public ResponseEntity<List<Employee>> getAllEmployees() {
        List<Employee> employees = employeeService.getAllEmployees();
        return ResponseEntity.ok(employees);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Employee> getEmployeeById(@PathVariable Long id) {
        return ResponseEntity.ok(employeeService.findById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Employee> updateEmployee(@PathVariable Long id, @RequestBody Employee employee) {
        return ResponseEntity.ok(employeeService.update(id, employee));
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteEmployee(@PathVariable Long id) {
        employeeService.delete(id);
        String responseMessage = String.format("Employee with ID %d has been successfully deleted.", id);
        return ResponseEntity.ok(responseMessage);
    }

    @PostMapping("/{id}/upload")
    public ResponseEntity<String> uploadProfilePicture(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        String uploadDir = "C:/Users/HP/Postman/files/uploads";

        try {
            Path filePath = Paths.get(uploadDir + file.getOriginalFilename());
            Files.write(filePath, file.getBytes());

            employeeService.updateProfilePicture(id, filePath.toString());

            return ResponseEntity.ok("Profile picture uploaded successfully!");

        } catch (IOException e) {
            return ResponseEntity.status(500).body("Failed to upload profile picture.");
        }
    }

    @GetMapping("/{id}/profile-picture")
    public ResponseEntity<byte[]> downloadProfilePicture(@PathVariable Long id) throws IOException {
        String filePath = employeeService.getProfilePicturePath(id);

        if (filePath == null || filePath.isEmpty()) {
            // Handle the case where the file path is null or empty
            return ResponseEntity.notFound().build();
        }

        Path path = Paths.get(filePath);

        if (!Files.exists(path)) {
            // Handle the case where the file does not exist
            return ResponseEntity.notFound().build();
        }

        byte[] image = Files.readAllBytes(path);

        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG) // Adjust this based on your image type
                .body(image);
    }

}
