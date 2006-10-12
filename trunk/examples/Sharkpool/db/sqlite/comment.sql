CREATE TABLE comment (
    comment_id INTEGER PRIMARY KEY,
    article INTEGER REFERENCES article,
    title TEXT,
    author TEXT,
    url TEXT,
    email TEXT,
    content TEXT,
    creation_date INTEGER
);
