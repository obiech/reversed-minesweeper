import 'package:equatable/equatable.dart';

import 'position.dart';

class PieceDragData extends Equatable {
  final int pieceId;
  final Position from;
  const PieceDragData({required this.pieceId, required this.from});

  @override
  List<Object?> get props => [pieceId, from];
}
