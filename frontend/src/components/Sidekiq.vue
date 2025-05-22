<template>
  <div style="height: 100vh; width: 100vw;">
    <iframe
      src="http://localhost:3000/sidekiq"
      style="width: 100%; height: 100%; border: none;"
      title="Sidekiq UI"
    ></iframe>
  </div>
</template>

<script>
export default {
  name: 'Sidekiq'
}
</script>
