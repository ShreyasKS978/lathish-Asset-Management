-- Create the database only if it doesn't exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'asset_management') THEN
      CREATE DATABASE asset_management;
   END IF;
END
$$;

-- Connect to the database
\connect asset_management

-- Create the requests table safely
CREATE TABLE IF NOT EXISTS requests (
    id BIGSERIAL PRIMARY KEY,
    employee_id VARCHAR(7) NOT NULL CHECK (employee_id ~ '^ATS0(?!000)\d{3}$'),
    asset_type VARCHAR(50) NOT NULL CHECK (asset_type IN (
        'laptop', 'monitor', 'keyboard', 'mouse', 
        'headphones', 'chair', 'phone', 'tablet'
    )),
    reason TEXT NOT NULL CHECK (
        reason ~ '^[A-Za-z0-9\s.,?@&()[\]\\|/\''"]+$'
        AND LENGTH(reason) >= 5
    ),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'approved', 'rejected')
    ),
    request_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_update_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    CONSTRAINT unique_active_request UNIQUE (employee_id, asset_type, request_date, is_active)
);

-- Create indexes only if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = 'idx_requests_employee_id'
    ) THEN
        CREATE INDEX idx_requests_employee_id ON requests(employee_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = 'idx_requests_status'
    ) THEN
        CREATE INDEX idx_requests_status ON requests(status);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = 'idx_requests_request_date'
    ) THEN
        CREATE INDEX idx_requests_request_date ON requests(request_date);
    END IF;
END
$$;
