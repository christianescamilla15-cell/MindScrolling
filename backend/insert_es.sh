#!/bin/bash
curl -X POST "https://rwhvjtfargojxccqblfb.supabase.co/rest/v1/quotes" \
-H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU" \
-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU" \
-H "Content-Type: application/json" \
-H "Prefer: resolution=ignore-duplicates" \
-d '[
  { "text": "La felicidad de tu vida depende de la calidad de tus pensamientos.", "author": "Marco Aurelio", "category": "stoicism", "lang": "es", "swipe_dir": "left" },
  { "text": "Sufrimos más en la imaginación que en la realidad.", "author": "Séneca", "category": "stoicism", "lang": "es", "swipe_dir": "left" },
  { "text": "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son.", "author": "Epicteto", "category": "stoicism", "lang": "es", "swipe_dir": "left" },
  { "text": "Solo sé que no sé nada.", "author": "Sócrates", "category": "philosophy", "lang": "es", "swipe_dir": "up" },
  { "text": "La duda es el origen de la sabiduría.", "author": "René Descartes", "category": "philosophy", "lang": "es", "swipe_dir": "up" },
  { "text": "La disciplina es el puente entre las metas y los logros.", "author": "Jim Rohn", "category": "discipline", "lang": "es", "swipe_dir": "right" },
  { "text": "Lo que pensamos, en eso nos convertimos.", "author": "Buda", "category": "reflection", "lang": "es", "swipe_dir": "down" }
]'

echo "Insert done"

curl -s "https://rwhvjtfargojxccqblfb.supabase.co/rest/v1/quotes?lang=eq.es&select=id" \
-H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU" \
-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU" | Select-String "id" | Measure-Object | Select-Object -ExpandProperty Count
