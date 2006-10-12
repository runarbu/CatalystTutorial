-- ServerDB
-- SQLite table definitions
--
-- Andy Grundman
-- April 2005

-- The server table contains all server fields and is the parent table 
-- to all other tables in the database.
--
-- Note that these are just sample fields.  My real application contains
-- many more fields specific to the servers at the client site.
CREATE TABLE server (
	name VARCHAR(30) PRIMARY KEY,
	ip_address VARCHAR(15),
	country VARCHAR(2),
	state VARCHAR(2),
	owner VARCHAR(30),
	support_status VARCHAR(30)
);
CREATE INDEX server_ip ON server(ip_address);

-- The application table is a 1-to-many mapping containing a list
-- of applications on a server.
CREATE TABLE application (
	id INTEGER PRIMARY KEY,
	server VARCHAR(30) NOT NULL REFERENCES server,
	type VARCHAR(30),
	description TEXT
);

-- The support history table is a 1-to-many mapping containing a list
-- of support changes to a server.
CREATE TABLE support_history (
	id INTEGER PRIMARY KEY,
	server VARCHAR(30) NOT NULL REFERENCES server,
	type VARCHAR(30),
	date VARCHAR(10)
);

-- Users
CREATE TABLE user (
	id INTEGER PRIMARY KEY,
	username VARCHAR(30) NOT NULL,
	password VARCHAR(40) NOT NULL
);

-- Roles
CREATE TABLE role (
	id INTEGER PRIMARY KEY,
	name VARCHAR(30)
);

-- Mapping
CREATE TABLE user_role (
	id INTEGER PRIMARY KEY,
	user INTEGER REFERENCES user,
	role INTEGER REFERENCES role
);
	
	
