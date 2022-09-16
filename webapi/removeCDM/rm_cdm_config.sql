\connect "OHDSI";


DELETE FROM ohdsi.source_daimon WHERE source_id IN 
  (SELECT source_id FROM ohdsi.source WHERE source_key='MY_CDM');

DELETE FROM ohdsi.source WHERE source_key='MY_CDM';







