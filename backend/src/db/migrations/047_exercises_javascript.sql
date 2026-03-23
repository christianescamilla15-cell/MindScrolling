-- 047_exercises_javascript.sql
-- 100 JavaScript exercises, bilingual EN+ES
-- Difficulty distribution: 1→25, 2→25, 3→25, 4→15, 5→10
-- Points: 10/20/30/50/100 | Penalty: 3/3/5/10/10

BEGIN;

INSERT INTO exercises (
  id, title_en, title_es,
  description_en, description_es,
  language, difficulty, category,
  starter_code, solution, expected_output,
  hint_count,
  hint_1_en, hint_1_es,
  hint_2_en, hint_2_es,
  hint_3_en, hint_3_es,
  points, hints_used_penalty, created_at
) VALUES

-- ============================================================
-- DIFFICULTY 1 — 25 exercises (basics x8, strings x6, math x5, arrays x4, functions x2)
-- ============================================================

-- 1
(gen_random_uuid(), 'Console Log', 'Registro en Consola',
'Print "Hello, World!" to the console.',
'Imprime "Hello, World!" en la consola.',
'javascript', 1, 'basics',
'// Print Hello, World!
console.log(___)',
'console.log("Hello, World!")',
'Hello, World!', 3,
'Use console.log() to print text.', 'Usa console.log() para imprimir texto.',
'Pass a string inside parentheses.', 'Pasa un string dentro de los paréntesis.',
'console.log("Hello, World!")', 'console.log("Hello, World!")',
10, 3, now()),

-- 2
(gen_random_uuid(), 'Declare a Variable', 'Declarar una Variable',
'Declare a variable named "age" with value 25 using let, then print it.',
'Declara una variable llamada "age" con valor 25 usando let, luego imprímela.',
'javascript', 1, 'basics',
'___ age = ___;
console.log(age)',
'let age = 25;
console.log(age)',
'25', 3,
'Use the let keyword to declare a variable.', 'Usa la palabra clave let para declarar una variable.',
'Assign the number 25 using the = operator.', 'Asigna el número 25 usando el operador =.',
'let age = 25;', 'let age = 25;',
10, 3, now()),

-- 3
(gen_random_uuid(), 'String Concatenation', 'Concatenación de Strings',
'Concatenate "Hello" and "World" with a space between them and print the result.',
'Concatena "Hello" y "World" con un espacio entre ellos e imprime el resultado.',
'javascript', 1, 'basics',
'let result = "Hello" ___ " " ___ "World";
console.log(result)',
'let result = "Hello" + " " + "World";
console.log(result)',
'Hello World', 3,
'Use the + operator to join strings.', 'Usa el operador + para unir strings.',
'You need two + operators total.', 'Necesitas dos operadores + en total.',
'"Hello" + " " + "World"', '"Hello" + " " + "World"',
10, 3, now()),

-- 4
(gen_random_uuid(), 'Basic Arithmetic', 'Aritmética Básica',
'Calculate the sum of 15 and 27, then print the result.',
'Calcula la suma de 15 y 27, luego imprime el resultado.',
'javascript', 1, 'basics',
'let sum = ___ + ___;
console.log(sum)',
'let sum = 15 + 27;
console.log(sum)',
'42', 3,
'Use the + operator between two numbers.', 'Usa el operador + entre dos números.',
'Assign the expression to a variable named sum.', 'Asigna la expresión a una variable llamada sum.',
'let sum = 15 + 27;', 'let sum = 15 + 27;',
10, 3, now()),

-- 5
(gen_random_uuid(), 'Boolean Value', 'Valor Booleano',
'Declare a variable "isActive" set to true and print it.',
'Declara una variable "isActive" con valor true e imprímela.',
'javascript', 1, 'basics',
'let isActive = ___;
console.log(isActive)',
'let isActive = true;
console.log(isActive)',
'true', 3,
'Boolean values are true or false (no quotes).', 'Los valores booleanos son true o false (sin comillas).',
'Use let to declare the variable.', 'Usa let para declarar la variable.',
'let isActive = true;', 'let isActive = true;',
10, 3, now()),

-- 6
(gen_random_uuid(), 'Typeof Operator', 'Operador Typeof',
'Print the type of the value 42 using typeof.',
'Imprime el tipo del valor 42 usando typeof.',
'javascript', 1, 'basics',
'console.log(___(42))',
'console.log(typeof 42)',
'number', 3,
'typeof is a unary operator, not a function.', 'typeof es un operador unario, no una función.',
'Write typeof followed by the value.', 'Escribe typeof seguido del valor.',
'typeof 42', 'typeof 42',
10, 3, now()),

-- 7
(gen_random_uuid(), 'Const Declaration', 'Declaración Const',
'Declare a constant PI with value 3.14 and print it.',
'Declara una constante PI con valor 3.14 e imprímela.',
'javascript', 1, 'basics',
'___ PI = ___;
console.log(PI)',
'const PI = 3.14;
console.log(PI)',
'3.14', 3,
'Use const for values that do not change.', 'Usa const para valores que no cambian.',
'const works like let but cannot be reassigned.', 'const funciona como let pero no puede reasignarse.',
'const PI = 3.14;', 'const PI = 3.14;',
10, 3, now()),

-- 8
(gen_random_uuid(), 'Ternary Operator', 'Operador Ternario',
'Use a ternary to print "even" if 4 is even, otherwise "odd".',
'Usa un ternario para imprimir "even" si 4 es par, de lo contrario "odd".',
'javascript', 1, 'basics',
'let result = (4 % 2 === 0) ___ "even" ___ "odd";
console.log(result)',
'let result = (4 % 2 === 0) ? "even" : "odd";
console.log(result)',
'even', 3,
'Ternary syntax: condition ? valueIfTrue : valueIfFalse.', 'Sintaxis ternaria: condición ? valorSiTrue : valorSiFalse.',
'Use ? and : to separate parts.', 'Usa ? y : para separar las partes.',
'(4 % 2 === 0) ? "even" : "odd"', '(4 % 2 === 0) ? "even" : "odd"',
10, 3, now()),

-- 9 strings
(gen_random_uuid(), 'String Length', 'Longitud de String',
'Print the length of the string "JavaScript".',
'Imprime la longitud del string "JavaScript".',
'javascript', 1, 'strings',
'let word = "JavaScript";
console.log(word.___)',
'let word = "JavaScript";
console.log(word.length)',
'10', 3,
'Strings have a .length property.', 'Los strings tienen una propiedad .length.',
'Access it with dot notation, no parentheses.', 'Accede con notación de punto, sin paréntesis.',
'word.length', 'word.length',
10, 3, now()),

-- 10
(gen_random_uuid(), 'Uppercase String', 'String en Mayúsculas',
'Convert the string "hello" to uppercase and print it.',
'Convierte el string "hello" a mayúsculas e imprímelo.',
'javascript', 1, 'strings',
'let str = "hello";
console.log(str.___())',
'let str = "hello";
console.log(str.toUpperCase())',
'HELLO', 3,
'Strings have a method to convert to uppercase.', 'Los strings tienen un método para convertir a mayúsculas.',
'The method is toUpperCase().', 'El método es toUpperCase().',
'str.toUpperCase()', 'str.toUpperCase()',
10, 3, now()),

-- 11
(gen_random_uuid(), 'String Index', 'Índice de String',
'Print the character at index 0 of the string "World".',
'Imprime el carácter en el índice 0 del string "World".',
'javascript', 1, 'strings',
'let str = "World";
console.log(str[___])',
'let str = "World";
console.log(str[0])',
'W', 3,
'Strings are zero-indexed arrays of characters.', 'Los strings son arrays de caracteres con índice cero.',
'Index 0 is the first character.', 'El índice 0 es el primer carácter.',
'str[0]', 'str[0]',
10, 3, now()),

-- 12
(gen_random_uuid(), 'Template Literal', 'Template Literal',
'Use a template literal to print "My name is Alice" where Alice comes from a variable.',
'Usa un template literal para imprimir "My name is Alice" donde Alice viene de una variable.',
'javascript', 1, 'strings',
'let name = "Alice";
console.log(`My name is ___`)',
'let name = "Alice";
console.log(`My name is ${name}`)',
'My name is Alice', 3,
'Template literals use backticks (`).', 'Los template literals usan comillas invertidas (`).',
'Embed variables with ${variableName}.', 'Incrusta variables con ${nombreVariable}.',
'`My name is ${name}`', '`My name is ${name}`',
10, 3, now()),

-- 13
(gen_random_uuid(), 'String Includes', 'String Includes',
'Check if "Hello World" includes "World" and print the boolean result.',
'Verifica si "Hello World" incluye "World" e imprime el resultado booleano.',
'javascript', 1, 'strings',
'let str = "Hello World";
console.log(str.___(___) )',
'let str = "Hello World";
console.log(str.includes("World"))',
'true', 3,
'Use the .includes() method on strings.', 'Usa el método .includes() en strings.',
'Pass the substring as a string argument.', 'Pasa la subcadena como argumento string.',
'str.includes("World")', 'str.includes("World")',
10, 3, now()),

-- 14
(gen_random_uuid(), 'String Trim', 'String Trim',
'Remove whitespace from both ends of "  hello  " and print the result.',
'Elimina espacios en blanco de ambos extremos de "  hello  " e imprime el resultado.',
'javascript', 1, 'strings',
'let str = "  hello  ";
console.log(str.___())',
'let str = "  hello  ";
console.log(str.trim())',
'hello', 3,
'There is a method to remove leading and trailing spaces.', 'Existe un método para eliminar espacios al inicio y al final.',
'The method is .trim().', 'El método es .trim().',
'str.trim()', 'str.trim()',
10, 3, now()),

-- 15 math
(gen_random_uuid(), 'Modulo Operator', 'Operador Módulo',
'Print the remainder of 17 divided by 5.',
'Imprime el resto de dividir 17 entre 5.',
'javascript', 1, 'math',
'console.log(17 ___ 5)',
'console.log(17 % 5)',
'2', 3,
'The modulo operator gives the remainder of division.', 'El operador módulo da el resto de la división.',
'Use the % symbol.', 'Usa el símbolo %.',
'17 % 5', '17 % 5',
10, 3, now()),

-- 16
(gen_random_uuid(), 'Math.max', 'Math.max',
'Print the maximum of 10, 45, and 22.',
'Imprime el máximo de 10, 45 y 22.',
'javascript', 1, 'math',
'console.log(Math.___( ___, ___, ___ ))',
'console.log(Math.max(10, 45, 22))',
'45', 3,
'Math has a built-in method to find the maximum.', 'Math tiene un método integrado para encontrar el máximo.',
'The method is Math.max().', 'El método es Math.max().',
'Math.max(10, 45, 22)', 'Math.max(10, 45, 22)',
10, 3, now()),

-- 17
(gen_random_uuid(), 'Math.abs', 'Math.abs',
'Print the absolute value of -7.',
'Imprime el valor absoluto de -7.',
'javascript', 1, 'math',
'console.log(Math.___(-7))',
'console.log(Math.abs(-7))',
'7', 3,
'Math.abs() converts negative numbers to positive.', 'Math.abs() convierte números negativos a positivos.',
'Pass -7 as the argument.', 'Pasa -7 como argumento.',
'Math.abs(-7)', 'Math.abs(-7)',
10, 3, now()),

