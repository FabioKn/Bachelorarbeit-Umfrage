-- Supabase Schema Update: Questionnaire-Felder zu video_questionnaire hinzufügen
-- Diese Befehle in der Supabase-Konsole unter "SQL Editor" ausführen

-- 0. Zuerst die View löschen, um Konflikte zu vermeiden
DROP VIEW IF EXISTS participant_summary;

-- 1. Neue Spalten zur video_questionnaire Tabelle hinzufügen
ALTER TABLE video_questionnaire 
ADD COLUMN IF NOT EXISTS gs_known BOOLEAN,
ADD COLUMN IF NOT EXISTS vis_experience BIGINT CHECK (vis_experience >= 1 AND vis_experience <= 5),
ADD COLUMN IF NOT EXISTS been_to_library BOOLEAN,
ADD COLUMN IF NOT EXISTS freitext TEXT,
ADD COLUMN IF NOT EXISTS memorable_book TEXT,
ADD COLUMN IF NOT EXISTS shelf_levels BIGINT CHECK (shelf_levels >= 1 AND shelf_levels <= 20);

-- 2. Neue Spalten zur final_questionnaire Tabelle hinzufügen
ALTER TABLE final_questionnaire 
ADD COLUMN IF NOT EXISTS memorable_book_final TEXT,
ADD COLUMN IF NOT EXISTS shelf_levels_final BIGINT CHECK (shelf_levels_final >= 1 AND shelf_levels_final <= 20);

-- 3. Kommentare für bessere Dokumentation
COMMENT ON COLUMN video_questionnaire.gs_known IS 'Hat der Teilnehmer schon von Gaussian Splatting gehört?';
COMMENT ON COLUMN video_questionnaire.vis_experience IS '3D-Visualisierung Erfahrung (1-5 Skala)';
COMMENT ON COLUMN video_questionnaire.been_to_library IS 'War der Teilnehmer schon in der HTWK-Bibliothek?';
COMMENT ON COLUMN video_questionnaire.freitext IS 'Freitextfeld für zusätzliche Kommentare zum Vorwissen';
COMMENT ON COLUMN video_questionnaire.memorable_book IS 'Welches Buch ist dem Teilnehmer aufgefallen?';
COMMENT ON COLUMN video_questionnaire.shelf_levels IS 'Geschätzte Anzahl der Regalbretter (1-20)';

COMMENT ON COLUMN final_questionnaire.memorable_book_final IS 'Welches Buch ist dem Teilnehmer nach der Erkundung aufgefallen?';
COMMENT ON COLUMN final_questionnaire.shelf_levels_final IS 'Geschätzte Anzahl der Regalbretter nach der Erkundung (1-20)';

-- 4. View neu erstellen mit konsistenten Datentypen
CREATE OR REPLACE VIEW participant_summary AS
SELECT 
  p.id as participant_id,
  p.created_at as participation_date,
  
  -- Video-Fragebogen Daten (erweitert)
  vq.gs_known,
  vq.vis_experience,
  vq.been_to_library,
  vq.freitext,
  vq.spatial_understanding as video_spatial_understanding,
  vq.realism as video_realism,
  vq.notable_objects,
  vq.tables_seen,
  vq.memorable_book,
  vq.shelf_levels,
  vq.sofa_color,
  vq.quality as video_quality,
  vq.orientation_confidence as video_orientation_confidence,
  vq.additional_comments as video_additional_comments,
  
  -- Erkundung
  es.exploration_time,
  
  -- Finaler Fragebogen
  fq.understanding_difference,
  fq.interactive_benefits,
  fq.realism_interactive,
  fq.final_orientation,
  fq.mental_map,
  fq.room_length,
  fq.room_width,
  fq.room_height,
  fq.memorable_book_final,
  fq.shelf_levels_final,
  fq.sofa_position,
  fq.sofa_location,
  fq.navigation_ease,
  fq.technical_issues,
  fq.overall_rating,
  fq.final_comments,
  
  -- Legacy Questionnaire (falls noch verwendet)
  q.gs_known as legacy_gs_known,
  q.vis_experience as legacy_vis_experience,
  q.freitext as legacy_freitext
  
FROM participants p
LEFT JOIN video_questionnaire vq ON p.id = vq.participant_id
LEFT JOIN exploration_sessions es ON p.id = es.participant_id
LEFT JOIN final_questionnaire fq ON p.id = fq.participant_id
LEFT JOIN questionnaire q ON p.id = q.participant_id;

-- 5. Überprüfung der Tabellenstrukturen
SELECT 'video_questionnaire' as table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'video_questionnaire' 
UNION ALL
SELECT 'final_questionnaire' as table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'final_questionnaire' 
ORDER BY table_name, column_name;

-- Erfolgreiche Ausführung bestätigen
SELECT 'Beide Tabellen erfolgreich erweitert!' as status;
