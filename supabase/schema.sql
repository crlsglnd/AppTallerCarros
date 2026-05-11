-- Supabase Schema for Taller de Carros

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: clientes
CREATE TABLE clientes (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    email TEXT,
    telefono TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: vehiculos
CREATE TABLE vehiculos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id TEXT REFERENCES clientes(id) ON DELETE CASCADE,
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    placa TEXT NOT NULL UNIQUE,
    anio INTEGER,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: ordenes_trabajo
CREATE TABLE ordenes_trabajo (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
    descripcion TEXT NOT NULL,
    estado TEXT NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'en_progreso', 'completada'
    fecha_ingreso TIMESTAMP WITH TIME ZONE,
    fecha_entrega TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: cotizaciones
CREATE TABLE cotizaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
    costo_mano_obra NUMERIC NOT NULL DEFAULT 0.0,
    metodo_pago TEXT NOT NULL DEFAULT 'efectivo', -- 'efectivo', 'tarjeta'
    porcentaje_recargo_tarjeta NUMERIC NOT NULL DEFAULT 0.0,
    total_calculado NUMERIC NOT NULL DEFAULT 0.0,
    estado TEXT NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'aceptada', 'declinada'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: cotizacion_detalles (Repuestos por cotizacion)
CREATE TABLE cotizacion_detalles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cotizacion_id UUID REFERENCES cotizaciones(id) ON DELETE CASCADE,
    descripcion TEXT NOT NULL,
    costo NUMERIC NOT NULL DEFAULT 0.0
);

-- Table: proveedores
CREATE TABLE proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    telefono TEXT,
    entrega_domicilio BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: repuestos_referencia (Base de conocimiento)
CREATE TABLE repuestos_referencia (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    marca_aplicable TEXT NOT NULL,
    modelo_aplicable TEXT NOT NULL,
    anios_aplicables TEXT NOT NULL,
    precio_referencia NUMERIC NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: configuracion_taller
CREATE TABLE configuracion_taller (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dia_semana TEXT NOT NULL, -- 0=Lunes, 1=Martes, ..., 6=Domingo
    max_ingresos_diarios INTEGER NOT NULL DEFAULT 5,
    hora_apertura TIME NOT NULL DEFAULT '08:00',
    hora_cierre TIME NOT NULL DEFAULT '17:00',
    esta_abierto BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(dia_semana)
);

-- Insertar configuración por defecto (Lunes a Viernes abierto, Sábado medio día, Domingo cerrado)
INSERT INTO configuracion_taller (dia_semana, max_ingresos_diarios, hora_apertura, hora_cierre, esta_abierto) VALUES 
('Lunes', 5, '08:00', '17:00', TRUE), -- Lunes
('Martes', 5, '08:00', '17:00', TRUE), -- Martes
('Miércoles', 5, '08:00', '17:00', TRUE), -- Miércoles
('Jueves', 5, '08:00', '17:00', TRUE), -- Jueves
('Viernes', 5, '08:00', '17:00', TRUE), -- Viernes
('Sábado', 3, '08:00', '12:00', TRUE), -- Sábado
('Domingo', 0, '00:00', '00:00', FALSE); -- Domingo


