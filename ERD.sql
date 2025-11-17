-- 1. 系統表
CREATE TABLE systems (
    system_id SERIAL PRIMARY KEY,
    system_code VARCHAR(50) UNIQUE NOT NULL,
    system_name VARCHAR(100) NOT NULL,
);

COMMENT ON TABLE systems IS '系統表';
COMMENT ON COLUMN systems.system_code IS '系統編碼';
COMMENT ON COLUMN systems.system_name IS '系統名稱';

-- 2. 零件表
CREATE TABLE parts (
    part_id SERIAL PRIMARY KEY,
    drawing_number VARCHAR(100) UNIQUE NOT NULL,
    part_name VARCHAR(200) NOT NULL,
    unit_price DECIMAL(10, 2),
    specification TEXT,
);

COMMENT ON TABLE parts IS '零件主資料';
COMMENT ON COLUMN parts.drawing_number IS '型號';
COMMENT ON COLUMN parts.part_name IS '零件名稱';
COMMENT ON COLUMN parts.unit_price IS '單價';
COMMENT ON COLUMN parts.sepcification IS '規格說明';

-- 3. 系統零件關聯表 (記錄每個零件在哪個系統使用及用量)
CREATE TABLE system_parts (
    id SERIAL PRIMARY KEY,
    system_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    quantity_per_SUT INTEGER NOT NULL,
    FOREIGN KEY (system_id) REFERENCES systems(system_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

COMMENT ON TABLE system_parts IS '系統零件用量';
COMMENT ON COLUMN system_parts.system_id IS '系統ID';
COMMENT ON COLUMN system_parts.part_id IS '零件ID';
COMMENT ON COLUMN system_parts.quantity_per_SUT IS '每組SUT用量';

-- 4. 庫存表 (現有庫存 + 新採購)
CREATE TABLE stock_inventory (
    inventory_id SERIAL PRIMARY KEY,
    part_id INTEGER NOT NULL,
    stock_code VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0,
    purchase_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

COMMENT ON TABLE stock_inventory IS '庫存資料';
COMMENT ON COLUMN stock_inventory.part_id IS '零件ID';
COMMENT ON COLUMN stock_inventory.stock_code IS '倉庫編號 (舊有庫存才有)';
COMMENT ON COLUMN stock_inventory.quantity IS '數量';
COMMENT ON COLUMN stock_inventory.purchase_date IS '採購日期';

-- ============================================
-- 創建索引
-- ============================================
CREATE INDEX idx_parent_system ON systems(parent_system_id);
CREATE INDEX idx_system_parts_system ON system_parts(system_id);
CREATE INDEX idx_system_parts_part ON system_parts(part_id);
CREATE INDEX idx_inventory_part ON stock_inventory(part_id);

