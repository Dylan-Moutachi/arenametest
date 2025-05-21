<script setup>
  import { ref } from "vue"

  const file = ref(null)
  const message = ref("") // message is different if file import succeeds or fails

  // when a file is selected, we set the file
  // and we reset the message if there was a previous import message
  const handleFileChange = (event) => {
    file.value = event.target.files[0]
    message.value = ""
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

      if (response.status === 207) {
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
    }
  }
</script>

<template>
  <div>
    <h1>Import CSV file</h1>

    <form @submit.prevent="handleSubmit">
      <input
        ref="fileInput"
        type="file"
        accept=".csv"
        @change="handleFileChange"
      />

      <button
        type="submit"
        :disabled="!file"
      >
        Import
      </button>

      <p v-if="message">{{ message }}</p>
    </form>
  </div>
</template>
