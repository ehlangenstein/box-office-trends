namespace :box_office do
  desc "Update movie records for a specific release year using Box Office Mojo Service in batches of 10"
  task update_movie_records_by_year: :environment do
    # Prompt for a release year
    puts "Enter the release year to update movies:"
    release_year = STDIN.gets.chomp.to_i

    Rails.logger.info "Updating movie records released in #{release_year} using Box Office Mojo Service"

    # Query movies with a blank distributor OR missing wikidata_id
    Movie.where("strftime('%Y', release_date) = ?", release_year.to_s)
         .where("distributor IS NULL")
         .find_in_batches(batch_size: 10) do |movies_batch|

      movies_batch.each do |movie|
        Rails.logger.info "Processing movie: #{movie.title} (IMDb ID: #{movie.imdb_id})"

        begin
          update_data = {}

          # Fetch Box Office data if distributor is missing
          if movie.distributor.blank?
            box_office_data = BoxOfficeMojoService.fetch_and_store_box_office_data(movie.imdb_id)

            if box_office_data
              update_data[:domestic_BO] = box_office_data[:domestic_box_office]
              update_data[:intl_BO] = box_office_data[:international_box_office]
              update_data[:total_BO] = box_office_data[:worldwide_box_office]
              update_data[:distributor] = box_office_data[:distributor]
              update_data[:open_wknd_BO] = box_office_data[:opening_weekend_box_office]
              update_data[:open_wknd_theaters] = box_office_data[:opening_theaters]
              update_data[:widest_release_theaters] = box_office_data[:widest_release]
              Rails.logger.info "Fetched Box Office data for #{movie.title}"
            else
              Rails.logger.warn "No Box Office data found for #{movie.title}"
            end
          end

          # Update the movie record if there is new data
          if update_data.any?
            movie.update!(update_data)
            Rails.logger.info "Updated movie: #{movie.title} with new data"
          else
            Rails.logger.info "No updates needed for movie: #{movie.title}"
          end

        rescue StandardError => e
          # Log the error and skip this movie
          Rails.logger.error "Error processing movie: #{movie.title} (IMDb ID: #{movie.imdb_id}). Error: #{e.message}"
          next # Explicitly skip to the next movie
        end
      end

      Rails.logger.info "Processed a batch of 10 movies."
    end

    Rails.logger.info "Finished updating movie records released in #{release_year}"
  end
end
