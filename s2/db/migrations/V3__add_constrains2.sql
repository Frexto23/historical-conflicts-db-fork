ALTER TABLE battle 
    ADD CONSTRAINT battle_intensity_range 
    CHECK (intensity BETWEEN 0 AND 10) NOT VALID;

ALTER TABLE military_unit 
    ADD CONSTRAINT military_unit_size_positive 
    CHECK (size >= 0) NOT VALID;