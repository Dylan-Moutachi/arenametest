<script setup>
import { ref, onMounted, watch } from 'vue'

const bookings = ref([])
const loading = ref(true)
const error = ref(null)

const searchShow = ref('')
const debouncedSearch = ref('')
let debounceTimeout = null

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

watch(searchShow, (newVal) => {
  clearTimeout(debounceTimeout)
  debounceTimeout = setTimeout(() => {
    debouncedSearch.value = newVal.trim()
    pagination.value.current_page = 1
    fetchBookings()
  }, 300)
})

const fetchBookings = async () => {
  loading.value = true
  error.value = null

  try {
    const params = new URLSearchParams()
    if (debouncedSearch.value) params.append('show', debouncedSearch.value)
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

onMounted(fetchBookings)

const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.total_pages) {
    pagination.value.current_page = page
    fetchBookings()
  }
}
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6">Statistics</h1>

    <div class="flex items-center gap-4 mb-6">
      <input
        type="text"
        v-model="searchShow"
        placeholder="Search show"
        class="border border-gray-300 rounded px-3 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />

      <router-link
        to="/import"
        class="ml-auto text-white bg-black hover:bg-gray-900 px-4 py-2 rounded transition"
      >
        Import CSV
      </router-link>
    </div>

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

    <div v-if="loading" class="text-gray-500">Loading...</div>
    <div v-if="error" class="text-red-600 font-semibold">{{ error }}</div>

    <ul v-if="!loading && !error" class="space-y-2">
      <li
        v-for="booking in bookings"
        :key="booking.id"
        class="border border-gray-200 rounded p-3"
      >
        <span class="font-semibold">{{ booking.first_name }} {{ booking.last_name }}</span> -
        Age: <span>{{ booking.age || "Unknown" }}</span> |
        Show: <span class="text-blue-500">{{ booking.show }}</span> |
        Price: <span class="text-green-500">{{ booking.price }}€</span>
      </li>
    </ul>

    <!-- Pagination controls -->
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
