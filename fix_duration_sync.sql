-- Fix songs that should have duration 2:49 (169 seconds) but were incorrectly set to 0:00
UPDATE songs SET duration = '2:49' 
WHERE title IN (
    'Megacopter Blades of the Goddess - Air to Surface (Destroy IV)',
    'Megacopter Blades of the Goddess - Reptoids (Destroy I)',
    'MLB Power Pros - All Star Game',
    'Monster vs Sheep - Level 01',
    'Mushihimesama - To Shinju Forest (Stage 1)',
    'Pigeon Blood - Carnelian',
    'Plexu The Time Travellers - Title Screen',
    'Powder - City (Stage 1)',
    'Power Drift - Silent Language',
    'Power Poke Dash - All or Nothing!'
) AND duration = '0:00';