# lib/tasks/import_companies.rake
require 'csv'

namespace :db do
  desc "Import companies from CSV file"
  task import_companies: :environment do
    file_path = Rails.root.join('db', 'data', 'companies_upload_1.csv')
    if File.exist?(file_path)
      row_count = 0

      # Log headers for debugging
      headers = CSV.open(file_path, &:readline)
      Rails.logger.info "CSV Headers: #{headers.inspect}"

      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        row_count += 1
        # Log entire row content for debugging
        Rails.logger.info "Reading row #{row_count}: #{row.inspect}"

        # Access and strip values directly, logging each one
        company_name = row[:company_name]&.strip
        is_top_company = row[:is_top_company].to_s.strip.downcase == 'true'
        company_id = row[:company_id]&.strip.presence

        # Log values after extraction
        Rails.logger.info "Parsed row #{row_count} - company_name: #{company_name.inspect}, is_top_company: #{is_top_company}, company_id: #{company_id.inspect}"

        # Skip if company_name is nil or blank
        if company_name.blank?
          Rails.logger.warn "Skipping row #{row_count}: 'company_name' is missing."
          next
        end

        begin
          company = Company.find_or_initialize_by(company_name: company_name)
          company.is_top_company = is_top_company
          company.company_id = company_id unless company_id.blank?
          company.save!

          Rails.logger.info "Row #{row_count} - Imported or updated company: #{company_name}"
        rescue StandardError => e
          Rails.logger.error "Row #{row_count} - Failed to import company: #{company_name}, Error: #{e.message}"
        end
      end

      Rails.logger.info "Finished importing companies. Total rows processed: #{row_count}"
    else
      Rails.logger.error "CSV file not found at #{file_path}"
    end
  end
end
