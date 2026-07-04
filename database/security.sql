DROP USER IF EXISTS 'recepcionista'@'localhost';
DROP USER IF EXISTS 'veterinario'@'localhost';
DROP USER IF EXISTS 'gerente'@'localhost';
DROP USER IF EXISTS 'admin_petvida'@'localhost';

CREATE USER 'recepcionista'@'localhost' IDENTIFIED BY 'recep123';
CREATE USER 'veterinario'@'localhost' IDENTIFIED BY 'vet123';
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'gerente123';
CREATE USER 'admin_petvida'@'localhost' IDENTIFIED BY 'admin123';

GRANT SELECT, INSERT ON petvida.tutores TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON petvida.animais TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON petvida.consultas TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON petvida.especies TO 'recepcionista'@'localhost';
GRANT EXECUTE ON PROCEDURE petvida.sp_agendar TO 'recepcionista'@'localhost';
GRANT EXECUTE ON PROCEDURE petvida.sp_cadastrar TO 'recepcionista'@'localhost';

GRANT SELECT ON petvida.* TO 'veterinario'@'localhost';
GRANT UPDATE (diagnostico, status) ON petvida.consultas TO 'veterinario'@'localhost';
GRANT EXECUTE ON PROCEDURE petvida.sp_concluir TO 'veterinario'@'localhost';

GRANT SELECT, INSERT, UPDATE ON petvida.* TO 'gerente'@'localhost';
GRANT EXECUTE ON petvida.* TO 'gerente'@'localhost';
GRANT DELETE ON petvida.consultas TO 'gerente'@'localhost';

GRANT ALL PRIVILEGES ON petvida.* TO 'admin_petvida'@'localhost' WITH GRANT OPTION;

REVOKE SELECT, INSERT ON petvida.consultas FROM 'recepcionista'@'localhost';

FLUSH PRIVILEGES;