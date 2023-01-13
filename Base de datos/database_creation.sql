/*
	Creación de base de datos llamada distributors.
    Creación de usuario dp_test con todos los privilegios sobre distributors.
    Creación de tabla distributors.
    Creación de tabla persons.
    Creación de tabla addresses.
    Creación de tabla phone_numbers y persons_phone_numbers para relación de uno a muchos con persons.
*/

CREATE DATABASE distributors;

USE distributors;

CREATE USER IF NOT EXISTS 'dp_test'@'localhost' IDENTIFIED BY 'DpPythonTest1*_';
GRANT ALL PRIVILEGES ON * . * TO 'dp_test'@'localhost';
FLUSH PRIVILEGES;

CREATE TABLE distributors (
	distributor_id VARCHAR(50) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estatus TINYINT NOT NULL,
    PRIMARY KEY (distributor_id));

CREATE TABLE persons (
	person_id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    segundo_nombre VARCHAR(50),
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    distributor_id VARCHAR(50) NOT NULL,
    PRIMARY KEY (person_id),
    FOREIGN KEY (distributor_id) REFERENCES distributors (distributor_id) ON DELETE CASCADE);

CREATE TABLE addresses (
	address_id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    calle VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    colonia VARCHAR(100) NOT NULL,
    person_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (address_id),
    FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE);

CREATE TABLE phone_numbers (
	phone_number_id INT UNSIGNED AUTO_INCREMENT NOT NULL,
	tel VARCHAR(50) NOT NULL,
	estatus TINYINT NOT NULL,
	PRIMARY KEY (phone_number_id));

CREATE TABLE persons_phone_numbers (
	person_id INT UNSIGNED NOT NULL,
	phone_number_id INT UNSIGNED NOT NULL,
	FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
	FOREIGN KEY (phone_number_id) REFERENCES phone_numbers (phone_number_id) ON DELETE CASCADE);
    
/* 
	Consultas para insertar datos en las tablas creadas.
    Se incluyen datos erróneos para futura limpieza.
*/

INSERT INTO distributors (distributor_id, estatus) VALUES 
	("A123", 1),
    ("B456", 1),
    ("C789", 1),
    ("D234", 1),
    ("E567", 1);

INSERT INTO persons (nombre, segundo_nombre, apellido_paterno, apellido_materno, distributor_id) VALUES 
	("Jo_rg5e", "", "Cárdenas*", "Galicia", "A123"),
    ("Artu*ro3", "", "Ramirez", "Lope&z", "B456"),
    ("B1re}nda", "", "Jimenez,", "Is3las", "C789"),
    ("Saman]tha", "", ",Lopez", "Flores", "D234"),
    ("Amanda{", "", "Cadenas,", "Herná4ndez'", "E567");
    
INSERT INTO addresses (calle, numero, colonia, person_id) VALUES
	("Juan Escu)tia", "211", "Juarez_", 1),
    ("Rosales_", "15", "Jabalíes", 2),
    ("Color*ada", "3", "Toledo*", 3),
    ("Luis Zuñiga_", "16", "Cent*ro", 4),
    ("Priva4da Astiller", "223", "Vila4 Galaxia_", 5);
    
INSERT INTO phone_numbers (tel, estatus) VALUES
	("6699115a566", 1),
    ("12345bf*67890", 1),
    ("67890s_123'45", 1),
    ("0987654312", 1),
    ("54er?36789540", 1);
    
