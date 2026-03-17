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
  String get loadingReflections => 'Cargando reflexiones…';

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
  String get premiumUnlock => 'Desbloquear MindScrolling Inside';

  @override
  String get premiumPrice => r'$59 MXN una vez — para siempre';

  @override
  String get premiumFeature => 'Función MindScrolling Inside';

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

  // ------------------------------------------------------------------
  // Navigation bottom bar
  // ------------------------------------------------------------------
  @override
  String get feed => 'Inicio';

  @override
  String get map => 'Mapa';

  @override
  String get insight => 'Reflexión';

  // ------------------------------------------------------------------
  // Settings screen
  // ------------------------------------------------------------------
  @override
  String get navigateTo => 'Ir a';

  @override
  String get about => 'Acerca de';

  @override
  String get reset => 'Restablecer';

  @override
  String get philosophyMap => 'Mapa filosófico';

  @override
  String get dailyChallenge => 'Reto diario';

  @override
  String get premium => 'MindScrolling Inside';

  @override
  String get donations => 'Donaciones';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get resetOnboarding => 'Reiniciar introducción';

  @override
  String get resetOnboardingTitle => '¿Reiniciar introducción?';

  @override
  String get resetOnboardingMsg =>
      'La introducción se mostrará de nuevo al reiniciar la app.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get onboardingResetDone =>
      'Introducción reiniciada. Reinicia la app para verla de nuevo.';

  @override
  String get couldNotOpenPrivacy => 'No se pudo abrir la política de privacidad';

  // ------------------------------------------------------------------
  // Feed screen
  // ------------------------------------------------------------------
  @override
  String get couldNotLoadQuotes => 'No se pudieron cargar las frases.';

  @override
  String get noQuotesAvailable => 'No hay frases disponibles.';

  @override
  String get noMoreQuotes =>
      'No hay más frases por ahora.\nRevisa tu conexión o actualiza para obtener más.';

  @override
  String get tryAgain => 'Reintentar';

  // ------------------------------------------------------------------
  // Onboarding screen
  // ------------------------------------------------------------------
  @override
  String get tellUsAboutYourself => 'Cuéntanos sobre ti';

  @override
  String get allFieldsOptional => 'Todos los campos son opcionales.';

  @override
  String get beginScrolling => 'Comenzar';

  @override
  String get youreAllSet => 'Todo listo.';

  @override
  String get wisdomAwaits => 'La sabiduría te espera en cada dirección.';

  @override
  String get starting => 'Iniciando…';

  @override
  String get startScrolling => 'Empezar a explorar';

  @override
  String get welcomeTitle => 'Bienvenido a MindScroll';

  @override
  String get welcomeSubtitle => 'Sabiduría filosófica para tu día a día';

  @override
  String get swipeToExplore => 'Desliza en cualquier dirección para explorar.';

  @override
  String get primaryInterest => 'Interés principal';

  @override
  String get yourGoal => 'Tu meta';

  // ------------------------------------------------------------------
  // Onboarding options
  // ------------------------------------------------------------------
  @override
  String get optPhilosophy => 'Filosofía';

  @override
  String get optStoicism => 'Estoicismo';

  @override
  String get optPersonalGrowth => 'Crecimiento personal';

  @override
  String get optMindfulness => 'Atención plena';

  @override
  String get optCuriosity => 'Curiosidad';

  @override
  String get optCalmMind => 'Mente tranquila';

  @override
  String get optDiscipline => 'Disciplina';

  @override
  String get optFindingMeaning => 'Encontrar sentido';

  @override
  String get optEmotionalClarity => 'Claridad emocional';

  // ------------------------------------------------------------------
  // Insights screen
  // ------------------------------------------------------------------
  @override
  String get weeklyInsight => 'Reflexión semanal';

  @override
  String get aiBadge => 'IA';

  @override
  String get refreshInsight => 'Actualizar reflexión';

  @override
  String get insightForming => 'Tu reflexión se está formando';

  @override
  String get insightFormingBody =>
      'Sigue explorando ideas filosóficas y tu reflexión semanal con IA aparecerá aquí.';

  @override
  String get insightTip1 =>
      'Desliza frases filosóficas para construir tu perfil.';

  @override
  String get insightTip2 => 'Da me gusta a las frases que resuenen contigo.';

  @override
  String get insightTip3 => 'Guarda tus favoritas en la Bóveda.';

  @override
  String get generatedByAI =>
      'Generado por Claude basado en tu recorrido filosófico esta semana.';

  @override
  String get couldNotRefresh =>
      'No se pudo actualizar. Mostrando la última reflexión conocida.';

  @override
  String get justGenerated => 'Recién generado';

  @override
  String get yesterday => 'ayer';

  @override
  String get daysAgo => 'días atrás';

  // ------------------------------------------------------------------
  // Vault screen
  // ------------------------------------------------------------------
  @override
  String get emptyVaultMsg => 'Guarda frases para construir tu bóveda';

  // ------------------------------------------------------------------
  // Challenges screen
  // ------------------------------------------------------------------
  @override
  String get dailyReflection => 'Reflexión diaria';

  @override
  String get defaultChallengeDesc =>
      'Reflexiona sobre un principio estoico hoy.';

  @override
  String get offlineChallenge => 'Mostrando reto sin conexión';

  @override
  String get logOneStep => 'Registrar un paso (+1)';

  @override
  String get completeChallenge => 'Completar reto';

  @override
  String get challengeCompleted => 'Reto completado';

  @override
  String get complete => '¡Completo!';

  @override
  String get progress => 'Progreso';

  @override
  String get dailyChallengeLabel => 'RETO DIARIO';

  @override
  String get percentComplete => '% completo';

  @override
  String get trackThis => 'Seguir este';

  // ------------------------------------------------------------------
  // Premium screen
  // ------------------------------------------------------------------
  @override
  String get unlockFullExperience => 'Desbloquea la experiencia completa';

  @override
  String get premiumSubtitle =>
      'Elimina todos los límites y distracciones.\nUn solo pago, para siempre.';

  @override
  String get alreadyPremium => 'MindScrolling Inside activo';

  @override
  String get featureColumn => 'Función';

  @override
  String get freeColumn => 'Gratis';

  @override
  String get premiumColumn => 'Inside';

  @override
  String get dailyFeed => 'Feed diario';

  @override
  String get limitedQuotes => 'Limitado (20 frases)';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get ads => 'Anuncios';

  @override
  String get occasional => 'Ocasionales';

  @override
  String get none => 'Ninguno';

  @override
  String get vaultSize => 'Tamaño de bóveda';

  @override
  String get savedQuotes20 => '20 frases guardadas';

  @override
  String get dailyChallenges => 'Retos diarios';

  @override
  String get viewOnly => 'Solo ver';

  @override
  String get fullAccess => 'Acceso completo';

  @override
  String get basic => 'Básico';

  @override
  String get fullPlusHistory => 'Completo + historial';

  @override
  String get oneTime => 'pago único';

  @override
  String get oneTimePurchase => 'Compra única — sin suscripción, nunca.';
  @override
  String get aiWeeklyInsight => 'Reflexión semanal IA';
  @override
  String get notIncluded => 'No incluido';
  @override
  String get included => 'Incluido';

  // ------------------------------------------------------------------
  // Philosophy Map screen
  // ------------------------------------------------------------------
  @override
  String get mapSubtitle =>
      'Tus tendencias filosóficas basadas en tu historial de deslizamiento.';

  @override
  String get saveSnapshot => 'Guardar captura';

  @override
  String get snapshotSaved => 'Captura guardada';

  @override
  String get snapshotError => 'Error al guardar la captura';

  // ------------------------------------------------------------------
  // Donations screen
  // ------------------------------------------------------------------
  @override
  String get supportMindScroll => 'Apoya MindScroll';

  @override
  String get donationDescription =>
      'MindScroll es un proyecto de pasión creado para llevar la filosofía atemporal a la vida cotidiana. Si te ha brindado un momento de claridad o calma, considera invitar un café — eso mantiene el proyecto vivo y en crecimiento.';

  @override
  String get everyContribution => 'Cada contribución es profundamente apreciada.';

  @override
  String get buyMeCoffee => 'Invítame un café';

  @override
  String get couldNotOpenDonation => 'No se pudo abrir la página de donación.';

  // ------------------------------------------------------------------
  // Swipe hint overlay
  // ------------------------------------------------------------------
  @override
  String get hintPhilosophy => 'FILOSOFÍA';

  @override
  String get hintStoicism => 'ESTOICISMO';

  @override
  String get hintDiscipline => 'DISCIPLINA';

  @override
  String get hintReflection => 'REFLEXIÓN';

  // Premium purchase flow
  @override
  String get restorePurchases => 'Restaurar compras';
  @override
  String get purchaseSuccess => '¡Bienvenido a MindScrolling Inside!';
  @override
  String get purchaseFailed => 'La compra no se pudo completar. Inténtalo de nuevo.';
  @override
  String get restoreSuccess => '¡Tu compra ha sido restaurada!';
  @override
  String get restoreFailed => 'No se pudieron restaurar las compras. Inténtalo de nuevo.';
  @override
  String get noPurchasesFound => 'No se encontraron compras anteriores.';
  @override
  String get premiumActive => 'MindScrolling Inside está activo';
  @override
  String get premiumRequired => 'Esta función requiere MindScrolling Inside';
  @override
  String get purchasing => 'Procesando compra...';

  // Vault limit
  @override
  String get vaultLimitReached => 'Límite de bóveda alcanzado. Actualiza a MindScrolling Inside para almacenamiento ilimitado.';

  // Reset experience
  @override
  String get resetExperience => 'Reiniciar experiencia';
  @override
  String get resetExperienceTitle => '¿Reiniciar experiencia?';
  @override
  String get resetExperienceMsg => 'Esto eliminará todos tus datos incluyendo bóveda, me gusta, preferencias y mapa filosófico. Esta acción no se puede deshacer.';
  @override
  String get resetExperienceDone => 'Experiencia reiniciada. Reinicia la app.';

  // Feed limit
  @override
  String get feedLimitReached => 'Alcanzaste el límite gratuito de hoy. Actualiza para frases ilimitadas.';

  // Ambient audio
  @override String get ambientAudio    => 'Audio ambiental';
  @override String get soundscapes     => 'Paisajes sonoros';
  @override String get nowPlaying      => 'Reproduciendo';
  @override String get audioComingSoon => 'Pistas de audio proximamente';
  @override String get play            => 'Reproducir';
  @override String get pause           => 'Pausar';
  @override String get volume          => 'Volumen';

  // Trial
  @override String get trialActive        => 'Prueba gratuita';
  @override String trialDaysLeft(int d)   => '$d días restantes de prueba gratuita';
  @override String get trialExpiredTitle   => 'Tu prueba gratuita ha terminado';
  @override String get trialExpiredMsg     => 'Las funciones premium están desactivadas.\nDesbloquea el acceso completo con un pago único.';
  @override String get trialExpiredButton  => 'Desbloquear MindScrolling Inside — \$4.99';
  @override String get continueReading     => 'Continuar gratis';

  // Author detail
  @override String get authorLoadError => 'No se pudo cargar el autor';
  @override String get topQuotes       => 'Frases destacadas';

  // Notifications
  @override String get notifications        => 'Notificaciones';
  @override String get dailyReminder        => 'Tu reflexi\u00f3n te espera';
  @override String get dailyReminderBody    => 'Toma un momento para explorar una nueva perspectiva filos\u00f3fica.';
  @override String get weeklyMapTitle       => 'Tu mapa filos\u00f3fico est\u00e1 listo';
  @override String get weeklyMapBody        => 'Mira c\u00f3mo evolucion\u00f3 tu camino filos\u00f3fico esta semana.';
  @override String get reminderTime         => 'Hora del recordatorio';
  @override String get notificationsEnabled => 'Recordatorios diarios activados';
  @override String get notificationsDisabled => 'Recordatorios desactivados';

  // Streak milestones
  @override String get milestone7Title  => '7 d\u00edas de sabidur\u00eda';
  @override String get milestone7Msg    => 'Una semana de reflexi\u00f3n filos\u00f3fica. Una vida sin examen no merece ser vivida. \u2014 S\u00f3crates';
  @override String get milestone30Title => '30 d\u00edas de crecimiento';
  @override String get milestone30Msg   => 'Un mes de reflexi\u00f3n constante. Te est\u00e1s convirtiendo en quien deb\u00edas ser.';
  @override String get milestoneClose   => 'Continuar';

  // Vault export
  @override String get exportVault      => 'Exportar b\u00f3veda';
  @override String get exportVaultEmpty => 'A\u00fan no hay frases para exportar.';

  // Philosophy Map tabs
  @override String get today      => 'Hoy';
  @override String get evolution  => 'Evoluci\u00f3n';
  @override String get comparedTo => 'Comparado con';

  // Redeem code
  @override String get redeemCode         => 'Canjear c\u00f3digo';
  @override String get redeemCodeTitle    => 'Activar MindScrolling Inside';
  @override String get redeemCodeSubtitle => 'Si recibiste un c\u00f3digo de activaci\u00f3n, ingr\u00e9salo aqu\u00ed para desbloquear acceso premium de por vida.';
  @override String get activateCode       => 'Activar c\u00f3digo';
  @override String get redeemSuccess      => 'Acceso premium activado de por vida. Disfruta la experiencia completa.';
  @override String get redeemFailed       => 'No se pudo activar el c\u00f3digo. Int\u00e9ntalo de nuevo.';
  @override String get codeNotFound       => 'C\u00f3digo no encontrado. Verifica e int\u00e9ntalo de nuevo.';
  @override String get codeAlreadyUsed    => 'Este c\u00f3digo ya fue utilizado.';
  @override String get codeExpired        => 'Este c\u00f3digo ha expirado.';
  @override String get invalidCodeFormat  => 'Ingresa un c\u00f3digo de activaci\u00f3n v\u00e1lido.';
  @override String get haveActivationCode => '\u00bfTienes un c\u00f3digo de activaci\u00f3n?';

  // Reflection card
  @override String get takeABreath    => 'Toma un respiro.';
  @override String get doingWell      => 'Lo estás haciendo bien.';
  @override String get swipeContinue  => 'Desliza para continuar tu camino.';
}
