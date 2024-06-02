CREATE SCHEMA IF NOT EXISTS dwh;

DROP TABLE IF EXISTS dwh.subjects;
CREATE TABLE dwh.subjects (
    subject_id VARCHAR(64),
    subject_number VARCHAR(126),
    subject VARCHAR(997),
    address VARCHAR(997),
    details VARCHAR(10485760),
    affiliation VARCHAR(126),
    visitor VARCHAR(126),
    contact_to VARCHAR(126),
    enter_at TIMESTAMP,
    work_at TIMESTAMP,
    end_at TIMESTAMP,
    exit_at TIMESTAMP,
    results VARCHAR(10485760),
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subject_id)
);

DROP TABLE IF EXISTS dwh.objects;
CREATE TABLE dwh.objects (
    subject_id VARCHAR(64),
    object_id VARCHAR(64),
    category VARCHAR(1),
    object_type VARCHAR(2),
    object_name VARCHAR(126),
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subject_id, object_id)
);

CREATE ROLE apache PASSWORD 'vagrant' LOGIN;
GRANT SELECT ON TABLE dwh.subjects, dwh.objects TO apache;

CREATE ROLE remote PASSWORD 'vagrant' LOGIN;
GRANT ALL PRIVILEGES ON SCHEMA dwh TO remote;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dwh TO remote;
