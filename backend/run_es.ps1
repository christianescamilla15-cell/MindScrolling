$env:SUPABASE_URL = "https://rwhvjtfargojxccqblfb.supabase.co"
$env:SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU"
node src\db\scripts\check_es_2.js
node src\db\seed_es.js
node src\db\scripts\check_es_2.js
