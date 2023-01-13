/*
	En los campos de persons se cambian los números por las letras correspondientes,
    también se eliminan los caracteres especiales.
    En la tabla addresses los campos calle y colonia se cambian los números por las letras correspondientes
    y se quitan caracteres esspeciales.
    En el caso de numero en tabla addresses y tel en la tabla phone_numbers,
    se eliminan todas las letras y caracteres especiales.
*/

USE distributors;
SET SQL_SAFE_UPDATES = 0;

UPDATE persons SET nombre = REPLACE(nombre, '0', 'o');
UPDATE persons SET nombre = REPLACE(nombre, '1', 'i');
UPDATE persons SET nombre = REPLACE(nombre, '3', 'e');
UPDATE persons SET nombre = REPLACE(nombre, '4', 'a');
UPDATE persons SET nombre = REPLACE(nombre, '5', 's');
UPDATE persons SET nombre = REGEXP_REPLACE(nombre, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE persons SET segundo_nombre = REPLACE(segundo_nombre, '0', 'o');
UPDATE persons SET segundo_nombre = REPLACE(segundo_nombre, '1', 'i');
UPDATE persons SET segundo_nombre = REPLACE(segundo_nombre, '3', 'e');
UPDATE persons SET segundo_nombre = REPLACE(segundo_nombre, '4', 'a');
UPDATE persons SET segundo_nombre = REPLACE(segundo_nombre, '5', 's');
UPDATE persons SET segundo_nombre = REGEXP_REPLACE(segundo_nombre, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE persons SET apellido_paterno = REPLACE(apellido_paterno, '0', 'o');
UPDATE persons SET apellido_paterno = REPLACE(apellido_paterno, '1', 'i');
UPDATE persons SET apellido_paterno = REPLACE(apellido_paterno, '3', 'e');
UPDATE persons SET apellido_paterno = REPLACE(apellido_paterno, '4', 'a');
UPDATE persons SET apellido_paterno = REPLACE(apellido_paterno, '5', 's');
UPDATE persons SET apellido_paterno = REGEXP_REPLACE(apellido_paterno, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE persons SET apellido_materno = REPLACE(apellido_materno, '0', 'o');
UPDATE persons SET apellido_materno = REPLACE(apellido_materno, '1', 'i');
UPDATE persons SET apellido_materno = REPLACE(apellido_materno, '3', 'e');
UPDATE persons SET apellido_materno = REPLACE(apellido_materno, '4', 'a');
UPDATE persons SET apellido_materno = REPLACE(apellido_materno, '5', 's');
UPDATE persons SET apellido_materno = REGEXP_REPLACE(apellido_materno, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE addresses SET calle = REPLACE(calle, '0', 'o');
UPDATE addresses SET calle = REPLACE(calle, '1', 'i');
UPDATE addresses SET calle = REPLACE(calle, '3', 'e');
UPDATE addresses SET calle = REPLACE(calle, '4', 'a');
UPDATE addresses SET calle = REPLACE(calle, '5', 's');
UPDATE addresses SET calle = REGEXP_REPLACE(calle, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE addresses SET colonia = REPLACE(colonia, '0', 'o');
UPDATE addresses SET colonia = REPLACE(colonia, '1', 'i');
UPDATE addresses SET colonia = REPLACE(colonia, '3', 'e');
UPDATE addresses SET colonia = REPLACE(colonia, '4', 'a');
UPDATE addresses SET colonia = REPLACE(colonia, '5', 's');
UPDATE addresses SET colonia = REGEXP_REPLACE(colonia, '[\]\\[!@#$%.&*`~^_{}:;<>,?/\\|()-]+', '');

UPDATE addresses SET numero = REGEXP_REPLACE(numero, "[a-z]|[\]\\[!@#$%.&*`~^_{}:;<>,'?/\\|()-]+", '');

UPDATE phone_numbers SET tel = REGEXP_REPLACE(tel, "[a-z]|[\]\\[!@#$%.&*`~^_{}:;<>,'?/\\|()-]+", '');

