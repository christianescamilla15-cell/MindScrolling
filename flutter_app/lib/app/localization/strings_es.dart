import 'app_strings.dart';

/// Spanish string implementations.
class StringsEs implements AppStrings {
  const StringsEs();

  // ------------------------------------------------------------------
  // General
  // ------------------------------------------------------------------
  @override
  String get appName => 'MindScroll';

  @override
  String get loading => 'Cargando…';

  @override
  String get vault => 'Bóveda';

  @override
  String get settings => 'Ajustes';

  @override
  String get streak => 'Racha';

  @override
  String get reflections => 'Reflexiones';

  @override
  String get save => 'Guardar';

  @override
  String get close => 'Cerrar';

  @override
  String get error => 'Algo salió mal';

  @override
  String get retry => 'Reintentar';

  // ------------------------------------------------------------------
  // Onboarding
  // ------------------------------------------------------------------
  @override
  String get onboardingTitle => 'Desplázate con intención.';

  @override
  String get onboardingSubtitle =>
      'Reemplaza el desplazamiento sin sentido con sabiduría duradera.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Comienza tu camino';

  @override
  String get onboardingProfile => 'Personalizar';

  // ------------------------------------------------------------------
  // Swipe direction labels
  // ------------------------------------------------------------------
  @override
  String get swipeUpLabel => 'Sabiduría';

  @override
  String get swipeRightLabel => 'Disciplina';

  @override
  String get swipeLeftLabel => 'Reflexión';

  @override
  String get swipeDownLabel => 'Filosofía';

  // ------------------------------------------------------------------
  // Profile form
  // ------------------------------------------------------------------
  @override
  String get ageRange => 'Rango de edad';

  @override
  String get interest => 'Interés principal';

  @override
  String get goal => 'Meta personal';

  @override
  String get language => 'Idioma';

  // ------------------------------------------------------------------
  // Features
  // ------------------------------------------------------------------
  @override
  String get challengeTitle => 'Reto de hoy';

  @override
  String get mapTitle => 'Mapa filosófico';

  // ------------------------------------------------------------------
  // Premium / monetisation
  // ------------------------------------------------------------------
  @override
  String get premiumUnlock => 'Desbloquear Premium';

  @override
  String get premiumPrice => '\$59 MXN una vez — para siempre';

  @override
  String get premiumFeature => 'Función Premium';

  // ------------------------------------------------------------------
  // Donations
  // ------------------------------------------------------------------
  @override
  String get donateTitle => 'Apoya MindScroll';

  @override
  String get donateBody =>
      'MindScroll es gratis y sin anuncios. Si te ha aportado valor, '
      'considera invitarme un café — eso mantiene el proyecto vivo.';

  @override
  String get donateBtn => 'Invítame un café ☕';

  // ------------------------------------------------------------------
  // Actions / toasts
  // ------------------------------------------------------------------
  @override
  String get shareVia => 'Compartir con…';

  @override
  String get savedVault => 'Guardado en la bóveda';

  @override
  String get removedLike => 'Me gusta eliminado';

  @override
  String get liked => '¡Me gusta!';

  @override
  String get alreadyVault => 'Ya está en tu bóveda';

  @override
  String get streakExtended => 'Racha extendida 🔥';

  @override
  String get copied => 'Copiado al portapapeles';

  @override
  String get doubleTapToLike => 'Toca dos veces para dar me gusta';

  @override
  String get exportImage => 'Exportar como imagen';

  // ------------------------------------------------------------------
  // Category names
  // ------------------------------------------------------------------
  @override
  String get philosophy => 'Filosofía';

  @override
  String get stoicism => 'Estoicismo';

  @override
  String get discipline => 'Disciplina';

  @override
  String get reflection => 'Reflexión';

  // ------------------------------------------------------------------
  // Category labels map
  // ------------------------------------------------------------------
  @override
  Map<String, String> get categoryLabels => const {
        'stoicism': 'Estoicismo',
        'philosophy': 'Filosofía',
        'discipline': 'Disciplina',
        'reflection': 'Reflexión',
      };
}
