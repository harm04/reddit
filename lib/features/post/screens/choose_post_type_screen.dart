import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/post/screens/create_post_screen.dart';
import 'package:reddit/theme/pallete.dart';

class ChoosePostTypeScreen extends ConsumerWidget {
  const ChoosePostTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardSize = 120;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          spacing: 5,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(postType: 'Text'),
                ),
              ),
              child: SizedBox(
                height: cardSize,
                width: cardSize,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Constants.textPath,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          currentTheme.iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Text Post'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(postType: 'Image'),
                ),
              ),
              child: SizedBox(
                height: cardSize,
                width: cardSize,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Constants.imagePath,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          currentTheme.iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Image Post'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(postType: 'Link'),
                ),
              ),
              child: SizedBox(
                height: cardSize,
                width: cardSize,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Constants.linkPath,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          currentTheme.iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Link Post'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
