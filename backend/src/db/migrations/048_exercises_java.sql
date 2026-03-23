-- 048_exercises_java.sql
-- 100 Java programming exercises, bilingual EN+ES
-- Distribution: diff1:25, diff2:25, diff3:25, diff4:15, diff5:10

BEGIN;

INSERT INTO exercises (
  id, title_en, title_es, description_en, description_es,
  language, difficulty, category,
  starter_code, expected_output,
  hint_count, hint_1_en, hint_1_es, hint_2_en, hint_2_es, hint_3_en, hint_3_es,
  points, hints_used_penalty, created_at
) VALUES

-- ============================================================
-- JAVA DIFFICULTY 1 (25 exercises)
-- ============================================================

(gen_random_uuid(),
 'Hello World', 'Hola Mundo',
 'Print the text "Hello, World!" to the console.',
 'Imprime el texto "Hello, World!" en la consola.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'Hello, World!',
 3,
 'Use System.out.println() to print a line.', 'Usa System.out.println() para imprimir una línea.',
 'Pass the string as an argument inside the parentheses.', 'Pasa la cadena como argumento dentro de los paréntesis.',
 'System.out.println("Hello, World!");', 'System.out.println("Hello, World!");',
 10, 3, now()),

(gen_random_uuid(),
 'Print an Integer', 'Imprimir un Entero',
 'Declare an integer variable with value 42 and print it.',
 'Declara una variable entera con valor 42 e imprímela.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '42',
 3,
 'Use the keyword int to declare an integer variable.', 'Usa la palabra clave int para declarar una variable entera.',
 'Assign the value with the = operator.', 'Asigna el valor con el operador =.',
 'int x = 42; System.out.println(x);', 'int x = 42; System.out.println(x);',
 10, 3, now()),

(gen_random_uuid(),
 'Add Two Numbers', 'Sumar Dos Números',
 'Declare two integers, 7 and 3, add them together, and print the result.',
 'Declara dos enteros, 7 y 3, súmalos e imprime el resultado.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '10',
 3,
 'Declare two int variables.', 'Declara dos variables int.',
 'Use the + operator to add them.', 'Usa el operador + para sumarlos.',
 'int sum = 7 + 3; System.out.println(sum);', 'int sum = 7 + 3; System.out.println(sum);',
 10, 3, now()),

(gen_random_uuid(),
 'String Concatenation', 'Concatenación de Cadenas',
 'Create two strings "Hello" and "Java", concatenate them with a space, and print the result.',
 'Crea dos cadenas "Hello" y "Java", concaténalas con un espacio e imprime el resultado.',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'Hello Java',
 3,
 'Use the + operator to concatenate strings.', 'Usa el operador + para concatenar cadenas.',
 'Include a space " " between the two strings.', 'Incluye un espacio " " entre las dos cadenas.',
 'System.out.println("Hello" + " " + "Java");', 'System.out.println("Hello" + " " + "Java");',
 10, 3, now()),

(gen_random_uuid(),
 'Boolean Variable', 'Variable Booleana',
 'Declare a boolean variable set to true and print it.',
 'Declara una variable booleana con valor true e imprímela.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'Use the keyword boolean to declare the variable.', 'Usa la palabra clave boolean para declarar la variable.',
 'Assign true (no quotes) to the variable.', 'Asigna true (sin comillas) a la variable.',
 'boolean flag = true; System.out.println(flag);', 'boolean flag = true; System.out.println(flag);',
 10, 3, now()),

(gen_random_uuid(),
 'Simple If Statement', 'Sentencia If Simple',
 'Check if the number 10 is greater than 5. If so, print "Yes".',
 'Verifica si el número 10 es mayor que 5. Si es así, imprime "Yes".',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'Yes',
 3,
 'Use an if statement with a condition in parentheses.', 'Usa una sentencia if con una condición entre paréntesis.',
 'The > operator checks greater-than.', 'El operador > verifica mayor que.',
 'if (10 > 5) { System.out.println("Yes"); }', 'if (10 > 5) { System.out.println("Yes"); }',
 10, 3, now()),

(gen_random_uuid(),
 'For Loop 1 to 5', 'Bucle For del 1 al 5',
 'Use a for loop to print the numbers 1 through 5, each on its own line.',
 'Usa un bucle for para imprimir los números del 1 al 5, cada uno en su propia línea.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1\n2\n3\n4\n5',
 3,
 'A for loop has three parts: init; condition; update.', 'Un bucle for tiene tres partes: inicio; condición; actualización.',
 'Start i at 1 and loop while i <= 5.', 'Comienza i en 1 y repite mientras i <= 5.',
 'for (int i = 1; i <= 5; i++) { System.out.println(i); }', 'for (int i = 1; i <= 5; i++) { System.out.println(i); }',
 10, 3, now()),

(gen_random_uuid(),
 'String Length', 'Longitud de Cadena',
 'Print the length of the string "programming".',
 'Imprime la longitud de la cadena "programming".',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '11',
 3,
 'Every String object has a length() method.', 'Todo objeto String tiene un método length().',
 'Call .length() on the string literal or variable.', 'Llama .length() sobre el literal o variable de cadena.',
 'System.out.println("programming".length());', 'System.out.println("programming".length());',
 10, 3, now()),

(gen_random_uuid(),
 'Array Declaration', 'Declaración de Arreglo',
 'Declare an integer array with values {1, 2, 3, 4, 5} and print its length.',
 'Declara un arreglo de enteros con valores {1, 2, 3, 4, 5} e imprime su longitud.',
 'java', 1, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '5',
 3,
 'Declare the array with int[] name = {values};', 'Declara el arreglo con int[] nombre = {valores};',
 'Arrays have a .length property (not a method).', 'Los arreglos tienen una propiedad .length (no es un método).',
 'int[] arr = {1,2,3,4,5}; System.out.println(arr.length);', 'int[] arr = {1,2,3,4,5}; System.out.println(arr.length);',
 10, 3, now()),

(gen_random_uuid(),
 'Access Array Element', 'Acceder a Elemento de Arreglo',
 'Declare an array {10, 20, 30} and print the second element.',
 'Declara un arreglo {10, 20, 30} e imprime el segundo elemento.',
 'java', 1, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '20',
 3,
 'Array indices start at 0.', 'Los índices de arreglo empiezan en 0.',
 'The second element is at index 1.', 'El segundo elemento está en el índice 1.',
 'int[] arr = {10,20,30}; System.out.println(arr[1]);', 'int[] arr = {10,20,30}; System.out.println(arr[1]);',
 10, 3, now()),

(gen_random_uuid(),
 'While Loop Countdown', 'Bucle While de Cuenta Regresiva',
 'Use a while loop to print numbers from 5 down to 1.',
 'Usa un bucle while para imprimir los números del 5 al 1 en orden descendente.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '5\n4\n3\n2\n1',
 3,
 'Initialize a counter at 5.', 'Inicializa un contador en 5.',
 'Decrease the counter by 1 each iteration with i--.', 'Disminuye el contador en 1 cada iteración con i--.',
 'int i = 5; while (i >= 1) { System.out.println(i); i--; }', 'int i = 5; while (i >= 1) { System.out.println(i); i--; }',
 10, 3, now()),

(gen_random_uuid(),
 'Even or Odd', 'Par o Impar',
 'Check if the number 7 is even or odd and print "odd".',
 'Verifica si el número 7 es par o impar e imprime "odd".',
 'java', 1, 'math',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'odd',
 3,
 'Use the modulo operator % to check the remainder.', 'Usa el operador módulo % para verificar el residuo.',
 'If number % 2 == 0 it is even, otherwise odd.', 'Si número % 2 == 0 es par, de lo contrario impar.',
 'if (7 % 2 == 0) { System.out.println("even"); } else { System.out.println("odd"); }', 'if (7 % 2 == 0) { System.out.println("even"); } else { System.out.println("odd"); }',
 10, 3, now()),

(gen_random_uuid(),
 'String Uppercase', 'Cadena en Mayúsculas',
 'Convert the string "hello" to uppercase and print it.',
 'Convierte la cadena "hello" a mayúsculas e imprímela.',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'HELLO',
 3,
 'String has a method to convert case.', 'String tiene un método para convertir mayúsculas/minúsculas.',
 'Use .toUpperCase() on the string.', 'Usa .toUpperCase() sobre la cadena.',
 'System.out.println("hello".toUpperCase());', 'System.out.println("hello".toUpperCase());',
 10, 3, now()),

(gen_random_uuid(),
 'Math Max', 'Máximo Matemático',
 'Use Math.max() to find and print the larger of 14 and 27.',
 'Usa Math.max() para encontrar e imprimir el mayor entre 14 y 27.',
 'java', 1, 'math',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '27',
 3,
 'The Math class provides utility methods.', 'La clase Math provee métodos utilitarios.',
 'Math.max(a, b) returns the larger of two values.', 'Math.max(a, b) devuelve el mayor de dos valores.',
 'System.out.println(Math.max(14, 27));', 'System.out.println(Math.max(14, 27));',
 10, 3, now()),

(gen_random_uuid(),
 'Cast Double to Int', 'Convertir Double a Int',
 'Declare a double 9.99 and cast it to an int. Print the result.',
 'Declara un double 9.99 y conviértelo a int. Imprime el resultado.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '9',
 3,
 'Use a cast by placing the target type in parentheses.', 'Usa un cast colocando el tipo destino entre paréntesis.',
 '(int) before the value truncates the decimal part.', '(int) antes del valor trunca la parte decimal.',
 'double d = 9.99; System.out.println((int) d);', 'double d = 9.99; System.out.println((int) d);',
 10, 3, now()),

(gen_random_uuid(),
 'String Substring', 'Subcadena',
 'Extract and print the substring "World" from "Hello World".',
 'Extrae e imprime la subcadena "World" de "Hello World".',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'World',
 3,
 'Use the .substring() method on a String.', 'Usa el método .substring() sobre un String.',
 'substring(startIndex) returns from that index to the end.', 'substring(startIndex) devuelve desde ese índice hasta el final.',
 'System.out.println("Hello World".substring(6));', 'System.out.println("Hello World".substring(6));',
 10, 3, now()),

(gen_random_uuid(),
 'Multiply With Function', 'Multiplicar con Función',
 'Write a static method multiply(int a, int b) that returns a*b. Call it with 4 and 5, then print the result.',
 'Escribe un método estático multiply(int a, int b) que retorne a*b. Llámalo con 4 y 5, luego imprime el resultado.',
 'java', 1, 'functions',
 'public class Solution {
    public static void main(String[] args) {
        // call multiply here
    }
}',
 '20',
 3,
 'Define the method outside main but inside the class.', 'Define el método fuera de main pero dentro de la clase.',
 'Use the return keyword to send back the result.', 'Usa la palabra clave return para devolver el resultado.',
 'static int multiply(int a, int b) { return a * b; }', 'static int multiply(int a, int b) { return a * b; }',
 10, 3, now()),

(gen_random_uuid(),
 'Print Array Elements', 'Imprimir Elementos de Arreglo',
 'Declare array {5, 10, 15} and print each element on its own line using a for loop.',
 'Declara el arreglo {5, 10, 15} e imprime cada elemento en su propia línea usando un bucle for.',
 'java', 1, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '5\n10\n15',
 3,
 'Loop from index 0 to arr.length - 1.', 'Itera desde el índice 0 hasta arr.length - 1.',
 'Access each element with arr[i] inside the loop.', 'Accede a cada elemento con arr[i] dentro del bucle.',
 'int[] arr = {5,10,15}; for (int i=0;i<arr.length;i++) System.out.println(arr[i]);', 'int[] arr = {5,10,15}; for (int i=0;i<arr.length;i++) System.out.println(arr[i]);',
 10, 3, now()),

