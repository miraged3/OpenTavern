enum LlmStreamEventType { textDelta, reasoningDelta }

class LlmStreamEvent {
  const LlmStreamEvent.text(this.delta) : type = LlmStreamEventType.textDelta;

  const LlmStreamEvent.reasoning(this.delta)
    : type = LlmStreamEventType.reasoningDelta;

  final LlmStreamEventType type;
  final String delta;
}
