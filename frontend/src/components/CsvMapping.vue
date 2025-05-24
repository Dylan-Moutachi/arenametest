<script setup>
import { defineProps, defineEmits } from "vue"

const props = defineProps({
  csvHeaders: {
    type: Array,
    required: true
  },
  modelValue: { // using v-model:columnMapping -> modelValue prop
    type: Object,
    required: true
  },
  bookingFields: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(["update:modelValue"])

// helper to update mapping reactively
const updateMapping = (key, value) => {
  emit("update:modelValue", {
    ...props.modelValue,
    [key]: value
  })
}

// compute headers not yet selected to avoid duplicates
const availableHeaders = (currentKey) => {
  return props.csvHeaders.filter(header =>
    !Object.entries(props.modelValue).some(
      ([key, selected]) => key !== currentKey && selected === header
    )
  )
}
</script>

<template>
  <div
    class="bg-gray-600 p-5 rounded border border-gray-300 max-h-[400px] overflow-auto"
    role="region"
    aria-label="CSV column mapping"
  >
    <h2 class="font-semibold mb-4 text-white">Map your CSV columns</h2>

    <div
      v-for="key in bookingFields"
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
        :id="key"
        class="flex-grow border border-gray-300 rounded px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-black"
        aria-required="true"
        :value="modelValue[key]"
        @change="e => updateMapping(key, e.target.value)"
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
</template>
