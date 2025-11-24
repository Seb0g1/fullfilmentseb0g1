<template>
  <div>
    <Header />
    <main>
      <HeroSection />
      <MarketplacesSection />
      <AdvantagesSection />
      <ProcessSection />
      <PricingSection />
      <CalculatorSection />
      <FAQSection />
      <ContactSection />
    </main>
    <Footer />
    <Logistics3D />
    <ParticleBackground />
    <SpeedBackground />
    <ManagerChat />
    <ScrollToTop />
    <ReadingProgress />
    <SmoothScroll />
  </div>
</template>

<script setup>
import { onMounted, defineAsyncComponent } from 'vue'
import Header from '../components/Header.vue'
import HeroSection from '../components/HeroSection.vue'
import MarketplacesSection from '../components/MarketplacesSection.vue'
import AdvantagesSection from '../components/AdvantagesSection.vue'
import ProcessSection from '../components/ProcessSection.vue'
import PricingSection from '../components/PricingSection.vue'
import CalculatorSection from '../components/CalculatorSection.vue'
import FAQSection from '../components/FAQSection.vue'
import ContactSection from '../components/ContactSection.vue'
import Footer from '../components/Footer.vue'
import ManagerChat from '../components/ManagerChat.vue'
import ScrollToTop from '../components/ScrollToTop.vue'
import ReadingProgress from '../components/ReadingProgress.vue'
import SmoothScroll from '../components/SmoothScroll.vue'

// Lazy load тяжелых компонентов
const Logistics3D = defineAsyncComponent(() => import('../components/Logistics3D.vue'))
const ParticleBackground = defineAsyncComponent(() => import('../components/ParticleBackground.vue'))
const SpeedBackground = defineAsyncComponent(() => import('../components/SpeedBackground.vue'))

onMounted(() => {
  // Глобальные настройки анимаций при скролле (оптимизировано)
  const observerOptions = {
    threshold: 0.05, // Уменьшено для более раннего срабатывания
    rootMargin: '50px 0px -50px 0px' // Оптимизировано
  }

  // Используем один observer для всех элементов
  const observer = new IntersectionObserver((entries) => {
    // Используем requestAnimationFrame для батчинга обновлений
    requestAnimationFrame(() => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-in')
          // Отключаем наблюдение после анимации для экономии ресурсов
          observer.unobserve(entry.target)
        }
      })
    })
  }, observerOptions)

  // Отложенная инициализация для лучшей производительности
  requestAnimationFrame(() => {
    const sections = document.querySelectorAll('.fade-in-section')
    sections.forEach(el => observer.observe(el))
  })
})
</script>
