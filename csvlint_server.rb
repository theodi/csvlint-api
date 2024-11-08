require 'sinatra'
require 'csvlint'
require 'webrick'
require 'securerandom'
require 'json'

set :port, ENV['PORT'] || 4567
set :server, 'webrick'

post '/validate' do
  content_type :json

  # Retrieve the CSV source (either URL or file path)
  csv_source = params[:csvUrl] || (params[:file] && params[:file][:tempfile].path)
  schema_source = params[:schemaUrl] || (params[:schema] && params[:schema][:tempfile].path)
  dialect = JSON.parse(params[:dialect] || '{}')  # Parse dialect JSON if provided

  # Track whether the sources are local files, so we know if we should delete them later
  csv_local_file = !params[:csvUrl] && csv_source
  schema_local_file = !params[:schemaUrl] && schema_source

  begin
    # Load schema if provided as a URL or file
    schema = nil
    if schema_source
      schema = params[:schemaUrl] ? Csvlint::Schema.load_from_uri(params[:schemaUrl]) : Csvlint::Schema.load_from_uri(File.new(schema_source))
    end

    if dialect.empty?
      dialect = nil
    end

    if (csv_local_file)
      validator = Csvlint::Validator.new(File.new(csv_source), dialect, schema)
    else
      validator = Csvlint::Validator.new(csv_source, dialect, schema)
    end


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
    # Ensure local temporary files are deleted
    File.delete(csv_source) if csv_local_file && File.exist?(csv_source)
    File.delete(schema_source) if schema_local_file && File.exist?(schema_source)
  end

  # Return the result as JSON
  result.to_json
end
