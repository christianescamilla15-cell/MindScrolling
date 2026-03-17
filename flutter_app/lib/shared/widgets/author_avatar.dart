import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';

/// Circular author portrait for quote cards.
///
/// Shows a real portrait for well-known philosophers (via Wikipedia/Wikimedia
/// thumbnails) and falls back to an elegant initial circle for others.
///
/// Usage:
/// ```dart
/// AuthorAvatar(name: 'Marcus Aurelius', size: 40, accentColor: AppColors.stoicism)
/// ```
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.accentColor,
  });

  final String name;
  final double size;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.stoicism;
    final url = _portraitUrl(name);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialFallback(
                initial: initial,
                color: color,
                size: size,
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return _InitialFallback(
                  initial: initial,
                  color: color,
                  size: size,
                );
              },
            )
          : _InitialFallback(
              initial: initial,
              color: color,
              size: size,
            ),
    );
  }

  /// Returns a Wikimedia thumbnail URL for known philosophers, or null.
  static String? _portraitUrl(String name) {
    final key = name.toLowerCase().trim();
    return _knownPortraits[key];
  }

  // Wikimedia Commons thumbnails (public domain portraits)
  // Format: 80px width for efficient mobile loading
  static const _knownPortraits = <String, String>{
    // Greek
    'marcus aurelius': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/MSR-ra-61-b-1-DM.jpg/200px-MSR-ra-61-b-1-DM.jpg',
    'marco aurelio': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/MSR-ra-61-b-1-DM.jpg/200px-MSR-ra-61-b-1-DM.jpg',
    'seneca': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Seneca-berlinantikensammlung-1.jpg/200px-Seneca-berlinantikensammlung-1.jpg',
    'séneca': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Seneca-berlinantikensammlung-1.jpg/200px-Seneca-berlinantikensammlung-1.jpg',
    'epictetus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Epicteti_Enchiridion_Latinis_versibus_adumbratum_%28Oxford_1715%29_frontispiece.jpg/200px-Epicteti_Enchiridion_Latinis_versibus_adumbratum_%28Oxford_1715%29_frontispiece.jpg',
    'epicteto': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Epicteti_Enchiridion_Latinis_versibus_adumbratum_%28Oxford_1715%29_frontispiece.jpg/200px-Epicteti_Enchiridion_Latinis_versibus_adumbratum_%28Oxford_1715%29_frontispiece.jpg',
    'plato': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Plato_Silanion_Musei_Capitolini_MC1377.jpg/200px-Plato_Silanion_Musei_Capitolini_MC1377.jpg',
    'platón': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Plato_Silanion_Musei_Capitolini_MC1377.jpg/200px-Plato_Silanion_Musei_Capitolini_MC1377.jpg',
    'aristotle': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Aristotle_Altemps_Inv8575.jpg/200px-Aristotle_Altemps_Inv8575.jpg',
    'aristóteles': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Aristotle_Altemps_Inv8575.jpg/200px-Aristotle_Altemps_Inv8575.jpg',
    'socrates': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Socrate_du_Louvre.jpg/200px-Socrate_du_Louvre.jpg',
    'sócrates': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Socrate_du_Louvre.jpg/200px-Socrate_du_Louvre.jpg',
    'heraclitus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Heraclitus%2C_Johannes_Moreelse.jpg/200px-Heraclitus%2C_Johannes_Moreelse.jpg',
    'heráclito': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Heraclitus%2C_Johannes_Moreelse.jpg/200px-Heraclitus%2C_Johannes_Moreelse.jpg',
    'pythagoras': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Kapitolinischer_Pythagoras_adjusted.jpg/200px-Kapitolinischer_Pythagoras_adjusted.jpg',
    'pitágoras': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Kapitolinischer_Pythagoras_adjusted.jpg/200px-Kapitolinischer_Pythagoras_adjusted.jpg',
    'democritus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Democritus2.jpg/200px-Democritus2.jpg',
    'demócrito': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Democritus2.jpg/200px-Democritus2.jpg',
    'cicero': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/M-T-Cicero.jpg/200px-M-T-Cicero.jpg',
    'cicerón': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/M-T-Cicero.jpg/200px-M-T-Cicero.jpg',
    'epicurus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Epikouros_BM_1843.jpg/200px-Epikouros_BM_1843.jpg',
    'epicuro': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Epikouros_BM_1843.jpg/200px-Epikouros_BM_1843.jpg',
    // Modern philosophers
    'nietzsche': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Nietzsche187a.jpg/200px-Nietzsche187a.jpg',
    'friedrich nietzsche': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Nietzsche187a.jpg/200px-Nietzsche187a.jpg',
    'immanuel kant': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Kant_gemaelde_3.jpg/200px-Kant_gemaelde_3.jpg',
    'arthur schopenhauer': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Arthur_Schopenhauer_by_J_Sch%C3%A4fer%2C_1859b.jpg/200px-Arthur_Schopenhauer_by_J_Sch%C3%A4fer%2C_1859b.jpg',
    'voltaire': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/D%27apr%C3%A8s_Maurice_Quentin_de_La_Tour%2C_Portrait_de_Voltaire%2C_d%C3%A9tail_du_visage_%28ch%C3%A2teau_de_Ferney%29.jpg/200px-D%27apr%C3%A8s_Maurice_Quentin_de_La_Tour%2C_Portrait_de_Voltaire%2C_d%C3%A9tail_du_visage_%28ch%C3%A2teau_de_Ferney%29.jpg',
    'confucius': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Confucius_Tang_Dynasty.jpg/200px-Confucius_Tang_Dynasty.jpg',
    'confucio': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Confucius_Tang_Dynasty.jpg/200px-Confucius_Tang_Dynasty.jpg',
    'lao tzu': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Zhang_Lu-Laozi_Riding_an_Ox.jpg/200px-Zhang_Lu-Laozi_Riding_an_Ox.jpg',
    'lao tse': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Zhang_Lu-Laozi_Riding_an_Ox.jpg/200px-Zhang_Lu-Laozi_Riding_an_Ox.jpg',
    'buddha': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Gandhara_Buddha_%28tnm%29.jpeg/200px-Gandhara_Buddha_%28tnm%29.jpeg',
    'buda': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Gandhara_Buddha_%28tnm%29.jpeg/200px-Gandhara_Buddha_%28tnm%29.jpeg',
    // Writers & thinkers
    'fyodor dostoevsky': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Vasily_Perov_-_%D0%9F%D0%BE%D1%80%D1%82%D1%80%D0%B5%D1%82_%D0%A4.%D0%9C.%D0%94%D0%BE%D1%81%D1%82%D0%BE%D0%B5%D0%B2%D1%81%D0%BA%D0%BE%D0%B3%D0%BE_-_Google_Art_Project.jpg/200px-Vasily_Perov_-_%D0%9F%D0%BE%D1%80%D1%82%D1%80%D0%B5%D1%82_%D0%A4.%D0%9C.%D0%94%D0%BE%D1%81%D1%82%D0%BE%D0%B5%D0%B2%D1%81%D0%BA%D0%BE%D0%B3%D0%BE_-_Google_Art_Project.jpg',
    'fiódor dostoyevski': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Vasily_Perov_-_%D0%9F%D0%BE%D1%80%D1%82%D1%80%D0%B5%D1%82_%D0%A4.%D0%9C.%D0%94%D0%BE%D1%81%D1%82%D0%BE%D0%B5%D0%B2%D1%81%D0%BA%D0%BE%D0%B3%D0%BE_-_Google_Art_Project.jpg/200px-Vasily_Perov_-_%D0%9F%D0%BE%D1%80%D1%82%D1%80%D0%B5%D1%82_%D0%A4.%D0%9C.%D0%94%D0%BE%D1%81%D1%82%D0%BE%D0%B5%D0%B2%D1%81%D0%BA%D0%BE%D0%B3%D0%BE_-_Google_Art_Project.jpg',
    'leo tolstoy': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/L.N.Tolstoy_Prokudin-Gorsky.jpg/200px-L.N.Tolstoy_Prokudin-Gorsky.jpg',
    'león tolstói': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/L.N.Tolstoy_Prokudin-Gorsky.jpg/200px-L.N.Tolstoy_Prokudin-Gorsky.jpg',
    'ralph waldo emerson': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Ralph_Waldo_Emerson_ca1857_retouched.jpg/200px-Ralph_Waldo_Emerson_ca1857_retouched.jpg',
    'albert einstein': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Albert_Einstein_Head.jpg/200px-Albert_Einstein_Head.jpg',
    'oscar wilde': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Oscar_Wilde_portrait.jpg/200px-Oscar_Wilde_portrait.jpg',
    'victor hugo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Victor_Hugo_by_%C3%89tienne_Carjat_1876_-_full.jpg/200px-Victor_Hugo_by_%C3%89tienne_Carjat_1876_-_full.jpg',
    'víctor hugo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Victor_Hugo_by_%C3%89tienne_Carjat_1876_-_full.jpg/200px-Victor_Hugo_by_%C3%89tienne_Carjat_1876_-_full.jpg',
    'mark twain': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Mark_Twain_by_AF_Bradley.jpg/200px-Mark_Twain_by_AF_Bradley.jpg',
    'william shakespeare': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Shakespeare.jpg/200px-Shakespeare.jpg',
    'mahatma gandhi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Mahatma-Gandhi%2C_studio%2C_1931.jpg/200px-Mahatma-Gandhi%2C_studio%2C_1931.jpg',
    'nelson mandela': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nelson_Mandela_1994.jpg/200px-Nelson_Mandela_1994.jpg',
    'martin luther king jr.': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Martin_Luther_King%2C_Jr..jpg/200px-Martin_Luther_King%2C_Jr..jpg',
    'winston churchill': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Sir_Winston_Churchill_-_19086236948.jpg/200px-Sir_Winston_Churchill_-_19086236948.jpg',
    'thomas aquinas': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/St-thomas-aquinas.jpg/200px-St-thomas-aquinas.jpg',
    'santo tomás de aquino': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/St-thomas-aquinas.jpg/200px-St-thomas-aquinas.jpg',
    'alexander the great': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Alexander_the_Great_mosaic.jpg/200px-Alexander_the_Great_mosaic.jpg',
    'alejandro magno': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Alexander_the_Great_mosaic.jpg/200px-Alexander_the_Great_mosaic.jpg',
    // Additional authors
    'albert camus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Albert_Camus%2C_gagnant_de_prix_Nobel%2C_portrait_en_buste%2C_pos%C3%A9_au_bureau%2C_faisant_face_%C3%A0_gauche%2C_cigarette_de_tabagisme.jpg/200px-Albert_Camus%2C_gagnant_de_prix_Nobel%2C_portrait_en_buste%2C_pos%C3%A9_au_bureau%2C_faisant_face_%C3%A0_gauche%2C_cigarette_de_tabagisme.jpg',
    'jean-paul sartre': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Sartre_1967_crop.jpg/200px-Sartre_1967_crop.jpg',
    'rumi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Mevlana_Celaleddin_Rumi.jpg/200px-Mevlana_Celaleddin_Rumi.jpg',
    'khalil gibran': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Kahlil_Gibran_1913.jpg/200px-Kahlil_Gibran_1913.jpg',
    'kahlil gibran': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Kahlil_Gibran_1913.jpg/200px-Kahlil_Gibran_1913.jpg',
    'plutarch': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Plutarch_of_Chaeronea-03-removebg-preview.png/200px-Plutarch_of_Chaeronea-03-removebg-preview.png',
    'plutarco': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Plutarch_of_Chaeronea-03-removebg-preview.png/200px-Plutarch_of_Chaeronea-03-removebg-preview.png',
    'sophocles': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Sophocles_pushkin.jpg/200px-Sophocles_pushkin.jpg',
    'sófocles': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Sophocles_pushkin.jpg/200px-Sophocles_pushkin.jpg',
    'virgil': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Virgil_mosaic_crop.jpg/200px-Virgil_mosaic_crop.jpg',
    'virgilio': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Virgil_mosaic_crop.jpg/200px-Virgil_mosaic_crop.jpg',
    'henry david thoreau': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Henry_David_Thoreau.jpg/200px-Henry_David_Thoreau.jpg',
    'benjamin franklin': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Joseph_Siffrein_Duplessis_-_Benjamin_Franklin_-_Google_Art_Project.jpg/200px-Joseph_Siffrein_Duplessis_-_Benjamin_Franklin_-_Google_Art_Project.jpg',
    'abraham lincoln': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Abraham_Lincoln_O-77_matte_collodion_print.jpg/200px-Abraham_Lincoln_O-77_matte_collodion_print.jpg',
    'francis of assisi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Cimabue_-_Saint_Francis.jpg/200px-Cimabue_-_Saint_Francis.jpg',
    'san francisco de asís': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Cimabue_-_Saint_Francis.jpg/200px-Cimabue_-_Saint_Francis.jpg',
    'marcus tullius cicero': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/M-T-Cicero.jpg/200px-M-T-Cicero.jpg',
    'aeschylus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Aischylos_B%C3%BCste.jpg/200px-Aischylos_B%C3%BCste.jpg',
    'esquilo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Aischylos_B%C3%BCste.jpg/200px-Aischylos_B%C3%BCste.jpg',
    'euripides': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Euripides_Pio-Clementino_Inv302.jpg/200px-Euripides_Pio-Clementino_Inv302.jpg',
    'eurípides': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Euripides_Pio-Clementino_Inv302.jpg/200px-Euripides_Pio-Clementino_Inv302.jpg',
    'ovid': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Ovid_Metamorphosen_Kupfertitel.jpg/200px-Ovid_Metamorphosen_Kupfertitel.jpg',
    'ovidio': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Ovid_Metamorphosen_Kupfertitel.jpg/200px-Ovid_Metamorphosen_Kupfertitel.jpg',
    'jorge luis borges': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Jorge_Luis_Borges_1951%2C_by_Grete_Stern.jpg/200px-Jorge_Luis_Borges_1951%2C_by_Grete_Stern.jpg',
    'paulo coelho': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/25_de_janeiro_de_2019_-_Paulo_Coelho_%28cropped_2%29.jpg/200px-25_de_janeiro_de_2019_-_Paulo_Coelho_%28cropped_2%29.jpg',
    'dalai lama': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Dalailama1_20121014_4639.jpg/200px-Dalailama1_20121014_4639.jpg',
    'thich nhat hanh': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Thich_Nhat_Hanh_12_%28cropped%29.jpg/200px-Thich_Nhat_Hanh_12_%28cropped%29.jpg',
    'thích nhất hạnh': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Thich_Nhat_Hanh_12_%28cropped%29.jpg/200px-Thich_Nhat_Hanh_12_%28cropped%29.jpg',
    // Modern thinkers & leaders
    'alan watts': 'https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/Alan_Watts_portrait.jpg/200px-Alan_Watts_portrait.jpg',
    'carl jung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/CGJung.jpg/200px-CGJung.jpg',
    'bruce lee': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Bruce_Lee_1973.jpg/200px-Bruce_Lee_1973.jpg',
    'thomas edison': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Thomas_Edison2.jpg/200px-Thomas_Edison2.jpg',
    'napoleon hill': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Napoleon_Hill_headshot.jpg/200px-Napoleon_Hill_headshot.jpg',
    'maya angelou': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Angelou_at_Clinton_inauguration_%28cropped_2%29.jpg/200px-Angelou_at_Clinton_inauguration_%28cropped_2%29.jpg',
    'mother teresa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Mother_Teresa_1.jpg/200px-Mother_Teresa_1.jpg',
    'viktor frankl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Viktor_Frankl2.jpg/200px-Viktor_Frankl2.jpg',
    'charles dickens': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Dickens_Gurney_head.jpg/200px-Dickens_Gurney_head.jpg',
    'john lennon': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/John_Lennon_1969_%28cropped%29.jpg/200px-John_Lennon_1969_%28cropped%29.jpg',
    'helen keller': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Helen_KellerA.jpg/200px-Helen_KellerA.jpg',
    'bertrand russell': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Bertrand_Russell_1957.jpg/200px-Bertrand_Russell_1957.jpg',
    'ernest hemingway': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/ErnestHemingway.jpg/200px-ErnestHemingway.jpg',
    'blaise pascal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Blaise_Pascal_Versailles.JPG/200px-Blaise_Pascal_Versailles.JPG',
    'johann wolfgang von goethe': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Goethe_%28Stieler_1828%29.jpg/200px-Goethe_%28Stieler_1828%29.jpg',
    'eleanor roosevelt': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Eleanor_Roosevelt_portrait_1933.jpg/200px-Eleanor_Roosevelt_portrait_1933.jpg',
    'wayne dyer': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/DrWayneDyer2009.jpg/200px-DrWayneDyer2009.jpg',
    'antoine de saint-exupéry': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Saint-Exup%C3%A9ry_par_un_photographe_inconnu.jpg/200px-Saint-Exup%C3%A9ry_par_un_photographe_inconnu.jpg',
    'john f. kennedy': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/John_F._Kennedy%2C_White_House_color_photo_portrait.jpg/200px-John_F._Kennedy%2C_White_House_color_photo_portrait.jpg',
    'albert schweitzer': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Bundesarchiv_Bild_183-D0116-0041-019%2C_Albert_Schweitzer.jpg/200px-Bundesarchiv_Bild_183-D0116-0041-019%2C_Albert_Schweitzer.jpg',
    'seneca the younger': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Seneca-berlinantikensammlung-1.jpg/200px-Seneca-berlinantikensammlung-1.jpg',
    'soren kierkegaard': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Kierkegaard.jpg/200px-Kierkegaard.jpg',
    'rené descartes': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Frans_Hals_-_Portret_van_Ren%C3%A9_Descartes.jpg/200px-Frans_Hals_-_Portret_van_Ren%C3%A9_Descartes.jpg',
    'ludwig wittgenstein': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Ludwig_Wittgenstein.jpg/200px-Ludwig_Wittgenstein.jpg',
    'theodore roosevelt': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/President_Roosevelt_-_Pach_Bros.jpg/200px-President_Roosevelt_-_Pach_Bros.jpg',
    'pablo picasso': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Pablo_picasso_1.jpg/200px-Pablo_picasso_1.jpg',
    'marie curie': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Marie_Curie_c._1920s.jpg/200px-Marie_Curie_c._1920s.jpg',
    'napoleon': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Jacques-Louis_David_-_The_Emperor_Napoleon_in_His_Study_at_the_Tuileries_-_Google_Art_Project.jpg/200px-Jacques-Louis_David_-_The_Emperor_Napoleon_in_His_Study_at_the_Tuileries_-_Google_Art_Project.jpg',
    'steve jobs': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Steve_Jobs_Headshot_2010-CROP_%28cropped_2%29.jpg/200px-Steve_Jobs_Headshot_2010-CROP_%28cropped_2%29.jpg',
    'henry ford': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Henry_ford_1919.jpg/200px-Henry_ford_1919.jpg',
    'george bernard shaw': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/George_Bernard_Shaw_1936.jpg/200px-George_Bernard_Shaw_1936.jpg',
    'galileo galilei': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Justus_Sustermans_-_Portrait_of_Galileo_Galilei%2C_1636.jpg/200px-Justus_Sustermans_-_Portrait_of_Galileo_Galilei%2C_1636.jpg',
    'aldous huxley': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Aldous_Huxley_psychedelic_experience.jpg/200px-Aldous_Huxley_psychedelic_experience.jpg',
    'george orwell': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/George_Orwell_press_photo.jpg/200px-George_Orwell_press_photo.jpg',
    'simone de beauvoir': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Simone_de_Beauvoir2.png/200px-Simone_de_Beauvoir2.png',
    'thomas jefferson': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Official_Presidential_portrait_of_Thomas_Jefferson_%28by_Rembrandt_Peale%2C_1800%29%28cropped%29.jpg/200px-Official_Presidential_portrait_of_Thomas_Jefferson_%28by_Rembrandt_Peale%2C_1800%29%28cropped%29.jpg',
    'miguel de cervantes': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Cervantes_J%C3%A1uregui.jpg/200px-Cervantes_J%C3%A1uregui.jpg',
    'rabindranath tagore': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Rabindranath_Tagore_in_1909.jpg/200px-Rabindranath_Tagore_in_1909.jpg',
    'baruch spinoza': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Spinoza.jpg/200px-Spinoza.jpg',
    'oprah winfrey': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Oprah_in_2014.jpg/200px-Oprah_in_2014.jpg',
    'coco chanel': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Coco_Chanel%2C_1920.jpg/200px-Coco_Chanel%2C_1920.jpg',
    'the buddha': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Gandhara_Buddha_%28tnm%29.jpeg/200px-Gandhara_Buddha_%28tnm%29.jpeg',
    'anaïs nin': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Anais_Nin.jpg/200px-Anais_Nin.jpg',
    'haruki murakami': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Murakami_Haruki_%282009%29.jpg/200px-Murakami_Haruki_%282009%29.jpg',
    'franklin d. roosevelt': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/FDR_1944_Color_Portrait.jpg/200px-FDR_1944_Color_Portrait.jpg',
    'kurt vonnegut': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Kurt_Vonnegut_1972.jpg/200px-Kurt_Vonnegut_1972.jpg',
  };
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({
    required this.initial,
    required this.color,
    required this.size,
  });

  final String initial;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
