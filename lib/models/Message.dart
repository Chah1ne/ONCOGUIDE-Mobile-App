import 'package:flutter/material.dart';

class Message {
  final String sender;
  final String receiver;
  final String message;
  final DateTime createdAt;

  Message({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      receiver: json['receiver'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
