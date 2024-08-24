package com.example.employeeregiter.service;

import com.example.employeeregiter.model.Employee;
import com.example.employeeregiter.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmployeeService {

    @Autowired
    private EmployeeRepository employeeRepository;

    public Employee save(Employee employee) {
        return employeeRepository.save(employee);
    }

    public List<Employee> getAllEmployees() {
        return employeeRepository.findAll();
    }

    public Employee findById(Long id) {
        return employeeRepository.findById(id).orElseThrow(() -> new RuntimeException("Employee not found"));
    }

    public Employee update(Long id, Employee employee) {
        Employee existingEmployee = findById(id);
        existingEmployee.setFirstname(employee.getFirstname());
        existingEmployee.setLastname(employee.getLastname());
        existingEmployee.setEmail(employee.getEmail());
//        existingEmployee.setPhoneNumber(existingEmployee.getPhoneNumber());
        return employeeRepository.save(existingEmployee);
    }

    public void delete(Long id) {
        employeeRepository.deleteById(id);
    }

    public void updateProfilePicture(Long id, String filePath) {
        Employee employee = findById(id);
        employee.setProfilePicturePath(filePath);
        employeeRepository.save(employee);
    }

    public String getProfilePicturePath(Long id) {
        return findById(id).getProfilePicturePath();
    }

}
