import { createRouter, createWebHistory } from 'vue-router'
import Stats from '../components/Stats.vue'
import CsvImport from '../components/CsvImport.vue'

const routes = [
  { path: '/stats', component: Stats },
  { path: '/import', component: CsvImport },
  { path: '/', redirect: '/stats' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
