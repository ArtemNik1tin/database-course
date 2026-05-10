DROP TABLE IF EXISTS Rentals_Item;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Bindings;
DROP TABLE IF EXISTS Boots;
DROP TABLE IF EXISTS Snowboards;
DROP TABLE IF EXISTS Brands;

CREATE TABLE Brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Snowboards (
  	snowboard_id SERIAL PRIMARY KEY,
  	brand_id INTEGER REFERENCES Brands(brand_id),
  	snowboard_length INTEGER CHECK(snowboard_length BETWEEN 80 AND 200) NOT NULL,
  	is_wide BOOLEAN NOT NULL,
  	model VARCHAR(50) NOT NULL,
  	year_of_release DATE NOT NULL,
  	mounting_orientation CHAR(1) CHECK (mounting_orientation IN ('L', 'R')) NOT NULL
);

CREATE TABLE Boots (
  	boots_id SERIAL PRIMARY KEY,
  	brand_id INTEGER REFERENCES Brands(brand_id),
  	foot_size INTEGER CHECK(foot_size BETWEEN 20 AND 50) NOT NULL,
  	model VARCHAR(50) NOT NULL,
  	year_of_release DATE NOT NULL,
  	sex CHAR(1) CHECK (sex IN ('M', 'W'))
);

CREATE TABLE Bindings (
  	binding_id SERIAL PRIMARY KEY,
  	brand_id INTEGER REFERENCES Brands(brand_id),
  	binding_size VARCHAR(2) CHECK (binding_size IN ('S', 'M', 'L', 'XL')) NOT NULL,
  	year_of_release DATE NOT NULL
);

CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL
);

CREATE TABLE Rentals (
    rental_id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES Clients(client_id),
    rental_date TIMESTAMP NOT NULL,
  	return_date TIMESTAMP CHECK (return_date >= rental_date) NOT NULL
);

CREATE TABLE Rentals_Item (
    rental_item_id SERIAL PRIMARY KEY,
    rental_id INTEGER REFERENCES Rentals(rental_id),
  	snowboard_id INTEGER REFERENCES Snowboards(snowboard_id),
  	boots_id INTEGER REFERENCES Boots(boots_id),
  	binding_id INTEGER REFERENCES Bindings(binding_id)
);