import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_ozgur/model/radio.dart';
import 'package:radio_ozgur/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen(
      (event) {
        if (event == PlayerState.playing) {
          _isPlaying = true;
        } else {
          _isPlaying = false;
        }
        setState(() {});
      },
    );
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    setState(() {});
  }

  playMusic(String url) {
    _audioPlayer.play(UrlSource(url));
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Stack(
        clipBehavior: Clip.antiAlias,
        fit: StackFit.expand,
        children: [
          VxAnimatedBox() // Container gibi ancak daha özellikli (animasyonlu)
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor1,
                    AIColors.primaryColor2,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple300,
                  secondaryColor: Colors.white,
                ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(80).p16(),
          radios != null
              ? VxSwiper.builder(
                  // Kayan pencereler oluşturmak için kullanıldı.
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                      // Container
                      child: ZStack(
                        [
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                              child: rad.category.text.uppercase.white
                                  .make()
                                  .px16(),
                            )
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10)
                                .make(),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make()
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: [
                              const Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double tap to play".text.gray100.make(),
                            ].vStack(),
                          )
                        ],
                      ),
                    )
                            .clip(Clip
                                .antiAlias) // Category kutusunun dışarı taşan kısmını sildi.
                            .bgImage(
                              DecorationImage(
                                image: NetworkImage(rad.image),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.4),
                                  BlendMode.darken,
                                ),
                              ),
                            )
                            .border(color: Colors.black, width: 5)
                            .withRounded(value: 60.0)
                            .make()
                            .onInkDoubleTap(
                      () {
                        playMusic(rad.url);
                      },
                    ).p16() // Padding
                        ;
                  },
                ).centered()
              : const CircularProgressIndicator().centered(),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying ? CupertinoIcons.stop_circle : null,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
      ),
    );
  }
}
