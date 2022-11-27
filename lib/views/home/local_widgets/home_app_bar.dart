import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/providers/theme_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_view.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_animated_icon.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_pop_up_menu_button.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle:
          Theme.of(context).brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      elevation: 0.0,
      leading: Center(
        child: IconButton(
          icon: ValueListenableBuilder<bool>(
            valueListenable: viewModel.drawerOpenedNotifier,
            builder: (context, opened, child) {
              return KfAnimatedIcons(
                showFirst: opened,
                duration: ConfigConstant.duration,
                secondChild: const Icon(Icons.menu),
                firstChild: const Icon(Icons.clear),
              );
            },
          ),
          onPressed: () {
            if (Scaffold.of(context).isDrawerOpen) {
              Scaffold.of(context).closeDrawer();
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
      ),
      actions: [
        // Center(
        //   child: IconButton(
        //     icon: Icon(Icons.folder_shared, color: Theme.of(context).colorScheme.primary),
        //     onPressed: () {
        //       viewModel.showImageSelector.value = !viewModel.showImageSelector.value;
        //     },
        //   ),
        // ),
        Center(
          child: IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleThemeMode();
            },
          ),
        ),
        Center(
          child: KfPopupMenuButton(
            fromAppBar: true,
            items: (BuildContext context) {
              return [
                KfPopMenuItem(
                  title: "Dictionary",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CharactersView()));
                  },
                  trailingIconData: Icons.keyboard_arrow_right,
                ),
                KfPopMenuItem(
                  title: "About us",
                  trailingIconData: Icons.keyboard_arrow_right,
                  onPressed: () {},
                ),
              ];
            },
            builder: (void Function() callback) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: callback,
              );
            },
          ),
        ),
      ],
    );
  }
}
