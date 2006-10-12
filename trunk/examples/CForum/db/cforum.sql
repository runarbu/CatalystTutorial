CREATE TABLE forum (
  id INTEGER PRIMARY KEY,
  name text,
  description text
);

CREATE TABLE thread (
  id INTEGER PRIMARY KEY,
  forum INT REFERENCES forum,
  title VARCHAR(255),
  sticky BOOLEAN, 
  closed BOOLEAN
);

CREATE TABLE post (
  id INTEGER PRIMARY KEY,
  thread INT REFERENCES thread,
  author INT REFERENCES user,
  posted datetime,
  updated datetime,
  content TEXT
);

CREATE TABLE forumadmin (
  user INT REFERENCES user,
  forum INT REFERENCES forum,
  PRIMARY KEY (user, forum)
);

CREATE TABLE user (
  id INTEGER PRIAMRY KEY,
  login varchar(100),
  password varchar(100),
  email varchar(255)
);
