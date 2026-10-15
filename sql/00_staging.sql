-- ============================================================
-- PROJECT: PlayLoop Main KPIs Analysis
-- Phase 1: staging
-- ============================================================

-- How to Run the Staging Script
--  1. Connect to the database
-- psql -h localhost -U postgres -d brightcart
--  2. Run the script
-- \i sql/00_staging.sql

-- Date format 
SET datestyle = 'ISO, YMD';


DROP TABLE IF EXISTS ad_revenue; 
CREATE TABLE ad_revenue(
	id			BIGINT,
	user_id		BIGINT, 
	fecha 		DATE,
	tipo_ad		VARCHAR, 
	red_ad		VARCHAR, 
	ingreso		DOUBLE PRECISION
);

\copy ad_revenue FROM 'data/processed/ad_revenue.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE IF EXISTS iap_products; 
CREATE TABLE iap_products(
	product_id		BIGINT, 
	nombre			VARCHAR, 
	tipo			VARCHAR,
	precio_base		VARCHAR, 
	monedas			DOUBLE PRECISION
);
\copy iap_products FROM 'data/processed/iap_products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE IF EXISTS matches; 
CREATE TABLE matches(
	partida_id		BIGINT, 
	user_id			BIGINT, 
	nivel			INTEGER, 
	fecha			DATE, 
	resultado		VARCHAR, 
	movimientos		INTEGER, 
	boosters_usaros	DOUBLE PRECISION
);

\copy matches FROM 'data/processed/matches.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')


DROP TABLE purchases; 
CREATE TABLE purchases(
	compra_id		BIGINT, 
	user_id			BIGINT, 
	producto_id		BIGINT, 
	fecha			DATE, 
	importe			DOUBLE PRECISION, 
	moneda			VARCHAR, 
	plataforma		VARCHAR, 
	reembolso		NUMERIC
);

\copy purchases FROM 'data/processed/purchases.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE sessions; 
CREATE TABLE sessions(
	evento_id 			BIGINT, 
	user_id				BIGINT, 
	fecha 				DATE, 
	duracion_segundos	INTEGER, 
	platforma			VARCHAR
);

\copy sessions FROM 'data/processed/sessions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE ua_spend; 
CREATE TABLE ua_spend(
	canal				VARCHAR, 
	fecha				DATE, 
	gasto				DOUBLE PRECISION, 
	instalaciones		INTEGER, 	
	impresiones			INTEGER, 
	clics				DOUBLE PRECISION
);

\copy ua_spend FROM 'data/processed/ua_spend.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE users;
CREATE TABLE users(
	user_id 			BIGINT, 
	fecha_instalacion	DATE,
	canal_adquisicion	VARCHAR,
	pais				VARCHAR, 
	plataforma			VARCHAR, 
	version_app			VARCHAR
);

\copy users FROM 'data/processed/users.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')