(gen_random_uuid(),
 'String Contains', 'Cadena Contiene',
 'Check whether the string "Java programming" contains "program" and print true or false.',
 'Verifica si la cadena "Java programming" contiene "program" e imprime true o false.',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'String has a .contains() method.', 'String tiene un método .contains().',
 'It returns a boolean value.', 'Devuelve un valor booleano.',
 'System.out.println("Java programming".contains("program"));', 'System.out.println("Java programming".contains("program"));',
 10, 3, now()),

(gen_random_uuid(),
 'Switch Statement', 'Sentencia Switch',
 'Use a switch statement on the integer 2. Print "two" for case 2, "other" for default.',
 'Usa una sentencia switch sobre el entero 2. Imprime "two" para el caso 2, "other" para el predeterminado.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        int x = 2;
        // your code
    }
}',
 'two',
 3,
 'Use switch(variable) { case value: ... break; }', 'Usa switch(variable) { case valor: ... break; }',
 'Don''t forget the break statement to avoid fall-through.', 'No olvides la sentencia break para evitar el fall-through.',
 'switch(x) { case 2: System.out.println("two"); break; default: System.out.println("other"); }', 'switch(x) { case 2: System.out.println("two"); break; default: System.out.println("other"); }',
 10, 3, now()),

(gen_random_uuid(),
 'Ternary Operator', 'Operador Ternario',
 'Use a ternary operator to print "positive" if 5 > 0, otherwise "negative".',
 'Usa un operador ternario para imprimir "positive" si 5 > 0, de lo contrario "negative".',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'positive',
 3,
 'The ternary operator has the form: condition ? valueA : valueB', 'El operador ternario tiene la forma: condición ? valorA : valorB',
 'You can use it directly inside println.', 'Puedes usarlo directamente dentro de println.',
 'System.out.println(5 > 0 ? "positive" : "negative");', 'System.out.println(5 > 0 ? "positive" : "negative");',
 10, 3, now()),

(gen_random_uuid(),
 'Math Absolute Value', 'Valor Absoluto',
 'Print the absolute value of -15 using the Math class.',
 'Imprime el valor absoluto de -15 usando la clase Math.',
 'java', 1, 'math',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '15',
 3,
 'The Math class has an abs() method.', 'La clase Math tiene un método abs().',
 'Pass the negative number directly to Math.abs().', 'Pasa el número negativo directamente a Math.abs().',
 'System.out.println(Math.abs(-15));', 'System.out.println(Math.abs(-15));',
 10, 3, now()),

(gen_random_uuid(),
 'String Replace', 'Reemplazar en Cadena',
 'Replace all occurrences of "a" with "o" in "banana" and print the result.',
 'Reemplaza todas las ocurrencias de "a" con "o" en "banana" e imprime el resultado.',
 'java', 1, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'bonono',
 3,
 'String has a .replace() method.', 'String tiene un método .replace().',
 'replace(oldChar, newChar) replaces every occurrence.', 'replace(antiguo, nuevo) reemplaza cada ocurrencia.',
 'System.out.println("banana".replace("a", "o"));', 'System.out.println("banana".replace("a", "o"));',
 10, 3, now()),

(gen_random_uuid(),
 'Increment and Decrement', 'Incremento y Decremento',
 'Start with int x = 5. Increment it twice then decrement it once. Print the final value.',
 'Comienza con int x = 5. Increméntalo dos veces y luego decreméntalo una vez. Imprime el valor final.',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        int x = 5;
        // your code
    }
}',
 '6',
 3,
 'Use ++ to increment and -- to decrement by 1.', 'Usa ++ para incrementar y -- para decrementar en 1.',
 'Each ++ adds 1 to the current value of x.', 'Cada ++ agrega 1 al valor actual de x.',
 'x++; x++; x--; System.out.println(x);', 'x++; x++; x--; System.out.println(x);',
 10, 3, now()),

(gen_random_uuid(),
 'Nested If-Else', 'If-Else Anidado',
 'Given int score = 85, print "A" if >= 90, "B" if >= 80, otherwise "C".',
 'Dado int score = 85, imprime "A" si >= 90, "B" si >= 80, de lo contrario "C".',
 'java', 1, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        int score = 85;
        // your code
    }
}',
 'B',
 3,
 'Chain multiple conditions with else if.', 'Encadena múltiples condiciones con else if.',
 'Check the highest threshold first.', 'Verifica el umbral más alto primero.',
 'if (score>=90) System.out.println("A"); else if (score>=80) System.out.println("B"); else System.out.println("C");', 'if (score>=90) System.out.println("A"); else if (score>=80) System.out.println("B"); else System.out.println("C");',
 10, 3, now()),

-- ============================================================
-- JAVA DIFFICULTY 2 (25 exercises)
-- ============================================================

(gen_random_uuid(),
 'Sum Array Elements', 'Suma de Elementos de Arreglo',
 'Write a static method sumArray(int[] arr) that returns the sum of all elements. Test with {1,2,3,4,5} and print the result.',
 'Escribe un método estático sumArray(int[] arr) que retorne la suma de todos los elementos. Pruébalo con {1,2,3,4,5} e imprime el resultado.',
 'java', 2, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '15',
 3,
 'Loop through the array accumulating a sum variable.', 'Itera el arreglo acumulando una variable suma.',
 'Initialize sum = 0 before the loop.', 'Inicializa sum = 0 antes del bucle.',
 'static int sumArray(int[] a) { int s=0; for(int x:a) s+=x; return s; }', 'static int sumArray(int[] a) { int s=0; for(int x:a) s+=x; return s; }',
 20, 3, now()),

(gen_random_uuid(),
 'Reverse a String', 'Invertir una Cadena',
 'Write a method that reverses the string "abcde" and prints the result.',
 'Escribe un método que invierta la cadena "abcde" e imprima el resultado.',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'edcba',
 3,
 'Use StringBuilder which has a reverse() method.', 'Usa StringBuilder que tiene un método reverse().',
 'new StringBuilder(str).reverse().toString() does the job.', 'new StringBuilder(str).reverse().toString() hace el trabajo.',
 'System.out.println(new StringBuilder("abcde").reverse().toString());', 'System.out.println(new StringBuilder("abcde").reverse().toString());',
 20, 3, now()),

(gen_random_uuid(),
 'Find Maximum in Array', 'Encontrar el Máximo en un Arreglo',
 'Write a static method maxInArray(int[] arr) that returns the largest value. Test with {3,7,1,9,4}.',
 'Escribe un método estático maxInArray(int[] arr) que retorne el valor más grande. Pruébalo con {3,7,1,9,4}.',
 'java', 2, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '9',
 3,
 'Initialize max with the first element of the array.', 'Inicializa max con el primer elemento del arreglo.',
 'Compare each element and update max when a larger value is found.', 'Compara cada elemento y actualiza max cuando se encuentra un valor mayor.',
 'static int maxInArray(int[] a){int m=a[0];for(int x:a)if(x>m)m=x;return m;}', 'static int maxInArray(int[] a){int m=a[0];for(int x:a)if(x>m)m=x;return m;}',
 20, 3, now()),

(gen_random_uuid(),
 'Fibonacci Sequence', 'Secuencia de Fibonacci',
 'Print the first 8 numbers of the Fibonacci sequence on one line separated by spaces.',
 'Imprime los primeros 8 números de la secuencia de Fibonacci en una línea separados por espacios.',
 'java', 2, 'math',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '0 1 1 2 3 5 8 13',
 3,
 'Start with a=0 and b=1, then repeatedly compute next = a+b.', 'Comienza con a=0 y b=1, luego calcula repetidamente next = a+b.',
 'Use a loop 8 times, printing each value and shifting a=b, b=next.', 'Usa un bucle 8 veces, imprimiendo cada valor y desplazando a=b, b=next.',
 'int a=0,b=1; for(int i=0;i<8;i++){System.out.print(a+" ");int t=a+b;a=b;b=t;}', 'int a=0,b=1; for(int i=0;i<8;i++){System.out.print(a+" ");int t=a+b;a=b;b=t;}',
 20, 3, now()),

(gen_random_uuid(),
 'Count Vowels', 'Contar Vocales',
 'Write a method that counts the number of vowels in "Hello World" and prints the count.',
 'Escribe un método que cuente las vocales en "Hello World" e imprima la cantidad.',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3',
 3,
 'Iterate over each character of the string.', 'Itera sobre cada carácter de la cadena.',
 'Check if each char is in the set {a,e,i,o,u} (lowercase).', 'Verifica si cada carácter está en el conjunto {a,e,i,o,u} (minúsculas).',
 'Convert to lowercase first, then check "aeiou".indexOf(ch) >= 0.', 'Convierte a minúsculas primero, luego verifica "aeiou".indexOf(ch) >= 0.',
 20, 3, now()),

(gen_random_uuid(),
 'ArrayList Basics', 'Fundamentos de ArrayList',
 'Create an ArrayList of Strings, add "apple", "banana", "cherry", then print the size.',
 'Crea un ArrayList de Strings, agrega "apple", "banana", "cherry", luego imprime el tamaño.',
 'java', 2, 'data_structures',
 'import java.util.ArrayList;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3',
 3,
 'Import java.util.ArrayList and instantiate with new ArrayList<>().', 'Importa java.util.ArrayList e instancia con new ArrayList<>().',
 'Use .add() to add elements to the list.', 'Usa .add() para agregar elementos a la lista.',
 'ArrayList<String> list = new ArrayList<>(); list.add("apple"); list.add("banana"); list.add("cherry"); System.out.println(list.size());', 'ArrayList<String> list = new ArrayList<>(); list.add("apple"); list.add("banana"); list.add("cherry"); System.out.println(list.size());',
 20, 3, now()),

(gen_random_uuid(),
 'HashMap Put and Get', 'HashMap Put y Get',
 'Create a HashMap<String,Integer>, put key "age" with value 30, then print the value.',
 'Crea un HashMap<String,Integer>, agrega la clave "age" con valor 30, luego imprime el valor.',
 'java', 2, 'data_structures',
 'import java.util.HashMap;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '30',
 3,
 'Import java.util.HashMap and create new HashMap<>().', 'Importa java.util.HashMap y crea new HashMap<>().',
 'Use .put(key, value) and .get(key).', 'Usa .put(clave, valor) y .get(clave).',
 'HashMap<String,Integer> map = new HashMap<>(); map.put("age",30); System.out.println(map.get("age"));', 'HashMap<String,Integer> map = new HashMap<>(); map.put("age",30); System.out.println(map.get("age"));',
 20, 3, now()),

(gen_random_uuid(),
 'Factorial Recursive', 'Factorial Recursivo',
 'Write a recursive method factorial(int n) and print factorial(5).',
 'Escribe un método recursivo factorial(int n) e imprime factorial(5).',
 'java', 2, 'functions',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '120',
 3,
 'A recursive method calls itself with a smaller argument.', 'Un método recursivo se llama a sí mismo con un argumento menor.',
 'Base case: factorial(0) or factorial(1) returns 1.', 'Caso base: factorial(0) o factorial(1) retorna 1.',
 'static int factorial(int n){return n<=1?1:n*factorial(n-1);}', 'static int factorial(int n){return n<=1?1:n*factorial(n-1);}',
 20, 3, now()),

