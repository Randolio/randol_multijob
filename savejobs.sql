CREATE TABLE IF NOT EXISTS `save_jobs` (
	`cid` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`job` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`grade` INT(11) NOT NULL
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;