require 'sinatra'
require 'csvlint'
require 'webrick'
require 'securerandom'
require 'json'

set :port, ENV['PORT'] || 4567
set :server, 'webrick'

post '/validate' do
  content_type :json

  # Retrieve file, schema, and dialect from the request
  csv_file = params[:file]
  schema_file = params[:schema]
  dialect = JSON.parse(params[:dialect] || '{}')  # Parse dialect JSON if provided

  # Generate a unique temporary file name
  csv_tempfile = "temp_#{SecureRandom.uuid}.csv"
  schema_tempfile = "temp_schema_#{SecureRandom.uuid}.json" if schema_file

  begin
    # Save the CSV file temporarily
    File.open(csv_tempfile, "wb") { |f| f.write(csv_file[:tempfile].read) }

    # Save schema file if provided
    schema = nil
    if schema_file
      File.open(schema_tempfile, "wb") { |f| f.write(schema_file[:tempfile].read) }
      schema = Csvlint::Schema.load_from_json(File.new(schema_tempfile))
    end

    # Create the CSV validator with dialect options and schema
    validator = Csvlint::Validator.new(File.new(csv_tempfile), dialect, schema)

    # Perform validation
    validator.validate

    # Map errors, warnings, and info messages into hashes
    errors = validator.errors.map do |error|
      {
        category: error.category,
        type: error.type,
        row: error.row,
        column: error.column,
        content: error.content
      }
    end

    warnings = validator.warnings.map do |warning|
      {
        category: warning.category,
        type: warning.type,
        row: warning.row,
        column: warning.column,
        content: warning.content
      }
    end

    info_messages = validator.info_messages.map do |info|
      {
        category: info.category,
        type: info.type,
        row: info.row,
        column: info.column,
        content: info.content
      }
    end

    # Collect results
    result = {
      valid: validator.valid?,
      errors: errors,
      warnings: warnings,
      info_messages: info_messages
    }

  rescue StandardError => e
    # Handle errors gracefully and return the error message as JSON
    result = { error: "Validation failed: #{e.message}" }
  ensure
    # Ensure temporary files are deleted
    File.delete(csv_tempfile) if File.exist?(csv_tempfile)
    File.delete(schema_tempfile) if schema_file && File.exist?(schema_tempfile)
  end

  # Return the result as JSON
  result.to_json
end