-- 18
(gen_random_uuid(), 'Math.round', 'Math.round',
'Round 4.6 to the nearest integer and print the result.',
'Redondea 4.6 al entero más cercano e imprime el resultado.',
'javascript', 1, 'math',
'console.log(Math.___(4.6))',
'console.log(Math.round(4.6))',
'5', 3,
'Math.round() rounds to the nearest integer.', 'Math.round() redondea al entero más cercano.',
'4.6 is closer to 5 than to 4.', '4.6 está más cerca de 5 que de 4.',
'Math.round(4.6)', 'Math.round(4.6)',
10, 3, now()),

-- 19
(gen_random_uuid(), 'Power Operator', 'Operador Potencia',
'Calculate 2 to the power of 8 and print the result.',
'Calcula 2 elevado a la potencia de 8 e imprime el resultado.',
'javascript', 1, 'math',
'console.log(2 ___ 8)',
'console.log(2 ** 8)',
'256', 3,
'JavaScript has an exponentiation operator.', 'JavaScript tiene un operador de exponenciación.',
'Use ** for exponentiation.', 'Usa ** para la exponenciación.',
'2 ** 8', '2 ** 8',
10, 3, now()),

-- 20
(gen_random_uuid(), 'Integer Division', 'División Entera',
'Print the integer part of 17 divided by 3 (no decimals).',
'Imprime la parte entera de 17 dividido entre 3 (sin decimales).',
'javascript', 1, 'math',
'console.log(Math.___(17 / 3))',
'console.log(Math.floor(17 / 3))',
'5', 3,
'Use Math.floor() to get the integer part of a division.', 'Usa Math.floor() para obtener la parte entera de una división.',
'Math.floor() rounds down to the nearest integer.', 'Math.floor() redondea hacia abajo al entero más cercano.',
'Math.floor(17 / 3)', 'Math.floor(17 / 3)',
10, 3, now()),

-- 21 arrays
(gen_random_uuid(), 'Array Length', 'Longitud de Array',
'Print the number of elements in the array [1, 2, 3, 4, 5].',
'Imprime el número de elementos en el array [1, 2, 3, 4, 5].',
'javascript', 1, 'arrays',
'let nums = [1, 2, 3, 4, 5];
console.log(nums.___)',
'let nums = [1, 2, 3, 4, 5];
console.log(nums.length)',
'5', 3,
'Arrays have a .length property.', 'Los arrays tienen una propiedad .length.',
'Access it with dot notation.', 'Accede con notación de punto.',
'nums.length', 'nums.length',
10, 3, now()),

-- 22
(gen_random_uuid(), 'Array Access', 'Acceso a Array',
'Print the third element of ["a", "b", "c", "d"].',
'Imprime el tercer elemento de ["a", "b", "c", "d"].',
'javascript', 1, 'arrays',
'let arr = ["a", "b", "c", "d"];
console.log(arr[___])',
'let arr = ["a", "b", "c", "d"];
console.log(arr[2])',
'c', 3,
'Arrays are zero-indexed.', 'Los arrays tienen índice cero.',
'The third element is at index 2.', 'El tercer elemento está en el índice 2.',
'arr[2]', 'arr[2]',
10, 3, now()),

-- 23
(gen_random_uuid(), 'Array Push', 'Array Push',
'Add the value 6 to the end of [1, 2, 3, 4, 5] and print the array.',
'Agrega el valor 6 al final de [1, 2, 3, 4, 5] e imprime el array.',
'javascript', 1, 'arrays',
'let nums = [1, 2, 3, 4, 5];
nums.___(6);
console.log(nums)',
'let nums = [1, 2, 3, 4, 5];
nums.push(6);
console.log(nums)',
'[1,2,3,4,5,6]', 3,
'Use .push() to add an element to the end of an array.', 'Usa .push() para agregar un elemento al final de un array.',
'push() modifies the array in place.', 'push() modifica el array en su lugar.',
'nums.push(6)', 'nums.push(6)',
10, 3, now()),

-- 24
(gen_random_uuid(), 'Array Join', 'Array Join',
'Join the array ["a", "b", "c"] into the string "a-b-c" and print it.',
'Une el array ["a", "b", "c"] en el string "a-b-c" e imprímelo.',
'javascript', 1, 'arrays',
'let arr = ["a", "b", "c"];
console.log(arr.___("___"))',
'let arr = ["a", "b", "c"];
console.log(arr.join("-"))',
'a-b-c', 3,
'Use .join() with a separator string.', 'Usa .join() con un string separador.',
'Pass "-" as the separator argument.', 'Pasa "-" como argumento separador.',
'arr.join("-")', 'arr.join("-")',
10, 3, now()),

-- 25 functions
(gen_random_uuid(), 'Simple Function', 'Función Simple',
'Write a function "greet" that returns the string "Hello!" then call it and print the result.',
'Escribe una función "greet" que retorne el string "Hello!" luego llámala e imprime el resultado.',
'javascript', 1, 'functions',
'function greet() {
  ___ "Hello!";
}
console.log(greet())',
'function greet() {
  return "Hello!";
}
console.log(greet())',
'Hello!', 3,
'Use the return keyword to return a value from a function.', 'Usa la palabra clave return para retornar un valor de una función.',
'The function body goes inside curly braces.', 'El cuerpo de la función va dentro de llaves.',
'return "Hello!";', 'return "Hello!";',
10, 3, now()),

-- ============================================================
-- DIFFICULTY 2 — 25 exercises
-- ============================================================

-- 26
(gen_random_uuid(), 'Function with Parameters', 'Función con Parámetros',
'Write a function "add" that takes two numbers and returns their sum. Print add(3, 4).',
'Escribe una función "add" que tome dos números y retorne su suma. Imprime add(3, 4).',
'javascript', 2, 'functions',
'function add(___, ___) {
  return ___ + ___;
}
console.log(add(3, 4))',
'function add(a, b) {
  return a + b;
}
console.log(add(3, 4))',
'7', 3,
'Define parameters inside the parentheses.', 'Define los parámetros dentro de los paréntesis.',
'Use the parameter names in the return expression.', 'Usa los nombres de los parámetros en la expresión de retorno.',
'function add(a, b) { return a + b; }', 'function add(a, b) { return a + b; }',
20, 3, now()),

-- 27
(gen_random_uuid(), 'Arrow Function', 'Función Flecha',
'Rewrite the function "square(n) { return n*n; }" as an arrow function and print square(5).',
'Reescribe la función "square(n) { return n*n; }" como función flecha e imprime square(5).',
'javascript', 2, 'functions',
'const square = ___ => ___;
console.log(square(5))',
'const square = n => n * n;
console.log(square(5))',
'25', 3,
'Arrow functions use => syntax.', 'Las funciones flecha usan la sintaxis =>.',
'For a single expression, you can omit curly braces and return.', 'Para una sola expresión, puedes omitir las llaves y return.',
'const square = n => n * n;', 'const square = n => n * n;',
20, 3, now()),

-- 28
(gen_random_uuid(), 'If-Else', 'If-Else',
'Write a function "sign" that returns "positive" for n>0, "negative" for n<0, else "zero". Print sign(-3).',
'Escribe una función "sign" que retorne "positive" para n>0, "negative" para n<0, si no "zero". Imprime sign(-3).',
'javascript', 2, 'basics',
'function sign(n) {
  if (n > 0) return "positive";
  ___ if (n < 0) return "negative";
  ___ return "zero";
}
console.log(sign(-3))',
'function sign(n) {
  if (n > 0) return "positive";
  else if (n < 0) return "negative";
  else return "zero";
}
console.log(sign(-3))',
'negative', 3,
'Use else if for a second condition.', 'Usa else if para una segunda condición.',
'The final else handles the remaining case.', 'El else final maneja el caso restante.',
'else if (n < 0)', 'else if (n < 0)',
20, 3, now()),

-- 29
(gen_random_uuid(), 'For Loop', 'Bucle For',
'Use a for loop to print the numbers 1 through 5, each on its own line.',
'Usa un bucle for para imprimir los números del 1 al 5, cada uno en su propia línea.',
'javascript', 2, 'basics',
'for (let i = ___; i ___ 5; i___) {
  console.log(i);
}',
'for (let i = 1; i <= 5; i++) {
  console.log(i);
}',
'1\n2\n3\n4\n5', 3,
'Start i at 1, loop while i <= 5.', 'Comienza i en 1, itera mientras i <= 5.',
'Use i++ to increment by 1 each iteration.', 'Usa i++ para incrementar en 1 cada iteración.',
'for (let i = 1; i <= 5; i++)', 'for (let i = 1; i <= 5; i++)',
20, 3, now()),

-- 30
(gen_random_uuid(), 'While Loop', 'Bucle While',
'Use a while loop to print the sum of 1+2+3+...+10.',
'Usa un bucle while para imprimir la suma de 1+2+3+...+10.',
'javascript', 2, 'basics',
'let sum = 0, i = 1;
while (i ___ 10) {
  sum ___ i;
  i++;
}
console.log(sum)',
'let sum = 0, i = 1;
while (i <= 10) {
  sum += i;
  i++;
}
console.log(sum)',
'55', 3,
'Loop while i is less than or equal to 10.', 'Itera mientras i sea menor o igual a 10.',
'Use += to add i to sum each iteration.', 'Usa += para sumar i a sum en cada iteración.',
'while (i <= 10) { sum += i; i++; }', 'while (i <= 10) { sum += i; i++; }',
20, 3, now()),

-- 31
(gen_random_uuid(), 'Array Map', 'Array Map',
'Double each element in [1, 2, 3, 4] using .map() and print the result.',
'Duplica cada elemento de [1, 2, 3, 4] usando .map() e imprime el resultado.',
'javascript', 2, 'arrays',
'let nums = [1, 2, 3, 4];
let doubled = nums.___(n => n * 2);
console.log(doubled)',
'let nums = [1, 2, 3, 4];
let doubled = nums.map(n => n * 2);
console.log(doubled)',
'[2,4,6,8]', 3,
'Use .map() to transform each element.', 'Usa .map() para transformar cada elemento.',
'The callback receives each element and returns the new value.', 'El callback recibe cada elemento y retorna el nuevo valor.',
'nums.map(n => n * 2)', 'nums.map(n => n * 2)',
20, 3, now()),

-- 32
(gen_random_uuid(), 'Array Filter', 'Array Filter',
'Filter out odd numbers from [1, 2, 3, 4, 5, 6] and print the even ones.',
'Filtra los números impares de [1, 2, 3, 4, 5, 6] e imprime los pares.',
'javascript', 2, 'arrays',
'let nums = [1, 2, 3, 4, 5, 6];
let evens = nums.___(n => n % 2 === 0);
console.log(evens)',
'let nums = [1, 2, 3, 4, 5, 6];
let evens = nums.filter(n => n % 2 === 0);
console.log(evens)',
'[2,4,6]', 3,
'Use .filter() to keep only elements that pass a test.', 'Usa .filter() para mantener solo los elementos que pasan una prueba.',
'The callback should return true to keep an element.', 'El callback debe retornar true para mantener un elemento.',
'nums.filter(n => n % 2 === 0)', 'nums.filter(n => n % 2 === 0)',
20, 3, now()),

-- 33
(gen_random_uuid(), 'Array Reduce', 'Array Reduce',
'Use .reduce() to find the sum of [10, 20, 30] and print the result.',
'Usa .reduce() para encontrar la suma de [10, 20, 30] e imprime el resultado.',
'javascript', 2, 'arrays',
'let nums = [10, 20, 30];
let sum = nums.___((___, n) => acc + n, 0);
console.log(sum)',
'let nums = [10, 20, 30];
let sum = nums.reduce((acc, n) => acc + n, 0);
console.log(sum)',
'60', 3,
'Use .reduce() with an accumulator.', 'Usa .reduce() con un acumulador.',
'The second argument (0) is the initial value.', 'El segundo argumento (0) es el valor inicial.',
'nums.reduce((acc, n) => acc + n, 0)', 'nums.reduce((acc, n) => acc + n, 0)',
20, 3, now()),

