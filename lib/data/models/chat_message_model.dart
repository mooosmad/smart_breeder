class ChatMessageModel {
  final String id;
  final String message;
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;
  final String? audioPath;
  final bool isVoiceMessage;
  final String? animalContext; // ID de l'animal concerné si applicable

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.audioPath,
    this.isVoiceMessage = false,
    this.animalContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'audioPath': audioPath,
      'isVoiceMessage': isVoiceMessage ? 1 : 0,
      'animalContext': animalContext,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      audioPath: json['audioPath'],
      isVoiceMessage: (json['isVoiceMessage'] is int)
          ? json['isVoiceMessage'] == 1
          : (json['isVoiceMessage'] ?? false),
      animalContext: json['animalContext'],
    );
  }

  bool get isFromUser => sender == 'user';
  bool get isFromAI => sender == 'ai';
}
