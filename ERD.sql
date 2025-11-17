-- 車輛表 (包含SUT和MRV)
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL COMMENT '車輛編號: 如001A, 001B, MRV001',
    vehicle_type ENUM('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '車輛類型',
    train_set VARCHAR(10) COMMENT '列車組號: 如001, 002... (SUT才有)',
    power_type ENUM('750DC', 'DIESEL') NOT NULL COMMENT '供能方式',
    status ENUM('待大修', '大修中', '已完成', '運行中') DEFAULT '待大修',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='車輛基本資料表';

-- 系統層級結構表 (支援多層級)
CREATE TABLE system_hierarchy (
    system_id INT AUTO_INCREMENT PRIMARY KEY,
    system_code VARCHAR(50) UNIQUE NOT NULL COMMENT '系統編碼',
    system_name VARCHAR(100) NOT NULL COMMENT '系統名稱',
    parent_system_id INT NULL COMMENT '父系統ID，NULL表示頂層系統',
    level_type ENUM('SYSTEM', 'SUBSYSTEM', 'COMPONENT') NOT NULL COMMENT '層級類型',
    applicable_vehicle_type SET('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '適用車輛類型',
    description TEXT,
    display_order INT DEFAULT 0 COMMENT '顯示順序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_system_id) REFERENCES system_hierarchy(system_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系統層級結構表';

-- 零件主表
CREATE TABLE parts (
    part_id INT AUTO_INCREMENT PRIMARY KEY,
    drawing_number VARCHAR(100) UNIQUE NOT NULL COMMENT '圖號/型號',
    part_name VARCHAR(200) NOT NULL COMMENT '零件名稱',
    specification TEXT COMMENT '規格說明',
    unit_price DECIMAL(12, 2) COMMENT '單價',
    unit VARCHAR(20) DEFAULT 'PCS' COMMENT '單位',
    critical_level ENUM('一般', '重要', '關鍵') DEFAULT '一般' COMMENT '重要程度',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='零件主資料表';

-- 系統零件關聯表 (記錄每個零件在哪些系統中使用及用量)
CREATE TABLE system_parts (
    system_part_id INT AUTO_INCREMENT PRIMARY KEY,
    system_id INT NOT NULL COMMENT '系統ID (可以是任何層級)',
    part_id INT NOT NULL COMMENT '零件ID',
    quantity_per_vehicle INT NOT NULL COMMENT '每輛車的用量',
    applicable_vehicle_type SET('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '適用車輛類型',
    installation_location VARCHAR(200) COMMENT '安裝位置描述',
    manual_reference VARCHAR(100) COMMENT 'Manual參考頁碼',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (system_id) REFERENCES system_hierarchy(system_id) ON DELETE RESTRICT,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_system_part_vehicle (system_id, part_id, applicable_vehicle_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系統零件關聯表';

-- 現有庫存位置表 (處理一個零件多個Stock Code的情況)
CREATE TABLE stock_locations (
    stock_location_id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT NOT NULL COMMENT '零件ID',
    stock_code VARCHAR(50) NOT NULL COMMENT '倉庫編號',
    quantity INT NOT NULL DEFAULT 0 COMMENT '庫存數量',
    location VARCHAR(100) COMMENT '存放位置',
    batch_info VARCHAR(100) COMMENT '批次資訊',
    status ENUM('使用中', '待合併', '已棄用') DEFAULT '使用中' COMMENT '編號狀態',
    is_primary BOOLEAN DEFAULT FALSE COMMENT '是否為主要編號',
    remarks TEXT COMMENT '備註 (用於記錄合併決策等)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_stock_code (stock_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='現有庫存位置表';

-- 供應商表
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(50) UNIQUE NOT NULL COMMENT '供應商編號',
    supplier_name VARCHAR(200) NOT NULL COMMENT '供應商名稱',
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    address TEXT,
    remarks TEXT,
    status ENUM('合作中', '已停用') DEFAULT '合作中',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供應商資料表';

-- 採購訂單表
CREATE TABLE procurement_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(50) UNIQUE NOT NULL COMMENT '採購單號',
    supplier_id INT NOT NULL COMMENT '供應商ID',
    order_date DATE NOT NULL COMMENT '採購日期',
    expected_delivery_date DATE COMMENT '預計到貨日期',
    actual_delivery_date DATE COMMENT '實際到貨日期',
    total_amount DECIMAL(15, 2) COMMENT '總金額',
    status ENUM('已下單', '部分到貨', '已到貨', '已取消') DEFAULT '已下單',
    remarks TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='採購訂單表';

-- 採購明細表
CREATE TABLE procurement_items (
    po_item_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL COMMENT '採購單ID',
    part_id INT NOT NULL COMMENT '零件ID',
    ordered_quantity INT NOT NULL COMMENT '採購數量',
    received_quantity INT DEFAULT 0 COMMENT '已到貨數量',
    unit_price DECIMAL(12, 2) NOT NULL COMMENT '採購單價',
    subtotal DECIMAL(15, 2) NOT NULL COMMENT '小計',
    expected_delivery_date DATE COMMENT '預計到貨日期',
    actual_delivery_date DATE COMMENT '實際到貨日期',
    status ENUM('待入庫', '部分入庫', '已入庫', '已取消') DEFAULT '待入庫',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (po_id) REFERENCES procurement_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='採購明細表';

-- 員工表 (用於記錄領用人)
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(50) UNIQUE NOT NULL COMMENT '員工編號',
    employee_name VARCHAR(100) NOT NULL COMMENT '員工姓名',
    department VARCHAR(100) COMMENT '部門',
    position VARCHAR(100) COMMENT '職位',
    phone VARCHAR(50),
    email VARCHAR(100),
    status ENUM('在職', '離職') DEFAULT '在職',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='員工資料表';

-- 零件分配表 (記錄零件的計劃分配)
CREATE TABLE parts_allocation (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT NOT NULL COMMENT '零件ID',
    source_type ENUM('現有庫存', '新採購') NOT NULL COMMENT '來源類型',
    source_id INT COMMENT '來源ID (stock_location_id 或 po_item_id)',
    allocated_quantity INT NOT NULL COMMENT '分配數量',
    allocation_purpose VARCHAR(200) COMMENT '分配用途說明',
    status ENUM('已計劃', '已預留', '已取消') DEFAULT '已計劃',
    allocated_date DATE COMMENT '分配日期',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='零件分配計劃表';

-- 零件使用記錄表 (實際領用/使用記錄)
CREATE TABLE parts_usage_records (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT NOT NULL COMMENT '零件ID',
    source_type ENUM('現有庫存', '新採購') NOT NULL COMMENT '來源類型',
    source_id INT COMMENT '來源ID',
    quantity INT NOT NULL COMMENT '領用/使用數量',
    usage_date DATE NOT NULL COMMENT '領用日期',
    employee_id INT COMMENT '領用人ID',
    usage_type ENUM('領用', '安裝使用', '測試消耗', '報廢') DEFAULT '領用',
    related_system_id INT COMMENT '相關系統ID',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id) ON DELETE RESTRICT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL,
    FOREIGN KEY (related_system_id) REFERENCES system_hierarchy(system_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='零件使用記錄表';

-- ============================================
-- 創建索引
-- ============================================

-- 車輛表索引
CREATE INDEX idx_vehicle_type ON vehicles(vehicle_type);
CREATE INDEX idx_train_set ON vehicles(train_set);

-- 系統層級索引
CREATE INDEX idx_parent_system ON system_hierarchy(parent_system_id);
CREATE INDEX idx_level_type ON system_hierarchy(level_type);

-- 零件表索引
CREATE INDEX idx_part_name ON parts(part_name);
CREATE INDEX idx_drawing_number ON parts(drawing_number);

-- 系統零件關聯索引
CREATE INDEX idx_system_parts_system ON system_parts(system_id);
CREATE INDEX idx_system_parts_part ON system_parts(part_id);

-- 庫存位置索引
CREATE INDEX idx_stock_part ON stock_locations(part_id);
CREATE INDEX idx_stock_status ON stock_locations(status);
CREATE INDEX idx_stock_primary ON stock_locations(is_primary);

-- 採購相關索引
CREATE INDEX idx_po_supplier ON procurement_orders(supplier_id);
CREATE INDEX idx_po_date ON procurement_orders(order_date);
CREATE INDEX idx_po_status ON procurement_orders(status);
CREATE INDEX idx_po_items_po ON procurement_items(po_id);
CREATE INDEX idx_po_items_part ON procurement_items(part_id);

-- 分配和使用記錄索引
CREATE INDEX idx_allocation_part ON parts_allocation(part_id);
CREATE INDEX idx_allocation_date ON parts_allocation(allocated_date);
CREATE INDEX idx_usage_part ON parts_usage_records(part_id);
CREATE INDEX idx_usage_date ON parts_usage_records(usage_date);
CREATE INDEX idx_usage_employee ON parts_usage_records(employee_id);