-- 34
(gen_random_uuid(), 'Object Literal', 'Objeto Literal',
'Create an object "person" with name "Bob" and age 30, then print person.name.',
'Crea un objeto "person" con name "Bob" y age 30, luego imprime person.name.',
'javascript', 2, 'objects',
'let person = { ___: "Bob", ___: 30 };
console.log(person.___)',
'let person = { name: "Bob", age: 30 };
console.log(person.name)',
'Bob', 3,
'Object literals use key: value pairs inside {}.', 'Los objetos literales usan pares clave: valor dentro de {}.',
'Access properties with dot notation.', 'Accede a las propiedades con notación de punto.',
'{ name: "Bob", age: 30 }', '{ name: "Bob", age: 30 }',
20, 3, now()),

-- 35
(gen_random_uuid(), 'Object Destructuring', 'Desestructuración de Objetos',
'Destructure name and age from { name: "Alice", age: 25 } and print both.',
'Desestructura name y age de { name: "Alice", age: 25 } e imprime ambos.',
'javascript', 2, 'objects',
'const { ___, ___ } = { name: "Alice", age: 25 };
console.log(name, age)',
'const { name, age } = { name: "Alice", age: 25 };
console.log(name, age)',
'Alice 25', 3,
'Destructuring uses { } on the left side of =.', 'La desestructuración usa { } en el lado izquierdo de =.',
'List the property names you want to extract.', 'Lista los nombres de propiedades que quieres extraer.',
'const { name, age } = obj;', 'const { name, age } = obj;',
20, 3, now()),

-- 36
(gen_random_uuid(), 'Spread Operator', 'Operador Spread',
'Merge [1, 2, 3] and [4, 5, 6] into one array using spread and print it.',
'Une [1, 2, 3] y [4, 5, 6] en un array usando spread e imprímelo.',
'javascript', 2, 'arrays',
'let a = [1, 2, 3], b = [4, 5, 6];
let merged = [___a, ___b];
console.log(merged)',
'let a = [1, 2, 3], b = [4, 5, 6];
let merged = [...a, ...b];
console.log(merged)',
'[1,2,3,4,5,6]', 3,
'The spread operator is three dots (...).', 'El operador spread son tres puntos (...).',
'Spread both arrays inside new array brackets.', 'Haz spread de ambos arrays dentro de nuevos corchetes.',
'[...a, ...b]', '[...a, ...b]',
20, 3, now()),

-- 37
(gen_random_uuid(), 'Default Parameters', 'Parámetros por Defecto',
'Write a function "greet" with a default name "stranger" that prints "Hello, <name>!". Call greet() and greet("Eve").',
'Escribe una función "greet" con nombre por defecto "stranger" que imprima "Hello, <name>!". Llama greet() y greet("Eve").',
'javascript', 2, 'functions',
'function greet(name = "___") {
  console.log(`Hello, ${name}!`);
}
greet();
greet("Eve")',
'function greet(name = "stranger") {
  console.log(`Hello, ${name}!`);
}
greet();
greet("Eve")',
'Hello, stranger!\nHello, Eve!', 3,
'Default parameters use = in the function signature.', 'Los parámetros por defecto usan = en la firma de la función.',
'If no argument is passed, the default value is used.', 'Si no se pasa argumento, se usa el valor por defecto.',
'function greet(name = "stranger")', 'function greet(name = "stranger")',
20, 3, now()),

-- 38
(gen_random_uuid(), 'String Split', 'String Split',
'Split "one,two,three" by comma into an array and print the result.',
'Divide "one,two,three" por coma en un array e imprime el resultado.',
'javascript', 2, 'strings',
'let str = "one,two,three";
console.log(str.___("___"))',
'let str = "one,two,three";
console.log(str.split(","))',
'["one","two","three"]', 3,
'Use .split() with a separator string.', 'Usa .split() con un string separador.',
'Pass "," as the argument.', 'Pasa "," como argumento.',
'str.split(",")', 'str.split(",")',
20, 3, now()),

-- 39
(gen_random_uuid(), 'String Replace', 'String Replace',
'Replace "cat" with "dog" in the string "I have a cat" and print the result.',
'Reemplaza "cat" con "dog" en el string "I have a cat" e imprime el resultado.',
'javascript', 2, 'strings',
'let str = "I have a cat";
console.log(str.___("cat", "dog"))',
'let str = "I have a cat";
console.log(str.replace("cat", "dog"))',
'I have a dog', 3,
'Use .replace(old, new) on strings.', 'Usa .replace(viejo, nuevo) en strings.',
'The first argument is what to find, the second is the replacement.', 'El primer argumento es lo que buscar, el segundo es el reemplazo.',
'str.replace("cat", "dog")', 'str.replace("cat", "dog")',
20, 3, now()),

-- 40
(gen_random_uuid(), 'String Slice', 'String Slice',
'Extract "World" from "Hello World" using .slice() and print it.',
'Extrae "World" de "Hello World" usando .slice() e imprímelo.',
'javascript', 2, 'strings',
'let str = "Hello World";
console.log(str.___(6))',
'let str = "Hello World";
console.log(str.slice(6))',
'World', 3,
'slice(start) extracts from start to end.', 'slice(inicio) extrae desde el inicio hasta el final.',
'"World" starts at index 6.', '"World" comienza en el índice 6.',
'str.slice(6)', 'str.slice(6)',
20, 3, now()),

-- 41
(gen_random_uuid(), 'Object Keys', 'Claves de Objeto',
'Print all keys of { a: 1, b: 2, c: 3 } using Object.keys().',
'Imprime todas las claves de { a: 1, b: 2, c: 3 } usando Object.keys().',
'javascript', 2, 'objects',
'let obj = { a: 1, b: 2, c: 3 };
console.log(Object.___(obj))',
'let obj = { a: 1, b: 2, c: 3 };
console.log(Object.keys(obj))',
'["a","b","c"]', 3,
'Object.keys() returns an array of the object''s keys.', 'Object.keys() retorna un array de las claves del objeto.',
'Pass the object as the argument.', 'Pasa el objeto como argumento.',
'Object.keys(obj)', 'Object.keys(obj)',
20, 3, now()),

-- 42
(gen_random_uuid(), 'Array Includes', 'Array Includes',
'Check if [5, 10, 15, 20] includes the value 15 and print the boolean result.',
'Verifica si [5, 10, 15, 20] incluye el valor 15 e imprime el resultado booleano.',
'javascript', 2, 'arrays',
'let nums = [5, 10, 15, 20];
console.log(nums.___(15))',
'let nums = [5, 10, 15, 20];
console.log(nums.includes(15))',
'true', 3,
'Arrays have an .includes() method.', 'Los arrays tienen un método .includes().',
'It returns true if the element is found.', 'Retorna true si el elemento es encontrado.',
'nums.includes(15)', 'nums.includes(15)',
20, 3, now()),

-- 43
(gen_random_uuid(), 'Array IndexOf', 'Array IndexOf',
'Find the index of "banana" in ["apple", "banana", "cherry"] and print it.',
'Encuentra el índice de "banana" en ["apple", "banana", "cherry"] e imprímelo.',
'javascript', 2, 'arrays',
'let fruits = ["apple", "banana", "cherry"];
console.log(fruits.___("banana"))',
'let fruits = ["apple", "banana", "cherry"];
console.log(fruits.indexOf("banana"))',
'1', 3,
'Use .indexOf() to find the position of an element.', 'Usa .indexOf() para encontrar la posición de un elemento.',
'Returns -1 if not found.', 'Retorna -1 si no se encuentra.',
'fruits.indexOf("banana")', 'fruits.indexOf("banana")',
20, 3, now()),

-- 44
(gen_random_uuid(), 'Nullish Coalescing', 'Fusión Nula',
'Use ?? to print "default" if the variable is null, otherwise print the variable value.',
'Usa ?? para imprimir "default" si la variable es null, de lo contrario imprime el valor de la variable.',
'javascript', 2, 'basics',
'let val = null;
console.log(val ___ "default")',
'let val = null;
console.log(val ?? "default")',
'default', 3,
'The ?? operator returns the right side if the left is null or undefined.', 'El operador ?? retorna el lado derecho si el izquierdo es null o undefined.',
'Use two question marks: ??.', 'Usa dos signos de interrogación: ??.',
'val ?? "default"', 'val ?? "default"',
20, 3, now()),

-- 45
(gen_random_uuid(), 'Optional Chaining', 'Encadenamiento Opcional',
'Safely access user?.address?.city from an object where address is undefined and print the result.',
'Accede de forma segura a user?.address?.city de un objeto donde address es undefined e imprime el resultado.',
'javascript', 2, 'objects',
'let user = { name: "Tom" };
console.log(user___address___city)',
'let user = { name: "Tom" };
console.log(user?.address?.city)',
'undefined', 3,
'Use ?. to avoid errors when accessing possibly undefined properties.', 'Usa ?. para evitar errores al acceder a propiedades posiblemente undefined.',
'Chain multiple ?. operators.', 'Encadena múltiples operadores ?.',
'user?.address?.city', 'user?.address?.city',
20, 3, now()),

-- 46
(gen_random_uuid(), 'Array Sort Numbers', 'Ordenar Array de Números',
'Sort [3, 1, 4, 1, 5, 9, 2, 6] in ascending order and print the result.',
'Ordena [3, 1, 4, 1, 5, 9, 2, 6] en orden ascendente e imprime el resultado.',
'javascript', 2, 'arrays',
'let nums = [3, 1, 4, 1, 5, 9, 2, 6];
nums.sort((___, ___) => a - b);
console.log(nums)',
'let nums = [3, 1, 4, 1, 5, 9, 2, 6];
nums.sort((a, b) => a - b);
console.log(nums)',
'[1,1,2,3,4,5,6,9]', 3,
'Pass a comparator function to .sort().', 'Pasa una función comparadora a .sort().',
'(a, b) => a - b sorts ascending.', '(a, b) => a - b ordena ascendentemente.',
'nums.sort((a, b) => a - b)', 'nums.sort((a, b) => a - b)',
20, 3, now()),

-- 47
(gen_random_uuid(), 'String Repeat', 'String Repeat',
'Print "ha" repeated 3 times using .repeat().',
'Imprime "ha" repetido 3 veces usando .repeat().',
'javascript', 2, 'strings',
'console.log("ha".___(3))',
'console.log("ha".repeat(3))',
'hahaha', 3,
'Strings have a .repeat(n) method.', 'Los strings tienen un método .repeat(n).',
'Pass the number of repetitions as the argument.', 'Pasa el número de repeticiones como argumento.',
'"ha".repeat(3)', '"ha".repeat(3)',
20, 3, now()),

-- 48
(gen_random_uuid(), 'Number to String', 'Número a String',
'Convert the number 42 to the string "42" and verify with typeof.',
'Convierte el número 42 al string "42" y verifica con typeof.',
'javascript', 2, 'basics',
'let n = 42;
let s = ___.toString();
console.log(typeof s)',
'let n = 42;
let s = n.toString();
console.log(typeof s)',
'string', 3,
'Numbers have a .toString() method.', 'Los números tienen un método .toString().',
'Call it on the variable, not the literal.', 'Llámalo en la variable, no en el literal.',
'n.toString()', 'n.toString()',
20, 3, now()),

