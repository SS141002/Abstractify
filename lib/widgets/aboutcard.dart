import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsCard extends StatefulWidget {
  const AboutUsCard({
    super.key,
    required this.name,
    required this.link,
    required this.avatarImage,
    this.iconImage = 'assets/images/linkedin.png',
    this.onTap,
  });

  final String name;
  final String link;
  final String avatarImage;
  final String iconImage;
  final VoidCallback? onTap;

  @override
  State<AboutUsCard> createState() => _AboutUsCardState();
}

class _AboutUsCardState extends State<AboutUsCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  Future<void> _launchProfile() async {
    try {
      final uri = Uri.parse(widget.link);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${widget.link}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap ?? _launchProfile,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _isHovered ? 1.03 : 1.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isHovered
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            elevation: _isPressed
                ? 8
                : _isHovered
                    ? 6
                    : 4,
            color: _isPressed
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..translate(
                        0.0,
                        _isPressed
                            ? 4.0
                            : _isHovered
                                ? -2.0
                                : 0.0,
                      ),
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage(widget.avatarImage),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: Image.asset(
                      widget.iconImage,
                      height: 32,
                    ),
                    tooltip: 'View LinkedIn profile',
                    onPressed: _launchProfile,
                    hoverColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