INSERT INTO persons_phone_numbers (person_id, phone_number_id) VALUES
	(1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

/*
	Procedimiento para consultar la información resumida al inicio de la página.
    Se hace con un procedimiento almacenado ya que la consulta es muy larga y puede confundirse dentro de la programación.
    Dentro de la consulta se hacen validaciones en los campos de la tabla persons y addresses
    para eliminar números y caracteres especiales.
    Dentro de la consulta se hace validación en la tabla phone_numbers para eliminar letras y caracteres especiales.
*/
DELIMITER //
CREATE PROCEDURE `get_distributors` ()
BEGIN
    SET @regex_str = "[0-9]|[\]\\[!@#$%.&*`~^_{}:;<>,'?/\\|()-]+";
    SET @regex_digits = "[a-z]|[\]\\[!@#$%.&*`~^_{}:;<>,'?/\\|()-]+";
    SELECT 
		persons.person_id,
		distributors.distributor_id, 
		CONCAT(
			REGEXP_REPLACE(persons.nombre, @regex_str, ''), ' ', 
			REGEXP_REPLACE(persons.segundo_nombre, @regex_str, ''), ' ', 
			REGEXP_REPLACE(persons.apellido_paterno, @regex_str, ''), ' ', 
			REGEXP_REPLACE(persons.apellido_materno, @regex_str, ''), ' '
		) AS `nombre_completo`,
		CONCAT(
			'Calle: ', REGEXP_REPLACE(addresses.calle, @regex_str, ''), 
			', #', REGEXP_REPLACE(addresses.numero, @regex_digits, ''),
			', Colonia: ', REGEXP_REPLACE(addresses.colonia, @regex_str, '')
		) AS `direccion`,
		REGEXP_REPLACE(phone_numbers.tel, @regex_digits, '') AS tel
		FROM distributors 
		INNER JOIN persons ON distributors.distributor_id = persons.distributor_id 
		INNER JOIN addresses ON persons.person_id = addresses.person_id 
		INNER JOIN persons_phone_numbers ON persons.person_id = persons_phone_numbers.person_id 
		INNER JOIN phone_numbers ON persons_phone_numbers.phone_number_id = phone_numbers.phone_number_id 
		WHERE distributors.estatus = 1 AND phone_numbers.estatus = 1;
END //

/*
	Procedimiento para agregar el distribuidor a la base de datos.
    Primero se agrega en tabla distirbutors
    y después se agrega el nombre en tabla persons
*/
DELIMITER //
CREATE PROCEDURE `add_distributor` (
	IN distributor_id VARCHAR(50),
    IN nombre VARCHAR(50),
    IN segundo_nombre VARCHAR(50),
    IN apellido_paterno VARCHAR(50),
    IN apellido_materno VARCHAR(50)
)
BEGIN
	INSERT INTO distributors (distributor_id, estatus) VALUES (distributor_id, 1);
    INSERT INTO persons (nombre, segundo_nombre, apellido_paterno, apellido_materno, distributor_id) VALUES (nombre, segundo_nombre, apellido_paterno, apellido_materno, distributor_id);
END //

/*
	Procedimiento para agregar la información extra del distribuidor.
    Se insetan los datos utilizando dos procecimiendos almacenados para respueta más rápida al ingresar un ID repetido.
    Se agrega la dirección en tabla addresses y el teléfono en phone_numbers
*/
DELIMITER //
CREATE PROCEDURE `add_address_tel` (
	IN distributor_id VARCHAR(50),
    IN calle VARCHAR(100),
    IN numero VARCHAR(10),
    IN colonia VARCHAR(100),
    IN tel VARCHAR(10)
)
BEGIN
    SELECT person_id INTO @person FROM persons WHERE persons.distributor_id = distributor_id;
    
    INSERT INTO addresses (calle, numero, colonia, person_id) VALUES (calle, numero, colonia, @person);
    
    INSERT INTO phone_numbers (tel, estatus) VALUES (tel, 1);
	SELECT LAST_INSERT_ID() INTO @tel_id;
    INSERT INTO persons_phone_numbers (person_id, phone_number_id) VALUES (@person, @tel_id);
END //

/* 
	Procedimiento almacenado para agregar o actualizar un número telefónico.
    Se busca si el teléfono existe asociado a esa persona, sino existe
    se desactivan todos los teléfonos y se agrega el nuevo.
    Si existe se revisa si el teléfono está activo o no, si está activo no se hace nada,
    de lo contrario se desactivan todos los teléfonos y se activa el recién ingresado.
*/
DELIMITER //
CREATE PROCEDURE `update_tel` (
	IN person_id INT,
    IN tel VARCHAR(50)
)
BEGIN
    SET SQL_SAFE_UPDATES = 0;
    SELECT phone_numbers.tel, phone_numbers.estatus INTO @existing_phone, @existing_estatus
		FROM persons_phone_numbers
		INNER JOIN phone_numbers ON persons_phone_numbers.phone_number_id = phone_numbers.phone_number_id 
		WHERE phone_numbers.tel = tel AND persons_phone_numbers.person_id = person_id;
        
    IF @existing_phone THEN
		IF @existing_estatus = 0 THEN
			UPDATE phone_numbers
				INNER JOIN persons_phone_numbers ON phone_numbers.phone_number_id = persons_phone_numbers.phone_number_id
                SET phone_numbers.estatus = 0
                WHERE persons_phone_numbers.person_id = person_id AND phone_numbers.estatus = 1;
                
			UPDATE phone_numbers
				INNER JOIN persons_phone_numbers ON phone_numbers.phone_number_id = persons_phone_numbers.phone_number_id
				SET phone_numbers.estatus = 1
				WHERE persons_phone_numbers.person_id = person_id AND phone_numbers.tel = @existing_phone;
		END IF;
	ELSE
		UPDATE phone_numbers
				INNER JOIN persons_phone_numbers ON phone_numbers.phone_number_id = persons_phone_numbers.phone_number_id
                SET phone_numbers.estatus = 0
                WHERE persons_phone_numbers.person_id = person_id AND phone_numbers.estatus = 1;
                
		INSERT INTO phone_numbers (tel, estatus) VALUES (tel, 1);
		SELECT LAST_INSERT_ID() INTO @tel_id;
		INSERT INTO persons_phone_numbers (person_id, phone_number_id) VALUES (person_id, @tel_id);
    END IF;
    
    SET @existing_phone = null;
END //