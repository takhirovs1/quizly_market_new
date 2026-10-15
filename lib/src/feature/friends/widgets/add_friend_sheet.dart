import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/friends_cubit.dart';
import '../models/friends_discovery_model.dart';
import 'friend_search_tile.dart';

/// Bottom sheet to find and add friends — searches by name/username/ID, and
/// falls back to server suggestions (people the user shared a purchased test
/// with) when the query is empty.
class AddFriendSheet extends StatefulWidget {
  const AddFriendSheet({required this.cubit, super.key});

  final FriendsCubit cubit;

  @override
  State<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<AddFriendSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => widget.cubit.searchUsers(value));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    widget.cubit.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: hc.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(l10n.friendsAddTitle, style: quizText(18, wBold, hc.text)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: hc.surface2, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: hc.text3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onChanged,
                        autofocus: true,
                        style: quizText(15, wMedium, hc.text),
                        cursorColor: hc.primary,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: InputBorder.none,
                          hintText: l10n.friendsSearchHint,
                          hintStyle: quizText(15, wRegular, hc.text3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: BlocBuilder<FriendsCubit, FriendsState>(
                bloc: widget.cubit,
                builder: (context, state) => _body(context, state),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, FriendsState state) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final hasQuery = state.searchQuery.trim().isNotEmpty;

    if (!hasQuery) {
      final suggestions = state.suggestions?.suggestions ?? const <FriendSuggestion>[];
      if (suggestions.isEmpty) return _hint(context, l10n.friendsSearchPrompt);
      return _list(context, l10n.friendsSuggestionsTitle, suggestions);
    }

    return switch (state.searchStatus) {
      StateStatus.loading => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(color: hc.primary)),
      ),
      StateStatus.error => _hint(context, l10n.somethingWentWrong),
      _ =>
        state.searchResults.isEmpty
            ? _hint(context, l10n.friendsSearchEmpty)
            : _list(context, null, state.searchResults),
    };
  }

  Widget _list(BuildContext context, String? header, List<FriendSuggestion> items) {
    final hc = context.x.homeColors;
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: items.length + (header != null ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (header != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(header, style: quizText(13, wSemibold, hc.text3)),
          );
        }
        final item = items[header != null ? index - 1 : index];
        return FriendSearchTile(suggestion: item, onAdd: () => widget.cubit.sendFriendRequest(item.user.id));
      },
    );
  }

  Widget _hint(BuildContext context, String text) {
    final hc = context.x.homeColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: Text(text, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3)),
      ),
    );
  }
}
