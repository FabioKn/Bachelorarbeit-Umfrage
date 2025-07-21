# Supabase Schema Update - Anleitung

## Überblick
Nach der Integration der Questionnaire-Fragen in den neuen Studienablauf müssen die Supabase-Tabellen erweitert werden.

## Neue Felder

### video_questionnaire Tabelle:
- `gs_known` (BOOLEAN) - Gaussian Splatting Vorwissen
- `vis_experience` (INTEGER 1-5) - 3D-Visualisierung Erfahrung  
- `been_to_library` (BOOLEAN) - HTWK-Bibliothek Besuch
- `freitext` (TEXT) - Freitext-Kommentar zum Vorwissen
- `memorable_book` (TEXT) - Aufgefallenes Buch
- `shelf_levels` (INTEGER 1-20) - Geschätzte Regalbretter-Anzahl

### final_questionnaire Tabelle:
- `memorable_book_final` (TEXT) - Aufgefallenes Buch nach Erkundung
- `shelf_levels_final` (INTEGER 1-20) - Geschätzte Regalbretter nach Erkundung

## Durchführung

### Schritt 1: Backup erstellen (empfohlen)
```sql
-- Backup der aktuellen Daten
CREATE TABLE video_questionnaire_backup AS SELECT * FROM video_questionnaire;
CREATE TABLE final_questionnaire_backup AS SELECT * FROM final_questionnaire;
```

### Schritt 2: Schema-Update ausführen
Führen Sie das SQL-Script aus: `supabase-schema-update-questionnaire.sql`

1. Supabase Dashboard öffnen
2. Zu "SQL Editor" navigieren 
3. Inhalt der Datei `supabase-schema-update-questionnaire.sql` kopieren und einfügen
4. "Run" klicken

### Schritt 3: Überprüfung
Nach der Ausführung sollten Sie eine Erfolgsmeldung sehen:
```
Beide Tabellen erfolgreich erweitert!
```

### Schritt 4: Test
- Testen Sie den neuen Studienablauf: start.html → video-questionnaire.html → interactive-viewer.html → final-questionnaire.html
- Überprüfen Sie in der Supabase-Konsole, ob die Daten korrekt ankommen

## Geänderte Dateien
- ✅ `video-questionnaire.html` - Erweitert um Vorwissen-Fragen + Freitext
- ✅ `interactive-viewer.html` - Emojis entfernt
- ✅ `thank-you.html` - Emojis entfernt  
- ✅ `index.html` - Emojis entfernt
- ✅ `supabase-schema-update-questionnaire.sql` - Schema-Update für beide Tabellen

## Hinweise
- Die ursprüngliche `questionnaire.html` bleibt als Legacy-Option bestehen
- Die neuen Felder sind optional (können NULL sein), um Kompatibilität zu gewährleisten
- Die Analytics-View `participant_summary` wurde erweitert für bessere Auswertungen

## Bei Problemen
Falls Fehler auftreten:
1. Überprüfen Sie die Fehlermeldung in der Supabase-Konsole
2. Prüfen Sie, ob alle Tabellen existieren: `participants`, `video_questionnaire`, `final_questionnaire`
3. Kontaktieren Sie den Entwickler bei persistenten Problemen
