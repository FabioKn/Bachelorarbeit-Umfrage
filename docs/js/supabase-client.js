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
