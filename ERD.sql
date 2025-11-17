-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE systems (
    system_id SERIAL PRIMARY KEY,
    system_code VARCHAR(50) NOT NULL UNIQUE,
    system_name VARCHAR(200) NOT NULL,
    parent_system_id INTEGER,
    level INTEGER NOT NULL CHECK (level IN (1, 2)),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_system_id) REFERENCES systems(system_id) ON DELETE CASCADE
);

-- 索引
CREATE INDEX idx_systems_parent ON systems(parent_system_id);
CREATE INDEX idx_systems_level ON systems(level);

-- 註釋
COMMENT ON TABLE systems IS '列車系統結構表';
COMMENT ON COLUMN systems.level IS '1=主系統, 2=子系統';

-- ============================================
-- 2. Parts（零件主表）
-- ============================================
CREATE TABLE parts (
    part_id SERIAL PRIMARY KEY,
    parts_name VARCHAR(200) NOT NULL,
    drawing_number VARCHAR(100) NOT NULL UNIQUE,
    unit_price NUMERIC(12, 2) CHECK (unit_price >= 0),
    stock_code VARCHAR(50) UNIQUE,
    part_category VARCHAR(100),
    is_critical BOOLEAN DEFAULT FALSE,
    specification TEXT,
    unit VARCHAR(20) DEFAULT '個',
    supplier_name VARCHAR(200),
    lead_time_days INTEGER CHECK (lead_time_days >= 0),
    moq INTEGER CHECK (moq >= 0),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX idx_parts_drawing_number ON parts(drawing_number);
CREATE INDEX idx_parts_stock_code ON parts(stock_code);
CREATE INDEX idx_parts_category ON parts(part_category);
CREATE INDEX idx_parts_supplier ON parts(supplier_name);

-- 註釋
COMMENT ON TABLE parts IS '零件主表';
COMMENT ON COLUMN parts.is_critical IS '是否為關鍵零件';
COMMENT ON COLUMN parts.moq IS '最小訂購量 (Minimum Order Quantity)';

-- ============================================
-- 3. Inventory（庫存表）
-- ============================================
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    part_id INTEGER NOT NULL UNIQUE,
    current_qty INTEGER DEFAULT 0 CHECK (current_qty >= 0),
    reserved_qty INTEGER DEFAULT 0 CHECK (reserved_qty >= 0),
    location VARCHAR(100),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE CASCADE,
    CHECK (reserved_qty <= current_qty)
);

-- 索引
CREATE INDEX idx_inventory_part ON inventory(part_id);

-- 註釋
COMMENT ON TABLE inventory IS '庫存表';
COMMENT ON COLUMN inventory.reserved_qty IS '已預留數量';

-- ============================================
-- 4. System_Parts_BOM（系統零件清單）
-- ============================================
CREATE TABLE system_parts_bom (
    bom_id SERIAL PRIMARY KEY,
    system_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    qty_per_train INTEGER NOT NULL CHECK (qty_per_train > 0),
    install_position VARCHAR(200),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (system_id) REFERENCES systems(system_id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE CASCADE,
    UNIQUE (system_id, part_id)
);

-- 索引
CREATE INDEX idx_bom_system ON system_parts_bom(system_id);
CREATE INDEX idx_bom_part ON system_parts_bom(part_id);

-- 註釋
COMMENT ON TABLE system_parts_bom IS '系統零件清單（Bill of Materials）';
COMMENT ON COLUMN system_parts_bom.qty_per_train IS '每輛列車所需數量';

-- ============================================
-- 5. Trains（列車表）
-- ============================================
CREATE TABLE trains (
    train_id SERIAL PRIMARY KEY,
    train_number VARCHAR(50) NOT NULL UNIQUE,
    train_name VARCHAR(100),
    manufacturing_year INTEGER,
    status VARCHAR(50) DEFAULT '運營中',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('待大修', '大修中', '已完成', '運營中'))
);

-- 索引
CREATE INDEX idx_trains_number ON trains(train_number);
CREATE INDEX idx_trains_status ON trains(status);

-- 註釋
COMMENT ON TABLE trains IS '列車基本資料表';

