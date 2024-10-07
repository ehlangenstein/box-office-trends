-- set all genres for Blink Twice to non primary
UPDATE movie_genres
SET primary_genre = 0
WHERE tmdb_id = 840705;

-- update thriller as primary genre
UPDATE movie_genres
SET primary = 1
WHERE tmdb_id = 840705 AND genre_id = 53;

-- set all genres for The substance to non primary
UPDATE movie_genres
SET primary_genre = 0
WHERE tmdb_id = 933260;

-- update horror as primary genre
UPDATE movie_genres
SET primary = 1
WHERE tmdb_id = 933260 AND genre_id = 27;

