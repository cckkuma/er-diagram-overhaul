-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE systems( 
    system_id    SERIAL PRIMARY KEY,
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
    stock_qty    INTEGER NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    specification    TEXT,
    supplier_name    VARCHAR(50)
);

-- ============================================
-- 3. System Parts BOM（零件用量表）
-- ============================================
CREATE TABLE system_parts_BOM( 
    bom_id    SERIAL PRIMARY KEY,
    system_id    INTEGER NOT NULL,
    part_id    INTEGER NOT NULL,
    qty_per_SUT    INTEGER NOT NULL CHECK (qty_per_SUT > 0),
    remarks    TEXT,
    FOREIGN KEY (system_id) REFERENCES systems(system_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

-- ============================================
-- 4. Overhaul Batch（維修批次表）
-- ============================================
CREATE TABLE overhaul_batch( 
    batch_id    SERIAL PRIMARY KEY,
    batch_name    VARCHAR(200) NOT NULL,
    train_count    INTEGER NOT NULL CHECK (train_count > 0),
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    status    VARCHAR(20) NOT NULL,
    remarks TEXT
);

-- ============================================
-- 5. Train（車輛資料表）
-- ============================================
CREATE TABLE train( 
    train_id    SERIAL PRIMARY KEY,
    batch_id    INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    status    VARCHAR(20) NOT NULL,
    remarks TEXT,
    FOREIGN KEY (batch_id) REFERENCES overhaul_batch(batch_id)
);

-- ============================================
-- 6. Procurement Records（採購記錄表）
-- ============================================
CREATE TABLE procurement_records( 
    po_id    SERIAL PRIMARY KEY,
    part_id    INTEGER NOT NULL,
    order_qty NUMERIC(10, 2) NOT NULL CHECK (order_qty > 0),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    received_qty NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (received_qty >= 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    total_amount NUMERIC(15, 2) GENERATED ALWAYS AS (order_qty * unit_price) STORED,
    status VARCHAR(20) NOT NULL,
    supplier VARCHAR(100),
    remarks TEXT,
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

-- ============================================
-- 7. Parts Usage Log（零件使用記錄表）
-- ============================================
CREATE TABLE parts_usage_log( 
    usage_id    SERIAL PRIMARY KEY,
    train_id    INTEGER NOT NULL,
    part_id    INTEGER NOT NULL,
    system_id    INTEGER NOT NULL,
    used_qty INTEGER NOT NULL CHECK (used_qty > 0),
    usage_date DATE NOT NULL,
    remarks TEXT,
    FOREIGN KEY (train_id) REFERENCES train(train_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id),
    FOREIGN KEY (system_id) REFERENCES systems(system_id)
);
