-- set all genres for Blink Twice to non primary
UPDATE movie_genres
SET is_primary= 0
WHERE tmdb_id = 840705;

-- update thriller as primary genre
UPDATE movie_genres
SET is_primary = 1
WHERE tmdb_id = 840705 AND genre_id = 53;

-- set all genres for The substance to non primary
UPDATE movie_genres
SET is_primary = 0
WHERE tmdb_id = 933260;

-- update horror as primary genre
UPDATE movie_genres
SET is_primary = 1
WHERE tmdb_id = 933260 AND genre_id = 27;

-- Set is_primary to 0 where is_primary is NULL or empty
UPDATE movie_genres
SET is_primary = 0
WHERE is_primary IS NULL;

-- Update movie genre names

UPDATE movie_genres
SET genre_name = (SELECT name FROM genres WHERE genres.genre_id = movie_genres.genre_id)
WHERE genre_name IS NULL OR genre_name = '';
