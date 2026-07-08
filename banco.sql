CREATE DATABASE IF NOT EXISTS biblioteca;

USE biblioteca;

CREATE TABLE IF NOT EXISTS itens (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  tipo       VARCHAR(10) NOT NULL,
  titulo     VARCHAR(255) NOT NULL,
  autor      VARCHAR(255) NOT NULL,
  tema       VARCHAR(255) NOT NULL,
  disponivel BOOLEAN NOT NULL DEFAULT TRUE,
  data_cadastro    DATETIME NOT NULL,
  data_emprestimo  DATETIME NULL,
  data_devolucao   DATETIME NULL,
  paginas    INT NULL,
  ano        INT NULL
);