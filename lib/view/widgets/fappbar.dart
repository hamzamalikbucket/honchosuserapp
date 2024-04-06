import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import '../../constants.dart';
import '../../model/category_and_products_list.dart';
import '../../utils/colors.dart';
import 'ficon_button.dart';

class FAppBar extends SliverAppBar {
  final List<ScrollDataModel> data;
  final BuildContext context;
  final bool isCollapsed;
  final double expandedHeight;
  final double collapsedHeight;
  final AutoScrollController scrollController;
  final TabController tabController;
  final void Function(bool isCollapsed) onCollapsed;
  final void Function(int index) onTap;
  final Widget hideoutWidget;
  final Widget filterTextFieldWidget;

  FAppBar({
    required this.data,
    required this.context,
    required this.isCollapsed,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.scrollController,
    required this.onCollapsed,
    required this.onTap,
    required this.tabController,
    required this.hideoutWidget,
    required this.filterTextFieldWidget,
  }) : super(elevation: 4.0, pinned: true, forceElevated: true);

  @override
  Color? get backgroundColor => scheme.surface;

  @override
  bool get automaticallyImplyLeading => false;

  // @override
  // Widget? get leading {
  //   return Center(
  //     child: FIconButton(
  //       onPressed: () {},
  //       backgroundColor: backgroundColor,
  //       icon: Icon(Icons.arrow_back),
  //     ),
  //   );
  // }

  // @override
  // List<Widget>? get actions {
  //   return [
  //     FIconButton(
  //       backgroundColor: backgroundColor,
  //       onPressed: () {},
  //       icon: Icon(Icons.share_outlined),
  //     ),
  //     FIconButton(
  //       backgroundColor: backgroundColor,
  //       onPressed: () {},
  //       icon: Icon(Icons.info_outline),
  //     ),
  //   ];
  // }

  @override
  Widget? get title {
    return AnimatedOpacity(
      opacity: this.isCollapsed ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      child: filterTextFieldWidget,
    );
  }

  @override
  PreferredSizeWidget? get bottom {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: scheme.surface,
        child: TabBar(
          padding: EdgeInsets.zero,
          isScrollable: true,
          controller: tabController,
          indicatorPadding: const EdgeInsets.only(
            right: 0.0,
            bottom: 3,
            top: 3,
          ),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: scheme.onSurface,
          indicator: BoxDecoration(
            //color:darkRedColor,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.9],
              colors: [lightRedColor, darkRedColor],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          tabs: data.map((e) {
            return Container(
              height: 40,
              alignment: Alignment.center,
              //width: 80,
              child: Tab(
                //text: e.category!.name,
                child: Text(
                  e.category!.name.toString(),
                )
              ),
            );
          }).toList(),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget? get flexibleSpace {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final top = constraints.constrainHeight();
        final collapsedHeight = MediaQuery.of(context).viewPadding.top + kToolbarHeight + 48;
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          onCollapsed(collapsedHeight != top);
        });
        return FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: hideoutWidget,
        );
      },
    );
  }
}
