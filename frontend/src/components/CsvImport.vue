<script setup>
  import { ref } from "vue"

  const file = ref(null)
  const MAX_FILE_SIZE_MB = 100

  // check the file size here and display message if too big
  const handleFileChange = (event) => {
    const selectedFile = event.target.files[0]

    // file.size is in bytes so to have megabytes we multiply the value in megabytes
    if (selectedFile && selectedFile.size > MAX_FILE_SIZE_MB * 1024 * 1024) {
      alert(`File is too large. Maximum allowed size is ${MAX_FILE_SIZE_MB} MB.`)
      file.value = null
    } else {
      file.value = selectedFile
    }
  }

  // send the form submit to the backend
  const handleSubmit = async () => {
    if (!file.value) return

    // use FormData to send file to the backend
    const formData = new FormData()
    formData.append("file", file.value)

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
    } catch (err) {
      console.error("Error caught:", err)
      alert("An unexpected error occurred during import.")
      file.value = null
    }
  }
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6">Import CSV file</h1>

    <form @submit.prevent="handleSubmit" class="flex flex-col justify-center gap-4">
      <div class="flex items-center">
        <input
          type="file"
          id="fileInput"
          accept=".csv"
          class="hidden"
          @change="handleFileChange"
        />

        <label
          for="fileInput"
          class="cursor-pointer bg-black border border-white text-white px-4 py-1 rounded-l hover:bg-white hover:text-black transition"
        >
          Select a file
        </label>

        <div
          class="inline-block border border-gray-300 rounded-r px-3 py-1 min-w-[250px] truncate align-middle"
          :title="file ? file.name : ''"
        >
          {{ file ? file.name : 'No file selected' }}
        </div>
      </div>

      <button
        type="submit"
        :disabled="!file"
        class="bg-black text-white px-4 py-2 rounded hover:bg-white hover:text-black disabled:opacity-50 transition"
      >
        Import
      </button>
    </form>

    <router-link
      to="/stats"
      class="inline-block mt-6 text-white bg-black hover:bg-white hover:text-black px-4 py-2 rounded transition"
    >
      Check stats
    </router-link>
  </div>
</template>
