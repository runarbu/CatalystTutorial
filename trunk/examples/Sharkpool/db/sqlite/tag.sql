CREATE TABLE tag (
    tag_id INTEGER PRIMARY KEY,
    article INTEGER REFERENCES article,
    name TEXT
);