-- 49
(gen_random_uuid(), 'ParseInt', 'ParseInt',
'Convert the string "42px" to the integer 42 using parseInt and print it.',
'Convierte el string "42px" al entero 42 usando parseInt e imprímelo.',
'javascript', 2, 'basics',
'console.log(___("42px"))',
'console.log(parseInt("42px"))',
'42', 3,
'parseInt() parses a string and returns an integer.', 'parseInt() analiza un string y retorna un entero.',
'It stops at the first non-numeric character.', 'Se detiene en el primer carácter no numérico.',
'parseInt("42px")', 'parseInt("42px")',
20, 3, now()),

-- 50
(gen_random_uuid(), 'Logical AND', 'AND Lógico',
'Print true only if both 5 > 3 AND 10 < 20 are true.',
'Imprime true solo si tanto 5 > 3 COMO 10 < 20 son verdaderos.',
'javascript', 2, 'basics',
'console.log(5 > 3 ___ 10 < 20)',
'console.log(5 > 3 && 10 < 20)',
'true', 3,
'Use && for logical AND.', 'Usa && para el AND lógico.',
'Both conditions must be true for && to return true.', 'Ambas condiciones deben ser verdaderas para que && retorne true.',
'5 > 3 && 10 < 20', '5 > 3 && 10 < 20',
20, 3, now()),

-- ============================================================
-- DIFFICULTY 3 — 25 exercises
-- ============================================================

-- 51
(gen_random_uuid(), 'Closure Counter', 'Contador con Closure',
'Create a makeCounter() function that returns a function. Each call to the returned function increments and returns a count starting from 0.',
'Crea una función makeCounter() que retorne una función. Cada llamada a la función retornada incrementa y retorna un contador comenzando en 0.',
'javascript', 3, 'functions',
'function makeCounter() {
  let count = 0;
  return function() {
    return ___;
  };
}
const counter = makeCounter();
console.log(counter());
console.log(counter());
console.log(counter())',
'function makeCounter() {
  let count = 0;
  return function() {
    return ++count;
  };
}
const counter = makeCounter();
console.log(counter());
console.log(counter());
console.log(counter())',
'1\n2\n3', 3,
'The inner function closes over the count variable.', 'La función interna cierra sobre la variable count.',
'Use ++count to increment before returning.', 'Usa ++count para incrementar antes de retornar.',
'return ++count;', 'return ++count;',
30, 5, now()),

-- 52
(gen_random_uuid(), 'Recursive Factorial', 'Factorial Recursivo',
'Write a recursive function factorial(n) that returns n!. Print factorial(5).',
'Escribe una función recursiva factorial(n) que retorne n!. Imprime factorial(5).',
'javascript', 3, 'algorithms',
'function factorial(n) {
  if (n ___ 1) return 1;
  return n * factorial(___);
}
console.log(factorial(5))',
'function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
console.log(factorial(5))',
'120', 3,
'A recursive function calls itself.', 'Una función recursiva se llama a sí misma.',
'The base case is n <= 1, return 1.', 'El caso base es n <= 1, retorna 1.',
'return n * factorial(n - 1);', 'return n * factorial(n - 1);',
30, 5, now()),

-- 53
(gen_random_uuid(), 'Fibonacci Sequence', 'Secuencia Fibonacci',
'Write a function fib(n) that returns the nth Fibonacci number. Print fib(8).',
'Escribe una función fib(n) que retorne el enésimo número Fibonacci. Imprime fib(8).',
'javascript', 3, 'algorithms',
'function fib(n) {
  if (n <= 1) return n;
  return ___(n-1) + ___(n-2);
}
console.log(fib(8))',
'function fib(n) {
  if (n <= 1) return n;
  return fib(n-1) + fib(n-2);
}
console.log(fib(8))',
'21', 3,
'Fibonacci: fib(n) = fib(n-1) + fib(n-2).', 'Fibonacci: fib(n) = fib(n-1) + fib(n-2).',
'Base cases: fib(0)=0, fib(1)=1.', 'Casos base: fib(0)=0, fib(1)=1.',
'return fib(n-1) + fib(n-2);', 'return fib(n-1) + fib(n-2);',
30, 5, now()),

-- 54
(gen_random_uuid(), 'Array FlatMap', 'Array FlatMap',
'Use .flatMap() to double each element of [[1,2],[3,4]] and flatten to one array.',
'Usa .flatMap() para duplicar cada elemento de [[1,2],[3,4]] y aplanar en un array.',
'javascript', 3, 'arrays',
'let nested = [[1,2],[3,4]];
let result = nested.___(arr => arr.map(n => n * 2));
console.log(result)',
'let nested = [[1,2],[3,4]];
let result = nested.flatMap(arr => arr.map(n => n * 2));
console.log(result)',
'[2,4,6,8]', 3,
'flatMap maps then flattens one level.', 'flatMap mapea y luego aplana un nivel.',
'The callback receives each sub-array.', 'El callback recibe cada sub-array.',
'nested.flatMap(arr => arr.map(n => n * 2))', 'nested.flatMap(arr => arr.map(n => n * 2))',
30, 5, now()),

-- 55
(gen_random_uuid(), 'Object Assign', 'Object Assign',
'Merge { a: 1, b: 2 } and { b: 3, c: 4 } into a new object and print it.',
'Une { a: 1, b: 2 } y { b: 3, c: 4 } en un nuevo objeto e imprímelo.',
'javascript', 3, 'objects',
'let obj = Object.___({}, { a: 1, b: 2 }, { b: 3, c: 4 });
console.log(obj)',
'let obj = Object.assign({}, { a: 1, b: 2 }, { b: 3, c: 4 });
console.log(obj)',
'{"a":1,"b":3,"c":4}', 3,
'Object.assign() merges source objects into a target.', 'Object.assign() une objetos fuente en un objetivo.',
'Later sources override earlier ones for duplicate keys.', 'Las fuentes posteriores sobreescriben las anteriores para claves duplicadas.',
'Object.assign({}, obj1, obj2)', 'Object.assign({}, obj1, obj2)',
30, 5, now()),

-- 56
(gen_random_uuid(), 'Promise Resolve', 'Promise Resolve',
'Create a Promise that resolves with "done" after 0ms and print the resolved value.',
'Crea una Promise que se resuelva con "done" después de 0ms e imprime el valor resuelto.',
'javascript', 3, 'functions',
'const p = new Promise((resolve) => {
  resolve("___");
});
p.then(val => console.log(val))',
'const p = new Promise((resolve) => {
  resolve("done");
});
p.then(val => console.log(val))',
'done', 3,
'Call resolve() with the value inside the Promise constructor.', 'Llama resolve() con el valor dentro del constructor de Promise.',
'Use .then() to handle the resolved value.', 'Usa .then() para manejar el valor resuelto.',
'resolve("done")', 'resolve("done")',
30, 5, now()),

-- 57
(gen_random_uuid(), 'Async/Await', 'Async/Await',
'Write an async function that awaits a Promise resolving to 42, then prints the result.',
'Escribe una función async que espere una Promise que se resuelve en 42, luego imprime el resultado.',
'javascript', 3, 'functions',
'async function run() {
  const val = ___ Promise.resolve(42);
  console.log(val);
}
run()',
'async function run() {
  const val = await Promise.resolve(42);
  console.log(val);
}
run()',
'42', 3,
'Use await inside an async function.', 'Usa await dentro de una función async.',
'await unwraps the resolved value of the Promise.', 'await desenvuelve el valor resuelto de la Promise.',
'const val = await Promise.resolve(42);', 'const val = await Promise.resolve(42);',
30, 5, now()),

-- 58
(gen_random_uuid(), 'Map Data Structure', 'Estructura de Datos Map',
'Create a Map, set key "x" to 10, then print the value for key "x".',
'Crea un Map, establece la clave "x" en 10, luego imprime el valor de la clave "x".',
'javascript', 3, 'data_structures',
'const m = new Map();
m.___("x", 10);
console.log(m.___("x"))',
'const m = new Map();
m.set("x", 10);
console.log(m.get("x"))',
'10', 3,
'Map uses .set(key, value) and .get(key).', 'Map usa .set(clave, valor) y .get(clave).',
'Maps can use any value as a key.', 'Los Maps pueden usar cualquier valor como clave.',
'm.set("x", 10); m.get("x")', 'm.set("x", 10); m.get("x")',
30, 5, now()),

-- 59
(gen_random_uuid(), 'Set Data Structure', 'Estructura de Datos Set',
'Remove duplicates from [1, 2, 2, 3, 3, 4] using a Set and print the unique values as an array.',
'Elimina duplicados de [1, 2, 2, 3, 3, 4] usando un Set e imprime los valores únicos como array.',
'javascript', 3, 'data_structures',
'let arr = [1, 2, 2, 3, 3, 4];
let unique = [...new ___(arr)];
console.log(unique)',
'let arr = [1, 2, 2, 3, 3, 4];
let unique = [...new Set(arr)];
console.log(unique)',
'[1,2,3,4]', 3,
'new Set() automatically removes duplicates.', 'new Set() elimina automáticamente los duplicados.',
'Spread the Set back into an array with [...set].', 'Convierte el Set a array de nuevo con [...set].',
'[...new Set(arr)]', '[...new Set(arr)]',
30, 5, now()),

-- 60
(gen_random_uuid(), 'Regex Test', 'Prueba de Regex',
'Test if the string "hello123" contains a digit using a regex and print the boolean result.',
'Prueba si el string "hello123" contiene un dígito usando una regex e imprime el resultado booleano.',
'javascript', 3, 'strings',
'let str = "hello123";
console.log(___.___.test(str))',
'let str = "hello123";
console.log(/\d/.test(str))',
'true', 3,
'Use a RegExp literal: /pattern/.', 'Usa un literal RegExp: /patrón/.',
'\\d matches any digit character.', '\\d coincide con cualquier carácter dígito.',
'/\\d/.test(str)', '/\\d/.test(str)',
30, 5, now()),

-- 61
(gen_random_uuid(), 'Array Every', 'Array Every',
'Check if every element in [2, 4, 6, 8] is even and print the result.',
'Verifica si cada elemento en [2, 4, 6, 8] es par e imprime el resultado.',
'javascript', 3, 'arrays',
'let nums = [2, 4, 6, 8];
console.log(nums.___(n => n % 2 === 0))',
'let nums = [2, 4, 6, 8];
console.log(nums.every(n => n % 2 === 0))',
'true', 3,
'Use .every() to check if all elements pass a test.', 'Usa .every() para verificar si todos los elementos pasan una prueba.',
'Returns false if any element fails the test.', 'Retorna false si algún elemento falla la prueba.',
'nums.every(n => n % 2 === 0)', 'nums.every(n => n % 2 === 0)',
30, 5, now()),

-- 62
(gen_random_uuid(), 'Array Some', 'Array Some',
'Check if at least one element in [1, 3, 5, 7, 8] is even and print the result.',
'Verifica si al menos un elemento en [1, 3, 5, 7, 8] es par e imprime el resultado.',
'javascript', 3, 'arrays',
'let nums = [1, 3, 5, 7, 8];
console.log(nums.___(n => n % 2 === 0))',
'let nums = [1, 3, 5, 7, 8];
console.log(nums.some(n => n % 2 === 0))',
'true', 3,
'Use .some() to check if any element passes a test.', 'Usa .some() para verificar si algún elemento pasa una prueba.',
'Returns true as soon as one element passes.', 'Retorna true en cuanto un elemento pasa.',
'nums.some(n => n % 2 === 0)', 'nums.some(n => n % 2 === 0)',
30, 5, now()),

