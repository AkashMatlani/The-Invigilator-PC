class Profile {
  String? profileImage = "";
  String? firstName = "";
  String? lastName = "";
  String? email = "";
  String? mobileNumber = "";
  String error = "";
  bool success = false;

  Profile(
      {this.profileImage,
      this.firstName,
      this.lastName,
      this.email,
      this.mobileNumber});
}
