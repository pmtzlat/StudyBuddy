import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/services/logging_service.dart';



FormFieldValidator<String> integerValidator(BuildContext context) {
  final _localizations = AppLocalizations.of(context)!;
      return (value) {
        if (value == null || value.isEmpty) {
          return null; // Return null if the field is empty (no validation error)
        }

        // Use regular expression to check if the value is an integer
        final RegExp regex = RegExp(r'^[0-9]+$');
        if (!regex.hasMatch(value)) {
          return _localizations.intValidator; // Validation error message
        }

        return null; // Return null if the input is a valid integer
      };
    }

String? futureDateValidator(DateTime? value) {
  if (value == null) {
    // If no date is selected, return an error message
    return '';
  }

  final selectedDate = DateTime.now();

  //logger.i(getCurrentLocale());

  if (value.isBefore(selectedDate)) {
    // If the selected date is not in the future, return an error message
    if (getCurrentLocale() == 'en_US') return 'Choose date in the future';
    return 'Fecha debe ser futura';

  }

  // Return null if the validation passes
  return null;
}
String getCurrentLocale() {
  return Intl.defaultLocale ?? 'en_US'; // 'en' is the default locale
}