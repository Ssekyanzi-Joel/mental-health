import 'package:flutter/material.dart';

class UnifiedBottomShell extends StatefulWidget {
  final List<Widget> pages;
  final List<NavigationItem> navigationItems;
  final int initialIndex;

  const UnifiedBottomShell({
    super.key,
    required this.pages,
    required this.navigationItems,
    this.initialIndex = 0,
  });

  @override
  State<UnifiedBottomShell> createState() => _UnifiedBottomShellState();
}

class _UnifiedBottomShellState extends State<UnifiedBottomShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: widget.pages),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.navigationItems.length, (i) {
              final isActive = i == _index;
              final item = widget.navigationItems[i];
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: screenWidth * 0.06, // responsive icon size
                      color: isActive ? Colors.green[700] : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03, // responsive text size
                        color: isActive ? Colors.green[700] : Colors.grey[600],
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        height: 3,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({required this.icon, required this.label});
}
