CREATE DATABASE IF NOT EXISTS petvida;
USE petvida;

CREATE TABLE veterinarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

CREATE TABLE tutores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

CREATE TABLE especies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE animais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    especie_id INT NOT NULL,
    raca VARCHAR(50) NOT NULL,
    data_nascimento DATE NOT NULL,
    tutor_id INT NOT NULL,
    CONSTRAINT fk_animais_especies FOREIGN KEY (especie_id) REFERENCES especies(id),
    CONSTRAINT fk_animais_tutores FOREIGN KEY (tutor_id) REFERENCES tutores(id) ON DELETE CASCADE
);

CREATE TABLE consultas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    animal_id INT NOT NULL,
    veterinario_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    diagnostico TEXT,
    valor DECIMAL(10,2) NOT NULL,
    status ENUM('agendada', 'em_atendimento', 'concluida', 'cancelada') NOT NULL DEFAULT 'agendada',
    CONSTRAINT fk_consultas_animais FOREIGN KEY (animal_id) REFERENCES animais(id) ON DELETE CASCADE,
    CONSTRAINT fk_consultas_veterinarios FOREIGN KEY (veterinario_id) REFERENCES veterinarios(id)
);

CREATE INDEX idx_consultas_data_hora ON consultas(data_hora);

CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT NOT NULL UNIQUE,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('pix', 'cartao', 'dinheiro', 'convenio') NOT NULL,
    data_pagamento DATETIME,
    status ENUM('pago', 'pendente', 'cancelado') NOT NULL DEFAULT 'pendente',
    CONSTRAINT fk_pagamentos_consultas FOREIGN KEY (consulta_id) REFERENCES consultas(id) ON DELETE CASCADE
);