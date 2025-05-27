# 🗂️ Arenametest


This SPA lets you import booking data from a CSV file, map its columns to internal system fields, and track the import’s progress and results via a background job. You can also view the imported bookings, search by event and access booking statistics.

## 🛠️ Tech Stack

### ⛁ Backend:
- Ruby 3.4.4
- Rails 8 (API-only)
- PostgreSQL
- Sidekiq
- Redis

### 🔬 Testing:
- RSpec
- Mocha
- FactoryBot

### 🖥️ Frontend:
- Node 24.0.2 (for build)
- Vite
- Vue 3 (Composition API)
- TailwindCSS

## 🚀 Getting Started
Follow these steps to set up the app locally for development and testing.

### 🛠️ Setup Instructions

💡 **Windows Compatibility**

  This project is primarily developed and tested in a Unix-like environment (macOS/Linux).
  If you're using Windows:

- Make sure Ruby, PostgreSQL and Node.js are correctly installed.
- We recommend running Redis (required for Sidekiq) via [Docker](https://www.docker.com/) or [WSL](https://learn.microsoft.com/en-us/windows/wsl/).
- Consider using Git Bash or WSL to run Unix-style commands like `bundle exec` or `rails db:migrate`.

**For macOS/Linux users:**

1. Clone the repo using **SSH** (requires SSH key configured):
  ```bash
  git clone git@github.com:Dylan-Moutachi/arenametest.git
  cd <project-root>
  ```
Or using **HTTPS**
  ```bash
  git clone https://github.com/Dylan-Moutachi/arenametest.git
  cd <project-root>
  ```

2. Install Ruby gems:
```bash
bundle install
```

3. Install frontend dependencies:
```bash
cd frontend
npm install
cd ..
```

4. Set up the database:
```bash
bundle exec rails db:create db:migrate
```

5. Start the app locally:

In three separate terminal tabs/windows:

**Backend (Rails API):**
```bash
bundle exec rails s
```
**Frontend (Vite + Vue 3):**
```bash
cd frontend
npm run dev
```
**Sidekiq (for background CSV imports):**
```bash
bundle exec sidekiq
```

### Running tests
To run the backend test suite:
```bash
bundle exec rspec
```
Tests use:
- RSpec
- FactoryBot
- Mocha
- Faker

There are currently no frontend unit tests configured.

### 🧰 Services Used
- PostgreSQL – primary database
- Redis – for Sidekiq background jobs
- Sidekiq – handles async CSV imports
- Kaminari – for pagination
- CharlockHolmes – for encoding detection
- PapaParse – for CSV parsing in the frontend

## ⚙️ How It Works

1. The user uploads a CSV file

2. The user is prompted to match CSV columns to internal booking fields

    ⚠ Importing is blocked until all required mappings are completed

3. The file is sent to the backend

4. When the import job is over, the UI displays import status and lists errors if they exist

5. The user can read booking list and stats, and search by event


### Import start

Once mapping is confirmed, the frontend triggers POST /api/v1/bookings/import

A Sidekiq job (BookingsImportJob) is enqueued to handle the processing

### Import status tracking

The frontend polls GET /api/v1/bookings_imports/:id/status every few seconds

The API returns updated status (processing, success, partial_success, failed) and error logs

### Display import results

On completion, the UI displays a summary: how many rows were successfully imported vs. failed and readable errors

### Display bookings and stats

By clicking "Check Stats", the user can access a dedicated page to view bookings, filter by event, and read statistics.

## 🧪 Tests
The system includes:

✅ Unit tests for models, controllers and services

✅ Sidekiq job tests to verify import execution

✅ Functional test for the end-to-end flow (real import testing)

## 🌐 API Endpoints

| Method | Endpoint                  | Description                        |
|--------|---------------------------|------------------------------------|
| GET    | /api/v1/bookings          | List all bookings and show stats   |
| POST   | /api/v1/bookings/import   | Import bookings via CSV            |
| GET    | /api/v1/bookings_imports/:id/status | Display import job status and errors if they exist |

You can access to Sidekiq dashboard via /sidekiq

## 🔄 Polling Strategy

Frontend polls the status endpoint every 3 seconds using setInterval to detect changes in import status. While import status is "processing", polling continues.

## 🧰 Frontend Components

| Component                | Purpose                               |
|--------------------------|----------------------------------------|
| `CsvImport.vue`          | Main entry point, handles file upload |
| `CsvMapping.vue`         | Column mapping UI                     |
| `Stats.vue` | Booking stats component   |
| `EventSearchBar.vue` | Event search bar component to search bookings by event |
| `BookingsImportStatus.vue` | Display import status by polling |

## 🧠 Performance and Robustness Considerations

### 🏎️ Performance
1. CSV max size

    Regarding sample.csv, a line weights about 600B. If we consider a 1KB line, the max size limit of 100MB allows about 100,000 lines, equivalent to Le Stade de France stadium capacity.

2. Sidekiq asynchronous job

    I decided to use Sidekiq asynchronous job in order to make imports in background, without locking the app process.

3. Sidekiq threads

    On a basic Heroku plan, the server allows up to 512MB of RAM. I set the maximum sidekiq threads to 2 in order to use maximum 200MB server RAM (2 import jobs maximum can run simultaneously). I let 300MB RAM to the system working and other operations.

4. Kaminari pagination

    To prevent excessive booking fetches at once, I set a pagination (by default 20 bookings displayed per page). Statistics are calculated independently.

### 💪 Robustness

  1. CSV import

      A dedicated CsvReaderService handles encoding detection and conversion, using the charlock_holmes gem.

      I count semicolons and commas to detect the column separator.

      Regarding the sample csv file, a booking can have no age or gender, but the other fields are mandatory.

      I made a Booking parent model BookingsImport, which records each import.

      The file is processed line by line, enabling partial imports in case some rows are invalid (e.g., due to a duplicate ticket number). Each failed line results in a specific error message displayed to the user. To optimize performance and reduce database load, valid bookings are grouped and saved in batches.


  2. Testing CI

      Unit and functional tests run for each commit. Native Lint and scan Ruby also run.
