
CREATE TABLE role (
  role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name TEXT UNIQUE NOT NULL
);

CREATE TABLE branch (
  branch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL
);

CREATE TABLE category (
  category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE supplier (
  supplier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  address TEXT NOT NULL
);

-- 2. IDENTITY & USERS
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id UUID REFERENCES role(role_id) ON DELETE SET NULL,
  username TEXT UNIQUE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE employee (
  employee_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES branch(branch_id) ON DELETE SET NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  position TEXT,
  salary NUMERIC(10,2),
  hire_date DATE
);

CREATE TABLE customer (
  customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone TEXT,
  email TEXT UNIQUE NOT NULL,
  default_shipping_address TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. HR OPERATIONS
CREATE TABLE attendance (
  attendance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
  date DATE NOT NULL,
  check_in TIMESTAMPTZ,
  check_out TIMESTAMPTZ,
  status TEXT
);

CREATE TABLE salary_record (
  salary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
  month DATE NOT NULL,
  basic_salary NUMERIC(10,2) NOT NULL,
  bonus NUMERIC(10,2) DEFAULT 0.00,
  deduction NUMERIC(10,2) DEFAULT 0.00,
  net_salary NUMERIC(10,2) NOT NULL
);

-- 4. PRODUCTS & INVENTORY
CREATE TABLE product (
  product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES category(category_id) ON DELETE SET NULL,
  supplier_id UUID REFERENCES supplier(supplier_id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'active'
);

CREATE TABLE product_variant (
  variant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES product(product_id) ON DELETE CASCADE,
  sku TEXT UNIQUE NOT NULL,
  size TEXT NOT NULL,
  color TEXT NOT NULL,
  price_adjustment NUMERIC(10,2) DEFAULT 0.00
);

CREATE TABLE inventory (
  inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_id UUID REFERENCES product_variant(variant_id) ON DELETE CASCADE,
  branch_id UUID REFERENCES branch(branch_id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 0,
  reorder_level INTEGER DEFAULT 10,
  last_updated TIMESTAMPTZ DEFAULT now()
);

-- 5. SHOPPING & CHECKOUT
CREATE TABLE cart (
  cart_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customer(customer_id) ON DELETE CASCADE,
  session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE cart_item (
  cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID REFERENCES cart(cart_id) ON DELETE CASCADE,
  variant_id UUID REFERENCES product_variant(variant_id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1
);

CREATE TABLE orders ( 
  order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customer(customer_id) ON DELETE SET NULL,
  employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
  branch_id UUID REFERENCES branch(branch_id) ON DELETE SET NULL,
  order_date TIMESTAMPTZ DEFAULT now(),
  total_amount NUMERIC(10,2) NOT NULL,
  payment_method TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  order_status TEXT DEFAULT 'pending'
);

CREATE TABLE order_item (
  order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  variant_id UUID REFERENCES product_variant(variant_id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL
);

-- 6. FULFILLMENT & SUPPLY CHAIN
CREATE TABLE delivery (
  delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  assigned_employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
  delivery_status TEXT DEFAULT 'pending',
  delivered_at TIMESTAMPTZ
);

CREATE TABLE notification (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customer(customer_id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT now(),
  status TEXT DEFAULT 'sent'
);

CREATE TABLE purchase_order (
  purchase_order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id UUID REFERENCES supplier(supplier_id) ON DELETE SET NULL,
  employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
  order_date TIMESTAMPTZ DEFAULT now(),
  status TEXT DEFAULT 'requested',
  total_amount NUMERIC(10,2) NOT NULL
);

CREATE TABLE purchase_order_item (
  po_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id UUID REFERENCES purchase_order(purchase_order_id) ON DELETE CASCADE,
  variant_id UUID REFERENCES product_variant(variant_id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  cost_price NUMERIC(10,2) NOT NULL
);