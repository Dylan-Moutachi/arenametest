<script setup>
import { computed } from "vue"

const props = defineProps({
  result: {
    type: Object,
    required: true,
  }
})

// Compute import status for display message
const statusMessage = computed(() => {
  const successes = props.result.successes || 0
  const errors = props.result.error_list || []

  if (successes > 0 && errors.length === 0) {
    return "Bookings successfully imported."
  } else if (successes > 0 && errors.length > 0) {
    return `Bookings partially imported: ${errors.length} error(s).`
  } else if (successes === 0 && errors.length > 0) {
    return `Import failure: ${errors.length} error(s).`
  } else {
    return ""
  }
})
</script>

<template>
  <div>
    <p class="font-semibold mb-2 text-white" v-if="statusMessage">{{ statusMessage }}</p>

    <div
      v-if="result.error_list && result.error_list.length"
      class="border border-red-500 rounded p-3 max-h-40 overflow-y-auto bg-red-50"
      aria-live="polite"
    >
      <ul>
        <li
          v-for="(error, idx) in result.error_list"
          :key="idx"
          class="text-red-700 mb-1 break-words"
        >
          <strong>Ticket #{{ error.row['ticket_number'] }}:</strong>
          {{ error.messages.join(", ") }}
        </li>
      </ul>
    </div>
  </div>
</template>
