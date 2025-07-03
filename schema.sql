-- schema.sql
-- Este script cria a estrutura de tabelas para o banco de dados do Sistema Logístico Terrazul.
-- Ele é projetado para ser executado uma única vez para inicializar o banco de dados.

-- Tabela para armazenar os motoristas
CREATE TABLE IF NOT EXISTS drivers (
    name TEXT PRIMARY KEY NOT NULL
);

-- Tabela para armazenar os tipos de clientes
CREATE TABLE IF NOT EXISTS client_types (
    name TEXT PRIMARY KEY NOT NULL
);

-- Tabela para armazenar os grupos de cidades
CREATE TABLE IF NOT EXISTS groups (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT UNIQUE NOT NULL,
    driver_name TEXT,
    FOREIGN KEY (driver_name) REFERENCES drivers(name) ON DELETE SET NULL
);

-- Tabela principal para armazenar as cidades e suas informações de coleta
CREATE TABLE IF NOT EXISTS cities (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    group_id TEXT,
    frequency TEXT NOT NULL,
    client_type_name TEXT,
    last_collection_date DATE,
    next_calculated_date DATE,
    is_priority INTEGER NOT NULL DEFAULT 0, -- 0 para False, 1 para True
    is_manually_rescheduled INTEGER NOT NULL DEFAULT 0, -- 0 para False, 1 para True
    status TEXT NOT NULL DEFAULT 'scheduled', -- Ex: 'scheduled', 'completed', 'pending'
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE SET NULL,
    FOREIGN KEY (client_type_name) REFERENCES client_types(name) ON DELETE SET NULL
);

-- Tabela para armazenar os feriados
CREATE TABLE IF NOT EXISTS holidays (
    "date" DATE PRIMARY KEY NOT NULL,
    description TEXT NOT NULL
);

-- Tabela para armazenar as regras de dias específicos (ex: não coletar às terças)
CREATE TABLE IF NOT EXISTS day_rules (
    id TEXT PRIMARY KEY NOT NULL,
    type TEXT NOT NULL, -- 'city' ou 'group'
    city_id TEXT,
    group_id TEXT,
    day_of_week INTEGER NOT NULL, -- 0=Domingo, 1=Segunda, ..., 6=Sábado
    rule TEXT NOT NULL, -- 'no_collection' ou 'fixed_day'
    description TEXT,
    cascade INTEGER NOT NULL DEFAULT 0, -- 0 para False, 1 para True
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);

-- Tabela para o histórico de eventos de uma cidade (coletas, reagendamentos, etc.)
CREATE TABLE IF NOT EXISTS city_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    city_id TEXT NOT NULL,
    "date" DATETIME NOT NULL,
    type TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

-- Tabela para agendamentos manuais, principalmente para fins logísticos
CREATE TABLE IF NOT EXISTS manual_schedules (
    id TEXT PRIMARY KEY NOT NULL,
    city_id TEXT NOT NULL,
    "date" DATE NOT NULL,
    description TEXT,
    is_logistics_only INTEGER NOT NULL DEFAULT 0, -- 0 para False, 1 para True
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

-- Tabela para registrar logs de imprevistos/emergências
CREATE TABLE IF NOT EXISTS emergency_logs (
    id TEXT PRIMARY KEY NOT NULL,
    type TEXT NOT NULL, -- 'vehicle-breakdown', 'weather', etc.
    description TEXT,
    affected_date DATE NOT NULL,
    delay_days INTEGER NOT NULL,
    cascade INTEGER NOT NULL DEFAULT 0, -- 0 para False, 1 para True
    "timestamp" DATETIME NOT NULL
);

-- Tabela de associação para registrar os grupos afetados por um imprevisto
CREATE TABLE IF NOT EXISTS emergency_affected_groups (
    emergency_log_id TEXT NOT NULL,
    group_id TEXT NOT NULL,
    PRIMARY KEY (emergency_log_id, group_id),
    FOREIGN KEY (emergency_log_id) REFERENCES emergency_logs(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);

-- Tabela de associação para registrar as cidades específicas afetadas por um imprevisto
CREATE TABLE IF NOT EXISTS emergency_affected_cities (
    emergency_log_id TEXT NOT NULL,
    city_id TEXT NOT NULL,
    original_date DATE,
    PRIMARY KEY (emergency_log_id, city_id),
    FOREIGN KEY (emergency_log_id) REFERENCES emergency_logs(id) ON DELETE CASCADE,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

-- Inserção de dados iniciais/padrão (opcional, mas recomendado)
INSERT OR IGNORE INTO drivers (name) VALUES ('Reinaldo'), ('Maicon');
INSERT OR IGNORE INTO client_types (name) VALUES ('Prefeitura'), ('Particular'), ('Extra');

PRAGMA foreign_keys = ON;
