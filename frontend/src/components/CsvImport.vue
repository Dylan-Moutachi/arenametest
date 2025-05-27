<script setup>
import { ref, onUnmounted } from "vue"
import Papa from "papaparse"
import CsvMapping from "./CsvMapping.vue"
import BookingsImportStatus from "./BookingsImportStatus.vue"

const file = ref(null)
const MAX_FILE_SIZE_MB = 100

const csvHeaders = ref([])

// used for columns order during mapping
const BOOKING_FIELDS = [
  "ticket_number",
  "booking_number",
  "booking_date",
  "booking_hour",
  "event_key",
  "event",
  "show_key",
  "show",
  "show_date",
  "show_hour",
  "show_end_date",
  "show_end_hour",
  "price",
  "product_type",
  "sales_channel",
  "last_name",
  "first_name",
  "email",
  "address",
  "postal_code",
  "country",
  "age",
  "gender"
]

// initialize column mapping
const columnMapping = ref({})
BOOKING_FIELDS.forEach(field => {
  columnMapping.value[field] = ""
})

// Reference to reset file input value for allowing same file import again
const fileInputRef = ref(null)

// Store the import result here to show success/errors after submission
const importResult = ref(null)

// Timer reference for polling
let pollingTimer = null
const POLLING_INTERVAL_MS = 3000 // 3 seconds interval

// Clear polling timer when component unmounts (avoid memory leaks)
onUnmounted(() => {
  if (pollingTimer) {
    clearTimeout(pollingTimer)
    pollingTimer = null
  }
})

// Polling function to fetch import status
const pollImportStatus = async (importId) => {
  try {
    const resp = await fetch(`http://localhost:3000/api/v1/bookings_imports/${importId}/status`)
    if (resp.ok) {
      const data = await resp.json()
      importResult.value = data
      if (data.status === "processing") {
        // Continue polling
        pollingTimer = setTimeout(() => pollImportStatus(importId), POLLING_INTERVAL_MS)
      } else {
        // Import finished, stop polling
        clearTimeout(pollingTimer)
        pollingTimer = null
      }
    } else {
      // Error during status fetch, stop polling
      clearTimeout(pollingTimer)
      pollingTimer = null
      alert("Error fetching import status")
    }
  } catch (err) {
    clearTimeout(pollingTimer)
    pollingTimer = null
    console.error("Polling error:", err)
  }
}

// check the file size here and display message if too big
const handleFileChange = (event) => {
  const selectedFile = event.target.files[0]

  // file.size is in bytes so to have megabytes we multiply the value in megabytes
  if (selectedFile && selectedFile.size > MAX_FILE_SIZE_MB * 1024 * 1024) {
    alert(`File is too large. Maximum allowed size is ${MAX_FILE_SIZE_MB} MB.`)
    file.value = null
    csvHeaders.value = []
    return
  } else {
    file.value = selectedFile

    const reader = new FileReader()
    reader.onload = (e) => {
      const csvText = e.target.result
      const parsed = Papa.parse(csvText, { preview: 1 })
      csvHeaders.value = (parsed.data[0] || [])

      // Reset mapping on new file
      BOOKING_FIELDS.forEach(field => {
        columnMapping.value[field] = ""
      })
    }
    reader.readAsText(selectedFile)
  }
}

// send the form submit to the backend
const handleSubmit = async () => {
  if (!file.value) return

  // use FormData to be able to send file to the backend
  const formData = new FormData()
  formData.append("file", file.value)

  // Add the stringified mapping JSON
  formData.append("csv_mapping", JSON.stringify(columnMapping.value))

  try {
    const response = await fetch("http://localhost:3000/api/v1/bookings/import", {
      method: "POST",
      body: formData
    })

    // Inform the user that the import is running in the background
    if (response.status === 202) {
      const json = await response.json()
      alert("Import started. The file is being processed in background.")
      importResult.value = null

      // Start polling using bookings_import_id
      pollImportStatus(json.bookings_import_id)

    } else if (response.status === 200) {
      // Expect JSON with successes and errors
      const data = await response.json()
      importResult.value = data
    } else if (response.status === 400) {
      const data = await response.json()
      alert(data.error || "Invalid file.")
      importResult.value = null
    } else {
      alert("An unexpected error occurred.")
      importResult.value = null
    }
  } catch (err) {
    console.error("Error caught:", err)
    alert("An unexpected error occurred during import.")
    importResult.value = null
  } finally {
    // reset everything after submission
    file.value = null
    csvHeaders.value = []
    // reset column mapping
    columnMapping.value = {}
    BOOKING_FIELDS.forEach(field => {
      columnMapping.value[field] = ""
    })

    // Reset file input
    if (fileInputRef.value) {
      fileInputRef.value.value = ""
    }
  }
}
</script>

<template>
  <div class="mx-auto px-6 py-8 min-h-screen flex flex-col">
    <h1 class="text-3xl font-bold mb-8">Import CSV file</h1>

    <form @submit.prevent="handleSubmit" class="flex flex-col gap-6">
      <!-- File selector -->
      <div class="flex items-center max-w-md">
        <input
          type="file"
          id="fileInput"
          accept=".csv"
          class="hidden"
          @change="handleFileChange"
          ref="fileInputRef"
        />
        <label
          for="fileInput"
          class="cursor-pointer bg-black border border-white text-white px-5 py-2 rounded-l hover:bg-white hover:text-black transition select-none"
          tabindex="0"
          @keydown.enter.prevent="$refs.fileInput.click()"
        >
          Select a file
        </label>
        <div
          class="flex-1 border border-white rounded-r px-4 py-2 truncate"
          :title="file ? file.name : ''"
          aria-live="polite"
        >
          {{ file ? file.name : 'No file selected' }}
        </div>
      </div>

      <!-- CSV Mapping component -->
      <CsvMapping
        v-if="csvHeaders.length"
        :csvHeaders="csvHeaders"
        v-model="columnMapping"
        :bookingFields="BOOKING_FIELDS"
      />

      <!-- Submit button -->
      <button
        type="submit"
        :disabled="!file || Object.values(columnMapping).some(val => val === '')"
        class="bg-black text-white px-6 py-3 rounded hover:bg-white hover:text-black disabled:opacity-50 disabled:cursor-not-allowed transition"
      >
        Import
      </button>
    </form>

    <!-- Display import results after submission -->
    <BookingsImportStatus v-if="importResult" :result="importResult" />

    <router-link
      to="/stats"
      class="inline-block mt-8 text-white bg-black hover:bg-white hover:text-black px-6 py-3 rounded transition"
    >
      Check stats
    </router-link>
  </div>
</template>
