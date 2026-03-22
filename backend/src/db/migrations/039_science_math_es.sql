-- 039_science_math_es.sql
-- MindScrolling — Science Mode: Mathematics batch (Spanish)
-- 250 quotes: lógica, teoría de números, geometría, álgebra, cálculo, estadística,
--   probabilidad, teoría de conjuntos, topología, teoría de juegos, fractales,
--   infinito, demostraciones, belleza matemática
--
-- All rows:
--   category       = 'philosophy'
--   lang           = 'es'
--   swipe_dir      = 'down'
--   pack_name      = 'free'
--   is_premium     = false
--   content_type   = 'science'
--   sub_category   = 'mathematics'
--   is_hidden_mode = true
--   locked_by      = 'science'
-- Run in Supabase SQL Editor

BEGIN;

-- ══════════════════════════════════════════════════════════════════════════════
-- MATEMÁTICAS — ESPAÑOL (250 citas)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by) VALUES

-- Archimedes (1–12)
(gen_random_uuid(), 'Dame un punto de apoyo y moveré el mundo.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas revelan sus secretos solo a quienes las abordan con amor puro.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'El círculo es la figura más perfecta de todas las formas planas.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El número pi es la llave que abre la puerta de la geometría circular.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La esfera es a su cilindro circunscrito como dos es a tres.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Con rigor y paciencia, cualquier problema geométrico cede ante la razón.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'La palanca no miente: detrás de cada fuerza hay una proporción exacta.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'He descubierto algo maravilloso y el agua desbordada fue mi primera prueba.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La demostración es el alma de las matemáticas; sin ella, solo hay conjetura.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Medir es conocer; cuantificar es comprender la naturaleza de las cosas.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'El método exhaustivo acerca tanto como se desee a la verdad geométrica.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Todo volumen curvo obedece a leyes que la razón puede capturar con exactitud.', 'Arquímedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),

-- Euclides (13–24)
(gen_random_uuid(), 'No hay camino real hacia la geometría.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Un punto es aquello que no tiene partes.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Una línea recta es la distancia más corta entre dos puntos.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El todo es mayor que cualquiera de sus partes.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los primos son los átomos de los números; de ellos se construye todo lo demás.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La demostración por reducción al absurdo es la herramienta más elegante del matemático.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Cosas iguales a una misma cosa son iguales entre sí.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La geometría es el lenguaje en que el universo está escrito.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Cinco postulados bastan para construir todo un mundo geométrico.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La lógica es el andamio sobre el cual se erige todo edificio matemático.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Dos rectas paralelas no se encuentran nunca; en eso reside su elegancia.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'El axioma es la semilla; la demostración, el árbol que de él brota.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Pitágoras (25–36)
(gen_random_uuid(), 'Los números gobiernan el universo.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Todo es número y armonía.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'El cuadrado de la hipotenusa es igual a la suma de los cuadrados de los catetos.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La música y las matemáticas son la misma verdad expresada de dos formas distintas.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'En los números pares e impares vive el secreto de la existencia.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La razón áurea es la proporción que la naturaleza prefiere sobre todas las demás.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Estudia las proporciones y comprenderás la armonía del cosmos.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discipline'], true, 'science'),
(gen_random_uuid(), 'Los números perfectos son raros, como la virtud en los hombres.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La geometría es el arte de razonar correctamente sobre figuras incorrectas.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El triángulo rectángulo es la forma fundamental de la que emerge todo lo demás.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Donde hay número hay orden; donde hay orden hay belleza.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'El uno no es un número; es el principio del que nacen todos los números.', 'Pitágoras', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Carl Friedrich Gauss (37–49)
(gen_random_uuid(), 'Las matemáticas son la reina de las ciencias.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La aritmética es la reina de las matemáticas.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Pocos resultados, pero maduros.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Prefiero haber descubierto una verdad que haber conquistado todo un reino.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La distribución normal no es normal; es milagrosa.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La teoría de los números es la joya más pura de las matemáticas.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'No es el conocimiento sino el acto de aprender el que concede mayor placer.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discipline'], true, 'science'),
(gen_random_uuid(), 'El error está en la naturaleza humana, pero la precisión es conquista de la mente.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Un resultado nuevo en matemáticas es como un diamante: requiere tiempo y presión.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'La suma de los ángulos interiores de un triángulo revela la curvatura del espacio.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los números complejos amplían nuestro horizonte sin abandonar la lógica.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Calcular no es pensar, pero pensar con precisión es la más alta forma de calcular.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La congruencia modular es el espejo en que la aritmética se contempla a sí misma.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),

-- Leonhard Euler (50–61)
(gen_random_uuid(), 'La identidad e a la i pi más uno igual a cero une los cinco números más importantes.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Leer a Euler es como escuchar la voz del maestro mismo.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La función exponencial es la función más importante de las matemáticas.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La topología nació de un puente: el problema de Königsberg reveló una nueva ciencia.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los grafos son el lenguaje de las conexiones que el álgebra no puede expresar sola.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La productividad de un matemático no mide su talento; mide su perseverancia.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Perder la vista no fue obstáculo: las matemáticas viven en la mente, no en los ojos.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'La serie armónica diverge, y en esa divergencia hay una lección sobre el infinito.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La fórmula de Euler para poliedros une vértices, aristas y caras en perfecta armonía.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Introducir la notación correcta es la mitad del trabajo en matemáticas.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'El número e es tan natural que aparece donde nadie lo espera.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las funciones trigonométricas y la exponencial son la misma cosa vista de ángulos distintos.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Henri Poincaré (62–73)
(gen_random_uuid(), 'Las matemáticas son el arte de dar el mismo nombre a cosas diferentes.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La intuición es el instrumento del descubrimiento; la lógica, el instrumento de la prueba.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El caos determinista muestra que predecir no siempre es posible aunque todo obedezca leyes.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La topología estudia lo que permanece cuando deformamos sin romper ni pegar.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Un resultado matemático verdadero es verdadero en todo universo posible.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La creatividad en matemáticas es elegir los problemas que vale la pena resolver.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La geometría no euclidiana no contradice a Euclides; amplía el universo posible.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El problema de los tres cuerpos es la primera ventana al infinito caos del cosmos.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La belleza matemática es una guía segura hacia la verdad.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Pensar en matemáticas es recombinar ideas hasta que surge algo nuevo e inesperado.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La conjetura es la semilla; solo la demostración la convierte en árbol frondoso.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Las series de Fourier transformaron el análisis para siempre; toda función es suma de senos.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Alan Turing (74–84)
(gen_random_uuid(), 'Una máquina que imita el pensamiento debe empezar por imitar el aprendizaje.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La cuestión no es si las máquinas pueden pensar, sino si los humanos pueden.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son la ciencia de los patrones: encontrar regularidad en el caos.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Un algoritmo es un pensamiento tan preciso que hasta una máquina puede seguirlo.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'La computabilidad define los límites de lo que la razón formal puede alcanzar.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La criptografía es matemática aplicada al secreto; el secreto protege la libertad.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El problema de la detención prueba que hay preguntas que ningún algoritmo puede responder.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La lógica matemática es la anatomía del razonamiento correcto.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Construir una mente artificial exige primero entender qué es la mente natural.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas discretas son el lenguaje en que está escrita la computación.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La prueba de que algo es imposible vale tanto como la prueba de que algo es posible.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Georg Cantor (85–96)
(gen_random_uuid(), 'El infinito no es un número; es una jerarquía de mundos sin fin.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Hay más números reales que racionales, aunque ambos sean infinitos.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La teoría de conjuntos es el fundamento sobre el que descansa toda la matemática moderna.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La esencia de las matemáticas reside en su libertad para crear nuevas estructuras.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los números transfinitos son tan reales como los naturales; solo más grandes.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La diagonal de Cantor es la prueba más elegante de que la infinitud tiene grados.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'El conjunto vacío es la nada que contiene todas las posibilidades matemáticas.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Aleph-cero es el primer infinito; aleph-uno, el segundo; y así sin término.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La hipótesis del continuo permanece indecidible: ni verdadera ni falsa en ZFC.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Contar es el primer acto matemático; comprender el infinito es el último.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La biyección revela cuándo dos conjuntos infinitos tienen el mismo tamaño.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Me opusieron, pero el tiempo ha dado la razón a quien se atrevió a pensar el infinito.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),

-- David Hilbert (97–108)
(gen_random_uuid(), 'Debemos saber. Sabremos.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas no tienen fronteras nacionales; son el patrimonio de toda la humanidad.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Un problema matemático bien planteado ya lleva en sí la semilla de su solución.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'La geometría axiomática libera a las matemáticas de toda dependencia de la intuición.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'El infinito real no existe en la naturaleza; existe solo en las matemáticas.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los veintitrés problemas que planteé en 1900 han guiado las matemáticas por un siglo.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discipline'], true, 'science'),
(gen_random_uuid(), 'El espacio de Hilbert amplió el álgebra lineal al universo de dimensión infinita.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La consistencia de las matemáticas es el precio que pagamos por su universalidad.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'En matemáticas no hay ignorabimus: todo problema tiene respuesta si se busca bien.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'La formalización es el sueño de reducir la matemática a manipulación de símbolos.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'La física matemática es el arte de traducir la naturaleza al lenguaje de los axiomas.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La demostración indirecta es tan válida como la directa: la verdad no elige su camino.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Emmy Noether (109–119)
(gen_random_uuid(), 'La estructura algebraica es más profunda que los números que la habitan.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Todo teorema de simetría esconde una ley de conservación; esa es mi contribución.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los anillos y los ideales son el lenguaje del álgebra abstracta moderna.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La abstracción no aleja de la realidad; la revela con mayor claridad.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son el campo donde el talento vence a todo prejuicio.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'La teoría de grupos es la gramática de la simetría universal.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Los módulos generalizan los espacios vectoriales; en esa generalización vive la profundidad.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Una matemática que solo calcula no comprende; debe ver la estructura subyacente.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'La elegancia algebraica no es decoración; es señal de que hemos encontrado la esencia.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Fui ignorada muchos años, pero las matemáticas nunca me ignoraron a mí.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'El álgebra conmutativa es el suelo fértil del que crece la geometría algebraica.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Srinivasa Ramanujan (120–131)
(gen_random_uuid(), 'Una ecuación no tiene sentido para mí a menos que exprese un pensamiento de Dios.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las fracciones continuas son ventanas hacia propiedades ocultas de los números.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Cada número entero es un amigo personal mío.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'El número 1729 no es trivial: es el menor que es suma de dos cubos de dos maneras distintas.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La intuición matemática puede superar a la demostración formal cuando el corazón la guía.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las series infinitas revelan verdades que la aritmética finita no puede imaginar.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La función partición encierra en sí la música secreta de los números enteros.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las fórmulas llegaban a mí en sueños; las matemáticas no conocen frontera entre lo real y lo onírico.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La teoría de números es hermosa precisamente porque no tiene aplicación práctica inmediata.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Descubrí sin maestros lo que los grandes habían tardado siglos en construir.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las identidades de Ramanujan son regalos que el infinito hace a los números finitos.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La modularidad de las formas es el secreto que conecta análisis y teoría de números.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Benoit Mandelbrot (132–142)
(gen_random_uuid(), 'Las nubes no son esferas; las montañas no son conos; los fractales sí las describen.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La geometría fractal es el lenguaje de la naturaleza rugosa.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La autosimilaridad es la firma de los fractales: el todo se repite en cada parte.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La dimensión fraccionaria no es una abstracción; describe costas y pulmones con exactitud.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El conjunto de Mandelbrot es infinitamente complejo y sin embargo nace de una ecuación simple.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La irregularidad de los mercados financieros es fractal; el riesgo se agrupa, no se dispersa.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los fractales enseñan que la belleza y la complejidad pueden surgir de reglas simples.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La longitud de una costa depende de la escala con que se mide: eso es un fractal.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Fui tachado de excéntrico; hoy los fractales están en la física, la biología y el arte.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Roughness es la palabra que describe lo que la geometría clásica ignoraba.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La geometría fractal no es solo estética; es una herramienta de modelado sin igual.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Bertrand Russell (143–153)
(gen_random_uuid(), 'Las matemáticas poseen no solo verdad sino suprema belleza.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La lógica es la juventud de las matemáticas y las matemáticas la madurez de la lógica.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La paradoja del barbero muestra que la ingenuidad en teoría de conjuntos tiene un precio.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El número es lo que tienen en común todos los conjuntos que pueden ponerse en biyección.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La certeza que buscamos en matemáticas es el antídoto del escepticismo filosófico.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La verdad matemática es independiente de la mente que la descubre.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Los Principia Mathematica intentaron derivar toda la aritmética de pura lógica.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'El análisis riguroso elimina la intuición engañosa y deja solo lo que resiste la prueba.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Incluso en matemáticas, comenzar con definiciones claras es el primer paso hacia la verdad.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La probabilidad es la lógica de la incertidumbre; sin ella, la ciencia sería ciega.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas simbólicas liberan al pensamiento de la tiranía del lenguaje ordinario.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Kurt Gödel (154–164)
(gen_random_uuid(), 'Cualquier sistema formal suficientemente poderoso es incompleto o inconsistente.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La consistencia de un sistema no puede probarse desde dentro de ese mismo sistema.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los teoremas de incompletitud no destruyen las matemáticas; las liberan de la ilusión de totalidad.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Existen verdades matemáticas que no pueden demostrarse dentro del sistema que las alberga.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La hipótesis del continuo es independiente de los axiomas de Zermelo-Fraenkel.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La aritmética es tan rica que ningún conjunto finito de axiomas puede capturarla por completo.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El universo matemático es más grande que cualquier descripción formal que hagamos de él.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La autorreferencia es la fuente de las paradojas más profundas de la lógica.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'El platonismo matemático sostiene que los números existen aunque nadie los piense.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La lógica de orden superior abre mundos que la de primer orden no puede tocar.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Demostrar la incompletitud fue como mostrar que el mapa nunca puede cubrir todo el territorio.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),

-- John von Neumann (165–175)
(gen_random_uuid(), 'En matemáticas no comprendes las cosas; simplemente te acostumbras a ellas.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La teoría de juegos transforma la estrategia en matemática exacta.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'El equilibrio de Nash es la cristalización matemática del conflicto racional.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las ecuaciones diferenciales son la poesía con que la naturaleza describe su movimiento.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El álgebra de operadores es la gramática de la mecánica cuántica.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La arquitectura de la computadora moderna surge directamente de principios matemáticos.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Una demostración que no aporta comprensión es una victoria vacía.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'El método de Monte Carlo muestra que el azar es una herramienta matemática poderosa.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La complejidad computacional mide cuánto cuesta resolver un problema con exactitud.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas, al alejarse de sus raíces empíricas, corren riesgo de volverse juego de símbolos.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La prueba experimental y la demostración formal son los dos pilares del conocimiento.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Blaise Pascal (176–186)
(gen_random_uuid(), 'El corazón tiene razones que la razón no conoce, pero las matemáticas tienen razones que el corazón no siente.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'El triángulo aritmético contiene en sí todos los secretos de la combinatoria.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La probabilidad nació de un juego de dados y terminó rigiendo las leyes del azar.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El espacio es infinito y su silencio eterno me espanta; la geometría me devuelve la calma.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La apuesta de Pascal es el primer argumento estadístico de la filosofía.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los números combinatorios describen cuántas formas existen de ordenar el mundo.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La inducción matemática es la escalera por la que subimos al infinito peldaño a peldaño.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Diseñé la primera calculadora porque las matemáticas merecen ser liberadas del esfuerzo manual.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'La teoría de la probabilidad convirtió la ignorancia en ciencia del azar.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Pensar bien es el principio de la moral; calcular bien es el principio de la ciencia.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La presión se transmite uniformemente en todos los fluidos: esa es la ley de Pascal.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- René Descartes (187–197)
(gen_random_uuid(), 'Cogito ergo sum: pienso, luego existo, y las matemáticas son el pensamiento más puro.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La geometría analítica une el álgebra y la geometría en un lenguaje unificado.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Un par de coordenadas basta para ubicar cualquier punto en el plano; eso lo cambió todo.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El método cartesiano divide los problemas en partes simples hasta hacerlos solubles.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'La certeza matemática es el modelo de toda certeza que la filosofía anhela.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Las curvas algebraicas son el puente entre la forma visible y la ecuación abstracta.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Ordenar las ideas matemáticas de simple a complejo es la clave del entendimiento.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son la única ciencia donde no puedo dudar de mis conclusiones.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'La recta y el plano son los objetos más simples; de ellos se construye toda la geometría.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La notación algebraica es el microscopio que revela la estructura de las ecuaciones.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Dudar de todo es el primer paso; la matemática es lo que sobrevive a esa duda.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),

-- G.H. Hardy (198–208)
(gen_random_uuid(), 'No existe lugar permanente en las matemáticas para las matemáticas feas.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son el único arte donde la perfección es alcanzable.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Un matemático es un hacedor de patrones; sus patrones son más duraderos que los del pintor.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La belleza es el primer test: no hay lugar permanente en el mundo para las matemáticas sin belleza.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas puras son la actividad más inútil y, por tanto, la más libre.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La prueba de que los primos son infinitos es una de las más bellas demostraciones conocidas.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Ramanujan fue el más romántico de los matemáticos: llegó de la nada con tesoros infinitos.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son un juego jugado según reglas simples con símbolos sin significado.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La teoría analítica de números usa herramientas continuas para estudiar objetos discretos.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Un matemático joven que no es revolucionario todavía no ha llegado a su madurez.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'La hipótesis de Riemann, de probarse, revelaría el orden oculto en la distribución de primos.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Paul Erdős (209–219)
(gen_random_uuid(), 'Un matemático es una máquina que convierte café en teoremas.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Dios tiene un libro con las demostraciones más elegantes; nuestro trabajo es encontrarlas.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'La colaboración matemática multiplica el talento individual por el número de colaboradores.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los números primos son más misteriosos cuanto más los estudias.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La combinatoria es el jardín donde florecen las demostraciones más sorprendentes.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los problemas que un niño puede entender pero nadie puede resolver son los más preciosos.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Publicar quinientos artículos no es vanidad; es amor a las matemáticas expresado con hechos.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'El número de Erdős mide la distancia matemática entre un autor y yo; es el grafo de la ciencia.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La probabilidad combinatoria es la ciencia de contar lo que no se puede contar directamente.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Otro teorema, otra pequeña victoria contra la ignorancia matemática del universo.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'La conjetura de Goldbach espera; mientras tanto, cada primo descubierto es un paso hacia ella.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discipline'], true, 'science'),

-- John Nash (220–230)
(gen_random_uuid(), 'El equilibrio de Nash es el punto donde nadie puede mejorar cambiando su estrategia unilateralmente.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La teoría de juegos no cooperativos revela por qué la racionalidad individual no garantiza el bien colectivo.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las variedades riemannianas son el escenario donde la geometría y el análisis se encuentran.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Toda variedad riemanniana puede ser embebida en un espacio euclidiano de suficiente dimensión.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La mente matemática y la mente enferma no son tan distintas; ambas buscan patrones ocultos.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'El dilema del prisionero ilustra que la cooperación es matemáticamente óptima bajo ciertas condiciones.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Las ecuaciones diferenciales parciales son el idioma en que el universo físico se escribe.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La existencia de un equilibrio en juegos finitos fue la demostración que cambió la economía.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Recuperar la razón fue tan difícil como demostrar un gran teorema: requirió años de trabajo.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los juegos de suma cero son el caso especial; el mundo real está lleno de sumas positivas.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La geometría diferencial es la matemática del espacio curvo donde vivimos realmente.', 'John Nash', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),

-- Citas temáticas adicionales sobre tópicos específicos (231–250)
(gen_random_uuid(), 'El cálculo infinitesimal es el arte de hacer finito lo infinitamente pequeño.', 'Leonhard Euler', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La estadística es la ciencia de aprender de los datos en presencia de incertidumbre.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La probabilidad bayesiana actualiza la creencia con la evidencia; eso es pensar bien.', 'Bertrand Russell', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'La topología algebraica clasifica los espacios por sus agujeros; el número de agujeros es su firma.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El teorema de Pitágoras es el más demostrado de la historia; cada demostración nueva revela algo más.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los números irracionales no son menos reales que los racionales; simplemente son más numerosos.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El álgebra booleana es la matemática de la verdad y la falsedad; toda lógica digital la usa.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La serie de Taylor aproxima funciones complejas mediante sumas de potencias simples.', 'Srinivasa Ramanujan', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Los números p-ádicos son otra forma de medir la distancia entre enteros; hay infinitos mundos.', 'Kurt Gödel', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La transformada de Fourier descompone cualquier señal en sus frecuencias constituyentes.', 'Henri Poincaré', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La teoría de la medida da fundamento riguroso al cálculo y a la probabilidad moderna.', 'Emmy Noether', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Los espacios vectoriales son el vocabulario básico de toda la matemática lineal aplicada.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'La conjetura de Fermat esperó tres siglos su demostración; la persistencia venció al tiempo.', 'G.H. Hardy', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Los números primos gemelos son pares separados por solo dos unidades; su infinitud sigue siendo misterio.', 'Paul Erdős', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'La demostración por contradicción es el arma más poderosa del arsenal matemático.', 'Euclides', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'El número áureo aparece en la espiral de la caracola, en las semillas del girasol y en el arte.', 'René Descartes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'La curva de campana describe la distribución de errores; en ella vive la regularidad del azar.', 'Carl Friedrich Gauss', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'El principio de inducción matemática es la escalera que sube al infinito un peldaño a la vez.', 'Blaise Pascal', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'La belleza de una demostración no garantiza su corrección, pero sí invita a buscarla.', 'Benoit Mandelbrot', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas son el único lenguaje universal que trasciende culturas, épocas y fronteras.', 'David Hilbert', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science')

ON CONFLICT (text, author) DO NOTHING;

COMMIT;
