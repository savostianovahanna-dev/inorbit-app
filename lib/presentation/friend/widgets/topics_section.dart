import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/repositories/friend_repository.dart';
import 'add_topic_input.dart';
import 'topic_chip.dart';

/// "Topics to discuss" section.
///
/// Topics are shown as deletable chips. Tapping "Add topic" reveals a
/// full-width text field (styled like the create-friend name input).
/// All mutations are persisted via [FriendRepository.updateFriend].
class TopicsSection extends StatefulWidget {
  const TopicsSection({super.key, required this.friend});

  final Friend friend;

  @override
  State<TopicsSection> createState() => _TopicsSectionState();
}

class _TopicsSectionState extends State<TopicsSection> {
  late List<String> _topics;
  bool _addingTopic = false;
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  final _inputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _topics = List<String>.from(widget.friend.topics);
    _inputFocus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TopicsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friend.topics != widget.friend.topics) {
      setState(() => _topics = List<String>.from(widget.friend.topics));
    }
  }

  @override
  void dispose() {
    _inputFocus.removeListener(_onFocusChanged);
    _inputFocus.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_inputFocus.hasFocus) {
      // Wait for keyboard to fully appear, then scroll to show the input.
      Future.delayed(const Duration(milliseconds: 400), () {
        final ctx = _inputKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _openInput() {
    setState(() => _addingTopic = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _inputFocus.requestFocus(),
    );
  }

  void _submitTopic() {
    final text = _inputController.text.trim();
    _inputController.clear();
    _inputFocus.unfocus();
    setState(() => _addingTopic = false);
    if (text.isEmpty || _topics.contains(text)) return;
    _persist([..._topics, text]);
  }

  void _cancelInput() {
    _inputController.clear();
    _inputFocus.unfocus();
    setState(() => _addingTopic = false);
  }

  Future<void> _persist(List<String> updated) async {
    setState(() => _topics = updated);
    try {
      await getIt<FriendRepository>().updateFriend(
        widget.friend.copyWith(topics: updated),
      );
    } catch (_) {
      // Revert on failure.
      if (mounted) setState(() => _topics = List<String>.from(_topics));
    }
  }

  void _deleteTopic(String text) {
    _persist(_topics.where((t) => t != text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics to discuss',
          style: AppTextStyles.sectionHeading.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 10),

        // Chips row + "Add topic" button (only when not currently editing)
        if (_topics.isNotEmpty || !_addingTopic)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final topic in _topics)
                TopicChip(
                  key: ValueKey(topic),
                  label: topic,
                  onDelete: () => _deleteTopic(topic),
                ),
              if (!_addingTopic) AddTopicInput(onTap: _openInput),
            ],
          ),

        // Full-width input (styled like the create-friend name input)
        if (_addingTopic) ...[
          if (_topics.isNotEmpty) const SizedBox(height: 8),
          SizedBox(
            key: _inputKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.63),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitTopic(),
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type topic…',
                        hintStyle: AppTextStyles.bodyRegular14.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary.withValues(alpha: 0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelInput,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
