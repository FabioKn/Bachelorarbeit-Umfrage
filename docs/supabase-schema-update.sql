-- Supabase Schema Update: Sofa-Position Fragen hinzufügen
-- Diese Befehle in der Supabase-Konsole unter "SQL Editor" ausführen
-- NUR NÖTIG, wenn final_questionnaire bereits OHNE die Sofa-Felder existiert

-- Neue Spalten zur final_questionnaire Tabelle hinzufügen
ALTER TABLE final_questionnaire 
ADD COLUMN IF NOT EXISTS sofa_position TEXT CHECK (sofa_position IN (
  'left', 'right', 'center', 'behind', 'unknown'
));

ALTER TABLE final_questionnaire 
ADD COLUMN IF NOT EXISTS sofa_location TEXT CHECK (sofa_location IN (
  'left_wall', 'right_wall', 'center', 'corner', 'unknown'
));

-- Kommentare zu den neuen Spalten hinzufügen
COMMENT ON COLUMN final_questionnaire.sofa_position IS 'Position des Sofas relativ zur Anfangsposition des Teilnehmers';
COMMENT ON COLUMN final_questionnaire.sofa_location IS 'Position des Sofas im Raum (absolute Position)';

-- View aktualisieren um neue Felder zu berücksichtigen
CREATE OR REPLACE VIEW participant_summary AS
SELECT 
  p.id as participant_id,
  p.created_at as participation_date,
  q.gs_known,
  q.vis_experience,
  vq.spatial_understanding as video_spatial_understanding,
  vq.realism as video_realism,
  vq.tables_seen,
  vq.sofa_color,
  es.exploration_time,
  fq.understanding_difference,
  fq.final_orientation,
  fq.sofa_position,  -- NEU
  fq.sofa_location,  -- NEU
  fq.overall_rating
FROM participants p
LEFT JOIN questionnaire q ON p.id = q.participant_id
LEFT JOIN video_questionnaire vq ON p.id = vq.participant_id
LEFT JOIN exploration_sessions es ON p.id = es.participant_id
LEFT JOIN final_questionnaire fq ON p.id = fq.participant_id;

-- Bestätigung der erfolgreichen Ausführung
SELECT 'Sofa-Position Spalten erfolgreich hinzugefügt!' as status;
