// References:
// https://github.com/juniorise/spooky-mb/blob/develop/lib/widgets/sp_pop_up_menu_button.dart

import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/core/mixins/stateful_mixin.dart';
import 'package:rect_getter/rect_getter.dart';

class KfPopMenuItem {
  final String title;
  final String? subtitle;
  final void Function()? onPressed;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  IconData? leadingIconData;
  IconData? trailingIconData;

  KfPopMenuItem({
    required this.title,
    this.onPressed,
    this.titleStyle,
    this.subtitleStyle,
    this.leadingIconData,
    this.trailingIconData,
    this.subtitle,
  });
}

class KfPopupMenuButton extends StatefulWidget {
  const KfPopupMenuButton({
    Key? key,
    required this.builder,
    required this.items,
    this.fromAppBar = false,
    this.dx,
    this.dy,
    this.dxGetter,
    this.dyGetter,
    this.onDimissed,
    this.smartDx = false,
  }) : super(key: key);

  /// show from left/right or dx
  /// base on touch position offset.
  /// `dx, dyGetter` is optional now.
  final bool smartDx;
  final bool fromAppBar;
  final Widget Function(void Function() callback) builder;
  final List<KfPopMenuItem> Function(BuildContext context) items;
  final void Function(KfPopMenuItem?)? onDimissed;

  final double Function(double dx)? dxGetter;
  final double Function(double dy)? dyGetter;

  final double? dx;
  final double? dy;

  @override
  State<KfPopupMenuButton> createState() => _KfPopupMenuButtonState();
}

class _KfPopupMenuButtonState extends State<KfPopupMenuButton> with StatefulMixin {
  RenderBox? overlay;
  Offset? childPosition;
  Size? childSize;

  GlobalKey<RectGetterState> globalKey = RectGetter.createGlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderObject? renderObject = Overlay.of(context)?.context.findRenderObject();
      if (renderObject is RenderBox) overlay = renderObject;
    });
  }

  RelativeRect? get relativeRect {
    if (childPosition == null || childSize == null) return null;
    return RelativeRect.fromSize(
      Rect.fromCenter(
        center: childPosition!,
        width: childSize!.width,
        height: childSize!.height,
      ),
      overlay!.size,
    );
  }

  double dxGetter(double dx) {
    if (widget.dxGetter != null) return widget.dxGetter!(dx);
    return dx;
  }

  double dyGetter(double dy) {
    if (widget.dyGetter != null) return widget.dyGetter!(dy);
    return dy;
  }

  void setChildPosition() {
    Rect? rect = RectGetter.getRectFromKey(globalKey);
    childPosition = rect?.center;
    childSize = rect?.size;
    if (widget.fromAppBar) {
      if (childPosition!.dx >= screenSize.width / 2) {
        childPosition = Offset(screenSize.width, 0);
      } else {
        childPosition = const Offset(0, 0);
      }
    } else {
      if (widget.smartDx && localPosition != null) {
        childPosition = Offset(
          localPosition!.dx > screenSize.width / 2 ? screenSize.width : 0.0,
          widget.dy ?? dyGetter(childPosition!.dy),
        );
      } else {
        childPosition = Offset(
          widget.dx ?? dxGetter(childPosition!.dx),
          widget.dy ?? dyGetter(childPosition!.dy),
        );
      }
    }
  }

  Offset? localPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.fromAppBar || widget.dxGetter != null || widget.dyGetter != null) {
      assert(widget.dx == null);
      assert(widget.dy == null);
    }

    if (widget.dx != null || widget.dy != null) {
      assert(widget.dyGetter == null);
      assert(widget.dxGetter == null);
    }

    return RectGetter(
      key: globalKey,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapDown: (detail) {
          localPosition = detail.localPosition;
        },
        onPanDown: (detail) {
          localPosition = detail.localPosition;
        },
        child: widget.builder(() async {
          setChildPosition();
          if (relativeRect == null) return;
          KfPopMenuItem? result = await showMenu<KfPopMenuItem>(
            context: context,
            position: relativeRect!,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: ConfigConstant.circlarRadius1,
              side: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            items: widget.items(context).map((e) => buildItem(e)).toList(),
          );
          if (result?.onPressed != null) result!.onPressed!();
          if (widget.onDimissed != null) widget.onDimissed!(result);
        }),
      ),
    );
  }

  PopupMenuItem<KfPopMenuItem> buildItem(KfPopMenuItem e) {
    return PopupMenuItem<KfPopMenuItem>(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.maybePop(context),
      value: e,
      child: ListTile(
        leading: e.leadingIconData != null
            ? Container(
                width: 40,
                alignment: Alignment.center,
                child: Icon(e.leadingIconData, color: e.titleStyle?.color),
              )
            : null,
        title: Text(e.title, textAlign: TextAlign.left, style: e.titleStyle),
        trailing: e.trailingIconData != null ? Icon(e.trailingIconData) : null,
        subtitle: e.subtitle != null
            ? Text(
                e.subtitle!,
                textAlign: TextAlign.left,
                style: e.subtitleStyle,
              )
            : null,
      ),
    );
  }
}
