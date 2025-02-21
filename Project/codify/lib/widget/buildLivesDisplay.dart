import 'package:codify/provider/lives_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildLivesDisplay extends StatefulWidget {
  const BuildLivesDisplay({super.key});

  @override
  State<BuildLivesDisplay> createState() => _BuildLivesDisplayState();
}

class _BuildLivesDisplayState extends State<BuildLivesDisplay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final overlay = Overlay.of(context);
    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarHeight,
        right: 0,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: _buildOverlayContent(context),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _isOverlayVisible = true;
    _animationController.forward();
  }

  void _hideOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _animationController.reverse().then((_) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
      });
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    final livesProvider = Provider.of<LivesProvider>(context, listen: false);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 10),
                Text(
                  livesProvider.lives?.refillTime != null &&
                      livesProvider.lives!.refillTime!.inMinutes > 0
                      ? "Lives refill in ${livesProvider.lives?.refillTime?.inMinutes}min"
                      : "Lives Full Enjoy Learning",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _hideOverlay();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final livesProvider = Provider.of<LivesProvider>(context);
    int currentLives = livesProvider.lives?.currentLives ?? 0;

    return GestureDetector(
      onTap: () {
        if (_isOverlayVisible) {
          _hideOverlay();
        } else {
          _showOverlay(context);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < currentLives; i++)
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
              for (int i = currentLives; i < 5; i++)
                const Icon(
                  Icons.favorite_border,
                  color: Colors.black,
                  size: 28,
                ),
            ],
          ),
        ],
      ),
    );
  }
}