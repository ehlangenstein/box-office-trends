class TmdbService
  def self.fetch_rated_movies(account_id, session_id)
    begin
      Tmdb::Account.rated_movies(account_id, session_id: session_id)
    rescue StandardError => e 
      Rails.logger.error("Error fetching details details: #{e.message}")
      nil
  end

  def self.fetch_movie_details(movie_id)
    begin
      Tmdb::Movie.detail(movie_id)
    rescue StandardError => e 
      Rails.logger.error("Error fetching movie details: #{e.message}")
      nil
    end

  def self.fetch_movie_credits(movie_id)
    begin
      Tmdb::Movie.credits(movie_id)
    rescue StandardError => e 
      Rails.logger.error("Error fetching credit details: #{e.message}")
    nil
  end
end
