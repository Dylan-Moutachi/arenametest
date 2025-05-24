<script setup>
import { ref } from 'vue'
import EventSearchBar from './EventSearchBar.vue'

const bookings = ref([])
const loading = ref(true)
const error = ref(null)

const lastSearchedEvent = ref('')

const stats = ref({
  average_age: null,
  average_price: null,
  total_revenue: null,
  booking_count: null,
  unique_buyers_count: null
})

const pagination = ref({
  current_page: 1,
  total_pages: 1,
  per_page: 20,
  total_count: 0
})

// Fetch bookings from API
const fetchBookings = async () => {
  loading.value = true
  error.value = null

  try {
    const params = new URLSearchParams()
    if (lastSearchedEvent.value) params.append('event', lastSearchedEvent.value)
    params.append('page', pagination.value.current_page)
    params.append('per_page', pagination.value.per_page)

    const response = await fetch(`http://localhost:3000/api/v1/bookings?${params.toString()}`)
    if (!response.ok) throw new Error('Bookings loading error')

    const data = await response.json()
    bookings.value = data.bookings
    stats.value = data.stats
    pagination.value = data.pagination
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

// Triggered by EventSearchBar
const handleSearch = (query) => {
  pagination.value.current_page = 1
  lastSearchedEvent.value = query || ''
  fetchBookings()
}

// Pagination
const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.total_pages) {
    pagination.value.current_page = page
    fetchBookings()
  }
}

// Initial load
fetchBookings()
</script>

<template>
  <div class="w-[800px] mx-auto px-6 py-8 min-h-screen flex flex-col">
    <h1 class="text-3xl font-bold mb-6">Statistics</h1>

    <div class="flex justify-between">
      <EventSearchBar @search="handleSearch" />

      <router-link
        to="/import"
        class="text-white bg-black hover:bg-white hover:text-black px-4 py-2 rounded transition mb-4"
      >
        Import CSV
      </router-link>
    </div>

    <!-- Stats cards -->
    <div
      v-if="!loading && !error"
      class="bg-white shadow border border-gray-200 rounded-lg p-4 mb-6 grid grid-cols-1 sm:grid-cols-5 gap-4 text-center"
    >
      <div>
        <div class="text-gray-500 text-sm">Bookings</div>
        <div class="text-xl font-semibold text-blue-600">{{ stats.booking_count }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Unique Buyers</div>
        <div class="text-xl font-semibold text-gray-600">{{ stats.unique_buyers_count || "-" }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Average Age</div>
        <div class="text-xl font-semibold text-gray-600">{{ stats.average_age || "-" }}</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Average Price</div>
        <div class="text-xl font-semibold text-gray-600">{{ stats.average_price || "-" }} €</div>
      </div>
      <div>
        <div class="text-gray-500 text-sm">Total Revenue</div>
        <div class="text-xl font-semibold text-green-600">{{ stats.total_revenue || "-" }} €</div>
      </div>
    </div>

    <!-- Loader -->
    <div v-if="loading" class="flex justify-center items-center py-10">
      <svg class="animate-spin h-8 w-8 text-gray-300" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
      </svg>
    </div>

    <!-- Error -->
    <div v-if="error" class="text-red-600 font-semibold">{{ error }}</div>

    <!-- Current search -->
    <div v-if="!loading && !error" class="mb-2 text-sm text-white">
      Showing results for: <span class="font-semibold text-white">{{ lastSearchedEvent || 'All events' }}</span>
    </div>

    <!-- Booking list -->
    <ul v-if="!loading && !error" class="space-y-2">
      <li v-for="booking in bookings" :key="booking.id" class="border border-gray-200 rounded p-3">
        <span class="font-semibold">{{ booking.first_name }} {{ booking.last_name }}</span> -
        Age: <span>{{ booking.age || "Unknown" }}</span> |
        Event: <span class="text-blue-500">{{ booking.event }}</span> |
        Price: <span class="text-green-500">{{ booking.price }}€</span>
      </li>
    </ul>

    <!-- Pagination -->
    <div class="flex justify-center gap-2 mt-6" v-if="pagination.total_pages > 1">
      <button
        :disabled="pagination.current_page === 1"
        @click="goToPage(pagination.current_page - 1)"
        class="px-3 py-1 border rounded disabled:opacity-50"
      >
        Prev
      </button>

      <span>Page {{ pagination.current_page }} / {{ pagination.total_pages }}</span>

      <button
        :disabled="pagination.current_page === pagination.total_pages"
        @click="goToPage(pagination.current_page + 1)"
        class="px-3 py-1 border rounded disabled:opacity-50"
      >
        Next
      </button>
    </div>
  </div>
</template>
