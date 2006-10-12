-- Sample data for ServerDB

-- Server(s)
-- Random server data can be generated and inserted by running:
-- script/createServers.pl

-- Users (pass: 12345)
REPLACE INTO user VALUES (1, 'admin', '8cb2237d0679ca88db6464eac60da96345513964');
REPLACE INTO user VALUES (2, 'user', '8cb2237d0679ca88db6464eac60da96345513964');

-- Roles
REPLACE INTO role VALUES (1, 'admin');

-- User Roles
REPLACE INTO user_role VALUES (1, 1, 1);

-- Some test history
REPLACE INTO support_history VALUES (1, 'ADLAB6500', 'Full Support', '2005-04-12');
