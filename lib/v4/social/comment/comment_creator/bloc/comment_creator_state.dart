part of 'comment_creator_bloc.dart';

class CommentCreatorState extends Equatable {
  const CommentCreatorState({
    required this.text,
    required this.replyTo,
  });

  final String text;
  final AmityComment? replyTo;

  @override
  List<Object?> get props => [text, replyTo];

  CommentCreatorState copyWith({
    String? text,
    AmityComment? replyTo,
  }) {
    return CommentCreatorState(
      text: text ?? this.text,
      replyTo: replyTo ?? this.replyTo, 
    );
  }
}