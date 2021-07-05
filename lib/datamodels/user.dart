import 'package:firebase_database/firebase_database.dart';

class DBUser {
  String fullName;
  String email;
  String phone;
  String id;
  DBUser({
    this.email,
    this.fullName,
    this.phone,
    this.id,
  });

  DBUser.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
  }
}
