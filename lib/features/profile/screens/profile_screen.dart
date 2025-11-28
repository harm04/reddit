import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    bool isLoading = ref.watch(authControllerProvider);

    return isLoading
        ? Loader()
        : ref
              .watch(userDetailsProvider(widget.userId))
              .when(
                data: (user) {
                  return Scaffold(
                    body: NestedScrollView(
                      headerSliverBuilder: (context, innerBosIsScrolled) {
                        return [
                          SliverAppBar(
                            automaticallyImplyActions: false,
                            floating: true,
                            snap: true,
                            expandedHeight: 150,
                            title: Text(
                              'Profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            flexibleSpace: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(user!.bannerPicture),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // child: Positioned.fill(
                                  //   child: Image.network(
                                  //     user!.bannerPicture,
                                  //     fit: BoxFit.cover,
                                  //   ),
                                  // ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 50, // Height of the shadow gradient
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(18),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                              user.profilePicture,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text('karma: ${user.karma}'),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'awards: ${user.awards.length}',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    user.uid == currentUser!.uid
                                        ? IconButton(
                                            onPressed: () {},
                                            icon: SvgPicture.asset(
                                              Constants.pencilPath,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        ];
                      },
                      body: Center(child: Text('Displaying communities')),
                    ),
                  );
                },
                error: (error, st) => ErrorText(error: error.toString()),
                loading: () => Loader(),
              );
  }
}
