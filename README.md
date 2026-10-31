# Glen Park Garden Dashboard

A cozy watering dashboard for Suzy's garden in Glen Park, San Francisco.

- Live page: https://hvanhemmen.github.io/glen-park-garden/
- Plants are stored in a Supabase table (`glen_park_plants`); `setup.sql` creates it.
- Weather comes straight from Open-Meteo in the browser.
- A GitHub Action saves a daily copy of the plant list to `backup/plants.json`.
