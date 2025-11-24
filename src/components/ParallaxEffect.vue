<script setup>
import { onMounted, onUnmounted } from 'vue'

let rafId = null
let ticking = false
let parallaxElements = []
let handleParallax = null

onMounted(() => {
  parallaxElements = document.querySelectorAll('[data-parallax]')
  
  if (parallaxElements.length === 0) return
  
  handleParallax = () => {
    if (ticking) return
    ticking = true
    
    rafId = requestAnimationFrame(() => {
      const scrollTop = window.pageYOffset
      
      parallaxElements.forEach(element => {
        const speed = parseFloat(element.dataset.parallax) || 0.5
        const yPos = -(scrollTop * speed)
        element.style.transform = `translate3d(0, ${yPos}px, 0)` // GPU ускорение
      })
      
      ticking = false
    })
  }
  
  window.addEventListener('scroll', handleParallax, { passive: true })
})

onUnmounted(() => {
  if (handleParallax) {
    window.removeEventListener('scroll', handleParallax)
  }
  if (rafId) cancelAnimationFrame(rafId)
})
</script>

<template>
  <!-- Компонент без визуального содержимого -->
</template>

