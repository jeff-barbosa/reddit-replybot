PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE defined_terms(id INT AUTO_INCREMENT, term VARCHAR(80), definition TEXT, PRIMARY KEY(id));
COMMIT;