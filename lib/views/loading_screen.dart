import 'package:emmie/providers/emmie_providers.dart';
import 'package:emmie/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDefaultTheme = themeMode == ThemeModeOptions.light ? true : false;

    final shimmmerBaseColor = isDefaultTheme ? Colors.grey.shade200 : const Color(0xFF252525);
    final shimmmerHighlightColor = isDefaultTheme ? Colors.grey.shade300 : const Color(0xFF303030);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        leading: _customMenuIcon(context: context, baseColor: shimmmerBaseColor, highlightColor: shimmmerHighlightColor),
        iconTheme: Theme.of(context).iconTheme,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        title: _AppBarTitle(baseColor: shimmmerBaseColor, highlightColor: shimmmerHighlightColor),
        actions: [
          Shimmer.fromColors(
            baseColor: shimmmerBaseColor,
            highlightColor: shimmmerHighlightColor,
            child: const SizedBox(width: 20, child: CircleAvatar()),
          ),
          const SizedBox(
            width: 15,
          ),
          Shimmer.fromColors(
            baseColor: shimmmerBaseColor,
            highlightColor: shimmmerHighlightColor,
            child: Container(
              width: 25,
              height: 0,
              margin: const EdgeInsets.symmetric(vertical: 20).copyWith(right: 10),
              decoration: BoxDecoration(
                color: shimmmerHighlightColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 20, bottom: 10),
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return index % 2 == 0
                    ? Shimmer.fromColors(
                        baseColor: shimmmerBaseColor,
                        highlightColor: shimmmerHighlightColor,
                        child: const _MessageOwnTile(),
                      )
                    : Shimmer.fromColors(
                        baseColor: shimmmerBaseColor,
                        highlightColor: shimmmerHighlightColor,
                        child: const _MessageTile(),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Column _customMenuIcon({required BuildContext context, required Color baseColor, required Color highlightColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 16,
            height: 5,
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 14,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 5).copyWith(left: 10),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 20,
            height: 5,
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  const _AppBarTitle({required this.baseColor, required this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: const CircleAvatar(),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile();

  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 15.0,
                ),
              ),
            ),
            // const SizedBox(height: 2),
            // Padding(
            //   padding: const EdgeInsets.only(top: 2.0),
            //   child: Container(
            //     width: 25,
            //     height: 10,
            //     margin: const EdgeInsets.symmetric(vertical: 5).copyWith(left: 3),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF252525),
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile();

  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
            ),
            // const SizedBox(height: 2),
            // Padding(
            //   padding: const EdgeInsets.only(top: 2.0),
            //   child: Container(
            //     width: 25,
            //     height: 10,
            //     margin: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 3),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF252525),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
