create database loja_dart;

use loja_dart;

CREATE TABLE IF NOT EXISTS `cliente` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nome` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pedido` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `descricao` VARCHAR(255) NOT NULL,
  `valor` DECIMAL(10, 2) NOT NULL,
  `cliente_id` INT,
  FOREIGN KEY (`cliente_id`) REFERENCES `cliente`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Limpa as tabelas para garantir uma execução limpa do script Dart
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `pedido`;
TRUNCATE TABLE `cliente`;
SET FOREIGN_KEY_CHECKS = 1;