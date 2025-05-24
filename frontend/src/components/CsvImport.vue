<script setup>
import { ref } from "vue"
import Papa from "papaparse"
import CsvMapping from "./CsvMapping.vue"

const file = ref(null)
const MAX_FILE_SIZE_MB = 100

const csvHeaders = ref([])

// useful to order columns during mapping
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

  // Add the strigified mapping JSON
  formData.append("csv_mapping", JSON.stringify(columnMapping.value))

  try {
    const response = await fetch("http://localhost:3000/api/v1/bookings/import", {
      method: "POST",
      body: formData
    })

    // Inform the user that the import is running in the background
    if (response.status === 202) {
      alert("Import started. The file is being processed in background.")
    } else if (response.status === 400) {
      const data = await response.json()
      alert(data.error || "Invalid file.")
    } else {
      alert("An unexpected error occurred.")
    }
  } catch (err) {
    console.error("Error caught:", err)
    alert("An unexpected error occurred during import.")
  } finally {
    // reset everything after submission, so user can re-import same file if needed
    file.value = null
    csvHeaders.value = []
    // reset column mapping
    columnMapping.value = {}
    BOOKING_FIELDS.forEach(field => {
      columnMapping.value[field] = ""
    })

    // Reset file input to allow selecting the same file again
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

    <router-link
      to="/stats"
      class="inline-block mt-8 text-white bg-black hover:bg-white hover:text-black px-6 py-3 rounded transition"
    >
      Check stats
    </router-link>
  </div>
</template>