-- 63
(gen_random_uuid(), 'Object Entries Loop', 'Bucle con Object.entries',
'Use Object.entries to print each key-value pair of { a: 1, b: 2 } as "a: 1" etc.',
'Usa Object.entries para imprimir cada par clave-valor de { a: 1, b: 2 } como "a: 1" etc.',
'javascript', 3, 'objects',
'let obj = { a: 1, b: 2 };
for (const [___, ___] of Object.___(obj)) {
  console.log(`${key}: ${val}`);
}',
'let obj = { a: 1, b: 2 };
for (const [key, val] of Object.entries(obj)) {
  console.log(`${key}: ${val}`);
}',
'a: 1\nb: 2', 3,
'Object.entries() returns [key, value] pairs.', 'Object.entries() retorna pares [clave, valor].',
'Destructure each pair in the for...of loop.', 'Desestructura cada par en el bucle for...of.',
'for (const [key, val] of Object.entries(obj))', 'for (const [key, val] of Object.entries(obj))',
30, 5, now()),

-- 64
(gen_random_uuid(), 'String PadStart', 'String PadStart',
'Pad the string "5" to length 3 with zeros at the start and print the result.',
'Rellena el string "5" hasta longitud 3 con ceros al inicio e imprime el resultado.',
'javascript', 3, 'strings',
'let s = "5";
console.log(s.___(3, "0"))',
'let s = "5";
console.log(s.padStart(3, "0"))',
'005', 3,
'Use .padStart(targetLength, padString).', 'Usa .padStart(longitudObjetivo, stringRelleno).',
'The first arg is the target length, the second is the pad character.', 'El primer arg es la longitud objetivo, el segundo es el carácter de relleno.',
's.padStart(3, "0")', 's.padStart(3, "0")',
30, 5, now()),

-- 65
(gen_random_uuid(), 'Destructure with Rest', 'Desestructuración con Rest',
'Destructure the first element and collect the rest from [1, 2, 3, 4, 5]. Print both.',
'Desestructura el primer elemento y recolecta el resto de [1, 2, 3, 4, 5]. Imprime ambos.',
'javascript', 3, 'arrays',
'const [first, ___rest] = [1, 2, 3, 4, 5];
console.log(first);
console.log(rest)',
'const [first, ...rest] = [1, 2, 3, 4, 5];
console.log(first);
console.log(rest)',
'1\n[2,3,4,5]', 3,
'Use ...rest in destructuring to collect remaining elements.', 'Usa ...rest en la desestructuración para recolectar los elementos restantes.',
'The rest element must be last in the pattern.', 'El elemento rest debe ser el último en el patrón.',
'const [first, ...rest] = arr;', 'const [first, ...rest] = arr;',
30, 5, now()),

-- 66
(gen_random_uuid(), 'Currying', 'Currying',
'Write a curried function add(a)(b) that returns a+b. Print add(3)(4).',
'Escribe una función currificada add(a)(b) que retorne a+b. Imprime add(3)(4).',
'javascript', 3, 'functions',
'const add = a => ___ => a + b;
console.log(add(3)(4))',
'const add = a => b => a + b;
console.log(add(3)(4))',
'7', 3,
'A curried function returns another function.', 'Una función currificada retorna otra función.',
'The outer function takes a, the inner takes b.', 'La función exterior toma a, la interior toma b.',
'const add = a => b => a + b;', 'const add = a => b => a + b;',
30, 5, now()),

-- 67
(gen_random_uuid(), 'Generator Function', 'Función Generadora',
'Write a generator that yields 1, 2, 3. Collect values with spread into an array and print.',
'Escribe un generador que produzca 1, 2, 3. Recolecta valores con spread en un array e imprime.',
'javascript', 3, 'functions',
'function* gen() {
  yield 1; yield 2; yield 3;
}
console.log([...___()])',
'function* gen() {
  yield 1; yield 2; yield 3;
}
console.log([...gen()])',
'[1,2,3]', 3,
'Generator functions use function* syntax.', 'Las funciones generadoras usan la sintaxis function*.',
'Spread the generator call into an array.', 'Haz spread de la llamada al generador en un array.',
'[...gen()]', '[...gen()]',
30, 5, now()),

-- 68
(gen_random_uuid(), 'Symbol Type', 'Tipo Symbol',
'Create two Symbols with the same description and print whether they are equal.',
'Crea dos Symbols con la misma descripción e imprime si son iguales.',
'javascript', 3, 'basics',
'const s1 = Symbol("id");
const s2 = Symbol("id");
console.log(s1 ___ s2)',
'const s1 = Symbol("id");
const s2 = Symbol("id");
console.log(s1 === s2)',
'false', 3,
'Each Symbol() call creates a unique symbol.', 'Cada llamada a Symbol() crea un símbolo único.',
'Even with the same description, two symbols are never equal.', 'Incluso con la misma descripción, dos símbolos nunca son iguales.',
's1 === s2 // false', 's1 === s2 // false',
30, 5, now()),

-- 69
(gen_random_uuid(), 'WeakMap', 'WeakMap',
'Create a WeakMap, store a value for an object key, then retrieve and print it.',
'Crea un WeakMap, almacena un valor para una clave de objeto, luego recupéralo e imprímelo.',
'javascript', 3, 'data_structures',
'const wm = new WeakMap();
const key = {};
wm.___( key, "secret" );
console.log(wm.___(key))',
'const wm = new WeakMap();
const key = {};
wm.set(key, "secret");
console.log(wm.get(key))',
'secret', 3,
'WeakMap keys must be objects.', 'Las claves de WeakMap deben ser objetos.',
'Use .set() and .get() just like a regular Map.', 'Usa .set() y .get() igual que un Map regular.',
'wm.set(key, val); wm.get(key)', 'wm.set(key, val); wm.get(key)',
30, 5, now()),

-- 70
(gen_random_uuid(), 'Array From', 'Array From',
'Use Array.from to create an array of squares [1,4,9,16,25] from length 5.',
'Usa Array.from para crear un array de cuadrados [1,4,9,16,25] desde longitud 5.',
'javascript', 3, 'arrays',
'let squares = Array.from({ length: 5 }, (_, i) => ___ );
console.log(squares)',
'let squares = Array.from({ length: 5 }, (_, i) => (i+1) ** 2);
console.log(squares)',
'[1,4,9,16,25]', 3,
'Array.from accepts a mapping function as second argument.', 'Array.from acepta una función de mapeo como segundo argumento.',
'i starts at 0, so use (i+1) ** 2.', 'i comienza en 0, así que usa (i+1) ** 2.',
'(_, i) => (i+1) ** 2', '(_, i) => (i+1) ** 2',
30, 5, now()),

-- 71
(gen_random_uuid(), 'String matchAll', 'String matchAll',
'Find all numbers in "a1 b22 c333" using matchAll and print them in an array.',
'Encuentra todos los números en "a1 b22 c333" usando matchAll e imprímelos en un array.',
'javascript', 3, 'strings',
'let str = "a1 b22 c333";
let matches = [...str.matchAll(___g)];
console.log(matches.map(m => m[0]))',
'let str = "a1 b22 c333";
let matches = [...str.matchAll(/\d+/g)];
console.log(matches.map(m => m[0]))',
'["1","22","333"]', 3,
'matchAll requires a global regex flag /g.', 'matchAll requiere la bandera global /g en la regex.',
'Each match object has m[0] as the matched string.', 'Cada objeto match tiene m[0] como el string coincidente.',
'/\\d+/g', '/\\d+/g',
30, 5, now()),

-- 72
(gen_random_uuid(), 'Prototype Chain', 'Cadena de Prototipos',
'Add a method "greet" to Animal.prototype. Create an Animal and call greet(). Print "Hello from Animal".',
'Agrega un método "greet" a Animal.prototype. Crea un Animal y llama greet(). Imprime "Hello from Animal".',
'javascript', 3, 'objects',
'function Animal() {}
Animal.___.greet = function() {
  console.log("Hello from Animal");
};
const a = new Animal();
a.greet()',
'function Animal() {}
Animal.prototype.greet = function() {
  console.log("Hello from Animal");
};
const a = new Animal();
a.greet()',
'Hello from Animal', 3,
'Methods shared across instances go on the prototype.', 'Los métodos compartidos entre instancias van en el prototipo.',
'Access prototype with ConstructorName.prototype.', 'Accede al prototipo con NombreConstructor.prototype.',
'Animal.prototype.greet = function() {...}', 'Animal.prototype.greet = function() {...}',
30, 5, now()),

-- 73
(gen_random_uuid(), 'Array Find', 'Array Find',
'Find the first number greater than 10 in [3, 7, 12, 5, 18] and print it.',
'Encuentra el primer número mayor que 10 en [3, 7, 12, 5, 18] e imprímelo.',
'javascript', 3, 'arrays',
'let nums = [3, 7, 12, 5, 18];
console.log(nums.___(n => n > 10))',
'let nums = [3, 7, 12, 5, 18];
console.log(nums.find(n => n > 10))',
'12', 3,
'Use .find() to get the first matching element.', 'Usa .find() para obtener el primer elemento coincidente.',
'Returns undefined if nothing matches.', 'Retorna undefined si nada coincide.',
'nums.find(n => n > 10)', 'nums.find(n => n > 10)',
30, 5, now()),

-- 74
(gen_random_uuid(), 'Array Flat', 'Array Flat',
'Flatten [[1,[2]],[3,[4,[5]]]] two levels deep and print the result.',
'Aplana [[1,[2]],[3,[4,[5]]]] dos niveles de profundidad e imprime el resultado.',
'javascript', 3, 'arrays',
'let arr = [[1,[2]],[3,[4,[5]]]];
console.log(arr.___(2))',
'let arr = [[1,[2]],[3,[4,[5]]]];
console.log(arr.flat(2))',
'[1,2,3,4,[5]]', 3,
'Use .flat(depth) to flatten nested arrays.', 'Usa .flat(profundidad) para aplanar arrays anidados.',
'Pass 2 to flatten two levels.', 'Pasa 2 para aplanar dos niveles.',
'arr.flat(2)', 'arr.flat(2)',
30, 5, now()),

-- 75
(gen_random_uuid(), 'Error Handling', 'Manejo de Errores',
'Wrap a JSON.parse call on invalid JSON in try/catch and print the error message.',
'Envuelve una llamada JSON.parse con JSON inválido en try/catch e imprime el mensaje de error.',
'javascript', 3, 'basics',
'try {
  JSON.parse("not json");
} catch (___) {
  console.log(e.message.slice(0, 17));
}',
'try {
  JSON.parse("not json");
} catch (e) {
  console.log(e.message.slice(0, 17));
}',
'Unexpected token', 3,
'Use try { } catch(e) { } for error handling.', 'Usa try { } catch(e) { } para el manejo de errores.',
'The error object has a .message property.', 'El objeto error tiene una propiedad .message.',
'catch (e) { console.log(e.message); }', 'catch (e) { console.log(e.message); }',
30, 5, now()),

-- ============================================================
-- DIFFICULTY 4 — 15 exercises
-- ============================================================

-- 76
(gen_random_uuid(), 'Memoization', 'Memoización',
'Implement a memoize(fn) wrapper that caches results. Wrap a slow square function and verify the cache works.',
'Implementa un wrapper memoize(fn) que cachea resultados. Envuelve una función cuadrado lenta y verifica que el caché funciona.',
'javascript', 4, 'patterns',
'function memoize(fn) {
  const cache = {};
  return function(n) {
    if (cache[___] !== undefined) return cache[n];
    cache[n] = fn(n);
    return ___;
  };
}
const sq = memoize(n => n * n);
console.log(sq(5));
console.log(sq(5))',
'function memoize(fn) {
  const cache = {};
  return function(n) {
    if (cache[n] !== undefined) return cache[n];
    cache[n] = fn(n);
    return cache[n];
  };
}
const sq = memoize(n => n * n);
console.log(sq(5));
console.log(sq(5))',
'25\n25', 3,
'Store computed results in a cache object.', 'Almacena resultados calculados en un objeto caché.',
'Check the cache before computing.', 'Verifica el caché antes de calcular.',
'if (cache[n] !== undefined) return cache[n];', 'if (cache[n] !== undefined) return cache[n];',
50, 10, now()),

