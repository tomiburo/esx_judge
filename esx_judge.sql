INSERT INTO `addon_account` (name, label, shared) VALUES
    ('society_judge', 'Sodnik', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_judge','Sodnik',1)
;

INSERT INTO `jobs` (name, label, whitelisted) VALUES
    ('judge', 'Sodnik', 1)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
    ('judge',0,'recruit','Pripravnik', 20,'{}','{}'),
    ('judge',1,'officer','Izkusen', 40,'{}','{}'),
    ('judge',2,'boss','Sef', 60,'{}','{}')
;