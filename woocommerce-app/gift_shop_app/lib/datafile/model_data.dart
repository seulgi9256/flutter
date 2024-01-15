import 'package:flutter/cupertino.dart';
import 'package:gift_shop_app/model/onboarding_slider.dart';

import '../generated/l10n.dart';
import '../model/language_model.dart';

class Data {


  static List<LanguageData> getLanguage() {
    return [
      LanguageData("English", "en", 1),
      LanguageData("Arabic", "ar", 2),
      LanguageData("spanish", "es", 3),
      LanguageData("german", "de", 4),
      LanguageData("italian", "it", 5),
      LanguageData("french", "fr", 6),
      LanguageData("russian", "ru", 7),
      LanguageData("ukrain", "uk", 8),
      LanguageData("polish", "pl", 9),
      LanguageData("hungarian", "hu", 10),
      LanguageData("hebrew", "he", 11),
      LanguageData("dutch", "nl", 12),
    ];
  }

  static List<Sliders> getSliderPages(BuildContext context) {
    return [
      Sliders(
          image: "onboarding1st_new.png",
          richTitle1st: S.of(context).unlimitedGiftsThatWillMake,
          richTitle2nd: S.of(context).youHappy,
          richTitle3rd: ""),
      Sliders(
          image: 'onboarding2nd_new.png',
          richTitle1st: S.of(context).amazingGiftVouchers,
          richTitle2nd: "",
          richTitle3rd: ""),
      Sliders(
          image: 'onboarding3rd_new.png',
          richTitle1st: "",
          richTitle2nd: S.of(context).surprise,
          richTitle3rd: S.of(context).yourLovedOnes),
    ];
  }
}
