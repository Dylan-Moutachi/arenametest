<script setup>
import { ref, watch, defineEmits } from 'vue'

// Props & Emits
const emit = defineEmits(['search'])

const searchEvent = ref('')
const suggestions = ref([])
const showSuggestions = ref(false)

// Debounce helper to limit API calls
function debounce(fn, delay) {
  let timeout
  return (...args) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => fn(...args), delay)
  }
}

// Fetch suggestions from API
const fetchEventSuggestions = debounce(async (query) => {
  if (!query) {
    suggestions.value = []
    return
  }

  try {
    const params = new URLSearchParams()
    params.append('event', query)

    const response = await fetch(`http://localhost:3000/api/v1/bookings?${params.toString()}`)
    if (!response.ok) throw new Error('Error fetching suggestions')

    const data = await response.json()
    const uniqueEvents = [...new Set(data.bookings.map(b => b.event))].filter(Boolean)
    suggestions.value = uniqueEvents
    showSuggestions.value = true
  } catch {
    suggestions.value = []
    showSuggestions.value = false
  }
}, 300)

// Watch for input changes
watch(searchEvent, (val) => {
  fetchEventSuggestions(val)
})

// Emit search query to parent
const handleSearch = () => {
  emit('search', searchEvent.value.trim())
  showSuggestions.value = false
  searchEvent.value = ''
}

// Called when selecting suggestion
const selectSuggestion = (suggestion) => {
  searchEvent.value = suggestion
  handleSearch()
}
</script>

<template>
  <div class="relative flex items-center max-w-full mb-3">
    <!-- Input -->
    <input
      type="text"
      v-model="searchEvent"
      @keyup.enter="handleSearch"
      @focus="showSuggestions = suggestions.length > 0"
      @blur="setTimeout(() => showSuggestions = false, 200)"
      placeholder="Search event"
      class="border border-white rounded-l px-3 py-1 focus:outline-none"
      autocomplete="off"
    />

    <!-- Search button -->
    <button
      type="button"
      @click="handleSearch"
      class="bg-black hover:bg-white hover:text-black border border-white text-white px-4 py-1 rounded-r transition"
    >
      Search
    </button>

    <!-- Autocomplete dropdown -->
    <ul
      v-if="showSuggestions && suggestions.length"
      class="absolute z-10 top-full left-0 right-0 text-black bg-white border border-gray-300 rounded-b max-h-48 overflow-auto shadow"
    >
      <li
        v-for="suggestion in suggestions"
        :key="suggestion"
        @mousedown.prevent="selectSuggestion(suggestion)"
        class="cursor-pointer px-3 py-1 hover:bg-gray-200"
      >
        {{ suggestion }}
      </li>
    </ul>
  </div>
</template>
