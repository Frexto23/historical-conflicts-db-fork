ALTER TABLE casualty_report 
    ADD CONSTRAINT casualty_report_killed_nonnegative 
    CHECK (killed >= 0) NOT VALID;

ALTER TABLE casualty_report 
    ADD CONSTRAINT casualty_report_wounded_nonnegative 
    CHECK (wounded >= 0) NOT VALID;

ALTER TABLE casualty_report 
    ADD CONSTRAINT casualty_report_missing_nonnegative 
    CHECK (missing >= 0) NOT VALID;