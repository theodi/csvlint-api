# CSVLint-API

CSVLint is a Ruby-based server for validating CSV files. It checks CSV files against standard structures and schemas, providing detailed feedback on any issues detected.

## Features

- **Structure Validation**: Checks for structural issues, such as inconsistent row lengths, incorrect quoting, and malformed line endings.
- **Schema Validation**: Validates CSV data against schemas (e.g., JSON-based) to ensure data formats, types, and constraints are met.
- **Dialect Options**: Flexible options for parsing CSV files, such as delimiters, quoting characters, and line terminators.
- **Detailed Reporting**: Provides error, warning, and informational feedback on validation results.

## Installation

### Prerequisites

Make sure you have the following installed on your system:

- **Ruby** (version 2.6 or higher)
- **Bundler** (for managing Ruby dependencies)

### Step 1: Clone the Repository

Clone the repository from GitHub and navigate into the project directory:

```bash
git clone https://github.com/theodi/csvlint-api.git
cd csvlint-api
```

### Step 2: Install Ruby Dependencies

Ensure you have Bundler installed. If not, you can install it with:

```bash
gem install bundler
```

Then install all required Ruby gems:

```bash
bundle install
```

### Step 3: Set Up Environment Variables

Create an `.env` file in the project root (you can start by copying `.env.example`):

```bash
cp .env.example .env
```

Set any necessary environment variables in `.env`. At minimum, you should define:

- `PORT`: The port on which the server will run (default: `4567`).

### Step 4: Run the Server Locally

To start the CSVLint server locally, use:

```bash
ruby csvlint_server.rb
```

The server will start on the specified port (default `4567`). You can access it at `http://localhost:4567`.

### Usage

#### Web Interface

To use CSVLint through a web interface, simply open the URL in your browser:

```bash
http://localhost:4567
```

#### API Usage

The CSVLint API allows you to programmatically validate CSV files. You can upload a CSV file or provide a URL to a CSV with optional schema and dialect options.

**Example `POST` Request:**

```bash
curl -X POST http://localhost:4567/validate \
-F "file=@/path/to/yourfile.csv" \
-F "schema=@/path/to/yourschema.json" \
-F "dialect={\"delimiter\":\",\",\"quoteChar\":\"\\\"\"}"
```

**Response:**

The API responds with JSON validation results. Here’s an example response format:

```json
{
  "valid": true,
  "errors": [],
  "warnings": [],
  "info_messages": []
}
```

#### Deploying to Render

1. **Log in to Render** and create a new service.
2. **Link your GitHub repository**.
3. **Choose the Ruby environment** and specify `Gemfile` for dependencies.
4. Set environment variables, including `PORT`.
5. Click **Create Web Service** to deploy.

### License

This project is licensed under the MIT License.