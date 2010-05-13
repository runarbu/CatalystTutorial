--
-- Add 'created' and 'updated' columns to 'book' table.
--
ALTER TABLE book ADD created INTEGER;
ALTER TABLE book ADD updated INTEGER;
UPDATE book SET created = DATETIME('NOW'), updated = DATETIME('NOW');
