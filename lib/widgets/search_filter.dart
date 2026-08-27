import 'package:flutter/material.dart';

class SearchFilter extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final int activeFilterCount;

  const SearchFilter({
    super.key,
    required this.onSearch,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search jobs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearch,
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: activeFilterCount > 0,
            label: Text('$activeFilterCount'),
            child: Builder(
              builder: (context) {
                return IconButton.filledTonal(
                  tooltip: 'Filters',
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
