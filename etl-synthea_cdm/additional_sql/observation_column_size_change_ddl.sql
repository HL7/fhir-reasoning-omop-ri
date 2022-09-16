alter table @cdmSchema.observation alter column observation_source_value type varchar(500) using observation_source_value::varchar(500);
alter table @cdmSchema.observation alter column value_as_string type varchar(500) using value_as_string::varchar(500);