-- 77
(gen_random_uuid(), 'Linked List Node', 'Nodo de Lista Enlazada',
'Implement a singly linked list. Create nodes 1->2->3 and print their values by traversal.',
'Implementa una lista enlazada simple. Crea nodos 1->2->3 e imprime sus valores por recorrido.',
'javascript', 4, 'data_structures',
'class Node {
  constructor(val) { this.val = val; this.next = ___; }
}
let head = new Node(1);
head.next = new Node(2);
head.next.next = new Node(3);
let cur = head;
while (cur) {
  console.log(cur.val);
  cur = cur.___;
}',
'class Node {
  constructor(val) { this.val = val; this.next = null; }
}
let head = new Node(1);
head.next = new Node(2);
head.next.next = new Node(3);
let cur = head;
while (cur) {
  console.log(cur.val);
  cur = cur.next;
}',
'1\n2\n3', 3,
'Initialize next to null in the constructor.', 'Inicializa next a null en el constructor.',
'Traverse by following .next until null.', 'Recorre siguiendo .next hasta null.',
'cur = cur.next;', 'cur = cur.next;',
50, 10, now()),

-- 78
(gen_random_uuid(), 'Binary Search', 'Búsqueda Binaria',
'Implement binary search on a sorted array. Return the index of target 7 in [1,3,5,7,9,11,13].',
'Implementa búsqueda binaria en un array ordenado. Retorna el índice del objetivo 7 en [1,3,5,7,9,11,13].',
'javascript', 4, 'algorithms',
'function binarySearch(arr, target) {
  let lo = 0, hi = arr.length - 1;
  while (lo <= hi) {
    let mid = Math.floor((lo + hi) / 2);
    if (arr[mid] === target) return ___;
    if (arr[mid] < target) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}
console.log(binarySearch([1,3,5,7,9,11,13], 7))',
'function binarySearch(arr, target) {
  let lo = 0, hi = arr.length - 1;
  while (lo <= hi) {
    let mid = Math.floor((lo + hi) / 2);
    if (arr[mid] === target) return mid;
    if (arr[mid] < target) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}
console.log(binarySearch([1,3,5,7,9,11,13], 7))',
'3', 3,
'Return the mid index when the target is found.', 'Retorna el índice mid cuando el objetivo es encontrado.',
'Adjust lo or hi to narrow the search window.', 'Ajusta lo o hi para reducir la ventana de búsqueda.',
'if (arr[mid] === target) return mid;', 'if (arr[mid] === target) return mid;',
50, 10, now()),

-- 79
(gen_random_uuid(), 'Deep Clone Object', 'Clonar Objeto en Profundidad',
'Deep clone { a: { b: { c: 42 } } } without using JSON, modify the clone, and confirm original is unchanged.',
'Clona en profundidad { a: { b: { c: 42 } } } sin usar JSON, modifica el clon y confirma que el original no cambió.',
'javascript', 4, 'objects',
'function deepClone(obj) {
  if (obj === null || typeof obj !== "object") return obj;
  const copy = {};
  for (const key in obj) {
    copy[key] = ___(obj[key]);
  }
  return copy;
}
const orig = { a: { b: { c: 42 } } };
const clone = deepClone(orig);
clone.a.b.c = 99;
console.log(orig.a.b.c)',
'function deepClone(obj) {
  if (obj === null || typeof obj !== "object") return obj;
  const copy = {};
  for (const key in obj) {
    copy[key] = deepClone(obj[key]);
  }
  return copy;
}
const orig = { a: { b: { c: 42 } } };
const clone = deepClone(orig);
clone.a.b.c = 99;
console.log(orig.a.b.c)',
'42', 3,
'Recursively clone nested objects.', 'Clona recursivamente los objetos anidados.',
'Call deepClone on each property value.', 'Llama deepClone en cada valor de propiedad.',
'copy[key] = deepClone(obj[key]);', 'copy[key] = deepClone(obj[key]);',
50, 10, now()),

-- 80
(gen_random_uuid(), 'Proxy Object', 'Objeto Proxy',
'Create a Proxy that logs "get: <key>" on every property access. Access proxy.name and proxy.age.',
'Crea un Proxy que registre "get: <clave>" en cada acceso de propiedad. Accede a proxy.name y proxy.age.',
'javascript', 4, 'patterns',
'const handler = {
  get(target, key) {
    console.log(`get: ${___}`);
    return target[key];
  }
};
const proxy = new ___({ name: "Al", age: 5 }, handler);
proxy.name;
proxy.age',
'const handler = {
  get(target, key) {
    console.log(`get: ${key}`);
    return target[key];
  }
};
const proxy = new Proxy({ name: "Al", age: 5 }, handler);
proxy.name;
proxy.age',
'get: name\nget: age', 3,
'The get trap receives (target, key).', 'La trampa get recibe (target, key).',
'Use new Proxy(target, handler).', 'Usa new Proxy(objetivo, manejador).',
'new Proxy(target, handler)', 'new Proxy(target, handler)',
50, 10, now()),

-- 81
(gen_random_uuid(), 'Compose Functions', 'Componer Funciones',
'Write a compose(f, g) function that returns h(x) = f(g(x)). Use it to compose double and addOne. Print compose(double, addOne)(3).',
'Escribe una función compose(f, g) que retorne h(x) = f(g(x)). Úsala para componer double y addOne. Imprime compose(double, addOne)(3).',
'javascript', 4, 'patterns',
'const double = x => x * 2;
const addOne = x => x + 1;
const compose = (f, g) => x => ___(___( x ));
console.log(compose(double, addOne)(3))',
'const double = x => x * 2;
const addOne = x => x + 1;
const compose = (f, g) => x => f(g(x));
console.log(compose(double, addOne)(3))',
'8', 3,
'compose applies g first, then f to the result.', 'compose aplica g primero, luego f al resultado.',
'addOne(3) = 4, double(4) = 8.', 'addOne(3) = 4, double(4) = 8.',
'f(g(x))', 'f(g(x))',
50, 10, now()),

-- 82
(gen_random_uuid(), 'Event Emitter', 'Emisor de Eventos',
'Implement a minimal EventEmitter with on() and emit(). Register a listener for "data" and emit it with value 42.',
'Implementa un EventEmitter mínimo con on() y emit(). Registra un listener para "data" y emítelo con valor 42.',
'javascript', 4, 'patterns',
'class EventEmitter {
  constructor() { this.listeners = {}; }
  on(event, fn) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[___].push(fn);
  }
  emit(event, data) {
    (this.listeners[event] || []).forEach(fn => fn(___));
  }
}
const ee = new EventEmitter();
ee.on("data", v => console.log(v));
ee.emit("data", 42)',
'class EventEmitter {
  constructor() { this.listeners = {}; }
  on(event, fn) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(fn);
  }
  emit(event, data) {
    (this.listeners[event] || []).forEach(fn => fn(data));
  }
}
const ee = new EventEmitter();
ee.on("data", v => console.log(v));
ee.emit("data", 42)',
'42', 3,
'Store listeners in an object keyed by event name.', 'Almacena listeners en un objeto con clave por nombre de evento.',
'Call each listener with the data argument in emit.', 'Llama cada listener con el argumento data en emit.',
'fn(data)', 'fn(data)',
50, 10, now()),

-- 83
(gen_random_uuid(), 'Queue Implementation', 'Implementación de Cola',
'Implement a Queue class with enqueue, dequeue, and size. Enqueue 1,2,3 then dequeue once. Print size.',
'Implementa una clase Queue con enqueue, dequeue y size. Encola 1,2,3 luego desencola una vez. Imprime el tamaño.',
'javascript', 4, 'data_structures',
'class Queue {
  constructor() { this.items = []; }
  enqueue(val) { this.items.push(val); }
  dequeue() { return this.items.___(); }
  get size() { return this.items.___; }
}
const q = new Queue();
q.enqueue(1); q.enqueue(2); q.enqueue(3);
q.dequeue();
console.log(q.size)',
'class Queue {
  constructor() { this.items = []; }
  enqueue(val) { this.items.push(val); }
  dequeue() { return this.items.shift(); }
  get size() { return this.items.length; }
}
const q = new Queue();
q.enqueue(1); q.enqueue(2); q.enqueue(3);
q.dequeue();
console.log(q.size)',
'2', 3,
'Use shift() to remove from the front of the array.', 'Usa shift() para eliminar del frente del array.',
'size is a getter that returns the array length.', 'size es un getter que retorna la longitud del array.',
'this.items.shift()', 'this.items.shift()',
50, 10, now()),

-- 84
(gen_random_uuid(), 'Throttle Function', 'Función Throttle',
'Implement throttle(fn, limit) that ensures fn is called at most once per limit ms. Show the pattern with a counter.',
'Implementa throttle(fn, limit) que asegure que fn se llame como máximo una vez por limit ms. Muestra el patrón con un contador.',
'javascript', 4, 'patterns',
'function throttle(fn, limit) {
  let lastCall = 0;
  return function(...args) {
    const now = Date.now();
    if (now - lastCall >= ___) {
      lastCall = now;
      return fn(...args);
    }
  };
}
let count = 0;
const inc = throttle(() => ++count, 100);
inc(); inc(); inc();
console.log(count)',
'function throttle(fn, limit) {
  let lastCall = 0;
  return function(...args) {
    const now = Date.now();
    if (now - lastCall >= limit) {
      lastCall = now;
      return fn(...args);
    }
  };
}
let count = 0;
const inc = throttle(() => ++count, 100);
inc(); inc(); inc();
console.log(count)',
'1', 3,
'Track the last call time to enforce the limit.', 'Rastrea el tiempo de la última llamada para imponer el límite.',
'Only execute fn when enough time has elapsed.', 'Solo ejecuta fn cuando haya pasado suficiente tiempo.',
'if (now - lastCall >= limit)', 'if (now - lastCall >= limit)',
50, 10, now()),

-- 85
(gen_random_uuid(), 'Merge Sort', 'Ordenamiento por Mezcla',
'Implement merge sort. Sort [38, 27, 43, 3, 9, 82, 10] and print the result.',
'Implementa merge sort. Ordena [38, 27, 43, 3, 9, 82, 10] e imprime el resultado.',
'javascript', 4, 'algorithms',
'function merge(left, right) {
  let res = [];
  while (left.length && right.length) {
    if (left[0] < right[0]) res.push(left.shift());
    else res.push(right.___());
  }
  return [...res, ...left, ...right];
}
function mergeSort(arr) {
  if (arr.length <= 1) return arr;
  const mid = Math.floor(arr.length / 2);
  return merge(mergeSort(arr.slice(0, mid)), mergeSort(arr.slice(___)));
}
console.log(mergeSort([38,27,43,3,9,82,10]))',
'function merge(left, right) {
  let res = [];
  while (left.length && right.length) {
    if (left[0] < right[0]) res.push(left.shift());
    else res.push(right.shift());
  }
  return [...res, ...left, ...right];
}
function mergeSort(arr) {
  if (arr.length <= 1) return arr;
  const mid = Math.floor(arr.length / 2);
  return merge(mergeSort(arr.slice(0, mid)), mergeSort(arr.slice(mid)));
}
console.log(mergeSort([38,27,43,3,9,82,10]))',
'[3,9,10,27,38,43,82]', 3,
'Split the array in half, sort each half, then merge.', 'Divide el array a la mitad, ordena cada mitad, luego mezcla.',
'Merge compares front elements of each half.', 'Merge compara los elementos del frente de cada mitad.',
'mergeSort(arr.slice(mid))', 'mergeSort(arr.slice(mid))',
50, 10, now()),

