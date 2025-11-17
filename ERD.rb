# schema_definition.rb
# 資料庫結構定義

class Customer
  # 客戶資料表
  attr_accessor :customer_id    # Primary Key
  attr_accessor :name           # 客戶姓名
  attr_accessor :email          # 電子郵件
  attr_accessor :phone          # 電話號碼
  
  # 關聯
  has_many :orders
  has_many :delivery_addresses
end

class Order
  # 訂單資料表
  attr_accessor :order_id       # Primary Key
  attr_accessor :customer_id    # Foreign Key
  attr_accessor :order_date     # 訂單日期
  attr_accessor :total_amount   # 總金額
  
  # 關聯
  belongs_to :customer
  has_many :line_items
end

class LineItem
  # 訂單明細資料表
  attr_accessor :line_id        # Primary Key
  attr_accessor :order_id       # Foreign Key
  attr_accessor :product_id     # Foreign Key
  attr_accessor :quantity       # 數量
  attr_accessor :price          # 價格
  
  # 關聯
  belongs_to :order
  belongs_to :product
end

class Product
  # 產品資料表
  attr_accessor :product_id     # Primary Key
  attr_accessor :product_name   # 產品名稱
  attr_accessor :unit_price     # 單價
  attr_accessor :stock_quantity # 庫存數量
  
  # 關聯
  has_many :line_items
end

class DeliveryAddress
  # 配送地址資料表
  attr_accessor :address_id     # Primary Key
  attr_accessor :customer_id    # Foreign Key
  attr_accessor :street         # 街道
  attr_accessor :city           # 城市
  attr_accessor :postal_code    # 郵遞區號
  
  # 關聯
  belongs_to :customer
end

# ER 關聯圖說明：
# Customer 1 --- * Order (一對多)
# Order 1 --- * LineItem (一對多)
# Product 1 --- * LineItem (一對多)
# Customer 1 --- * DeliveryAddress (一對多)
