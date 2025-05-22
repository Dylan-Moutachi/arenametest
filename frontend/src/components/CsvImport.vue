<script setup>
  import { ref } from "vue"

  const file = ref(null)
  const message = ref("") // message is different if file import succeeds or fails
  const MAX_FILE_SIZE_MB = 5

  // also check the file size here and display message if too big
  const handleFileChange = (event) => {
    const selectedFile = event.target.files[0]

    // file.size is in bytes so to have megabytes we multiply the value set in backend in megabytes
    if (selectedFile && selectedFile.size > MAX_FILE_SIZE_MB * 1024 * 1024) {
      message.value = `File is too large. Maximum allowed size is ${MAX_FILE_SIZE_MB} MB.`
      file.value = null
    } else {
      file.value = selectedFile
      message.value = ""
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

      const data = await response.json()

      if (response.status === 400) {
        message.value = data.error || "Invalid file."
        file.value = null
      } else if (response.status === 207) {
        message.value = data.message || `Import completed with some errors. Imported: ${data.imported} lines`
        console.error("Import errors:", data.errors)
        file.value = null
      } else if (response.ok) {
        message.value = data.message
        file.value = null
      } else if (response.status === 422) {
        message.value = data.message || "No lines were imported."
        console.error("Import errors:", data.details)
        file.value = null
      } else {
        console.error("Import failed:", data.error || "Unknown error")
      }
    } catch (err) {
      console.error("Error caught:", err)
      message.value = "An unexpected error occurred during import."
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
          class="cursor-pointer bg-black text-white px-4 py-2 rounded-l hover:bg-gray-900 transition"
        >
          Select a file
        </label>

        <div
          class="inline-block border border-gray-300 rounded-r px-3 py-1 min-w-[250px] truncate align-middle"
          :title="file ? file.name : ''"
        >
          {{ file ? file.name : 'Aucun fichier sélectionné' }}
        </div>
      </div>

      <button
        type="submit"
        :disabled="!file"
        class="bg-black text-white px-4 py-2 rounded hover:bg-gray-900 disabled:opacity-50 transition"
      >
        Import
      </button>

      <p
        v-if="message"
        class="text-sm"
        :class="message.toLowerCase().includes('error') || message.toLowerCase().includes('invalid') ? 'text-red-500' : 'text-white'"
      >
        {{ message }}
      </p>
    </form>

    <router-link
      to="/stats"
      class="inline-block mt-6 text-white bg-black hover:bg-gray-900 px-4 py-2 rounded transition"
    >
      Check stats
    </router-link>
  </div>
</template>
