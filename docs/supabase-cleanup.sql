-- Cleanup Script: Fehlerhafte Tabellen entfernen (falls nötig)
-- Nur ausführen, wenn die Tabellen bereits mit falschen Datentypen erstellt wurden

-- 1. Policies entfernen (falls vorhanden)
DROP POLICY IF EXISTS "Allow anonymous insert on video_questionnaire" ON video_questionnaire;
DROP POLICY IF EXISTS "Allow anonymous select on video_questionnaire" ON video_questionnaire;
DROP POLICY IF EXISTS "Allow anonymous insert on exploration_sessions" ON exploration_sessions;
DROP POLICY IF EXISTS "Allow anonymous select on exploration_sessions" ON exploration_sessions;
DROP POLICY IF EXISTS "Allow anonymous insert on final_questionnaire" ON final_questionnaire;
DROP POLICY IF EXISTS "Allow anonymous select on final_questionnaire" ON final_questionnaire;

-- 2. Views entfernen (falls vorhanden)
DROP VIEW IF EXISTS participant_summary;

-- 3. Indizes entfernen (falls vorhanden)
DROP INDEX IF EXISTS idx_video_questionnaire_participant_id;
DROP INDEX IF EXISTS idx_video_questionnaire_timestamp;
DROP INDEX IF EXISTS idx_exploration_sessions_participant_id;
DROP INDEX IF EXISTS idx_exploration_sessions_timestamp;
DROP INDEX IF EXISTS idx_final_questionnaire_participant_id;
DROP INDEX IF EXISTS idx_final_questionnaire_timestamp;

-- 4. Tabellen entfernen (falls vorhanden)
DROP TABLE IF EXISTS video_questionnaire CASCADE;
DROP TABLE IF EXISTS exploration_sessions CASCADE;
DROP TABLE IF EXISTS final_questionnaire CASCADE;

-- 5. Trigger-Funktion entfernen (falls vorhanden)
DROP FUNCTION IF EXISTS trigger_set_timestamp() CASCADE;

-- Bestätigung
SELECT 'Cleanup abgeschlossen! Jetzt das korrigierte Schema ausführen.' as status;
