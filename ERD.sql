-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE systems( 
    system_id    SERIAL PRIMARY KEY,
    system_code    VARCHAR(50) NOT NULL UNIQUE,
    system_name    VARCHAR(200) NOT NULL,
    description    TEXT
);

-- ============================================
-- 2. Parts（零件表）
-- ============================================
CREATE TABLE parts( 
    part_id    SERIAL PRIMARY KEY,
    drawing_number    VARCHAR(50) NOT NULL UNIQUE,
    part_name    VARCHAR(200) NOT NULL,
    unit_price    NUMERIC(12, 2) CHECK (unit_price >= 0),
    unit_of_measure    VARCHAR(20),
    stock_code    VARCHAR(50),
    specification    TEXT,
    supplier_name    VARCHAR(50)
);
