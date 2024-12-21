import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabTitles;

  const CustomTabBar({
    Key? key,
    required this.tabController,
    required this.tabTitles,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.tabTitles.length, (index) {
        final isSelected = _tabController.index == index;
        return GestureDetector(
          onTap: () => setState(() {
            _tabController.index = index;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF009A90) : const Color(0x009A90),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              widget.tabTitles[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    super.dispose();
  }
}