-- 86
(gen_random_uuid(), 'Observer Pattern', 'Patrón Observador',
'Implement a simple Observable with subscribe and next. Subscribe two observers, call next(5), and print the outputs.',
'Implementa un Observable simple con subscribe y next. Suscribe dos observadores, llama next(5) e imprime las salidas.',
'javascript', 4, 'patterns',
'class Observable {
  constructor() { this._subs = []; }
  subscribe(fn) { this._subs.push(fn); }
  next(val) { this._subs.forEach(___ => fn(val)); }
}
const obs = new Observable();
obs.subscribe(v => console.log("A:" + v));
obs.subscribe(v => console.log("B:" + v));
obs.next(5)',
'class Observable {
  constructor() { this._subs = []; }
  subscribe(fn) { this._subs.push(fn); }
  next(val) { this._subs.forEach(fn => fn(val)); }
}
const obs = new Observable();
obs.subscribe(v => console.log("A:" + v));
obs.subscribe(v => console.log("B:" + v));
obs.next(5)',
'A:5\nB:5', 3,
'Store subscriber functions in an array.', 'Almacena las funciones suscriptoras en un array.',
'Call each subscriber with the value in next().', 'Llama a cada suscriptor con el valor en next().',
'this._subs.forEach(fn => fn(val))', 'this._subs.forEach(fn => fn(val))',
50, 10, now()),

-- 87
(gen_random_uuid(), 'Trie Prefix Search', 'Búsqueda de Prefijos con Trie',
'Implement a basic Trie that inserts words and checks if a prefix exists. Insert "apple", search prefix "app".',
'Implementa un Trie básico que inserta palabras y verifica si un prefijo existe. Inserta "apple", busca el prefijo "app".',
'javascript', 4, 'data_structures',
'class Trie {
  constructor() { this.root = {}; }
  insert(word) {
    let node = this.root;
    for (const ch of word) {
      if (!node[ch]) node[ch] = {};
      node = node[___];
    }
  }
  hasPrefix(prefix) {
    let node = this.root;
    for (const ch of prefix) {
      if (!node[ch]) return false;
      node = node[ch];
    }
    return ___;
  }
}
const t = new Trie();
t.insert("apple");
console.log(t.hasPrefix("app"))',
'class Trie {
  constructor() { this.root = {}; }
  insert(word) {
    let node = this.root;
    for (const ch of word) {
      if (!node[ch]) node[ch] = {};
      node = node[ch];
    }
  }
  hasPrefix(prefix) {
    let node = this.root;
    for (const ch of prefix) {
      if (!node[ch]) return false;
      node = node[ch];
    }
    return true;
  }
}
const t = new Trie();
t.insert("apple");
console.log(t.hasPrefix("app"))',
'true', 3,
'Each Trie node is an object whose keys are characters.', 'Cada nodo Trie es un objeto cuyas claves son caracteres.',
'Traverse the trie character by character.', 'Recorre el trie carácter por carácter.',
'node = node[ch];', 'node = node[ch];',
50, 10, now()),

-- 88
(gen_random_uuid(), 'Async Iterator', 'Iterador Asíncrono',
'Create an async generator that yields 1, 2, 3 with a small delay. Consume it and print each value.',
'Crea un generador asíncrono que produzca 1, 2, 3 con un pequeño retraso. Consúmelo e imprime cada valor.',
'javascript', 4, 'functions',
'async function* asyncGen() {
  for (let i = 1; i <= 3; i++) {
    await Promise.resolve();
    ___ i;
  }
}
(async () => {
  for ___ (const val of asyncGen()) {
    console.log(val);
  }
})()',
'async function* asyncGen() {
  for (let i = 1; i <= 3; i++) {
    await Promise.resolve();
    yield i;
  }
}
(async () => {
  for await (const val of asyncGen()) {
    console.log(val);
  }
})()',
'1\n2\n3', 3,
'Async generators use async function* and yield.', 'Los generadores asíncronos usan async function* y yield.',
'Consume with for await...of loop.', 'Consúmelos con el bucle for await...of.',
'for await (const val of asyncGen())', 'for await (const val of asyncGen())',
50, 10, now()),

-- 89
(gen_random_uuid(), 'Flatten Nested Object', 'Aplanar Objeto Anidado',
'Write a flatten function that converts { a: { b: { c: 1 } }, d: 2 } to { "a.b.c": 1, d: 2 }.',
'Escribe una función flatten que convierta { a: { b: { c: 1 } }, d: 2 } a { "a.b.c": 1, d: 2 }.',
'javascript', 4, 'objects',
'function flatten(obj, prefix = "") {
  return Object.entries(obj).reduce((acc, [k, v]) => {
    const key = prefix ? `${prefix}.${k}` : k;
    if (typeof v === "object" && v !== null) {
      Object.assign(acc, ___(v, key));
    } else {
      acc[key] = v;
    }
    return acc;
  }, {});
}
console.log(JSON.stringify(flatten({ a: { b: { c: 1 } }, d: 2 })))',
'function flatten(obj, prefix = "") {
  return Object.entries(obj).reduce((acc, [k, v]) => {
    const key = prefix ? `${prefix}.${k}` : k;
    if (typeof v === "object" && v !== null) {
      Object.assign(acc, flatten(v, key));
    } else {
      acc[key] = v;
    }
    return acc;
  }, {});
}
console.log(JSON.stringify(flatten({ a: { b: { c: 1 } }, d: 2 })))',
'{"a.b.c":1,"d":2}', 3,
'Recursively call flatten with the current key as prefix.', 'Llama recursivamente flatten con la clave actual como prefijo.',
'Use Object.assign to merge nested results.', 'Usa Object.assign para unir resultados anidados.',
'Object.assign(acc, flatten(v, key))', 'Object.assign(acc, flatten(v, key))',
50, 10, now()),

-- 90
(gen_random_uuid(), 'LRU Cache', 'Caché LRU',
'Implement an LRU Cache with capacity 2. Put (1,1), (2,2), get(1), put(3,3), then get(2) — should return -1.',
'Implementa un Caché LRU con capacidad 2. Pon (1,1), (2,2), get(1), pon (3,3), luego get(2) — debe retornar -1.',
'javascript', 4, 'data_structures',
'class LRUCache {
  constructor(cap) { this.cap = cap; this.map = new ___(); }
  get(key) {
    if (!this.map.has(key)) return -1;
    const val = this.map.get(key);
    this.map.delete(key); this.map.set(key, val);
    return val;
  }
  put(key, val) {
    if (this.map.has(key)) this.map.delete(key);
    else if (this.map.size >= this.cap) this.map.delete(this.map.keys().next().___);
    this.map.set(key, val);
  }
}
const c = new LRUCache(2);
c.put(1,1); c.put(2,2); c.get(1); c.put(3,3);
console.log(c.get(2))',
'class LRUCache {
  constructor(cap) { this.cap = cap; this.map = new Map(); }
  get(key) {
    if (!this.map.has(key)) return -1;
    const val = this.map.get(key);
    this.map.delete(key); this.map.set(key, val);
    return val;
  }
  put(key, val) {
    if (this.map.has(key)) this.map.delete(key);
    else if (this.map.size >= this.cap) this.map.delete(this.map.keys().next().value);
    this.map.set(key, val);
  }
}
const c = new LRUCache(2);
c.put(1,1); c.put(2,2); c.get(1); c.put(3,3);
console.log(c.get(2))',
'-1', 3,
'A Map maintains insertion order — exploit this for LRU.', 'Un Map mantiene el orden de inserción — explota esto para LRU.',
'Re-insert on get to mark as recently used.', 'Re-inserta en get para marcarlo como recientemente usado.',
'this.map.keys().next().value', 'this.map.keys().next().value',
50, 10, now()),

-- ============================================================
-- DIFFICULTY 5 — 10 exercises
-- ============================================================

-- 91
(gen_random_uuid(), 'Promise.all Race', 'Carrera con Promise.all',
'Write promiseAll(promises) that resolves with all results in order, or rejects on first failure. Test with [1,2,3] resolves.',
'Escribe promiseAll(promises) que resuelve con todos los resultados en orden, o rechaza en el primer fallo. Prueba con [1,2,3] que se resuelven.',
'javascript', 5, 'challenges',
'function promiseAll(promises) {
  return new Promise((resolve, reject) => {
    let results = [], count = 0;
    promises.forEach((p, i) => {
      Promise.resolve(p).then(val => {
        results[i] = val;
        if (++count === ___) resolve(results);
      }).catch(reject);
    });
  });
}
promiseAll([Promise.resolve(1), Promise.resolve(2), Promise.resolve(3)])
  .then(console.log)',
'function promiseAll(promises) {
  return new Promise((resolve, reject) => {
    let results = [], count = 0;
    promises.forEach((p, i) => {
      Promise.resolve(p).then(val => {
        results[i] = val;
        if (++count === promises.length) resolve(results);
      }).catch(reject);
    });
  });
}
promiseAll([Promise.resolve(1), Promise.resolve(2), Promise.resolve(3)])
  .then(console.log)',
'[1,2,3]', 3,
'Track resolved count against total promises length.', 'Rastrea el conteo de resueltos contra la longitud total de promises.',
'Resolve only when all have completed.', 'Resuelve solo cuando todos hayan completado.',
'if (++count === promises.length) resolve(results)', 'if (++count === promises.length) resolve(results)',
100, 10, now()),

-- 92
(gen_random_uuid(), 'Implement bind()', 'Implementar bind()',
'Implement Function.prototype.myBind(ctx, ...args) that works like native bind. Test with a greet function.',
'Implementa Function.prototype.myBind(ctx, ...args) que funcione como bind nativo. Prueba con una función greet.',
'javascript', 5, 'challenges',
'Function.prototype.myBind = function(ctx, ...partial) {
  const fn = ___;
  return function(...args) {
    return fn.call(___, ...partial, ...args);
  };
};
function greet(greeting, name) { console.log(`${greeting}, ${name}!`); }
const hi = greet.myBind(null, "Hello");
hi("World")',
'Function.prototype.myBind = function(ctx, ...partial) {
  const fn = this;
  return function(...args) {
    return fn.call(ctx, ...partial, ...args);
  };
};
function greet(greeting, name) { console.log(`${greeting}, ${name}!`); }
const hi = greet.myBind(null, "Hello");
hi("World")',
'Hello, World!', 3,
'Capture this (the original function) before returning the new function.', 'Captura this (la función original) antes de retornar la nueva función.',
'Use fn.call(ctx, ...partial, ...args) to apply with context.', 'Usa fn.call(ctx, ...partial, ...args) para aplicar con contexto.',
'const fn = this; fn.call(ctx, ...partial, ...args)', 'const fn = this; fn.call(ctx, ...partial, ...args)',
100, 10, now()),