(gen_random_uuid(),
 'Check Palindrome', 'Verificar Palíndromo',
 'Write a method isPalindrome(String s) that returns true if s reads the same forwards and backwards. Test with "racecar".',
 'Escribe un método isPalindrome(String s) que retorne true si s se lee igual en ambas direcciones. Pruébalo con "racecar".',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'Reverse the string and compare it with the original.', 'Invierte la cadena y compárala con el original.',
 'Use StringBuilder.reverse() for easy reversal.', 'Usa StringBuilder.reverse() para invertir fácilmente.',
 'static boolean isPalindrome(String s){return s.equals(new StringBuilder(s).reverse().toString());}', 'static boolean isPalindrome(String s){return s.equals(new StringBuilder(s).reverse().toString());}',
 20, 3, now()),

(gen_random_uuid(),
 'Sort Array Ascending', 'Ordenar Arreglo Ascendente',
 'Sort the array {5,2,8,1,9} in ascending order and print all elements on one line separated by spaces.',
 'Ordena el arreglo {5,2,8,1,9} en orden ascendente e imprime todos los elementos en una línea separados por espacios.',
 'java', 2, 'arrays',
 'import java.util.Arrays;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1 2 5 8 9',
 3,
 'Use Arrays.sort() from java.util.Arrays.', 'Usa Arrays.sort() de java.util.Arrays.',
 'After sorting, loop over the array to print each element.', 'Después de ordenar, itera el arreglo para imprimir cada elemento.',
 'int[] a={5,2,8,1,9}; Arrays.sort(a); for(int x:a) System.out.print(x+" ");', 'int[] a={5,2,8,1,9}; Arrays.sort(a); for(int x:a) System.out.print(x+" ");',
 20, 3, now()),

(gen_random_uuid(),
 'Simple Class and Object', 'Clase y Objeto Simple',
 'Create a class Dog with a field name (String). Instantiate it with name "Rex" and print the name.',
 'Crea una clase Dog con un campo name (String). Instanciala con nombre "Rex" e imprime el nombre.',
 'java', 2, 'objects',
 'public class Solution {
    static class Dog {
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'Rex',
 3,
 'Define a field inside the class: String name;', 'Define un campo dentro de la clase: String name;',
 'Use the new keyword to create an instance.', 'Usa la palabra clave new para crear una instancia.',
 'static class Dog { String name; } Dog d = new Dog(); d.name = "Rex"; System.out.println(d.name);', 'static class Dog { String name; } Dog d = new Dog(); d.name = "Rex"; System.out.println(d.name);',
 20, 3, now()),

(gen_random_uuid(),
 'Constructor Usage', 'Uso del Constructor',
 'Create a class Point with int x and int y fields and a constructor. Instantiate Point(3,4) and print x and y.',
 'Crea una clase Point con campos int x e int y y un constructor. Instancia Point(3,4) e imprime x y y.',
 'java', 2, 'objects',
 'public class Solution {
    static class Point {
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '3 4',
 3,
 'A constructor has the same name as the class and no return type.', 'Un constructor tiene el mismo nombre que la clase y no tiene tipo de retorno.',
 'Assign this.x = x inside the constructor.', 'Asigna this.x = x dentro del constructor.',
 'static class Point{int x,y;Point(int x,int y){this.x=x;this.y=y;}} Point p=new Point(3,4);System.out.println(p.x+" "+p.y);', 'static class Point{int x,y;Point(int x,int y){this.x=x;this.y=y;}} Point p=new Point(3,4);System.out.println(p.x+" "+p.y);',
 20, 3, now()),

(gen_random_uuid(),
 'String Split', 'Dividir Cadena',
 'Split "one,two,three" by comma and print the number of parts.',
 'Divide "one,two,three" por coma e imprime el número de partes.',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3',
 3,
 'Use the .split() method on a String, passing the delimiter.', 'Usa el método .split() sobre un String, pasando el delimitador.',
 '.split() returns a String array.', '.split() retorna un arreglo de String.',
 'String[] parts = "one,two,three".split(","); System.out.println(parts.length);', 'String[] parts = "one,two,three".split(","); System.out.println(parts.length);',
 20, 3, now()),

(gen_random_uuid(),
 'Enhanced For Loop', 'Bucle For Mejorado',
 'Use an enhanced for-each loop to print each element of the array {"red","green","blue"} on its own line.',
 'Usa un bucle for-each mejorado para imprimir cada elemento del arreglo {"red","green","blue"} en su propia línea.',
 'java', 2, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        String[] colors = {"red","green","blue"};
        // your code
    }
}',
 'red\ngreen\nblue',
 3,
 'The enhanced for loop syntax is: for (Type item : collection).', 'La sintaxis del for mejorado es: for (Tipo item : colección).',
 'No index needed — the loop gives you each element directly.', 'No se necesita índice — el bucle te da cada elemento directamente.',
 'for (String c : colors) System.out.println(c);', 'for (String c : colors) System.out.println(c);',
 20, 3, now()),

(gen_random_uuid(),
 'Static Counter', 'Contador Estático',
 'Create a class with a static counter field. Increment it 5 times using a loop and print the final value.',
 'Crea una clase con un campo contador estático. Increméntalo 5 veces en un bucle e imprime el valor final.',
 'java', 2, 'objects',
 'public class Solution {
    static int counter = 0;
    public static void main(String[] args) {
        // your code
    }
}',
 '5',
 3,
 'A static field belongs to the class, not an instance.', 'Un campo estático pertenece a la clase, no a una instancia.',
 'Access it directly with counter++ inside the loop.', 'Accédelo directamente con counter++ dentro del bucle.',
 'for (int i=0;i<5;i++) counter++; System.out.println(counter);', 'for (int i=0;i<5;i++) counter++; System.out.println(counter);',
 20, 3, now()),

(gen_random_uuid(),
 'Integer Parsing', 'Parseo de Entero',
 'Parse the string "123" to an integer, add 7, and print the result.',
 'Parsea la cadena "123" a entero, suma 7, e imprime el resultado.',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        String s = "123";
        // your code
    }
}',
 '130',
 3,
 'Use Integer.parseInt() to convert a String to int.', 'Usa Integer.parseInt() para convertir un String a int.',
 'Once parsed, you can perform arithmetic on it.', 'Una vez parseado, puedes realizar aritmética con él.',
 'int n = Integer.parseInt(s); System.out.println(n + 7);', 'int n = Integer.parseInt(s); System.out.println(n + 7);',
 20, 3, now()),

(gen_random_uuid(),
 '2D Array Sum', 'Suma de Arreglo 2D',
 'Declare a 2x2 int matrix {{1,2},{3,4}} and print the sum of all elements.',
 'Declara una matriz int 2x2 {{1,2},{3,4}} e imprime la suma de todos los elementos.',
 'java', 2, 'arrays',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '10',
 3,
 'A 2D array is declared as int[][] matrix = {{...},{...}};', 'Un arreglo 2D se declara como int[][] matriz = {{...},{...}};',
 'Use nested for loops to iterate rows and columns.', 'Usa bucles for anidados para iterar filas y columnas.',
 'int[][] m={{1,2},{3,4}}; int s=0; for(int[] r:m) for(int x:r) s+=x; System.out.println(s);', 'int[][] m={{1,2},{3,4}}; int s=0; for(int[] r:m) for(int x:r) s+=x; System.out.println(s);',
 20, 3, now()),

(gen_random_uuid(),
 'String Format', 'Formateo de Cadena',
 'Use String.format() to print "Name: Alice, Age: 30".',
 'Usa String.format() para imprimir "Name: Alice, Age: 30".',
 'java', 2, 'strings',
 'public class Solution {
    public static void main(String[] args) {
        String name = "Alice";
        int age = 30;
        // your code
    }
}',
 'Name: Alice, Age: 30',
 3,
 'String.format() uses %s for String and %d for int placeholders.', 'String.format() usa %s para String y %d para int como marcadores.',
 'Pass the variables in order after the format string.', 'Pasa las variables en orden después de la cadena de formato.',
 'System.out.println(String.format("Name: %s, Age: %d", name, age));', 'System.out.println(String.format("Name: %s, Age: %d", name, age));',
 20, 3, now()),

(gen_random_uuid(),
 'Overloaded Methods', 'Métodos Sobrecargados',
 'Write two overloaded methods add(int,int) and add(double,double). Print add(2,3) and add(1.5,2.5).',
 'Escribe dos métodos sobrecargados add(int,int) y add(double,double). Imprime add(2,3) y add(1.5,2.5).',
 'java', 2, 'functions',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '5\n4.0',
 3,
 'Overloading means same method name but different parameter types.', 'Sobrecarga significa el mismo nombre de método pero distintos tipos de parámetros.',
 'The compiler picks the correct version based on argument types.', 'El compilador elige la versión correcta según los tipos de argumentos.',
 'static int add(int a,int b){return a+b;} static double add(double a,double b){return a+b;}', 'static int add(int a,int b){return a+b;} static double add(double a,double b){return a+b;}',
 20, 3, now()),

(gen_random_uuid(),
 'Try-Catch Block', 'Bloque Try-Catch',
 'Try to parse "abc" as an integer inside a try-catch and print "Invalid" when the exception occurs.',
 'Intenta parsear "abc" como entero dentro de un try-catch e imprime "Invalid" cuando ocurra la excepción.',
 'java', 2, 'basics',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'Invalid',
 3,
 'Wrap the risky code in a try block.', 'Envuelve el código riesgoso en un bloque try.',
 'Catch NumberFormatException to handle bad number strings.', 'Captura NumberFormatException para manejar cadenas numéricas inválidas.',
 'try { Integer.parseInt("abc"); } catch (NumberFormatException e) { System.out.println("Invalid"); }', 'try { Integer.parseInt("abc"); } catch (NumberFormatException e) { System.out.println("Invalid"); }',
 20, 3, now()),

(gen_random_uuid(),
 'Bubble Sort', 'Ordenamiento Burbuja',
 'Implement bubble sort on {64,34,25,12,22} and print the sorted array on one line.',
 'Implementa el ordenamiento burbuja en {64,34,25,12,22} e imprime el arreglo ordenado en una línea.',
 'java', 2, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '12 22 25 34 64',
 3,
 'Bubble sort compares adjacent elements and swaps them if out of order.', 'El ordenamiento burbuja compara elementos adyacentes y los intercambia si están fuera de orden.',
 'Use nested loops: outer for passes, inner for comparisons.', 'Usa bucles anidados: externo para pasadas, interno para comparaciones.',
 'Use a temp variable to swap: int t=a[j];a[j]=a[j+1];a[j+1]=t;', 'Usa una variable temporal para intercambiar: int t=a[j];a[j]=a[j+1];a[j+1]=t;',
 20, 3, now()),

