CREATE TABLE IF NOT EXISTS inventory (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100),
    stock_level INT,
    weekly_usage INT,
    weeks_cover GENERATED ALWAYS AS (stock_level / NULLIF(weekly_usage, 0)) STORED
);

CREATE TABLE IF NOT EXISTS agent_feedback (
    id SERIAL PRIMARY KEY,
    entity VARCHAR(100),
    rule VARCHAR(100),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Data
INSERT INTO inventory (product_id, product_name, stock_level, weekly_usage) VALUES
('Microchip X', 'High Performance Microcontroller', 200, 100), -- 2 weeks cover
('Resistor Y', 'Standard Resistor', 10000, 500), -- 20 weeks cover
('Capacitor Z', 'Ceramic Capacitor', 5000, 200) -- 25 weeks cover
ON CONFLICT (product_id) DO NOTHING;
