require 'uri'
require 'net/http'
require 'json'

class TmdbCreditsService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

  # Fetch and store credits for a given movie
  def self.fetch_and_store_credits(movie_id)
    url = URI("#{TMDB_API_URL}/movie/#{movie_id}/credits?language=en-US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    credits_data = JSON.parse(response.read_body)

    if credits_data
      movie = Movie.find_by(tmdb_id: movie_id)
      return unless movie # Skip if movie is not found
      
      # Save cast (actors) with order 0-4
      credits_data["cast"].each do |cast_member|
        next unless cast_member["order"] <= 4  # Only actors with order 0-4

        person = find_or_create_person(cast_member)
        save_credit(movie.id, person.id, cast_member["character"], "Acting", cast_member["credit_id"])
      end

      # Save specific crew members for Writing, Directing, and Production
      credits_data["crew"].each do |crew_member|
        if valid_department_and_job?(crew_member)
          person = find_or_create_person(crew_member)
          save_credit(movie.id, person.id, nil, crew_member["job"], crew_member["credit_id"])
        end
      end

      Rails.logger.info "Credits for movie #{movie.title} successfully updated."
    else
      Rails.logger.error "Failed to fetch credits for TMDB movie ID #{movie_id}."
    end
  end

  private

  # Helper to find or create a person
  def self.find_or_create_person(person_data)
    Person.find_or_create_by(person_id: person_data["id"]) do |person|
      person.name = person_data["name"]
      person.profile_path = person_data["profile_path"]
    end
  end

  # Helper to save a credit
  def self.save_credit(movie_id, person_id, character, role, credit_id)
    Credit.find_or_create_by(
      movie_id: movie_id,
      person_id: person_id,
      character: character,
      role: role,
      credit_id: credit_id
    )
  end

  # Validate the department and job
  def self.valid_department_and_job?(crew_member)
    valid_jobs = {
      "Writing" => ["Screenplay", "Writer"],
      "Production" => ["Executive Producer", "Producer"],
      "Directing" => ["Director"]
    }

    department = crew_member["department"]
    job = crew_member["job"]

    valid_jobs[department]&.include?(job)
  end
end
