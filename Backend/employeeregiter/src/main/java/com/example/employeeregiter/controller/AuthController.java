package com.example.employeeregiter.controller;

import com.example.employeeregiter.config.Impl.UserDetailsImpl;
import com.example.employeeregiter.config.jwt.JwtUtils;
import com.example.employeeregiter.model.ERoles;
import com.example.employeeregiter.model.Roles;
import com.example.employeeregiter.model.User;
import com.example.employeeregiter.payload.request.LoginRequest;
import com.example.employeeregiter.payload.request.SignupRequest;
import com.example.employeeregiter.payload.response.JwtResponse;
import com.example.employeeregiter.payload.response.MessageResponse;
import com.example.employeeregiter.repository.RoleRepository;
import com.example.employeeregiter.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.management.relation.Role;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*",maxAge = 3600)
@RestController
@RequestMapping("api/auth")
public class AuthController {

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    RoleRepository roleRepository;

    @Autowired
    PasswordEncoder encoder;

    @Autowired
    JwtUtils jwtUtils;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(item -> item.getAuthority())
                .collect(Collectors.toList());

        return ResponseEntity.ok(new JwtResponse(jwt,
                userDetails.getId(),
                userDetails.getUsername(),
                userDetails.getEmail(),
                roles));

    }

    @PostMapping("/signup")
    public  ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signupRequest) {

        if (userRepository.existsByUsername(signupRequest.getUsername())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error:Username is already taken!"));
        }

        if(userRepository.existsByEmail(signupRequest.getEmail())){
            return ResponseEntity.badRequest().body(new MessageResponse("Error:Email is already taken!"));
        }

        //Create new user

        User user = new User(signupRequest.getUsername(),signupRequest.getEmail(), encoder.encode(signupRequest.getPassword()));

        Set<String> userRoles = signupRequest.getRole();
        Set<Roles> roles = new HashSet<>();

        if(userRoles == null){
            Roles userRole = roleRepository.findByName(ERoles.USER)
                    .orElseThrow(()-> new RuntimeException("Error:ROle is not found"));
            roles.add(userRole);
        }else {
            userRoles.forEach(
                    role -> {
                        switch (role) {
                            case "admin":
                                Roles adminRole = roleRepository.findByName(ERoles.ADMIN)
                                        .orElseThrow(() -> new RuntimeException("Error:ROle is not found"));
                                roles.add(adminRole);
                                break;
                            default:
                                Roles userRole = roleRepository.findByName(ERoles.USER)
                                        .orElseThrow(() -> new RuntimeException("Error: ROle is not  found"));
                                roles.add(userRole);
                        }
                    });

        }
                        user.setRoles(roles);
                        userRepository.save(user);

                        return ResponseEntity.ok(new MessageResponse("User Registration Success"));
                    }

}