-- ============================================
-- 6. Overhaul_Projects（大修項目表）
-- ============================================
CREATE TABLE overhaul_projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    project_code VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE,
    target_end_date DATE,
    actual_end_date DATE,
    total_trains INTEGER DEFAULT 55 CHECK (total_trains > 0),
    status VARCHAR(50) DEFAULT '計劃中',
    project_manager VARCHAR(100),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('計劃中', '進行中', '已完成', '暫停', '已取消')),
    CHECK (target_end_date >= start_date)
);

-- 索引
CREATE INDEX idx_projects_code ON overhaul_projects(project_code);
CREATE INDEX idx_projects_status ON overhaul_projects(status);

-- 註釋
COMMENT ON TABLE overhaul_projects IS '大修項目表';

-- ============================================
-- 7. Train_Overhaul（列車大修記錄）
-- ============================================
CREATE TABLE train_overhaul (
    record_id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    train_id INTEGER NOT NULL,
    start_date DATE,
    completed_date DATE,
    status VARCHAR(50) DEFAULT '待開始',
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES overhaul_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (train_id) REFERENCES trains(train_id) ON DELETE CASCADE,
    UNIQUE (project_id, train_id),
    CHECK (status IN ('待開始', '進行中', '已完成', '暫停')),
    CHECK (completed_date IS NULL OR completed_date >= start_date)
);

-- 索引
CREATE INDEX idx_train_overhaul_project ON train_overhaul(project_id);
CREATE INDEX idx_train_overhaul_train ON train_overhaul(train_id);
CREATE INDEX idx_train_overhaul_status ON train_overhaul(status);

-- 註釋
COMMENT ON TABLE train_overhaul IS '列車大修記錄表';

-- ============================================
-- 8. Procurement（採購記錄表）
-- ============================================
CREATE TABLE procurement (
    procurement_id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    required_qty INTEGER NOT NULL CHECK (required_qty > 0),
    ordered_qty INTEGER DEFAULT 0 CHECK (ordered_qty >= 0),
    received_qty INTEGER DEFAULT 0 CHECK (received_qty >= 0),
    po_number VARCHAR(50),
    order_date DATE,
    expected_date DATE,
    actual_date DATE,
    unit_price NUMERIC(12, 2) CHECK (unit_price >= 0),
    total_amount NUMERIC(15, 2) CHECK (total_amount >= 0),
    status VARCHAR(50) DEFAULT '待採購',
    supplier_name VARCHAR(200),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES overhaul_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE CASCADE,
    CHECK (status IN ('待採購', '已下單', '部分到貨', '已到貨', '已入庫', '已取消')),
    CHECK (received_qty <= ordered_qty)
);

-- 索引
CREATE INDEX idx_procurement_project ON procurement(project_id);
CREATE INDEX idx_procurement_part ON procurement(part_id);
CREATE INDEX idx_procurement_status ON procurement(status);
CREATE INDEX idx_procurement_po ON procurement(po_number);

-- 註釋
COMMENT ON TABLE procurement IS '採購記錄表';

-- ============================================
-- 9. Parts_Usage（零件使用記錄表）
-- ============================================
CREATE TABLE parts_usage (
    usage_id SERIAL PRIMARY KEY,
    train_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    system_id INTEGER NOT NULL,
    planned_qty INTEGER NOT NULL CHECK (planned_qty >= 0),
    actual_qty INTEGER NOT NULL CHECK (actual_qty >= 0),
    usage_date DATE NOT NULL,
    source VARCHAR(50) DEFAULT '現有庫存',
    operator VARCHAR(100),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (train_id) REFERENCES trains(train_id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE CASCADE,
    FOREIGN KEY (system_id) REFERENCES systems(system_id) ON DELETE CASCADE,
    CHECK (source IN ('現有庫存', '新採購'))
);

-- 索引
CREATE INDEX idx_usage_train ON parts_usage(train_id);
CREATE INDEX idx_usage_part ON parts_usage(part_id);
CREATE INDEX idx_usage_system ON parts_usage(system_id);
CREATE INDEX idx_usage_date ON parts_usage(usage_date);

-- 註釋
COMMENT ON TABLE parts_usage IS '零件使用記錄表';
