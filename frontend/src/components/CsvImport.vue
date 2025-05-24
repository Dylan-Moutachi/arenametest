<script setup>
import { ref } from "vue"
import Papa from "papaparse"

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

    file.value = null
    csvHeaders.value = []
  } catch (err) {
    console.error("Error caught:", err)
    alert("An unexpected error occurred during import.")
    file.value = null
    csvHeaders.value = []
  }
}

// compute headers not yet selected
const availableHeaders = (currentKey) => {
  return csvHeaders.value.filter(header =>
    !Object.entries(columnMapping.value).some(
      ([key, selected]) => key !== currentKey && selected === header
    )
  )
}
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
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
          class="flex-1 border border-gray-300 rounded-r px-4 py-2 truncate"
          :title="file ? file.name : ''"
          aria-live="polite"
        >
          {{ file ? file.name : 'No file selected' }}
        </div>
      </div>

      <!-- Mapping -->
      <div
        v-if="csvHeaders.length"
        class="bg-gray-600 p-5 rounded border border-gray-300 max-h-[400px] overflow-auto"
        role="region"
        aria-label="CSV column mapping"
      >
        <h2 class="font-semibold mb-4 text-white">Map your CSV columns</h2>

        <div
          v-for="key in BOOKING_FIELDS"
          :key="key"
          class="mb-4 flex flex-col sm:flex-row sm:items-center sm:gap-4"
        >
          <label
            :for="key"
            class="block mb-1 sm:mb-0 sm:w-40 text-sm font-medium text-white whitespace-nowrap"
          >
            {{ key }}
          </label>
          <select
            v-model="columnMapping[key]"
            :id="key"
            class="flex-grow border border-gray-300 rounded px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-black"
            aria-required="true"
          >
            <option value="">Select CSV column</option>
            <option
              v-for="header in availableHeaders(key)"
              :key="header"
              :value="header"
            >
              {{ header }}
            </option>
          </select>
        </div>
      </div>

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
