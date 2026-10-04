import 'package:flutter_bloc/flutter_bloc.dart';

/// Event transformer that ignores new events while an event is actively processing (droppable).
/// Prevents double-taps on booking, payment, and submission buttons.
EventTransformer<E> droppable<E>() {
  return (events, mapper) {
    bool isProcessing = false;
    return events.asyncExpand((event) async* {
      if (!isProcessing) {
        isProcessing = true;
        try {
          yield* mapper(event);
        } finally {
          isProcessing = false;
        }
      }
    });
  };
}
