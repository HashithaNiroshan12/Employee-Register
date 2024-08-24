package com.example.employeeregiter.repository;

import com.example.employeeregiter.model.ERoles;
import com.example.employeeregiter.model.Roles;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Roles,Long> {
    Optional<Roles> findByName(ERoles name);
}
