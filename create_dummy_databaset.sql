-- Example database and tables creation script
CREATE TABLE IF NOT EXISTS public.created_table_2 (
	column1 varchar NULL,
	column2 varchar NULL
);
INSERT INTO public.created_table_2 (column1,column2) VALUES
	 ('C1R1','C2R1'),
	 ('C1R2','C2R2'),
	 ('C1R3','C2R3'),
	 ('C1R4','C2R4'),
	 ('C1R5','C2R5'),
	 (pg_catalog.concat('now: ',pg_catalog.clock_timestamp()),'C2R6'),
	 (pg_catalog.concat('db: ',pg_catalog.current_database()),'C2R7' ),
	 (pg_catalog.concat('schema: ',pg_catalog.current_schema()),'C2R8'),
	 (pg_catalog.concat('user: ',pg_catalog."current_user"()),'C2R9'),
	('C1R10','C2R10')
;