-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Tempo de geração: 04/07/2026 às 15:36
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `petvida`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `animais`
--

CREATE TABLE `animais` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `especie_id` int(11) NOT NULL,
  `raca` varchar(50) NOT NULL,
  `data_nascimento` date NOT NULL,
  `tutor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Acionadores `animais`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_animal` AFTER INSERT ON `animais` FOR EACH ROW BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES ('animais', 'INSERT', NEW.id, CONCAT('Novo animal cadastrado: ', NEW.nome, ' (Raça: ', NEW.raca, ')'));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `consultas`
--

CREATE TABLE `consultas` (
  `id` int(11) NOT NULL,
  `animal_id` int(11) NOT NULL,
  `veterinario_id` int(11) NOT NULL,
  `data_hora` datetime NOT NULL,
  `diagnostico` text DEFAULT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status` enum('agendada','em_atendimento','concluida','cancelada') NOT NULL DEFAULT 'agendada'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Acionadores `consultas`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_consulta` AFTER INSERT ON `consultas` FOR EACH ROW BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES ('consultas', 'INSERT', NEW.id, CONCAT('Nova consulta agendada para o animal ID: ', NEW.animal_id, ' com o valor de R$ ', NEW.valor));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_after_update_consulta_status` AFTER UPDATE ON `consultas` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
        VALUES ('consultas', 'UPDATE_STATUS', NEW.id, CONCAT('Status alterado de "', OLD.status, '" para "', NEW.status, '"'));
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_before_delete_consulta` BEFORE DELETE ON `consultas` FOR EACH ROW BEGIN
    DECLARE v_status_pagamento VARCHAR(20);
    SELECT status INTO v_status_pagamento FROM pagamentos WHERE consulta_id = OLD.id LIMIT 1;
    IF v_status_pagamento = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro de Segurança: Não é possível excluir uma consulta que já foi paga.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `especies`
--

CREATE TABLE `especies` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `log_auditoria`
--

CREATE TABLE `log_auditoria` (
  `id` int(11) NOT NULL,
  `tabela_afetada` varchar(50) NOT NULL,
  `acao` varchar(20) NOT NULL,
  `registro_id` int(11) NOT NULL,
  `detalhes` text DEFAULT NULL,
  `data_hora` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `pagamentos`
--

CREATE TABLE `pagamentos` (
  `id` int(11) NOT NULL,
  `consulta_id` int(11) NOT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `forma_pagamento` enum('pix','cartao','dinheiro','convenio') NOT NULL,
  `data_pagamento` datetime DEFAULT NULL,
  `status` enum('pago','pendente','cancelado') NOT NULL DEFAULT 'pendente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Acionadores `pagamentos`
--
DELIMITER $$
CREATE TRIGGER `trg_before_update_pagamento` BEFORE UPDATE ON `pagamentos` FOR EACH ROW BEGIN
    IF NEW.status = 'pago' AND OLD.status <> 'pago' THEN
        SET NEW.data_pagamento = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `tutores`
--

CREATE TABLE `tutores` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `cpf` varchar(14) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `veterinarios`
--

CREATE TABLE `veterinarios` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `crmv` varchar(20) NOT NULL,
  `especialidade` varchar(50) NOT NULL,
  `telefone` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `animais`
--
ALTER TABLE `animais`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_animais_especies` (`especie_id`),
  ADD KEY `fk_animais_tutores` (`tutor_id`);

--
-- Índices de tabela `consultas`
--
ALTER TABLE `consultas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_consultas_animais` (`animal_id`),
  ADD KEY `fk_consultas_veterinarios` (`veterinario_id`),
  ADD KEY `idx_consultas_data_hora` (`data_hora`);

--
-- Índices de tabela `especies`
--
ALTER TABLE `especies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nome` (`nome`);

--
-- Índices de tabela `log_auditoria`
--
ALTER TABLE `log_auditoria`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `pagamentos`
--
ALTER TABLE `pagamentos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `consulta_id` (`consulta_id`);

--
-- Índices de tabela `tutores`
--
ALTER TABLE `tutores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cpf` (`cpf`);

--
-- Índices de tabela `veterinarios`
--
ALTER TABLE `veterinarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `crmv` (`crmv`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `animais`
--
ALTER TABLE `animais`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `consultas`
--
ALTER TABLE `consultas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `especies`
--
ALTER TABLE `especies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `log_auditoria`
--
ALTER TABLE `log_auditoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `pagamentos`
--
ALTER TABLE `pagamentos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tutores`
--
ALTER TABLE `tutores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `veterinarios`
--
ALTER TABLE `veterinarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `animais`
--
ALTER TABLE `animais`
  ADD CONSTRAINT `fk_animais_especies` FOREIGN KEY (`especie_id`) REFERENCES `especies` (`id`),
  ADD CONSTRAINT `fk_animais_tutores` FOREIGN KEY (`tutor_id`) REFERENCES `tutores` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `consultas`
--
ALTER TABLE `consultas`
  ADD CONSTRAINT `fk_consultas_animais` FOREIGN KEY (`animal_id`) REFERENCES `animais` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_consultas_veterinarios` FOREIGN KEY (`veterinario_id`) REFERENCES `veterinarios` (`id`);

--
-- Restrições para tabelas `pagamentos`
--
ALTER TABLE `pagamentos`
  ADD CONSTRAINT `fk_pagamentos_consultas` FOREIGN KEY (`consulta_id`) REFERENCES `consultas` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
