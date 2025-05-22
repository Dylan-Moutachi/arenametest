import { createRouter, createWebHistory } from 'vue-router'
import Stats from '../components/Stats.vue'
import CsvImport from '../components/CsvImport.vue'
import Sidekiq from '../components/Sidekiq.vue'

const routes = [
  { path: '/stats', component: Stats },
  { path: '/import', component: CsvImport },
  { path: '/', redirect: '/stats' },
  { path: '/sidekiq', component: Sidekiq }
]

  const router = createRouter({
    history: createWebHistory(),
    routes
  })
export default router
