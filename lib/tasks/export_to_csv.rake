# lib/tasks/export_to_csv.rake
require 'csv'

namespace :export do

  # Export Movies Table
  desc "Export movies data to CSV"
  task movies_to_csv: :environment do
    CSV.open("exports/movies/movies_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", "w") do |csv|
      csv << ["TMDB ID", "Title", "Budget", "IMDB ID", "Release Date", "Revenue", "Primary Genre", 
              "Opening Weekend Theaters", "Opening Weekend BO", "Domestic BO", "International BO", 
              "Total BO", "RT Audience", "RT Critic", "Domestic Distributor", "International Distributor", 
              "Director", "Logged", "Poster Path", "Distributor", "Widest Release Theaters", "Wikidata ID"]

      Movie.find_each do |movie|
        csv << [
          movie.tmdb_id,
          movie.title,
          movie.budget,
          movie.imdb_id,
          movie.release_date,
          movie.revenue,
          movie.primary_genre,
          movie.open_wknd_theaters,
          movie.open_wknd_BO,
          movie.domestic_BO,
          movie.intl_BO,
          movie.total_BO,
          movie.RT_audience,
          movie.RT_critic,
          movie.domestic_distrib,
          movie.intl_distrib,
          movie.director,
          movie.logged,
          movie.poster_path,
          movie.distributor,
          movie.widest_release_theaters,
          movie.wikidata_id
        ]
      end
    end
    puts "Movies data exported to exports/movies.csv"
  end

  # Export Weekly Box Office Table
  desc "Export weekly box office data to CSV"
  task weekly_box_offices_to_csv: :environment do
    CSV.open("exports/weekly_box_offices/weekly_BO_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", "w") do |csv|
      csv << ["Movie ID", "Week Number", "Year", "Rank", "Rank Last Week", "Weekly Gross", 
              "Gross Change per Week", "Total Theaters", "Change Theaters per Week", 
              "Per Theater Average Gross", "Total Gross", "Weeks in Release", "Distributor"]

      WeeklyBoxOffice.find_each do |record|
        csv << [
          record.movie_id,
          record.week_number,
          record.year,
          record.rank,
          record.rank_last_week,
          record.weekly_gross,
          record.gross_change_per_week,
          record.total_theaters,
          record.change_theaters_per_week,
          record.per_theater_average_gross,
          record.total_gross,
          record.weeks_in_release,
          record.distributor
        ]
      end
    end
    puts "Weekly box office data exported to exports/weekly_box_offices.csv"
  end

  # Export Yearly Box Office Table
  desc "Export yearly box office data to CSV"
  task yearly_box_offices_to_csv: :environment do
    CSV.open("exports/yearly_box_offices/yearly_BO_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", "w") do |csv|
      csv << ["Movie ID", "Year", "Rank", "Domestic Gross", "Total Theaters", "Opening Revenue", 
              "Percent of Total", "Opening Weekend Theaters", "Opening Weekend Date", "Distributor"]

      YearlyBoxOffice.find_each do |record|
        csv << [
          record.movie_id,
          record.year,
          record.rank,
          record.domestic_gross,
          record.total_theaters,
          record.opening_rev,
          record.percent_of_total,
          record.open_wknd_theaters,
          record.opening_weekend,
          record.distributor
        ]
      end
    end
    puts "Yearly box office data exported to exports/yearly_box_offices.csv"
  end

  # Export Monthly Box Office Table
  desc "Export monthly box office data to CSV"
  task monthly_box_offices_to_csv: :environment do
    CSV.open("exports/monthly_box_offices/monthly_BO_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", "w") do |csv|
      csv << ["Movie ID", "Month", "Year", "Rank", "Domestic Gross", "Total Theaters", 
              "Total Gross", "Release Date", "Distributor"]

      MonthlyBoxOffice.find_each do |record|
        csv << [
          record.movie_id,
          record.month,
          record.year,
          record.rank,
          record.domestic_gross,
          record.total_theaters,
          record.total_gross,
          record.release_date,
          record.distributor
        ]
      end
    end
    puts "Monthly box office data exported to exports/monthly_box_offices.csv"
  end
end
