// js/supabase-client.js
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm'

const SUPABASE_URL = 'https://ynvvlwxhunjofrexdfmq.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InludnZsd3hodW5qb2ZyZXhkZm1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2MDg4MjMsImV4cCI6MjA2NDE4NDgyM30.FcJS_sY0PaqZVIXB0nceoKdT5_2WxEsSLs1QGHbM0JY'  // ⚠️ noch ersetzen!

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

export async function createParticipant() {
  const { data, error } = await supabase.from('participants').insert({}).select('id').single()
  if (error) {
    console.error('Teilnehmer konnte nicht erstellt werden:', error)
    return null
  }
  const id = data.id
  sessionStorage.setItem('participant_id', id)
  return id
}

export function getParticipantId() {
  return sessionStorage.getItem('participant_id')
}

export async function submitQuestionnaire({ gs_known, vis_experience, freitext }) {
  const participant_id = getParticipantId()
  const { error } = await supabase.from('questionnaire').insert([{
    participant_id,
    gs_known,
    vis_experience,
    freitext
  }])
  if (error) console.error('Fehler beim Speichern des Fragebogens:', error)
}

export async function submitClick({ object_label, x, y, z }) {
  const participant_id = getParticipantId()
  const { error } = await supabase.from('click_data').insert([{
    participant_id,
    object_label,
    x, y, z,
    timestamp: new Date().toISOString()
  }])
  if (error) {
    console.error('Fehler beim Klick-Logging:', error)
    return false
  }
  return true
}

export async function submitDistanceEstimate(estimated_distance) {
  const participant_id = getParticipantId()
  const { error } = await supabase.from('click_data').insert([{
    participant_id,
    object_label: 'distance',
    estimated_distance,
    timestamp: new Date().toISOString()
  }])
  if (error) console.error('Fehler beim Speichern der Distanzschätzung:', error)
}

// Neue Funktionen für das erweiterte Umfrage-System

export async function submitVideoQuestionnaire(formData) {
  const participant_id = getParticipantId()
  console.log('Speichere Video-Fragebogen für Teilnehmer:', participant_id)
  console.log('Daten:', formData)
  
  const { data, error } = await supabase.from('video_questionnaire').insert([{
    participant_id,
    ...formData,
    timestamp: new Date().toISOString()
  }])
  
  if (error) {
    console.error('Fehler beim Speichern des Video-Fragebogens:', error)
    alert('Fehler beim Speichern: ' + error.message)
  } else {
    console.log('Video-Fragebogen erfolgreich gespeichert:', data)
  }
}

export async function logExplorationTime(explorationTime) {
  const participant_id = getParticipantId()
  const { error } = await supabase.from('exploration_sessions').insert([{
    participant_id,
    exploration_time: explorationTime,
    timestamp: new Date().toISOString()
  }])
  if (error) console.error('Fehler beim Speichern der Erkundungszeit:', error)
}

export async function submitFinalQuestionnaire(formData) {
  const participant_id = getParticipantId()
  console.log('Speichere finalen Fragebogen für Teilnehmer:', participant_id)
  console.log('Daten:', formData)
  
  const { data, error } = await supabase.from('final_questionnaire').insert([{
    participant_id,
    ...formData,
    timestamp: new Date().toISOString()
  }])
  
  if (error) {
    console.error('Fehler beim Speichern des finalen Fragebogens:', error)
    alert('Fehler beim Speichern: ' + error.message)
  } else {
    console.log('Finaler Fragebogen erfolgreich gespeichert:', data)
  }
}

export async function loadPreviousAnswers() {
  const participant_id = getParticipantId()
  if (!participant_id) return null
  
  try {
    // Lade alle Antworten des Teilnehmers
    const [questionnaire, videoQuestionnaire, finalQuestionnaire] = await Promise.all([
      supabase.from('questionnaire').select('*').eq('participant_id', participant_id).single(),
      supabase.from('video_questionnaire').select('*').eq('participant_id', participant_id).single(),
      supabase.from('final_questionnaire').select('*').eq('participant_id', participant_id).single()
    ])
    
    const answers = []
    
    if (questionnaire.data) {
      answers.push({
        id: questionnaire.data.id,
        type: 'Vorwissen-Fragebogen',
        data: questionnaire.data
      })
    }
    
    if (videoQuestionnaire.data) {
      answers.push({
        id: videoQuestionnaire.data.id,
        type: 'Video-Fragebogen',
        data: videoQuestionnaire.data
      })
    }
    
    return answers
  } catch (error) {
    console.error('Fehler beim Laden der vorherigen Antworten:', error)
    return null
  }
}

export async function updatePreviousAnswer(id, updateData) {
  // Diese Funktion könnte erweitert werden, um spezifische Antworten zu aktualisieren
  console.log('Antwort-Update:', id, updateData)
  // Hier könnte eine UPDATE-Operation auf die entsprechende Tabelle ausgeführt werden
}

export async function getParticipantStats(participantId) {
  try {
    // Hole verschiedene Statistiken für den Teilnehmer
    const [sessions, questionnaires, videoQuestionnaires] = await Promise.all([
      supabase.from('exploration_sessions').select('exploration_time').eq('participant_id', participantId),
      supabase.from('questionnaire').select('id').eq('participant_id', participantId),
      supabase.from('video_questionnaire').select('id').eq('participant_id', participantId)
    ])
    
    let totalTime = 0
    if (sessions.data && sessions.data.length > 0) {
      totalTime = sessions.data.reduce((sum, session) => sum + (session.exploration_time || 0), 0)
    }
    
    return {
      total_time: totalTime,
      questions_answered: (questionnaires.data?.length || 0) + (videoQuestionnaires.data?.length || 0)
    }
  } catch (error) {
    console.error('Fehler beim Laden der Teilnehmer-Statistiken:', error)
    return null
  }
}
