/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../inherited_widgets/configurations_inherited_widgets.dart';
import '../models/models.dart';
import '../utils/constants/constants.dart';
import '../utils/emoji_parser.dart';
import '../utils/package_strings.dart';
import '../values/enumeration.dart';
import '../widgets/chat_view_inherited_widget.dart';
import '../widgets/profile_image_widget.dart';
import '../widgets/suggestions/suggestions_config_inherited_widget.dart';

/// Extension for DateTime to get specific formats of dates and time.
extension TimeDifference on DateTime {
  String getDay(String chatSeparatorDatePattern) {
    final now = DateTime.now();

    /// Compares only the year, month, and day of the dates, ignoring the time.
    /// For example, `2024-12-09 22:00` and `2024-12-10 00:05` are on different
    /// calendar days but less than 24 hours apart. This ensures the difference
    /// is based on the date, not the total hours between the timestamps.
    final targetDate = DateTime(year, month, day);
    final currentDate = DateTime(now.year, now.month, now.day);

    final differenceInDays = currentDate.difference(targetDate).inDays;

    if (differenceInDays == 0) {
      return PackageStrings.currentLocale.today;
    } else if (differenceInDays <= 1 && differenceInDays >= -1) {
      return PackageStrings.currentLocale.yesterday;
    } else {
      final DateFormat formatter = DateFormat(chatSeparatorDatePattern);
      return formatter.format(this);
    }
  }

  String get getDateFromDateTime {
    final DateFormat formatter = DateFormat(dateFormat);
    return formatter.format(this);
  }

  String get getTimeFromDateTime => DateFormat.Hm().format(this);
}

/// Extension on String which implements different types string validations.
extension ValidateString on String {
  bool get isImageUrl {
    final imageUrlRegExp = RegExp(imageUrlRegExpression);
    return imageUrlRegExp.hasMatch(this) || startsWith('data:image');
  }

  bool get fromMemory => startsWith('data:image');

  bool get isAllEmoji {
    for (String s in EmojiParser().unemojify(this).split(" ")) {
      if (!s.startsWith(":") || !s.endsWith(":")) {
        return false;
      }
    }
    return true;
  }

  bool get isUrl => Uri.tryParse(this)?.isAbsolute ?? false;

  Widget getUserProfilePicture({
    required ChatUser? Function(String) getChatUser,
    double? profileCircleRadius,
    EdgeInsets? profileCirclePadding,
  }) {
    final user = getChatUser(this);
    return Padding(
      padding: profileCirclePadding ?? const EdgeInsets.only(left: 4),
      child: ProfileImageWidget(
        imageUrl: user?.profilePhoto,
        imageType: user?.imageType,
        defaultAvatarImage: user?.defaultAvatarImage ?? Constants.profileImage,
        circleRadius: profileCircleRadius ?? 8,
        assetImageErrorBuilder: user?.assetImageErrorBuilder,
        networkImageErrorBuilder: user?.networkImageErrorBuilder,
        networkImageProgressIndicatorBuilder:
            user?.networkImageProgressIndicatorBuilder,
      ),
    );
  }
}

/// Extension on MessageType for checking specific message type
extension MessageTypes on MessageType {
  bool get isImage => this == MessageType.image;

  bool get isText => this == MessageType.text;

  bool get isVoice => this == MessageType.voice;

  bool get isCustom => this == MessageType.custom;

  bool get isFile => this == MessageType.file;
}

/// Extension on ConnectionState for checking specific connection.
extension ConnectionStates on ConnectionState {
  bool get isWaiting => this == ConnectionState.waiting;

  bool get isActive => this == ConnectionState.active;
}

/// Extension on nullable sting to return specific state string.
extension ChatViewStateTitleExtension on String? {
  String getChatViewStateTitle(ChatViewState state) {
    switch (state) {
      case ChatViewState.hasMessages:
        return this ?? '';
      case ChatViewState.noData:
        return this ?? PackageStrings.currentLocale.noMessage;
      case ChatViewState.loading:
        return this ?? '';
      case ChatViewState.error:
        return this ?? PackageStrings.currentLocale.somethingWentWrong;
    }
  }
}

