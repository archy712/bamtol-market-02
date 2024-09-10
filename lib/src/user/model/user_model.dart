import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String? uid;
  final String? nickName;
  final double? temperature;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.uid,
    this.nickName,
    this.temperature,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? nickName,
    double? temperature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nickName: nickName ?? this.nickName,
      temperature: temperature ?? this.temperature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.create(String name, String uid) {
    return UserModel(
      nickName: name,
      uid: uid,
      temperature: Random().nextInt(100) + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
        uid,
        nickName,
        temperature,
        createdAt,
        updatedAt,
      ];
}
