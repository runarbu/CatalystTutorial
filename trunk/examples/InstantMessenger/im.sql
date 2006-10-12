
CREATE TABLE messages (
  message_id INTEGER PRIMARY KEY AUTOINCREMENT,
  author TEXT NOT NULL,
  content TEXT NOT NULL,
  posted INTEGER NOT NULL
);

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  session_data TEXT NOT NULL,
  expires INTEGER NOT NULL
);

