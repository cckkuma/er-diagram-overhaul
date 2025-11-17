
erDiagram
    PARTS {
        bigint part_id PK
        varchar part_number
        varchar part_name
        varchar unit
        numeric unit_price
        char(3) currency
        boolean is_stocked
    }
    SUPPLIERS {
        bigint supplier_id PK
        varchar supplier_code
        varchar name
        int lead_time_days
    }
    WAREHOUSES {
        bigint warehouse_id PK
        varchar warehouse_code
        varchar name
    }
    STOCK_ITEMS {
        bigint stock_id PK
        bigint part_id FK
        bigint warehouse_id FK
        varchar stock_code
        numeric qty_onhand
        numeric qty_reserved
    }
    SYSTEMS {
        smallint system_id PK
        varchar system_code
        varchar system_name
    }
    SUBSYSTEMS {
        bigint subsystem_id PK
        smallint system_id FK
        varchar subsystem_name
    }
    VEHICLES {
        bigint vehicle_id PK
        varchar vehicle_code
    }
    PART_USAGE_TEMPLATES {
        bigint usage_id PK
        bigint part_id FK
        bigint subsystem_id FK
        numeric qty_per_vehicle
    }
    PROJECTS {
        bigint project_id PK
        varchar name
    }
    PROJECT_VEHICLES {
        bigint id PK
        bigint project_id FK
        bigint vehicle_id FK
    }
    ALLOCATIONS {
        bigint allocation_id PK
        bigint project_id FK
        bigint part_id FK
        bigint subsystem_id FK
        bigint vehicle_id FK
        numeric qty_allocated
    }
    PURCHASE_ORDERS {
        bigint po_id PK
        bigint supplier_id FK
        date po_date
        varchar status
    }
    PO_LINES {
        bigint po_line_id PK
        bigint po_id FK
        bigint part_id FK
        numeric qty_ordered
        numeric unit_price
        varchar currency
    }
    GOODS_RECEIPTS {
        bigint gr_id PK
        bigint po_line_id FK
        bigint part_id FK
        bigint warehouse_id FK
        numeric qty_received
        date receipt_date
    }
    PRICE_HISTORY {
        bigint price_history_id PK
        bigint part_id FK
        bigint supplier_id FK
        numeric unit_price
        date effective_date
    }
    ALTERNATE_PARTS {
        bigint id PK
        bigint part_id FK
        bigint alternate_part_id FK
        varchar note
    }

    PARTS ||--o{ STOCK_ITEMS : "has"
    WAREHOUSES ||--o{ STOCK_ITEMS : "stores"
    PARTS ||--o{ PART_USAGE_TEMPLATES : "used in"
    SUBSYSTEMS ||--o{ PART_USAGE_TEMPLATES : "contains"
    SYSTEMS ||--o{ SUBSYSTEMS : "contains"
    PROJECTS ||--o{ PROJECT_VEHICLES : "includes"
    VEHICLES ||--o{ PROJECT_VEHICLES : "in"
    PROJECTS ||--o{ ALLOCATIONS : "requires"
    PARTS ||--o{ ALLOCATIONS : "allocated"
    SUBSYSTEMS ||--o{ ALLOCATIONS : "for"
    VEHICLES ||--o{ ALLOCATIONS : "for"
    SUPPLIERS ||--o{ PURCHASE_ORDERS : "supplies"
    PURCHASE_ORDERS ||--o{ PO_LINES : "has"
    PARTS ||--o{ PO_LINES : "orders"
    PO_LINES ||--o{ GOODS_RECEIPTS : "received by"
    PARTS ||--o{ PRICE_HISTORY : "has"
    PARTS ||--o{ ALTERNATE_PARTS : "has alt"
    PARTS ||--o{ GOODS_RECEIPTS : "recorded in"
    WAREHOUSES ||--o{ GOODS_RECEIPTS : "received into"
