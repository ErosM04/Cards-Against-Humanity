import 'package:material_ui/material_ui.dart';

/// Detached, bordered scrollable box rendering a single release-note section.
class ReleaseSectionBox extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color accentColor;

  const ReleaseSectionBox({
    super.key,
    required this.title,
    required this.items,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxListHeight =
        (MediaQuery.sizeOf(context).height * 0.16).clamp(80.0, 150.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF232327),
              border: Border.all(
                color: Colors.white.withAlpha(200),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(70),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(200),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxListHeight),
                child: Scrollbar(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, index) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('-'),
                        const SizedBox(width: 4),
                        Expanded(child: Text(items[index])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
