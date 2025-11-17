-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(10) NOT NULL CHECK (vehicle_type IN ('SUT_A', 'SUT_B', 'MRV')),
    train_set VARCHAR(10),
    power_type VARCHAR(10) NOT NULL CHECK (power_type IN ('750DC', 'DIESEL')),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vehicles IS '車輛基本資料';
COMMENT ON COLUMN vehicles.vehicle_number IS '車輛編號: 001A, 001B, MRV001';
COMMENT ON COLUMN vehicles.vehicle_type IS '車輛類型';
COMMENT ON COLUMN vehicles.train_set IS '列車組號: 001, 002...';
COMMENT ON COLUMN vehicles.power_type IS '供能方式';
