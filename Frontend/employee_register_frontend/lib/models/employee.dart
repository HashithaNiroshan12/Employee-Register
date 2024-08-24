class Employee {
  final int id;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? profilePicturePath;

  Employee({required this.id,  this.firstname,  this.lastname, this.email,  this.profilePicturePath});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      profilePicturePath: json['profilePicturePath'] ?? '',
    );
  }

  // Method to convert an Employee object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'profileImageUrl': profilePicturePath,
    };
  }
}