-- 93
(gen_random_uuid(), 'Virtual DOM Diff', 'Diff de DOM Virtual',
'Write a diff(oldNode, newNode) that returns a patch describing changes. Test string vs string node.',
'Escribe un diff(oldNode, newNode) que retorne un parche describiendo cambios. Prueba nodo string vs string.',
'javascript', 5, 'challenges',
'function diff(oldNode, newNode) {
  if (typeof oldNode !== typeof newNode) return { type: ___ };
  if (typeof oldNode === "string") {
    return oldNode !== newNode ? { type: "REPLACE", newNode } : null;
  }
  return null;
}
console.log(JSON.stringify(diff("hello", "world")))',
'function diff(oldNode, newNode) {
  if (typeof oldNode !== typeof newNode) return { type: "REPLACE" };
  if (typeof oldNode === "string") {
    return oldNode !== newNode ? { type: "REPLACE", newNode } : null;
  }
  return null;
}
console.log(JSON.stringify(diff("hello", "world")))',
'{"type":"REPLACE","newNode":"world"}', 3,
'Return a patch object describing the change type.', 'Retorna un objeto parche describiendo el tipo de cambio.',
'Compare string nodes directly for equality.', 'Compara nodos string directamente por igualdad.',
'{ type: "REPLACE", newNode }', '{ type: "REPLACE", newNode }',
100, 10, now()),

-- 94
(gen_random_uuid(), 'State Machine', 'Máquina de Estados',
'Implement a traffic light state machine: green->yellow->red->green. Print three transitions.',
'Implementa una máquina de estados de semáforo: green->yellow->red->green. Imprime tres transiciones.',
'javascript', 5, 'patterns',
'const transitions = {
  green: "yellow",
  yellow: "red",
  red: "___"
};
function createLight(init) {
  let state = init;
  return {
    next() { state = transitions[___]; return state; }
  };
}
const light = createLight("green");
console.log(light.next());
console.log(light.next());
console.log(light.next())',
'const transitions = {
  green: "yellow",
  yellow: "red",
  red: "green"
};
function createLight(init) {
  let state = init;
  return {
    next() { state = transitions[state]; return state; }
  };
}
const light = createLight("green");
console.log(light.next());
console.log(light.next());
console.log(light.next())',
'yellow\nred\ngreen', 3,
'Use a transitions object mapping current state to next.', 'Usa un objeto de transiciones que mapea el estado actual al siguiente.',
'Update state using state = transitions[state].', 'Actualiza el estado usando state = transitions[state].',
'state = transitions[state];', 'state = transitions[state];',
100, 10, now()),

-- 95
(gen_random_uuid(), 'Topological Sort', 'Ordenamiento Topológico',
'Implement topological sort using DFS on graph { a:[''b'',''c''], b:[''d''], c:[''d''], d:[] }. Print valid order.',
'Implementa ordenamiento topológico usando DFS en grafo { a:[''b'',''c''], b:[''d''], c:[''d''], d:[] }. Imprime un orden válido.',
'javascript', 5, 'algorithms',
'function topoSort(graph) {
  const visited = new Set(), result = [];
  function dfs(node) {
    if (visited.has(node)) return;
    visited.add(node);
    for (const dep of (graph[node] || [])) dfs(___);
    result.___(node);
  }
  for (const node of Object.keys(graph)) dfs(node);
  return result.reverse();
}
const g = { a:["b","c"], b:["d"], c:["d"], d:[] };
console.log(topoSort(g)[0])',
'function topoSort(graph) {
  const visited = new Set(), result = [];
  function dfs(node) {
    if (visited.has(node)) return;
    visited.add(node);
    for (const dep of (graph[node] || [])) dfs(dep);
    result.push(node);
  }
  for (const node of Object.keys(graph)) dfs(node);
  return result.reverse();
}
const g = { a:["b","c"], b:["d"], c:["d"], d:[] };
console.log(topoSort(g)[0])',
'a', 3,
'DFS: push node to result after visiting all dependencies.', 'DFS: empuja el nodo al resultado después de visitar todas las dependencias.',
'Reverse the result at the end for correct order.', 'Invierte el resultado al final para el orden correcto.',
'result.push(node); return result.reverse();', 'result.push(node); return result.reverse();',
100, 10, now()),

-- 96
(gen_random_uuid(), 'Reactive Signals', 'Señales Reactivas',
'Implement createSignal(val) returning [get, set] and createEffect(fn) that re-runs when signals change. Print two effect runs.',
'Implementa createSignal(val) que retorna [get, set] y createEffect(fn) que se vuelve a ejecutar cuando las señales cambian. Imprime dos ejecuciones del efecto.',
'javascript', 5, 'patterns',
'let currentEffect = null;
function createSignal(val) {
  const subs = new Set();
  return [
    () => { if (currentEffect) subs.add(___); return val; },
    (newVal) => { val = newVal; subs.forEach(fn => fn()); }
  ];
}
function createEffect(fn) {
  currentEffect = fn; fn(); currentEffect = ___;
}
const [count, setCount] = createSignal(0);
createEffect(() => console.log("count:", count()));
setCount(1)',
'let currentEffect = null;
function createSignal(val) {
  const subs = new Set();
  return [
    () => { if (currentEffect) subs.add(currentEffect); return val; },
    (newVal) => { val = newVal; subs.forEach(fn => fn()); }
  ];
}
function createEffect(fn) {
  currentEffect = fn; fn(); currentEffect = null;
}
const [count, setCount] = createSignal(0);
createEffect(() => console.log("count:", count()));
setCount(1)',
'count: 0\ncount: 1', 3,
'Track the currently executing effect in a global variable.', 'Rastrea el efecto ejecutándose actualmente en una variable global.',
'When a signal is read, subscribe the current effect.', 'Cuando se lee una señal, suscribe el efecto actual.',
'subs.add(currentEffect)', 'subs.add(currentEffect)',
100, 10, now()),

-- 97
(gen_random_uuid(), 'Parser Combinator', 'Combinador de Parsers',
'Implement a char(c) parser and seq(p1, p2) combinator. Parse "ab" with seq(char("a"), char("b")). Print result.',
'Implementa un parser char(c) y el combinador seq(p1, p2). Parsea "ab" con seq(char("a"), char("b")). Imprime el resultado.',
'javascript', 5, 'challenges',
'const char = c => input => {
  if (input[0] === c) return { val: c, rest: ___.slice(1) };
  return null;
};
const seq = (p1, p2) => input => {
  const r1 = p1(input);
  if (!r1) return null;
  const r2 = p2(r1.rest);
  if (!r2) return null;
  return { val: [r1.val, r2.val], rest: r2.rest };
};
const r = seq(char("a"), char("b"))("ab");
console.log(JSON.stringify(r.val))',
'const char = c => input => {
  if (input[0] === c) return { val: c, rest: input.slice(1) };
  return null;
};
const seq = (p1, p2) => input => {
  const r1 = p1(input);
  if (!r1) return null;
  const r2 = p2(r1.rest);
  if (!r2) return null;
  return { val: [r1.val, r2.val], rest: r2.rest };
};
const r = seq(char("a"), char("b"))("ab");
console.log(JSON.stringify(r.val))',
'["a","b"]', 3,
'Each parser takes input and returns {val, rest} or null.', 'Cada parser toma input y retorna {val, rest} o null.',
'seq chains two parsers: pass r1.rest to p2.', 'seq encadena dos parsers: pasa r1.rest a p2.',
'rest: input.slice(1)', 'rest: input.slice(1)',
100, 10, now()),

-- 98
(gen_random_uuid(), 'Immutable Update', 'Actualización Inmutable',
'Write produce(state, recipe) that applies recipe to a draft without mutating the original. Print original and updated.',
'Escribe produce(state, recipe) que aplica recipe a un borrador sin mutar el original. Imprime el original y el actualizado.',
'javascript', 5, 'patterns',
'function produce(state, recipe) {
  const draft = ___(state);
  recipe(draft);
  return draft;
}
const orig = { count: 0, name: "test" };
const next = produce(orig, d => { d.count++; });
console.log(orig.count);
console.log(next.count)',
'function produce(state, recipe) {
  const draft = Object.assign({}, state);
  recipe(draft);
  return draft;
}
const orig = { count: 0, name: "test" };
const next = produce(orig, d => { d.count++; });
console.log(orig.count);
console.log(next.count)',
'0\n1', 3,
'Create a shallow copy of state before passing to recipe.', 'Crea una copia superficial de state antes de pasar al recipe.',
'Use Object.assign({}, state) for the draft.', 'Usa Object.assign({}, state) para el borrador.',
'Object.assign({}, state)', 'Object.assign({}, state)',
100, 10, now()),

-- 99
(gen_random_uuid(), 'Serialize/Deserialize BST', 'Serializar/Deserializar BST',
'Implement serialize and deserialize for a BST node structure. Verify round-trip for a 3-node tree.',
'Implementa serialize y deserialize para una estructura de nodo BST. Verifica ida y vuelta para un árbol de 3 nodos.',
'javascript', 5, 'data_structures',
'class BSTNode {
  constructor(v, l=null, r=null) { this.v=v; this.l=l; this.r=r; }
}
function serialize(node) {
  if (!node) return "null";
  return `${node.v},${___(node.l)},${serialize(node.r)}`;
}
function deserialize(data) {
  const vals = data.split(",");
  function build() {
    const v = vals.shift();
    if (v === "null") return null;
    return new BSTNode(+v, build(), build());
  }
  return ___;
}
const root = new BSTNode(2, new BSTNode(1), new BSTNode(3));
const s = serialize(root);
const r = deserialize(s);
console.log(r.v, r.l.v, r.r.v)',
'class BSTNode {
  constructor(v, l=null, r=null) { this.v=v; this.l=l; this.r=r; }
}
function serialize(node) {
  if (!node) return "null";
  return `${node.v},${serialize(node.l)},${serialize(node.r)}`;
}
function deserialize(data) {
  const vals = data.split(",");
  function build() {
    const v = vals.shift();
    if (v === "null") return null;
    return new BSTNode(+v, build(), build());
  }
  return build();
}
const root = new BSTNode(2, new BSTNode(1), new BSTNode(3));
const s = serialize(root);
const r = deserialize(s);
console.log(r.v, r.l.v, r.r.v)',
'2 1 3', 3,
'Use preorder traversal for both serialize and deserialize.', 'Usa recorrido preorden tanto para serializar como para deserializar.',
'In deserialize, shift values off the array to build nodes.', 'En deserialize, saca valores del array para construir nodos.',
'return build();', 'return build();',
100, 10, now()),

-- 100
(gen_random_uuid(), 'Pipe with Error Handling', 'Pipe con Manejo de Errores',
'Implement pipe(...fns) that chains async functions left-to-right, stopping on error. Run a 3-step pipeline.',
'Implementa pipe(...fns) que encadena funciones asíncronas de izquierda a derecha, deteniendo en error. Ejecuta una tubería de 3 pasos.',
'javascript', 5, 'challenges',
'const pipe = (...fns) => async (input) => {
  let result = input;
  for (const fn of fns) {
    result = ___ fn(result);
    if (result instanceof Error) return result;
  }
  return result;
};
const double = async x => x * 2;
const addTen = async x => x + 10;
const toString = async x => `value:${x}`;
pipe(double, addTen, toString)(5).then(console.log)',
'const pipe = (...fns) => async (input) => {
  let result = input;
  for (const fn of fns) {
    result = await fn(result);
    if (result instanceof Error) return result;
  }
  return result;
};
const double = async x => x * 2;
const addTen = async x => x + 10;
const toString = async x => `value:${x}`;
pipe(double, addTen, toString)(5).then(console.log)',
'value:20', 3,
'Use await in the loop to resolve each async function.', 'Usa await en el bucle para resolver cada función asíncrona.',
'double(5)=10, addTen(10)=20, toString(20)="value:20".', 'double(5)=10, addTen(10)=20, toString(20)="value:20".',
'result = await fn(result);', 'result = await fn(result);',
100, 10, now())

ON CONFLICT DO NOTHING;

COMMIT;