/// Extension on State for accessing inherited widget.
extension StatefulWidgetExtension on State {
  ChatViewInheritedWidget? get chatViewIW =>
      context.mounted ? ChatViewInheritedWidget.of(context) : null;

  ReplySuggestionsConfig? get suggestionsConfig => context.mounted
      ? SuggestionsConfigIW.of(context)?.suggestionsConfig
      : null;

  ConfigurationsInheritedWidget get chatListConfig =>
      context.mounted && ConfigurationsInheritedWidget.of(context) != null
          ? ConfigurationsInheritedWidget.of(context)!
          : const ConfigurationsInheritedWidget(
              chatBackgroundConfig: ChatBackgroundConfiguration(),
              child: SizedBox.shrink(),
            );
}

/// Extension on State for accessing inherited widget.
extension BuildContextExtension on BuildContext {
  ChatViewInheritedWidget? get chatViewIW =>
      mounted ? ChatViewInheritedWidget.of(this) : null;

  ReplySuggestionsConfig? get suggestionsConfig =>
      mounted ? SuggestionsConfigIW.of(this)?.suggestionsConfig : null;

  ConfigurationsInheritedWidget get chatListConfig =>
      mounted && ConfigurationsInheritedWidget.of(this) != null
          ? ConfigurationsInheritedWidget.of(this)!
          : const ConfigurationsInheritedWidget(
              chatBackgroundConfig: ChatBackgroundConfiguration(),
              child: SizedBox.shrink(),
            );

  ChatBubbleConfiguration? get chatBubbleConfig =>
      chatListConfig.chatBubbleConfig;
}

extension TargetPlatformExtension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;

  bool get isIOS => this == TargetPlatform.iOS;

  // TODO(YASH): As audio_waveforms(https://pub.dev/packages/audio_waveforms)
  //  only supports Android & iOS as of now.
  bool get isAudioWaveformsSupported => isIOS || isAndroid;
}

extension ReplyMessageExteension on ReplyMessage {
  bool get isEmpty => messageId.isEmpty && message.isEmpty && replyTo != null
      ? replyTo!.isEmpty
      : true && replyBy.isEmpty;
}

extension ReactionExteension on Reaction {
  bool get isEmpty => reactions.isEmpty && reactedUserIds.isEmpty;
}

extension ListExtension<T> on List<T> {
  /// Returns the first element that matches [test], or `null` if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    final valuesLength = length;
    for (var i = 0; i < valuesLength; i++) {
      final element = this[i];
      if (test(element)) return element;
    }
    return null;
  }

  /// Extension method to convert a list to a map with customizable key-value pairs.
  /// * required: [getKey] to extract the key from each element of the list.
  ///
  /// (optional): [getValue] to determines the value associated with each element in the resulting map.
  /// If not provided, the elements themselves will be used as values.
  ///
  /// (optional): [where] return all elements that satisfy the predicate [where].
  /// Example:
  /// ```dart
  /// final numbers = <int>[1,2,3,4,5,6,7];
  /// result = numbers.toMap<int, int>(getKey: (e) => e, where: (x) => x > 5); // {6: 6, 7: 7}
  /// ```
  Map<K, V> toMap<K, V>({
    required K? Function(T element) getKey,
    V Function(T element)? getValue,
    bool Function(T element)? where,
  }) {
    assert(
      getValue == null && T is! V,
      'Ensure generic type of value of map is same as generic type of list',
    );

    final mapList = <K, V>{};

    for (final element in this) {
      if (element == null) continue;
      if (where != null && !where(element)) continue;
      final key = getKey(element);
      if (key == null) continue;
      mapList[key] = (getValue?.call(element) ?? element) as V;
    }
    return mapList;
  }
}
