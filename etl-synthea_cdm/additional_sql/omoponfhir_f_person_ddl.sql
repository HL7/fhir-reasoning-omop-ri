create table @cdmSchema.f_person
(
    person_id          integer not null
	constraint f_person_pk
		primary key,
    family_name        varchar(255),
    given1_name        varchar(255),
    given2_name        varchar(255),
    prefix_name        varchar(255),
    suffix_name        varchar(255),
    preferred_language varchar(255),
    ssn                varchar(12),
    active             smallint,
    contact_point1     varchar(255),
    contact_point2     varchar(255),
    contact_point3     varchar(255),
    maritalstatus      varchar(255)
);
