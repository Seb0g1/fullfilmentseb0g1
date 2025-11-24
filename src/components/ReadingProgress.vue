<template>
  <div class="reading-progress" :style="{ width: `${progress}%` }"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const progress = ref(0)
let rafId = null
let ticking = false

const updateProgress = () => {
  if (ticking) return
  ticking = true
  
  rafId = requestAnimationFrame(() => {
    const windowHeight = window.innerHeight
    const documentHeight = document.documentElement.scrollHeight
    const scrollTop = window.scrollY
    const totalScroll = documentHeight - windowHeight
    const scrollProgress = (scrollTop / totalScroll) * 100
    progress.value = Math.min(100, Math.max(0, scrollProgress))
    ticking = false
  })
}

// Throttled версия для resize
let resizeTimeout
const handleResize = () => {
  clearTimeout(resizeTimeout)
  resizeTimeout = setTimeout(updateProgress, 150)
}

onMounted(() => {
  window.addEventListener('scroll', updateProgress, { passive: true })
  window.addEventListener('resize', handleResize, { passive: true })
  updateProgress()
})

onUnmounted(() => {
  window.removeEventListener('scroll', updateProgress)
  window.removeEventListener('resize', handleResize)
  if (rafId) cancelAnimationFrame(rafId)
  clearTimeout(resizeTimeout)
})
</script>

<style scoped>
.reading-progress {
  position: fixed;
  top: 0;
  left: 0;
  height: 3px;
  background: var(--gradient-primary);
  z-index: 10000;
  transition: width 0.1s ease-out;
  box-shadow: 0 0 10px rgba(99, 102, 241, 0.5);
  will-change: width; /* Оптимизация для плавной анимации */
  transform: translateZ(0); /* GPU ускорение */
  contain: layout style paint; /* Изоляция для производительности */
}
</style>