(gen_random_uuid(),
 'Linear Search', 'Búsqueda Lineal',
 'Write a method linearSearch(int[] arr, int target) returning the index of the target or -1 if not found. Search for 7 in {3,7,1,9}.',
 'Escribe un método linearSearch(int[] arr, int target) que retorne el índice del objetivo o -1 si no se encuentra. Busca 7 en {3,7,1,9}.',
 'java', 2, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1',
 3,
 'Loop through every element and compare with the target.', 'Itera cada elemento y compara con el objetivo.',
 'Return the index immediately when a match is found.', 'Retorna el índice inmediatamente cuando se encuentra una coincidencia.',
 'static int linearSearch(int[] a,int t){for(int i=0;i<a.length;i++)if(a[i]==t)return i;return -1;}', 'static int linearSearch(int[] a,int t){for(int i=0;i<a.length;i++)if(a[i]==t)return i;return -1;}',
 20, 3, now()),

(gen_random_uuid(),
 'Interface Implementation', 'Implementación de Interfaz',
 'Define interface Greetable with method greet(). Implement it in class English to print "Hello". Call greet().',
 'Define la interfaz Greetable con el método greet(). Impleméntala en la clase English para imprimir "Hello". Llama greet().',
 'java', 2, 'objects',
 'public class Solution {
    interface Greetable {
        void greet();
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'Hello',
 3,
 'Use the interface keyword to define the contract.', 'Usa la palabra clave interface para definir el contrato.',
 'Use the implements keyword in the class declaration.', 'Usa la palabra clave implements en la declaración de la clase.',
 'static class English implements Greetable { public void greet(){System.out.println("Hello");} }', 'static class English implements Greetable { public void greet(){System.out.println("Hello");} }',
 20, 3, now()),

(gen_random_uuid(),
 'Stack with ArrayDeque', 'Pila con ArrayDeque',
 'Create a stack using ArrayDeque, push 1, 2, 3, then pop and print all three values.',
 'Crea una pila usando ArrayDeque, empuja 1, 2, 3, luego saca e imprime los tres valores.',
 'java', 2, 'data_structures',
 'import java.util.ArrayDeque;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3\n2\n1',
 3,
 'ArrayDeque can be used as a LIFO stack.', 'ArrayDeque puede usarse como una pila LIFO.',
 'Use .push() to add and .pop() to remove from the top.', 'Usa .push() para agregar y .pop() para quitar de la cima.',
 'ArrayDeque<Integer> s=new ArrayDeque<>(); s.push(1);s.push(2);s.push(3); System.out.println(s.pop());System.out.println(s.pop());System.out.println(s.pop());', 'ArrayDeque<Integer> s=new ArrayDeque<>(); s.push(1);s.push(2);s.push(3); System.out.println(s.pop());System.out.println(s.pop());System.out.println(s.pop());',
 20, 3, now()),

-- ============================================================
-- JAVA DIFFICULTY 3 (25 exercises)
-- ============================================================

(gen_random_uuid(),
 'Binary Search', 'Búsqueda Binaria',
 'Implement binary search on a sorted array {1,3,5,7,9,11} to find index of 7. Print the index.',
 'Implementa búsqueda binaria en el arreglo ordenado {1,3,5,7,9,11} para encontrar el índice de 7. Imprime el índice.',
 'java', 3, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3',
 3,
 'Binary search uses low, high, and mid pointers.', 'La búsqueda binaria usa punteros low, high y mid.',
 'If arr[mid] < target, move low = mid + 1; if greater, high = mid - 1.', 'Si arr[mid] < objetivo, mueve low = mid + 1; si es mayor, high = mid - 1.',
 'static int bSearch(int[] a,int t){int l=0,h=a.length-1;while(l<=h){int m=(l+h)/2;if(a[m]==t)return m;else if(a[m]<t)l=m+1;else h=m-1;}return -1;}', 'static int bSearch(int[] a,int t){int l=0,h=a.length-1;while(l<=h){int m=(l+h)/2;if(a[m]==t)return m;else if(a[m]<t)l=m+1;else h=m-1;}return -1;}',
 30, 5, now()),

(gen_random_uuid(),
 'Inheritance and Polymorphism', 'Herencia y Polimorfismo',
 'Create abstract class Shape with abstract method area(). Subclass Circle with radius 5. Print the area (use Math.PI).',
 'Crea la clase abstracta Shape con el método abstracto area(). Subclase Circle con radio 5. Imprime el área (usa Math.PI).',
 'java', 3, 'objects',
 'public class Solution {
    abstract static class Shape {
        abstract double area();
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '78.53981633974483',
 3,
 'Use the abstract keyword on both the class and the method.', 'Usa la palabra clave abstract tanto en la clase como en el método.',
 'Circle extends Shape and overrides area() with Math.PI * r * r.', 'Circle extiende Shape y sobreescribe area() con Math.PI * r * r.',
 'static class Circle extends Shape{double r;Circle(double r){this.r=r;}double area(){return Math.PI*r*r;}} System.out.println(new Circle(5).area());', 'static class Circle extends Shape{double r;Circle(double r){this.r=r;}double area(){return Math.PI*r*r;}} System.out.println(new Circle(5).area());',
 30, 5, now()),

(gen_random_uuid(),
 'Linked List Node', 'Nodo de Lista Enlazada',
 'Implement a singly linked list by hand. Insert 1, 2, 3 and traverse it, printing each value.',
 'Implementa una lista enlazada simple a mano. Inserta 1, 2, 3 y recórrela imprimiendo cada valor.',
 'java', 3, 'data_structures',
 'public class Solution {
    static class Node {
        int val; Node next;
        Node(int v) { val = v; }
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '1\n2\n3',
 3,
 'Create a head node and chain nodes via the next field.', 'Crea un nodo cabeza y encadena nodos mediante el campo next.',
 'Traverse using a while loop: while (curr != null).', 'Recorre con un bucle while: while (curr != null).',
 'Node h=new Node(1); h.next=new Node(2); h.next.next=new Node(3); Node c=h; while(c!=null){System.out.println(c.val);c=c.next;}', 'Node h=new Node(1); h.next=new Node(2); h.next.next=new Node(3); Node c=h; while(c!=null){System.out.println(c.val);c=c.next;}',
 30, 5, now()),

(gen_random_uuid(),
 'Generic Method', 'Método Genérico',
 'Write a generic method <T> void printArray(T[] arr) that prints each element. Test with Integer array {1,2,3}.',
 'Escribe un método genérico <T> void printArray(T[] arr) que imprima cada elemento. Pruébalo con el arreglo Integer {1,2,3}.',
 'java', 3, 'functions',
 'public class Solution {
    public static void main(String[] args) {
        Integer[] nums = {1, 2, 3};
        // your code
    }
}',
 '1\n2\n3',
 3,
 'Declare the type parameter before the return type: static <T> void.', 'Declara el parámetro de tipo antes del tipo de retorno: static <T> void.',
 'Inside the method, iterate and print each element.', 'Dentro del método, itera e imprime cada elemento.',
 'static <T> void printArray(T[] a){for(T x:a)System.out.println(x);}', 'static <T> void printArray(T[] a){for(T x:a)System.out.println(x);}',
 30, 5, now()),

(gen_random_uuid(),
 'Lambda Expression', 'Expresión Lambda',
 'Use a lambda to implement Comparator and sort {"banana","apple","cherry"} alphabetically. Print sorted list.',
 'Usa una lambda para implementar Comparator y ordenar {"banana","apple","cherry"} alfabéticamente. Imprime la lista ordenada.',
 'java', 3, 'functions',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        List<String> fruits = Arrays.asList("banana","apple","cherry");
        // your code
    }
}',
 'apple\nbanana\ncherry',
 3,
 'Collections.sort() accepts a Comparator as second argument.', 'Collections.sort() acepta un Comparator como segundo argumento.',
 'A lambda for Comparator looks like: (a, b) -> a.compareTo(b).', 'Una lambda para Comparator luce: (a, b) -> a.compareTo(b).',
 'Collections.sort(fruits,(a,b)->a.compareTo(b)); fruits.forEach(System.out::println);', 'Collections.sort(fruits,(a,b)->a.compareTo(b)); fruits.forEach(System.out::println);',
 30, 5, now()),

(gen_random_uuid(),
 'Stream Filter and Map', 'Stream Filter y Map',
 'Given a list of integers {1,2,3,4,5,6}, use streams to filter even numbers and print each doubled value.',
 'Dado un lista de enteros {1,2,3,4,5,6}, usa streams para filtrar números pares e imprime cada valor duplicado.',
 'java', 3, 'functions',
 'import java.util.*;
import java.util.stream.*;
public class Solution {
    public static void main(String[] args) {
        List<Integer> nums = Arrays.asList(1,2,3,4,5,6);
        // your code
    }
}',
 '4\n8\n12',
 3,
 'Call .stream() on the list to start the pipeline.', 'Llama .stream() sobre la lista para iniciar el pipeline.',
 'Use .filter(n -> n % 2 == 0) then .map(n -> n * 2).', 'Usa .filter(n -> n % 2 == 0) luego .map(n -> n * 2).',
 'nums.stream().filter(n->n%2==0).map(n->n*2).forEach(System.out::println);', 'nums.stream().filter(n->n%2==0).map(n->n*2).forEach(System.out::println);',
 30, 5, now()),

(gen_random_uuid(),
 'Custom Exception', 'Excepción Personalizada',
 'Create a custom exception NegativeNumberException. Throw it if a number is negative. Catch and print "Negative!".',
 'Crea una excepción personalizada NegativeNumberException. Lánzala si un número es negativo. Atrápala e imprime "Negative!".',
 'java', 3, 'basics',
 'public class Solution {
    // define exception here
    public static void main(String[] args) {
        // your code with -5
    }
}',
 'Negative!',
 3,
 'Extend RuntimeException or Exception to create a custom exception.', 'Extiende RuntimeException o Exception para crear una excepción personalizada.',
 'Use the throw keyword inside a method when the condition is met.', 'Usa la palabra clave throw dentro de un método cuando se cumpla la condición.',
 'static class NegativeNumberException extends RuntimeException{} static void check(int n){if(n<0)throw new NegativeNumberException();} try{check(-5);}catch(NegativeNumberException e){System.out.println("Negative!");}', 'static class NegativeNumberException extends RuntimeException{} static void check(int n){if(n<0)throw new NegativeNumberException();} try{check(-5);}catch(NegativeNumberException e){System.out.println("Negative!");}',
 30, 5, now()),

(gen_random_uuid(),
 'Iterator Pattern', 'Patrón Iterador',
 'Use an Iterator to traverse an ArrayList of {"x","y","z"} and print each element.',
 'Usa un Iterator para recorrer un ArrayList de {"x","y","z"} e imprime cada elemento.',
 'java', 3, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'x\ny\nz',
 3,
 'Call .iterator() on the collection to get an Iterator.', 'Llama .iterator() sobre la colección para obtener un Iterator.',
 'Use hasNext() in the while condition and next() to get the element.', 'Usa hasNext() en la condición while y next() para obtener el elemento.',
 'ArrayList<String> l=new ArrayList<>(Arrays.asList("x","y","z")); Iterator<String> it=l.iterator(); while(it.hasNext())System.out.println(it.next());', 'ArrayList<String> l=new ArrayList<>(Arrays.asList("x","y","z")); Iterator<String> it=l.iterator(); while(it.hasNext())System.out.println(it.next());',
 30, 5, now()),

