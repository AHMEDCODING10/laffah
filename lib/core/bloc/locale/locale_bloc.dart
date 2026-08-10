import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_event.dart';
import 'locale_state.dart';

const String _prefLanguageCode = 'locale_language_code';
const String _defaultLanguageCode = 'ar';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences sharedPreferences;

  LocaleBloc({required this.sharedPreferences}) : super(const LocaleState(Locale(_defaultLanguageCode))) {
    on<LoadSavedLocale>((event, emit) {
      final savedLanguageCode = sharedPreferences.getString(_prefLanguageCode);
      if (savedLanguageCode != null) {
        emit(LocaleState(Locale(savedLanguageCode)));
      } else {
        emit(const LocaleState(Locale(_defaultLanguageCode)));
      }
    });

    on<ChangeLocale>((event, emit) async {
      await sharedPreferences.setString(_prefLanguageCode, event.locale.languageCode);
      emit(LocaleState(event.locale));
    });
  }
}
