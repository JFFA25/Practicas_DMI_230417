/// Da formato a la clasificación de edad según el país.
class AgeRatings {

  /// [countryCode]: MX, US, DE, CN, EG.  [certification]: lo que devuelve The Movie DB.
  /// Si el país no tiene clasificación se muestra "NR" (sin clasificar).
  static String label( String countryCode, String certification ) {
    final value = certification.trim();
    if ( value.isEmpty ) return 'NR';

    // En Alemania TMDB devuelve solo el número (0, 6, 12, 16, 18): se muestra como FSK
    if ( countryCode == 'DE' && int.tryParse(value) != null ) return 'FSK $value';

    return value;
  }
}
