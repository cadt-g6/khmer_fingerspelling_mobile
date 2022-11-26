import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/view_model_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_mobile.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<HomeViewModel>(
      create: (context) => HomeViewModel(),
      builder: (context, viewModel, child) {
        return HomeMobile(viewModel: viewModel);
      },
    );
  }
}
