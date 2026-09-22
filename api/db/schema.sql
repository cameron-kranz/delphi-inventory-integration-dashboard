-- schema.sql - defines the shape of our inventory table

CREATE TABLE IF NOT EXISTS inventory (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    sku           TEXT NOT NULL UNIQUE,
    name          TEXT NOT NULL,
    category      TEXT,
    quantity      INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    unit_price    REAL NOT NULL DEFAULT 0 CHECK (unit_price >= 0),
    supplier      TEXT,
    last_updated  TEXT NOT NULL DEFAULT (datetime('now'))
);