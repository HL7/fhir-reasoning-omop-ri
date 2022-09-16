create view @cdmSchema.f_immunization_view
            (immunization_id,
             person_id,
             immunization_concept_id,
             immunization_date,
             immunization_datetime,
             immunization_type_concept_id,
             immunization_status,
             provider_id,
             visit_occurrence_id,
             lot_number,
             route_concept_id,
             quantity,
             immunization_note)
as

SELECT d.drug_exposure_id              AS immunization_id,
       d.person_id,
       d.drug_concept_id               AS immunization_concept_id,
       d.drug_exposure_start_date      AS immunization_date,
       d.drug_exposure_start_datetime  AS immunization_datetime,
       d.drug_type_concept_id          AS immunization_type_concept_id,
       d.stop_reason                   AS immunization_status,
       d.provider_id,
       d.visit_occurrence_id,
       d.lot_number,
       d.route_concept_id,
       d.quantity,
       d.sig                          AS immunization_note
FROM @cdmSchema.drug_exposure d
JOIN @cdmSchema.concept c on d.drug_concept_id = c.concept_id
WHERE (c.vocabulary_id in ('NDC','RxNorm','CPT4','HCPCS')
                AND c.concept_class_id not in ('CPT4 Modifier','CPT4 Hierarchy','HCPCS Class','HCPCS Modifier', 'Place of Service')
                AND (
                    lower(c.concept_name) like ('%vacc%') OR
                    lower(c.concept_name) like ('%immuniz%') OR
                    lower(c.concept_name) like ('%toxoid%')
                    )
                AND c.domain_id = 'Drug')
          OR c.vocabulary_id in ('CVX')
UNION ALL
SELECT (p.procedure_occurrence_id) AS immunization_id,
       p.person_id,
       p.procedure_concept_id      AS immunization_concept_id,
       p.procedure_date            AS immunization_date,
       p.procedure_datetime        AS immunization_datetime,
       p.procedure_type_concept_id AS immunization_type_concept_id,
       NULL                                           AS immunization_status,
       p.provider_id,
       p.visit_occurrence_id,
       NULL                                           AS lot_number,
       NULL                                           AS route_concept_id,
       p.quantity,
       NULL                                           AS immunization_note
FROM @cdmSchema.procedure_occurrence p
JOIN @cdmSchema.concept c on p.procedure_concept_id = c.concept_id
WHERE (c.vocabulary_id in ('NDC','RxNorm','CPT4','HCPCS')
                AND c.concept_class_id not in ('CPT4 Modifier','CPT4 Hierarchy','HCPCS Class','HCPCS Modifier', 'Place of Service')
                AND (
                    lower(c.concept_name) like ('%vacc%') OR
                    lower(c.concept_name) like ('%immuniz%') OR
                    lower(c.concept_name) like ('%toxoid%')
                    )
                AND c.domain_id = 'Drug')
          OR c.vocabulary_id in ('CVX')
;