(gen_random_uuid(),
 'Merge Sort', 'Ordenamiento por Mezcla',
 'Implement merge sort on {38,27,43,3,9,82,10} and print the sorted array on one line.',
 'Implementa merge sort en {38,27,43,3,9,82,10} e imprime el arreglo ordenado en una línea.',
 'java', 3, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3 9 10 27 38 43 82',
 3,
 'Merge sort divides the array in half recursively, then merges.', 'Merge sort divide el arreglo a la mitad recursivamente, luego fusiona.',
 'The merge step combines two sorted subarrays into one sorted array.', 'El paso de fusión combina dos subarreglos ordenados en uno solo.',
 'Recursively split: mergeSort(arr, 0, arr.length-1) then merge left and right halves.', 'Divide recursivamente: mergeSort(arr, 0, arr.length-1) luego fusiona mitades.',
 30, 5, now()),

(gen_random_uuid(),
 'Enum Usage', 'Uso de Enum',
 'Define an enum Day with MON, TUE, WED. Use a switch to print "Midweek" for WED.',
 'Define un enum Day con MON, TUE, WED. Usa un switch para imprimir "Midweek" para WED.',
 'java', 3, 'objects',
 'public class Solution {
    enum Day { MON, TUE, WED }
    public static void main(String[] args) {
        Day d = Day.WED;
        // your code
    }
}',
 'Midweek',
 3,
 'Enum values are accessed as EnumName.VALUE.', 'Los valores de enum se acceden como NombreEnum.VALOR.',
 'A switch on an enum uses the value name directly (no class prefix).', 'Un switch sobre un enum usa el nombre del valor directamente (sin prefijo de clase).',
 'switch(d){case WED: System.out.println("Midweek"); break; default: System.out.println("Other");}', 'switch(d){case WED: System.out.println("Midweek"); break; default: System.out.println("Other");}',
 30, 5, now()),

(gen_random_uuid(),
 'Optional Usage', 'Uso de Optional',
 'Create an Optional<String> with value "Java". If present, print the value in uppercase.',
 'Crea un Optional<String> con valor "Java". Si está presente, imprime el valor en mayúsculas.',
 'java', 3, 'basics',
 'import java.util.Optional;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'JAVA',
 3,
 'Use Optional.of("value") to wrap a non-null value.', 'Usa Optional.of("valor") para envolver un valor no nulo.',
 'Call .ifPresent(v -> ...) to act only when a value exists.', 'Llama .ifPresent(v -> ...) para actuar solo cuando existe un valor.',
 'Optional.of("Java").ifPresent(v->System.out.println(v.toUpperCase()));', 'Optional.of("Java").ifPresent(v->System.out.println(v.toUpperCase()));',
 30, 5, now()),

(gen_random_uuid(),
 'HashSet Deduplication', 'Deduplicación con HashSet',
 'Add {"a","b","a","c","b"} to a HashSet and print its size.',
 'Agrega {"a","b","a","c","b"} a un HashSet e imprime su tamaño.',
 'java', 3, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '3',
 3,
 'A HashSet stores only unique elements.', 'Un HashSet almacena solo elementos únicos.',
 'Duplicate entries are silently ignored on .add().', 'Las entradas duplicadas son ignoradas silenciosamente al llamar .add().',
 'HashSet<String> s=new HashSet<>(Arrays.asList("a","b","a","c","b")); System.out.println(s.size());', 'HashSet<String> s=new HashSet<>(Arrays.asList("a","b","a","c","b")); System.out.println(s.size());',
 30, 5, now()),

(gen_random_uuid(),
 'Functional Interface', 'Interfaz Funcional',
 'Define a functional interface MathOp with method operate(int a, int b). Use a lambda to add two numbers and print the result.',
 'Define una interfaz funcional MathOp con el método operate(int a, int b). Usa una lambda para sumar dos números e imprime el resultado.',
 'java', 3, 'functions',
 'public class Solution {
    @FunctionalInterface
    interface MathOp {
        int operate(int a, int b);
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '7',
 3,
 'A functional interface has exactly one abstract method.', 'Una interfaz funcional tiene exactamente un método abstracto.',
 'Assign a lambda to a variable of the interface type.', 'Asigna una lambda a una variable del tipo de la interfaz.',
 'MathOp add = (a,b) -> a+b; System.out.println(add.operate(3,4));', 'MathOp add = (a,b) -> a+b; System.out.println(add.operate(3,4));',
 30, 5, now()),

(gen_random_uuid(),
 'String Join', 'Unir Cadenas',
 'Join the list {"one","two","three"} with " - " separator using String.join() and print the result.',
 'Une la lista {"one","two","three"} con el separador " - " usando String.join() e imprime el resultado.',
 'java', 3, 'strings',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("one","two","three");
        // your code
    }
}',
 'one - two - three',
 3,
 'String.join(delimiter, collection) merges all elements.', 'String.join(delimitador, colección) une todos los elementos.',
 'The first argument is the separator string.', 'El primer argumento es la cadena separadora.',
 'System.out.println(String.join(" - ", words));', 'System.out.println(String.join(" - ", words));',
 30, 5, now()),

(gen_random_uuid(),
 'Stack-Based Parenthesis Check', 'Verificación de Paréntesis con Pila',
 'Write a method isBalanced(String s) using a stack to check if parentheses in "(()())" are balanced. Print true.',
 'Escribe un método isBalanced(String s) usando una pila para verificar si los paréntesis en "(()())" están balanceados. Imprime true.',
 'java', 3, 'algorithms',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'Push ( onto the stack; pop when ) is encountered.', 'Empuja ( a la pila; saca cuando encuentras ).',
 'The string is balanced if the stack is empty at the end.', 'La cadena está balanceada si la pila está vacía al final.',
 'static boolean isBalanced(String s){Deque<Character> st=new ArrayDeque<>();for(char c:s.toCharArray()){if(c==''('')st.push(c);else if(c=='')''&&st.isEmpty())return false;else if(c=='')'' )st.pop();}return st.isEmpty();}', 'static boolean isBalanced(String s){Deque<Character> st=new ArrayDeque<>();for(char c:s.toCharArray()){if(c==''('')st.push(c);else if(c=='')''&&st.isEmpty())return false;else if(c=='')'' )st.pop();}return st.isEmpty();}',
 30, 5, now()),

(gen_random_uuid(),
 'Map Frequency Count', 'Conteo de Frecuencia con Map',
 'Count the frequency of each character in "mississippi" and print the count for ''s''.',
 'Cuenta la frecuencia de cada carácter en "mississippi" e imprime el conteo de ''s''.',
 'java', 3, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '4',
 3,
 'Use a HashMap<Character, Integer> to store counts.', 'Usa un HashMap<Character, Integer> para almacenar conteos.',
 'Use map.getOrDefault(ch, 0) + 1 to increment safely.', 'Usa map.getOrDefault(ch, 0) + 1 para incrementar de forma segura.',
 'Map<Character,Integer> m=new HashMap<>(); for(char c:"mississippi".toCharArray()) m.put(c,m.getOrDefault(c,0)+1); System.out.println(m.get(''s''));', 'Map<Character,Integer> m=new HashMap<>(); for(char c:"mississippi".toCharArray()) m.put(c,m.getOrDefault(c,0)+1); System.out.println(m.get(''s''));',
 30, 5, now()),

(gen_random_uuid(),
 'Varargs Method', 'Método con Varargs',
 'Write a method sum(int... nums) that sums any number of ints. Print sum(1,2,3,4,5).',
 'Escribe un método sum(int... nums) que sume cualquier cantidad de enteros. Imprime sum(1,2,3,4,5).',
 'java', 3, 'functions',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '15',
 3,
 'Declare varargs with type... name in the parameter list.', 'Declara varargs con tipo... nombre en la lista de parámetros.',
 'Inside the method, nums is treated as a regular array.', 'Dentro del método, nums se trata como un arreglo normal.',
 'static int sum(int... n){int s=0;for(int x:n)s+=x;return s;} System.out.println(sum(1,2,3,4,5));', 'static int sum(int... n){int s=0;for(int x:n)s+=x;return s;} System.out.println(sum(1,2,3,4,5));',
 30, 5, now()),

