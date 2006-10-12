CREATE TABLE article (
  article_id CHAR(36) NOT NULL,
  title VARCHAR(100) NOT NULL,
  summary VARCHAR(250) NOT NULL,
  author VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  uri VARCHAR(112),
  creation_date INTEGER NOT NULL,
  modification_date INTEGER,
  publication_date INTEGER,
  expiration_date INTEGER,
  CONSTRAINT pk_article_id PRIMARY KEY (article_id)
) /*! ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_bin */;

CREATE UNIQUE INDEX idx_article_uri ON article (uri);
CREATE INDEX idx_article_publication_date ON article (publication_date);
CREATE INDEX idx_article_expiration_date ON article (expiration_date);
