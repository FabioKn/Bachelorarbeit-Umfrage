-- Supabase SQL Schema für erweiterte Bachelorarbeit-Umfrage
-- Diese Befehle in der Supabase-Konsole unter "SQL Editor" ausführen

-- 1. Erweiterte Video-Fragebogen Tabelle
CREATE TABLE IF NOT EXISTS video_questionnaire (
  id BIGSERIAL PRIMARY KEY,
  participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
  spatial_understanding INTEGER NOT NULL CHECK (spatial_understanding >= 1 AND spatial_understanding <= 5),
  realism INTEGER NOT NULL CHECK (realism >= 1 AND realism <= 5),
  notable_objects TEXT,
  tables_seen INTEGER CHECK (tables_seen >= 0),
  sofa_color TEXT,
  quality INTEGER NOT NULL CHECK (quality >= 1 AND quality <= 5),
  orientation_confidence INTEGER NOT NULL CHECK (orientation_confidence >= 1 AND orientation_confidence <= 5),
  additional_comments TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Erkundungssitzungen Tabelle
CREATE TABLE IF NOT EXISTS exploration_sessions (
  id BIGSERIAL PRIMARY KEY,
  participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
  exploration_time BIGINT NOT NULL, -- Zeit in Millisekunden
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Finaler Fragebogen Tabelle
CREATE TABLE IF NOT EXISTS final_questionnaire (
  id BIGSERIAL PRIMARY KEY,
  participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
  
  -- Vergleich Video vs. Interaktiv
  understanding_difference TEXT NOT NULL CHECK (understanding_difference IN (
    'much_better_interactive', 'better_interactive', 'no_difference', 
    'better_video', 'much_better_video'
  )),
  interactive_benefits TEXT[], -- Array von Vorteilen
  realism_interactive INTEGER NOT NULL CHECK (realism_interactive >= 1 AND realism_interactive <= 10),
  
  -- Räumliche Kognition
  final_orientation INTEGER NOT NULL CHECK (final_orientation >= 1 AND final_orientation <= 5),
  mental_map INTEGER NOT NULL CHECK (mental_map >= 1 AND mental_map <= 5),
  room_length INTEGER CHECK (room_length > 0),
  room_width INTEGER CHECK (room_width > 0),
  room_height INTEGER CHECK (room_height > 0),
  
  -- Sofa-Position Fragen (neu hinzugefügt)
  sofa_position TEXT CHECK (sofa_position IN (
    'left', 'right', 'center', 'behind', 'unknown'
  )),
  sofa_location TEXT CHECK (sofa_location IN (
    'left_wall', 'right_wall', 'center', 'corner', 'unknown'
  )),
  
  -- Benutzererfahrung
  navigation_ease INTEGER NOT NULL CHECK (navigation_ease >= 1 AND navigation_ease <= 5),
  technical_issues TEXT[], -- Array von technischen Problemen
  
  -- Abschließende Bewertung
  overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 10),
  final_comments TEXT,
  
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Row Level Security (RLS) aktivieren
ALTER TABLE video_questionnaire ENABLE ROW LEVEL SECURITY;
ALTER TABLE exploration_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE final_questionnaire ENABLE ROW LEVEL SECURITY;

-- 5. Policies für anonymen Zugriff (wie bei den bestehenden Tabellen)
CREATE POLICY "Allow anonymous insert on video_questionnaire" ON video_questionnaire
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on video_questionnaire" ON video_questionnaire
  FOR SELECT USING (true);

CREATE POLICY "Allow anonymous insert on exploration_sessions" ON exploration_sessions
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on exploration_sessions" ON exploration_sessions
  FOR SELECT USING (true);

CREATE POLICY "Allow anonymous insert on final_questionnaire" ON final_questionnaire
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on final_questionnaire" ON final_questionnaire
  FOR SELECT USING (true);

-- 6. Indizes für bessere Performance
CREATE INDEX IF NOT EXISTS idx_video_questionnaire_participant_id ON video_questionnaire(participant_id);
CREATE INDEX IF NOT EXISTS idx_video_questionnaire_timestamp ON video_questionnaire(timestamp);

CREATE INDEX IF NOT EXISTS idx_exploration_sessions_participant_id ON exploration_sessions(participant_id);
CREATE INDEX IF NOT EXISTS idx_exploration_sessions_timestamp ON exploration_sessions(timestamp);

CREATE INDEX IF NOT EXISTS idx_final_questionnaire_participant_id ON final_questionnaire(participant_id);
CREATE INDEX IF NOT EXISTS idx_final_questionnaire_timestamp ON final_questionnaire(timestamp);

-- 7. Trigger für automatische Zeitstempel-Updates (optional)
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Views für Analytics (optional - für spätere Auswertung)
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
  fq.sofa_position,
  fq.sofa_location,
  fq.overall_rating
FROM participants p
LEFT JOIN questionnaire q ON p.id = q.participant_id
LEFT JOIN video_questionnaire vq ON p.id = vq.participant_id
LEFT JOIN exploration_sessions es ON p.id = es.participant_id
LEFT JOIN final_questionnaire fq ON p.id = fq.participant_id;

-- Erfolgreiche Ausführung bestätigen
SELECT 'Alle Tabellen und Policies erfolgreich erstellt!' as status;