(gen_random_uuid(),
 'Comparable Interface', 'Interfaz Comparable',
 'Create class Student with int grade implementing Comparable<Student>. Sort a list and print the lowest grade.',
 'Crea la clase Student con int grade implementando Comparable<Student>. Ordena una lista e imprime la calificación más baja.',
 'java', 3, 'objects',
 'import java.util.*;
public class Solution {
    static class Student implements Comparable<Student> {
        int grade;
        Student(int g) { grade = g; }
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '72',
 3,
 'Implement compareTo(Student other) returning grade - other.grade.', 'Implementa compareTo(Student other) retornando grade - other.grade.',
 'Collections.sort() calls compareTo internally.', 'Collections.sort() llama a compareTo internamente.',
 'public int compareTo(Student o){return grade-o.grade;} List<Student> l=Arrays.asList(new Student(85),new Student(72),new Student(90)); Collections.sort(l); System.out.println(l.get(0).grade);', 'public int compareTo(Student o){return grade-o.grade;} List<Student> l=Arrays.asList(new Student(85),new Student(72),new Student(90)); Collections.sort(l); System.out.println(l.get(0).grade);',
 30, 5, now()),

(gen_random_uuid(),
 'Builder Pattern', 'Patrón Builder',
 'Implement a simple Builder for class Person with name and age. Build Person("Alice",25) and print name and age.',
 'Implementa un Builder simple para la clase Person con name y age. Construye Person("Alice",25) e imprime nombre y edad.',
 'java', 3, 'patterns',
 'public class Solution {
    static class Person {
        String name; int age;
        // builder inside
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'Alice 25',
 3,
 'The Builder is an inner class with setter methods that return this.', 'El Builder es una clase interna con métodos setter que retornan this.',
 'The final build() method creates and returns the Person.', 'El método final build() crea y retorna la Person.',
 'static class Builder{String n;int a;Builder name(String n){this.n=n;return this;}Builder age(int a){this.a=a;return this;}Person build(){Person p=new Person();p.name=n;p.age=a;return p;}}', 'static class Builder{String n;int a;Builder name(String n){this.n=n;return this;}Builder age(int a){this.a=a;return this;}Person build(){Person p=new Person();p.name=n;p.age=a;return p;}}',
 30, 5, now()),

(gen_random_uuid(),
 'Recursion: Power Function', 'Recursión: Función Potencia',
 'Write a recursive method power(int base, int exp) and print power(2,10).',
 'Escribe un método recursivo power(int base, int exp) e imprime power(2,10).',
 'java', 3, 'math',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1024',
 3,
 'Base case: exp == 0 returns 1.', 'Caso base: exp == 0 retorna 1.',
 'Recursive case: base * power(base, exp - 1).', 'Caso recursivo: base * power(base, exp - 1).',
 'static long power(int b,int e){return e==0?1:b*power(b,e-1);} System.out.println(power(2,10));', 'static long power(int b,int e){return e==0?1:b*power(b,e-1);} System.out.println(power(2,10));',
 30, 5, now()),

(gen_random_uuid(),
 'String Anagram Check', 'Verificar Anagrama',
 'Write a method isAnagram(String a, String b) and test with "listen" and "silent". Print true.',
 'Escribe un método isAnagram(String a, String b) y pruébalo con "listen" y "silent". Imprime true.',
 'java', 3, 'strings',
 'import java.util.Arrays;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'Sort both strings and compare — anagrams will be equal when sorted.', 'Ordena ambas cadenas y compáralas — los anagramas serán iguales cuando se ordenen.',
 'Convert to char array, sort with Arrays.sort, then back to String.', 'Convierte a arreglo de char, ordena con Arrays.sort, luego de vuelta a String.',
 'static boolean isAnagram(String a,String b){char[] x=a.toCharArray(),y=b.toCharArray();Arrays.sort(x);Arrays.sort(y);return Arrays.equals(x,y);}', 'static boolean isAnagram(String a,String b){char[] x=a.toCharArray(),y=b.toCharArray();Arrays.sort(x);Arrays.sort(y);return Arrays.equals(x,y);}',
 30, 5, now()),

(gen_random_uuid(),
 'TreeMap Sorted Keys', 'TreeMap con Claves Ordenadas',
 'Put {"banana":2,"apple":5,"cherry":1} in a TreeMap and iterate printing key=value pairs.',
 'Agrega {"banana":2,"apple":5,"cherry":1} en un TreeMap e itera imprimiendo pares clave=valor.',
 'java', 3, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'apple=5\nbanana=2\ncherry=1',
 3,
 'TreeMap keeps keys sorted in natural order.', 'TreeMap mantiene las claves ordenadas en orden natural.',
 'Use entrySet() to iterate key-value pairs.', 'Usa entrySet() para iterar los pares clave-valor.',
 'TreeMap<String,Integer> m=new TreeMap<>(); m.put("banana",2);m.put("apple",5);m.put("cherry",1); for(var e:m.entrySet())System.out.println(e.getKey()+"="+e.getValue());', 'TreeMap<String,Integer> m=new TreeMap<>(); m.put("banana",2);m.put("apple",5);m.put("cherry",1); for(var e:m.entrySet())System.out.println(e.getKey()+"="+e.getValue());',
 30, 5, now()),

(gen_random_uuid(),
 'Singleton Pattern', 'Patrón Singleton',
 'Implement a thread-safe Singleton class Config with a method getValue() returning "prod". Print getValue().',
 'Implementa una clase Singleton Config segura para hilos con un método getValue() que retorne "prod". Imprime getValue().',
 'java', 3, 'patterns',
 'public class Solution {
    static class Config {
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'prod',
 3,
 'Make the constructor private so no one can call new Config().', 'Haz el constructor privado para que nadie pueda llamar new Config().',
 'Provide a static getInstance() method that returns the single instance.', 'Provee un método estático getInstance() que retorne la única instancia.',
 'static class Config{private static Config inst;private Config(){}static Config getInstance(){if(inst==null)inst=new Config();return inst;}String getValue(){return "prod";}}', 'static class Config{private static Config inst;private Config(){}static Config getInstance(){if(inst==null)inst=new Config();return inst;}String getValue(){return "prod";}}',
 30, 5, now()),

-- ============================================================
-- JAVA DIFFICULTY 4 (15 exercises)
-- ============================================================

(gen_random_uuid(),
 'LRU Cache', 'Caché LRU',
 'Implement an LRU cache of capacity 3 using LinkedHashMap. Insert keys 1,2,3, access 1, insert 4, then print whether key 2 is present.',
 'Implementa un caché LRU de capacidad 3 usando LinkedHashMap. Inserta las claves 1,2,3, accede a 1, inserta 4, luego imprime si la clave 2 está presente.',
 'java', 4, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'false',
 3,
 'LinkedHashMap with accessOrder=true evicts the least-recently-used entry.', 'LinkedHashMap con accessOrder=true desaloja la entrada menos recientemente usada.',
 'Override removeEldestEntry() to return true when size > capacity.', 'Sobreescribe removeEldestEntry() para retornar true cuando size > capacidad.',
 'Use new LinkedHashMap<>(cap, 0.75f, true){ protected boolean removeEldestEntry(Map.Entry e){return size()>3;}};', 'Usa new LinkedHashMap<>(cap, 0.75f, true){ protected boolean removeEldestEntry(Map.Entry e){return size()>3;}};',
 50, 10, now()),

(gen_random_uuid(),
 'Quick Sort Implementation', 'Implementación de Quick Sort',
 'Implement quicksort on {10,7,8,9,1,5} and print the sorted array on one line.',
 'Implementa quicksort en {10,7,8,9,1,5} e imprime el arreglo ordenado en una línea.',
 'java', 4, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1 5 7 8 9 10',
 3,
 'Choose a pivot (e.g., last element) and partition around it.', 'Elige un pivote (por ejemplo, el último elemento) y particiona alrededor de él.',
 'Elements smaller than pivot go left; larger go right. Recurse on both sides.', 'Elementos menores al pivote van a la izquierda; mayores a la derecha. Recursa en ambos lados.',
 'static void quickSort(int[] a,int l,int r){if(l<r){int p=partition(a,l,r);quickSort(a,l,p-1);quickSort(a,p+1,r);}}', 'static void quickSort(int[] a,int l,int r){if(l<r){int p=partition(a,l,r);quickSort(a,l,p-1);quickSort(a,p+1,r);}}',
 50, 10, now()),

(gen_random_uuid(),
 'Generic Stack', 'Pila Genérica',
 'Implement a generic Stack<T> class with push, pop, and isEmpty. Push 3 integers and pop them all, printing each.',
 'Implementa una clase genérica Stack<T> con push, pop e isEmpty. Empuja 3 enteros y sácalos todos, imprimiendo cada uno.',
 'java', 4, 'data_structures',
 'public class Solution {
    static class Stack<T> {
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '3\n2\n1',
 3,
 'Use an ArrayList<T> internally to store elements.', 'Usa un ArrayList<T> internamente para almacenar elementos.',
 'push() adds to the end; pop() removes and returns the last element.', 'push() agrega al final; pop() elimina y retorna el último elemento.',
 'Use list.add(item) for push and list.remove(list.size()-1) for pop.', 'Usa list.add(item) para push y list.remove(list.size()-1) para pop.',
 50, 10, now()),

(gen_random_uuid(),
 'Observer Pattern', 'Patrón Observador',
 'Implement Observer pattern: EventBus notifies two listeners on publish("Hello"). Each prints the message.',
 'Implementa el patrón Observer: EventBus notifica a dos listeners al llamar publish("Hello"). Cada uno imprime el mensaje.',
 'java', 4, 'patterns',
 'import java.util.*;
public class Solution {
    interface Observer { void onEvent(String msg); }
    static class EventBus {
        // your code
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'Hello\nHello',
 3,
 'EventBus holds a List<Observer> and iterates it on publish.', 'EventBus mantiene un List<Observer> e itera sobre él al publicar.',
 'Call subscribe() to add observers and notify() to iterate and call onEvent.', 'Llama subscribe() para agregar observadores y notify() para iterar y llamar onEvent.',
 'Add two lambda observers: bus.subscribe(msg->System.out.println(msg));', 'Agrega dos observadores lambda: bus.subscribe(msg->System.out.println(msg));',
 50, 10, now()),

(gen_random_uuid(),
 'Binary Tree Traversal', 'Recorrido de Árbol Binario',
 'Build a simple binary tree with root 1, left 2, right 3. Print in-order traversal (left, root, right).',
 'Construye un árbol binario simple con raíz 1, izquierda 2, derecha 3. Imprime el recorrido en inorden (izquierda, raíz, derecha).',
 'java', 4, 'data_structures',
 'public class Solution {
    static class TreeNode {
        int val; TreeNode left, right;
        TreeNode(int v) { val = v; }
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '2\n1\n3',
 3,
 'In-order: recursively visit left, then root, then right.', 'En inorden: visita recursivamente izquierda, luego raíz, luego derecha.',
 'Write inOrder(TreeNode node) that recurses on node.left, prints node.val, then recurses on node.right.', 'Escribe inOrder(TreeNode node) que recursa en node.left, imprime node.val, luego recursa en node.right.',
 'static void inOrder(TreeNode n){if(n==null)return;inOrder(n.left);System.out.println(n.val);inOrder(n.right);}', 'static void inOrder(TreeNode n){if(n==null)return;inOrder(n.left);System.out.println(n.val);inOrder(n.right);}',
 50, 10, now()),

(gen_random_uuid(),
 'Decorator Pattern', 'Patrón Decorador',
 'Implement Decorator pattern: TextPrinter prints text; UpperDecorator wraps it, converting to uppercase. Print "hello".',
 'Implementa el patrón Decorador: TextPrinter imprime texto; UpperDecorator lo envuelve convirtiéndolo a mayúsculas. Imprime "hello".',
 'java', 4, 'patterns',
 'public class Solution {
    interface Printer { void print(String text); }
    public static void main(String[] args) {
        // your code
    }
}',
 'HELLO',
 3,
 'The decorator holds a reference to the wrapped Printer.', 'El decorador mantiene una referencia al Printer envuelto.',
 'UpperDecorator.print() transforms text then delegates to the wrapped printer.', 'UpperDecorator.print() transforma el texto luego delega al printer envuelto.',
 'static class UpperDecorator implements Printer{Printer p;UpperDecorator(Printer p){this.p=p;}public void print(String t){p.print(t.toUpperCase());}}', 'static class UpperDecorator implements Printer{Printer p;UpperDecorator(Printer p){this.p=p;}public void print(String t){p.print(t.toUpperCase());}}',
 50, 10, now()),

(gen_random_uuid(),
 'Streams Reduce', 'Streams Reduce',
 'Use Stream.reduce() to compute the product of {1,2,3,4,5} and print it.',
 'Usa Stream.reduce() para calcular el producto de {1,2,3,4,5} e imprímelo.',
 'java', 4, 'functions',
 'import java.util.*;
import java.util.stream.*;
public class Solution {
    public static void main(String[] args) {
        List<Integer> nums = Arrays.asList(1,2,3,4,5);
        // your code
    }
}',
 '120',
 3,
 'reduce(identity, accumulator) folds the stream into a single value.', 'reduce(identidad, acumulador) reduce el stream a un valor único.',
 'The identity for multiplication is 1.', 'La identidad para la multiplicación es 1.',
 'int result = nums.stream().reduce(1,(a,b)->a*b); System.out.println(result);', 'int result = nums.stream().reduce(1,(a,b)->a*b); System.out.println(result);',
 50, 10, now()),

(gen_random_uuid(),
 'Graph BFS', 'BFS en Grafo',
 'Build an adjacency list graph with 4 nodes. BFS from node 0 and print visited nodes in order.',
 'Construye un grafo de lista de adyacencia con 4 nodos. BFS desde el nodo 0 e imprime los nodos visitados en orden.',
 'java', 4, 'algorithms',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '0\n1\n2\n3',
 3,
 'Use a Queue and a visited boolean array for BFS.', 'Usa una Queue y un arreglo booleano visited para BFS.',
 'Enqueue the start node, mark visited, then process neighbors in FIFO order.', 'Encola el nodo inicial, marca como visitado, luego procesa vecinos en orden FIFO.',
 'Use LinkedList as Queue; poll() to dequeue, add() to enqueue neighbors.', 'Usa LinkedList como Queue; poll() para desencolar, add() para encolar vecinos.',
 50, 10, now()),

(gen_random_uuid(),
 'Memoized Fibonacci', 'Fibonacci Memoizado',
 'Implement fibonacci(n) with memoization using a HashMap. Print fibonacci(40).',
 'Implementa fibonacci(n) con memoización usando un HashMap. Imprime fibonacci(40).',
 'java', 4, 'algorithms',
 'import java.util.*;
public class Solution {
    static Map<Integer,Long> memo = new HashMap<>();
    public static void main(String[] args) {
        // your code
    }
}',
 '102334155',
 3,
 'Before computing, check if the result is already in the map.', 'Antes de calcular, verifica si el resultado ya está en el mapa.',
 'Store computed results with memo.put(n, result) before returning.', 'Almacena los resultados calculados con memo.put(n, result) antes de retornar.',
 'static long fib(int n){if(n<=1)return n;if(memo.containsKey(n))return memo.get(n);long r=fib(n-1)+fib(n-2);memo.put(n,r);return r;}', 'static long fib(int n){if(n<=1)return n;if(memo.containsKey(n))return memo.get(n);long r=fib(n-1)+fib(n-2);memo.put(n,r);return r;}',
 50, 10, now()),

(gen_random_uuid(),
 'Immutable Class', 'Clase Inmutable',
 'Create an immutable class Money with int amount and String currency. Instantiate and print "100 USD".',
 'Crea una clase inmutable Money con int amount y String currency. Instancia e imprime "100 USD".',
 'java', 4, 'objects',
 'public class Solution {
    // define Money here
    public static void main(String[] args) {
        // your code
    }
}',
 '100 USD',
 3,
 'Make the class final, all fields private final, and provide only getters.', 'Haz la clase final, todos los campos private final, y provee solo getters.',
 'Initialize all fields in the constructor only — no setters allowed.', 'Inicializa todos los campos solo en el constructor — no se permiten setters.',
 'final static class Money{private final int amount;private final String currency;Money(int a,String c){amount=a;currency=c;}public String toString(){return amount+" "+currency;}}', 'final static class Money{private final int amount;private final String currency;Money(int a,String c){amount=a;currency=c;}public String toString(){return amount+" "+currency;}}',
 50, 10, now()),

(gen_random_uuid(),
 'Strategy Pattern', 'Patrón Estrategia',
 'Implement Strategy pattern: Sorter accepts a sort strategy. Test with BubbleStrategy and print sorted {3,1,2}.',
 'Implementa el patrón Estrategia: Sorter acepta una estrategia de ordenamiento. Prueba con BubbleStrategy e imprime {3,1,2} ordenado.',
 'java', 4, 'patterns',
 'public class Solution {
    interface SortStrategy { void sort(int[] arr); }
    static class Sorter {
        SortStrategy strategy;
        Sorter(SortStrategy s) { strategy = s; }
        void sort(int[] arr) { strategy.sort(arr); }
    }
    public static void main(String[] args) {
        // your code
    }
}',
 '1 2 3',
 3,
 'BubbleStrategy implements SortStrategy and performs bubble sort.', 'BubbleStrategy implementa SortStrategy y realiza el ordenamiento burbuja.',
 'Pass a lambda or anonymous class as the strategy.', 'Pasa una lambda o clase anónima como estrategia.',
 'Sorter s=new Sorter(arr->{Arrays.sort(arr);}); int[] a={3,1,2}; s.sort(a); for(int x:a)System.out.print(x+" ");', 'Sorter s=new Sorter(arr->{Arrays.sort(arr);}); int[] a={3,1,2}; s.sort(a); for(int x:a)System.out.print(x+" ");',
 50, 10, now()),

(gen_random_uuid(),
 'Collectors groupingBy', 'Collectors groupingBy',
 'Group a list of words {"cat","car","bar","bat"} by their first letter using Collectors.groupingBy and print the group for "b".',
 'Agrupa una lista de palabras {"cat","car","bar","bat"} por su primera letra usando Collectors.groupingBy e imprime el grupo de "b".',
 'java', 4, 'functions',
 'import java.util.*;
import java.util.stream.*;
public class Solution {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("cat","car","bar","bat");
        // your code
    }
}',
 '[bar, bat]',
 3,
 'Use words.stream().collect(Collectors.groupingBy(...)).', 'Usa words.stream().collect(Collectors.groupingBy(...)).',
 'The classifier lambda can return the first character as a String.', 'La lambda clasificadora puede retornar el primer carácter como String.',
 'Map<String,List<String>> g=words.stream().collect(Collectors.groupingBy(w->w.substring(0,1))); System.out.println(g.get("b"));', 'Map<String,List<String>> g=words.stream().collect(Collectors.groupingBy(w->w.substring(0,1))); System.out.println(g.get("b"));',
 50, 10, now()),

(gen_random_uuid(),
 'Trie Data Structure', 'Estructura de Datos Trie',
 'Implement a Trie that supports insert and search. Insert "apple" and "app", then print search("app").',
 'Implementa un Trie que soporte insert y search. Inserta "apple" y "app", luego imprime search("app").',
 'java', 4, 'data_structures',
 'public class Solution {
    static class TrieNode {
        TrieNode[] children = new TrieNode[26];
        boolean isEnd;
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'true',
 3,
 'Each TrieNode has 26 children (one per letter) and an isEnd flag.', 'Cada TrieNode tiene 26 hijos (uno por letra) y un indicador isEnd.',
 'Insert by following/creating nodes; search by following existing nodes.', 'Inserta siguiendo/creando nodos; busca siguiendo nodos existentes.',
 'Map c-''a'' to children index; mark isEnd=true at the last character of insert.', 'Mapea c-''a'' al índice de hijos; marca isEnd=true en el último carácter del insert.',
 50, 10, now()),

(gen_random_uuid(),
 'Thread-Safe Counter', 'Contador Thread-Safe',
 'Use AtomicInteger to implement a thread-safe counter. Increment it 1000 times across 2 threads and print the final value.',
 'Usa AtomicInteger para implementar un contador thread-safe. Increméntalo 1000 veces en 2 hilos e imprime el valor final.',
 'java', 4, 'challenges',
 'import java.util.concurrent.atomic.*;
public class Solution {
    static AtomicInteger counter = new AtomicInteger(0);
    public static void main(String[] args) throws InterruptedException {
        // your code
    }
}',
 '2000',
 3,
 'AtomicInteger.incrementAndGet() is thread-safe without synchronization.', 'AtomicInteger.incrementAndGet() es thread-safe sin sincronización.',
 'Create two Thread objects, each calling counter.incrementAndGet() 1000 times.', 'Crea dos objetos Thread, cada uno llamando counter.incrementAndGet() 1000 veces.',
 'Join both threads with t1.join(); t2.join(); before printing.', 'Une ambos hilos con t1.join(); t2.join(); antes de imprimir.',
 50, 10, now()),

(gen_random_uuid(),
 'Dynamic Programming: Longest Common Subsequence', 'Programación Dinámica: Subsecuencia Común Más Larga',
 'Implement the LCS algorithm for strings "ABCBDAB" and "BDCAB". Print the length of the LCS.',
 'Implementa el algoritmo LCS para las cadenas "ABCBDAB" y "BDCAB". Imprime la longitud del LCS.',
 'java', 4, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '4',
 3,
 'Build a 2D DP table dp[i][j] = length of LCS of first i chars of s1 and first j chars of s2.', 'Construye una tabla DP 2D dp[i][j] = longitud del LCS de los primeros i chars de s1 y primeros j chars de s2.',
 'If s1[i-1]==s2[j-1], dp[i][j]=dp[i-1][j-1]+1; else max(dp[i-1][j],dp[i][j-1]).', 'Si s1[i-1]==s2[j-1], dp[i][j]=dp[i-1][j-1]+1; si no max(dp[i-1][j],dp[i][j-1]).',
 'Answer is dp[m][n] where m=s1.length(), n=s2.length().', 'La respuesta es dp[m][n] donde m=s1.length(), n=s2.length().',
 50, 10, now()),

-- ============================================================
-- JAVA DIFFICULTY 5 (10 exercises)
-- ============================================================

(gen_random_uuid(),
 'Concurrent Producer-Consumer', 'Productor-Consumidor Concurrente',
 'Implement a producer-consumer using a BlockingQueue of capacity 3. Producer enqueues 1-5; consumer dequeues and prints each.',
 'Implementa un productor-consumidor usando un BlockingQueue de capacidad 3. El productor encola 1-5; el consumidor desencola e imprime cada uno.',
 'java', 5, 'challenges',
 'import java.util.concurrent.*;
public class Solution {
    public static void main(String[] args) throws InterruptedException {
        BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(3);
        // your code
    }
}',
 '1\n2\n3\n4\n5',
 3,
 'Use put() on the producer thread and take() on the consumer thread.', 'Usa put() en el hilo productor y take() en el hilo consumidor.',
 'Both threads should run concurrently; join them before the main thread exits.', 'Ambos hilos deben ejecutarse concurrentemente; únelos antes de que el hilo main termine.',
 'Use a sentinel value (e.g., -1) or a fixed count to stop the consumer gracefully.', 'Usa un valor centinela (p.ej., -1) o un conteo fijo para detener el consumidor limpiamente.',
 100, 10, now()),

(gen_random_uuid(),
 'Red-Black Tree Insertion Concept', 'Concepto de Inserción en Árbol Rojo-Negro',
 'Use Java''s TreeSet (backed by a red-black tree) to insert {5,3,7,1,4} and print them in order.',
 'Usa el TreeSet de Java (respaldado por un árbol rojo-negro) para insertar {5,3,7,1,4} e imprime en orden.',
 'java', 5, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '1\n3\n4\n5\n7',
 3,
 'TreeSet maintains sorted order using a self-balancing red-black tree internally.', 'TreeSet mantiene el orden ordenado usando internamente un árbol rojo-negro autoequilibrante.',
 'Add all elements and iterate — they will be in natural sorted order.', 'Agrega todos los elementos e itera — estarán en orden natural ordenado.',
 'TreeSet<Integer> s=new TreeSet<>(Arrays.asList(5,3,7,1,4)); s.forEach(System.out::println);', 'TreeSet<Integer> s=new TreeSet<>(Arrays.asList(5,3,7,1,4)); s.forEach(System.out::println);',
 100, 10, now()),

(gen_random_uuid(),
 'Knapsack 0/1 Dynamic Programming', 'Mochila 0/1 con Programación Dinámica',
 'Solve 0/1 knapsack: weights={2,3,4,5}, values={3,4,5,6}, capacity=8. Print the maximum value.',
 'Resuelve la mochila 0/1: pesos={2,3,4,5}, valores={3,4,5,6}, capacidad=8. Imprime el valor máximo.',
 'java', 5, 'algorithms',
 'public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 '10',
 3,
 'Build a 2D DP table dp[i][w] = max value using first i items with weight limit w.', 'Construye una tabla DP 2D dp[i][w] = valor máximo usando los primeros i ítems con límite de peso w.',
 'For each item, either skip it (dp[i-1][w]) or take it (dp[i-1][w-wt]+val) if it fits.', 'Para cada ítem, omítelo (dp[i-1][w]) o tómalo (dp[i-1][w-wt]+val) si cabe.',
 'Answer is dp[n][capacity] where n = number of items.', 'La respuesta es dp[n][capacity] donde n = número de ítems.',
 100, 10, now()),

(gen_random_uuid(),
 'Reactive Pipeline with CompletableFuture', 'Pipeline Reactivo con CompletableFuture',
 'Chain CompletableFuture: fetch "42" async, parse to int, multiply by 2, then print the result.',
 'Encadena CompletableFuture: obtén "42" de forma asíncrona, conviértelo a int, multiplícalo por 2, luego imprime el resultado.',
 'java', 5, 'challenges',
 'import java.util.concurrent.*;
public class Solution {
    public static void main(String[] args) throws Exception {
        // your code
    }
}',
 '84',
 3,
 'CompletableFuture.supplyAsync() runs a task on the common pool.', 'CompletableFuture.supplyAsync() ejecuta una tarea en el pool común.',
 'Chain .thenApply() for each transformation step.', 'Encadena .thenApply() para cada paso de transformación.',
 'CompletableFuture.supplyAsync(()->\"42\").thenApply(Integer::parseInt).thenApply(n->n*2).thenAccept(System.out::println).get();', 'CompletableFuture.supplyAsync(()->\"42\").thenApply(Integer::parseInt).thenApply(n->n*2).thenAccept(System.out::println).get();',
 100, 10, now()),

(gen_random_uuid(),
 'Dijkstra Shortest Path', 'Camino Más Corto de Dijkstra',
 'Implement Dijkstra on a weighted graph with 5 nodes. Find shortest distance from node 0 to node 4 and print it.',
 'Implementa Dijkstra en un grafo ponderado con 5 nodos. Encuentra la distancia más corta del nodo 0 al nodo 4 e imprímela.',
 'java', 5, 'algorithms',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // graph: 0-1(2), 0-2(4), 1-2(1), 1-3(7), 2-4(3), 3-4(1)
        // your code
    }
}',
 '8',
 3,
 'Use a PriorityQueue ordered by distance to always expand the nearest node.', 'Usa una PriorityQueue ordenada por distancia para expandir siempre el nodo más cercano.',
 'Initialize dist[] with Integer.MAX_VALUE and dist[0]=0.', 'Inicializa dist[] con Integer.MAX_VALUE y dist[0]=0.',
 'Relax edges: if dist[u]+weight < dist[v], update dist[v] and enqueue (dist[v],v).', 'Relaja aristas: si dist[u]+peso < dist[v], actualiza dist[v] y encola (dist[v],v).',
 100, 10, now()),

(gen_random_uuid(),
 'Design a Thread Pool', 'Diseñar un Pool de Hilos',
 'Use Executors.newFixedThreadPool(2) to run 5 tasks printing their task number. Shutdown and await termination.',
 'Usa Executors.newFixedThreadPool(2) para ejecutar 5 tareas imprimiendo su número de tarea. Apaga y espera la terminación.',
 'java', 5, 'challenges',
 'import java.util.concurrent.*;
public class Solution {
    public static void main(String[] args) throws InterruptedException {
        // your code
    }
}',
 'Task 1\nTask 2\nTask 3\nTask 4\nTask 5',
 3,
 'ExecutorService pool = Executors.newFixedThreadPool(2);', 'ExecutorService pool = Executors.newFixedThreadPool(2);',
 'Submit Runnable tasks with pool.submit(() -> System.out.println(...)).', 'Envía tareas Runnable con pool.submit(() -> System.out.println(...)).',
 'Call pool.shutdown() then pool.awaitTermination(10, TimeUnit.SECONDS).', 'Llama pool.shutdown() luego pool.awaitTermination(10, TimeUnit.SECONDS).',
 100, 10, now()),

(gen_random_uuid(),
 'Segment Tree Range Sum', 'Árbol de Segmentos Suma de Rango',
 'Build a segment tree over {1,3,5,7,9,11}. Query the sum of range [1,3] (0-indexed) and print it.',
 'Construye un árbol de segmentos sobre {1,3,5,7,9,11}. Consulta la suma del rango [1,3] (índice 0) e imprímela.',
 'java', 5, 'data_structures',
 'public class Solution {
    static int[] tree;
    public static void main(String[] args) {
        // your code
    }
}',
 '15',
 3,
 'Build the tree by recursively summing children into parent nodes.', 'Construye el árbol sumando recursivamente hijos en nodos padres.',
 'For range query [l,r], recurse and combine overlapping segments.', 'Para la consulta de rango [l,r], recursa y combina segmentos superpuestos.',
 'build(arr,1,0,n-1); then query(1,0,n-1,1,3) returns sum of indices 1..3 = 3+5+7 = 15.', 'build(arr,1,0,n-1); luego query(1,0,n-1,1,3) retorna la suma de índices 1..3 = 3+5+7 = 15.',
 100, 10, now()),

(gen_random_uuid(),
 'Reflection API', 'API de Reflexión',
 'Use Java Reflection to call the private method secret() on class Vault that returns "42". Print the result.',
 'Usa Reflection de Java para llamar al método privado secret() en la clase Vault que retorna "42". Imprime el resultado.',
 'java', 5, 'challenges',
 'import java.lang.reflect.*;
public class Solution {
    static class Vault {
        private String secret() { return "42"; }
    }
    public static void main(String[] args) throws Exception {
        // your code
    }
}',
 '42',
 3,
 'Use Class.getDeclaredMethod("secret") to get the private method.', 'Usa Class.getDeclaredMethod("secret") para obtener el método privado.',
 'Call method.setAccessible(true) before invoking.', 'Llama method.setAccessible(true) antes de invocar.',
 'Method m=Vault.class.getDeclaredMethod("secret");m.setAccessible(true);System.out.println(m.invoke(new Vault()));', 'Method m=Vault.class.getDeclaredMethod("secret");m.setAccessible(true);System.out.println(m.invoke(new Vault()));',
 100, 10, now()),

(gen_random_uuid(),
 'Custom Annotation Processor', 'Procesador de Anotación Personalizado',
 'Define annotation @Label(value). Annotate a class with @Label("Hero"). Use reflection to read and print the label at runtime.',
 'Define la anotación @Label(value). Anota una clase con @Label("Hero"). Usa reflexión para leer e imprimir la etiqueta en tiempo de ejecución.',
 'java', 5, 'challenges',
 'import java.lang.annotation.*;
import java.lang.reflect.*;
public class Solution {
    // define annotation here
    // annotate a class here
    public static void main(String[] args) throws Exception {
        // your code
    }
}',
 'Hero',
 3,
 'Use @Retention(RetentionPolicy.RUNTIME) so the annotation is available via reflection.', 'Usa @Retention(RetentionPolicy.RUNTIME) para que la anotación esté disponible mediante reflexión.',
 'Use @Target(ElementType.TYPE) to apply to classes.', 'Usa @Target(ElementType.TYPE) para aplicar a clases.',
 'SomeClass.class.getAnnotation(Label.class).value() returns the annotation string.', 'SomeClass.class.getAnnotation(Label.class).value() retorna el string de la anotación.',
 100, 10, now()),

(gen_random_uuid(),
 'A* Pathfinding on Grid', 'Pathfinding A* en Cuadrícula',
 'Implement A* on a 4x4 grid (0=open,1=wall). Find path from (0,0) to (3,3). Print the path length.',
 'Implementa A* en una cuadrícula 4x4 (0=abierto,1=pared). Encuentra el camino de (0,0) a (3,3). Imprime la longitud del camino.',
 'java', 5, 'algorithms',
 'import java.util.*;
public class Solution {
    static int[][] grid = {
        {0,0,0,0},
        {0,1,1,0},
        {0,0,0,0},
        {0,0,0,0}
    };
    public static void main(String[] args) {
        // your code
    }
}',
 '7',
 3,
 'A* uses a priority queue ordered by f = g + h where g is cost so far and h is heuristic.', 'A* usa una priority queue ordenada por f = g + h donde g es el costo acumulado y h es la heurística.',
 'Use Manhattan distance as the heuristic h(node) = |x-goalX| + |y-goalY|.', 'Usa la distancia Manhattan como heurística h(nodo) = |x-objetivoX| + |y-objetivoY|.',
 'Expand neighbors in 4 directions (up, down, left, right) checking bounds and walls.', 'Expande vecinos en 4 direcciones (arriba, abajo, izquierda, derecha) verificando límites y paredes.',
 100, 10, now())

(gen_random_uuid(),
 'Queue with LinkedList', 'Cola con LinkedList',
 'Create a Queue using LinkedList, enqueue "first", "second", "third", then dequeue and print all three in order.',
 'Crea una Queue usando LinkedList, encola "first", "second", "third", luego desencola e imprime las tres en orden.',
 'java', 2, 'data_structures',
 'import java.util.*;
public class Solution {
    public static void main(String[] args) {
        // your code
    }
}',
 'first\nsecond\nthird',
 3,
 'LinkedList implements the Queue interface.', 'LinkedList implementa la interfaz Queue.',
 'Use offer() to enqueue and poll() to dequeue.', 'Usa offer() para encolar y poll() para desencolar.',
 'Queue<String> q=new LinkedList<>(); q.offer("first");q.offer("second");q.offer("third"); System.out.println(q.poll());System.out.println(q.poll());System.out.println(q.poll());', 'Queue<String> q=new LinkedList<>(); q.offer("first");q.offer("second");q.offer("third"); System.out.println(q.poll());System.out.println(q.poll());System.out.println(q.poll());',
 20, 3, now()),

(gen_random_uuid(),
 'Abstract Class', 'Clase Abstracta',
 'Define abstract class Vehicle with abstract method fuelType(). Subclass Car returns "gasoline". Print the fuel type.',
 'Define la clase abstracta Vehicle con el método abstracto fuelType(). La subclase Car retorna "gasoline". Imprime el tipo de combustible.',
 'java', 3, 'objects',
 'public class Solution {
    abstract static class Vehicle {
        abstract String fuelType();
    }
    public static void main(String[] args) {
        // your code
    }
}',
 'gasoline',
 3,
 'A subclass of an abstract class must implement all abstract methods.', 'Una subclase de una clase abstracta debe implementar todos los métodos abstractos.',
 'Use the extends keyword and override fuelType() with @Override.', 'Usa la palabra clave extends y sobreescribe fuelType() con @Override.',
 'static class Car extends Vehicle{String fuelType(){return "gasoline";}} System.out.println(new Car().fuelType());', 'static class Car extends Vehicle{String fuelType(){return "gasoline";}} System.out.println(new Car().fuelType());',
 30, 5, now()),

(gen_random_uuid(),
 'Collectors toMap', 'Collectors toMap',
 'Convert a list of strings {"a","bb","ccc"} into a Map<String,Integer> of word to its length using Collectors.toMap. Print the length of "bb".',
 'Convierte una lista de cadenas {"a","bb","ccc"} en un Map<String,Integer> de palabra a su longitud usando Collectors.toMap. Imprime la longitud de "bb".',
 'java', 3, 'functions',
 'import java.util.*;
import java.util.stream.*;
public class Solution {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("a","bb","ccc");
        // your code
    }
}',
 '2',
 3,
 'Use words.stream().collect(Collectors.toMap(keyMapper, valueMapper)).', 'Usa words.stream().collect(Collectors.toMap(mapaClaves, mapaValores)).',
 'The key mapper can be w -> w and the value mapper w -> w.length().', 'El mapeador de claves puede ser w -> w y el de valores w -> w.length().',
 'Map<String,Integer> m=words.stream().collect(Collectors.toMap(w->w,w->w.length())); System.out.println(m.get("bb"));', 'Map<String,Integer> m=words.stream().collect(Collectors.toMap(w->w,w->w.length())); System.out.println(m.get("bb"));',
 30, 5, now())

ON CONFLICT DO NOTHING;

COMMIT;
