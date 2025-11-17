
-- ========================================
-- 1. 客戶資料表 (Customers)
-- ========================================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '客戶ID',
    name VARCHAR(100) NOT NULL COMMENT '客戶姓名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '電子郵件',
    phone VARCHAR(20) COMMENT '聯絡電話',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    INDEX idx_email (email),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客戶資料表';

-- ========================================
-- 2. 產品資料表 (Products)
-- ========================================
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '產品ID',
    product_name VARCHAR(200) NOT NULL COMMENT '產品名稱',
    description TEXT COMMENT '產品描述',
    unit_price DECIMAL(10, 2) NOT NULL COMMENT '單價',
    stock_quantity INT DEFAULT 0 COMMENT '庫存數量',
    category VARCHAR(50) COMMENT '產品類別',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否啟用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    INDEX idx_product_name (product_name),
    INDEX idx_category (category),
    CHECK (unit_price >= 0),
    CHECK (stock_quantity >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='產品資料表';

-- ========================================
-- 3. 訂單資料表 (Orders)
-- ========================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '訂單ID',
    customer_id INT NOT NULL COMMENT '客戶ID',
    order_date DATE NOT NULL COMMENT '訂單日期',
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '訂單總金額',
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') 
        DEFAULT 'pending' COMMENT '訂單狀態',
    payment_method VARCHAR(50) COMMENT '付款方式',
    shipping_fee DECIMAL(10, 2) DEFAULT 0 COMMENT '運費',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status),
    CHECK (total_amount >= 0),
    CHECK (shipping_fee >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='訂單資料表';

-- ========================================
-- 4. 訂單明細資料表 (Line Items)
-- ========================================
CREATE TABLE line_items (
    line_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '訂單明細ID',
    order_id INT NOT NULL COMMENT '訂單ID',
    product_id INT NOT NULL COMMENT '產品ID',
    quantity INT NOT NULL COMMENT '數量',
    unit_price DECIMAL(10, 2) NOT NULL COMMENT '單價',
    subtotal DECIMAL(10, 2) NOT NULL COMMENT '小計',
    discount DECIMAL(10, 2) DEFAULT 0 COMMENT '折扣金額',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id),
    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (subtotal >= 0),
    CHECK (discount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='訂單明細資料表';

-- ========================================
-- 5. 配送地址資料表 (Delivery Addresses)
-- ========================================
CREATE TABLE delivery_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '地址ID',
    customer_id INT NOT NULL COMMENT '客戶ID',
    recipient_name VARCHAR(100) NOT NULL COMMENT '收件人姓名',
    phone VARCHAR(20) NOT NULL COMMENT '聯絡電話',
    street VARCHAR(200) NOT NULL COMMENT '街道地址',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    state VARCHAR(50) COMMENT '州/省',
    postal_code VARCHAR(20) NOT NULL COMMENT '郵遞區號',
    country VARCHAR(50) DEFAULT 'Taiwan' COMMENT '國家',
    is_default BOOLEAN DEFAULT FALSE COMMENT '是否為預設地址',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_postal_code (postal_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配送地址資料表';
