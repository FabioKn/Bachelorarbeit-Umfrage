# Supabase Setup Anleitung

## 🗄️ Datenbank-Schema für erweiterte Bachelorarbeit-Umfrage

### Schritt 1: Supabase-Konsole öffnen
1. Gehe zu [supabase.com](https://supabase.com)
2. Logge dich in dein Projekt ein
3. Navigiere zu **"SQL Editor"** im linken Menü

### Schritt 2: Schema ausführen
1. Öffne die Datei `supabase-schema.sql`
2. Kopiere den gesamten Inhalt
3. Füge ihn in den SQL Editor ein
4. Klicke auf **"Run"**

### Schritt 3: Verifizierung
Nach erfolgreicher Ausführung solltest du diese neuen Tabellen sehen:

#### Neue Tabellen:
- ✅ `video_questionnaire` - Fragen zum 20s Video
- ✅ `exploration_sessions` - Zeiterfassung der interaktiven Erkundung  
- ✅ `final_questionnaire` - Abschlussfragebogen mit Vergleichen

#### Bestehende Tabellen (sollten unverändert bleiben):
- ✅ `participants` - Teilnehmer-IDs
- ✅ `questionnaire` - Ursprünglicher Fragebogen
- ✅ `click_data` - Klick-Daten aus dem Viewer

### Schritt 4: Tabellen überprüfen
Gehe zu **"Table Editor"** und verifiziere:

#### `video_questionnaire` Struktur:
```
- id (bigint, primary key)
- participant_id (bigint, foreign key)
- spatial_understanding (integer, 1-5)
- realism (integer, 1-5) 
- notable_objects (text)
- tables_seen (integer)
- sofa_color (text)
- quality (integer, 1-5)
- orientation_confidence (integer, 1-5)
- additional_comments (text)
- timestamp (timestamptz)
```

#### `exploration_sessions` Struktur:
```
- id (bigint, primary key)
- participant_id (bigint, foreign key)
- exploration_time (bigint) # Zeit in Millisekunden
- timestamp (timestamptz)
```

#### `final_questionnaire` Struktur:
```
- id (bigint, primary key)
- participant_id (bigint, foreign key)
- understanding_difference (text)
- interactive_benefits (text[]) # Array
- realism_interactive (integer, 1-10)
- final_orientation (integer, 1-5)
- mental_map (integer, 1-5)
- room_length/width/height (integer)
- navigation_ease (integer, 1-5)
- technical_issues (text[]) # Array
- overall_rating (integer, 1-10)
- final_comments (text)
- timestamp (timestamptz)
```

### Schritt 5: Permissions testen
Teste die Permissions mit diesem SQL Query:
```sql
-- Test Insert in video_questionnaire
INSERT INTO video_questionnaire 
(participant_id, spatial_understanding, realism, quality, orientation_confidence)
VALUES (1, 3, 4, 4, 3);

-- Wenn dieser Query funktioniert, sind die Permissions korrekt
```

### Troubleshooting

#### Fehler: "relation already exists"
- Das ist normal, wenn Tabellen bereits existieren
- Das Script verwendet `CREATE TABLE IF NOT EXISTS`

#### Fehler: "permission denied"
- Überprüfe, ob du Admin-Rechte im Projekt hast
- Policies könnten fehlschlagen - diese können manuell hinzugefügt werden

#### Fehler: "foreign key constraint"
- Stelle sicher, dass die `participants` Tabelle existiert
- Diese sollte bereits aus deinem ursprünglichen Setup vorhanden sein

### Nächste Schritte
Nach erfolgreichem Setup:
1. ✅ Teste die neue Umfrage: `start.html`
2. ✅ Überprüfe Datenerfassung in Supabase
3. ✅ Teste den kompletten Flow: Video → Fragebogen → Erkundung → Finale Fragen

### Support
Bei Problemen:
- Überprüfe die Browser-Konsole auf JavaScript-Fehler
- Schaue in die Supabase Logs
- Teste einzelne API-Calls manuell

---
**Hinweis:** Das Schema ist rückwärtskompatibel - deine bestehenden Daten bleiben unverändert!
