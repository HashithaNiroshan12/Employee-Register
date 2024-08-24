package com.example.employeeregiter.repository;

import com.example.employeeregiter.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmployeeRepository extends JpaRepository<Employee,Long> {
}
