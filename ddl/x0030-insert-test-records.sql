
INSERT INTO dwh.subjects (
    subject_id, subject_number, subject, address, details,
    affiliation, visitor, contact_to,
    enter_at, work_at, end_at, exit_at, results
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
;

INSERT INTO dwh.objects (
    subject_id, object_id, category, object_type, object_name
) VALUES (?, ?, ?, ?, ?)
;
