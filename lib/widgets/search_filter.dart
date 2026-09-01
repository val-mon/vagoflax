import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/providers/user.dart';

class SearchFilter extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  const SearchFilter({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getBookmarkIcon(User? user) {
    final currentText = _controller.text.trim();

    if (user == null) {
      return Icons.question_mark; // shouldn't be here...
    } else if (currentText.isEmpty) {
      return Icons.collections_bookmark_outlined;
    } else if (user.savedSearches.contains(_controller.text.trim())) {
      return Icons.bookmark_remove_outlined;
    } else {
      return Icons.bookmark_add_outlined;
    }
  }

  void _handleSavedSearches() {
    final currentText = _controller.text.trim();
    final user = context.read<UserProvider>().currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save searches.'),
        ),
      );
      return;
    }

    if (currentText.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final currentUser = dialogCtx.watch<UserProvider>().currentUser;
            final searches = currentUser?.savedSearches ?? [];

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              icon: const Icon(Icons.bookmark_outline, size: 28),
              title: const Text('Saved Searches'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              content: searches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "You haven't saved any searches yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                      ),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: searches.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final search = searches[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: const Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              title: Text(
                                search,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                color: Colors.grey[600],
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Remove',
                                onPressed: () {
                                  setDialogState(() {
                                    context
                                        .read<UserProvider>()
                                        .removeSavedSearch(search);
                                  });
                                },
                              ),
                              onTap: () {
                                _controller.text = search;
                                widget.onSearch(search);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (user.savedSearches.contains(currentText)) {
      context.read<UserProvider>().removeSavedSearch(currentText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search "$currentText" removed from saved searches.'),
        ),
      );
    } else {
      context.read<UserProvider>().addSavedSearch(currentText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search "$currentText" saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search jobs',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(_getBookmarkIcon(user), size: 20),
                  tooltip: 'Save / View saved searches',
                  onPressed: _handleSavedSearches,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: widget.onSearch,
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: widget.activeFilterCount > 0,
            label: Text('${widget.activeFilterCount}'),
            child: IconButton.filledTonal(
              tooltip: 'Filters',
              icon: const Icon(Icons.tune),
              onPressed: widget.onFilterTap,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
