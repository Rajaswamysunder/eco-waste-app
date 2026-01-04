import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  String get role => _user?.role ?? 'user';

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updateUserDetails({
    String? name,
    String? phone,
    String? address,
  }) {
    if (_user != null) {
      _user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
        address: address ?? _user!.address,
        role: _user!.role,
        assignedStreet: _user!.assignedStreet,
        createdAt: _user!.createdAt,
      );
      notifyListeners();
    }
  }
}
