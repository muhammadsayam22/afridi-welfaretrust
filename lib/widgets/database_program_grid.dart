import 'package:flutter/material.dart';

/// Plain display data for a database-driven program card.
class ProgramRecord {
  final String title;
  final String description;
  final String image;

  const ProgramRecord({
    required this.title,
    required this.description,
    this.image = '',
  });
}

/// Renders a responsive grid of program cards loaded from SQLite.
///
/// Shows a loading indicator while data loads, an empty state when there are
/// no records, and an error state when queries fail.
class DatabaseProgramGrid<T> extends StatelessWidget {
  const DatabaseProgramGrid({
    super.key,
    required this.loader,
    required this.selector,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final Future<List<T>> loader;
  final ProgramRecord Function(T item) selector;
  final IconData fallbackIcon;
  final Color fallbackColor;

  static const Color _brandGreen = Color(0xFF087F5B);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: loader,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: _brandGreen),
            ),
          );
        }

        if (snapshot.hasError) {
          return _messageCard(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            message: 'We could not load this section right now. '
                'Please try again later.',
            color: Colors.red,
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _messageCard(
            icon: Icons.inbox_outlined,
            title: 'No records yet',
            message: 'Programs will be added soon. Please check back later.',
            color: Colors.grey,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 750 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 1.9 : 1.55,
              children: items.map((item) {
                final record = selector(item);
                return _programCard(record);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _programCard(ProgramRecord record) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: _imageOrFallback(record.image, fallbackIcon, fallbackColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            record.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            record.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageOrFallback(
    String image,
    IconData icon,
    Color color,
  ) {
    if (image.trim().isEmpty) {
      return _fallback(icon, color);
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(icon, color),
    );
  }

  Widget _fallback(IconData icon, Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 38),
    );
  }

  Widget _messageCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 42),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}