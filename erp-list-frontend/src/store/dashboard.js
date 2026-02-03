import { defineStore } from 'pinia'
import { ref } from 'vue'

const STORAGE_KEY_COLLAPSED = 'dashboard_guide_collapsed'
const STORAGE_KEY_SECTION_HIDDEN = 'dashboard_guide_section_hidden'

export const useDashboardStore = defineStore('dashboard', () => {
  const guideCollapsed = ref(localStorage.getItem(STORAGE_KEY_COLLAPSED) === 'true')
  const guideSectionHidden = ref(localStorage.getItem(STORAGE_KEY_SECTION_HIDDEN) === 'true')

  function toggleGuideCollapsed() {
    guideCollapsed.value = !guideCollapsed.value
    localStorage.setItem(STORAGE_KEY_COLLAPSED, String(guideCollapsed.value))
  }

  function hideGuideSection() {
    guideSectionHidden.value = true
    localStorage.setItem(STORAGE_KEY_SECTION_HIDDEN, 'true')
  }

  function showGuideSection() {
    guideSectionHidden.value = false
    localStorage.setItem(STORAGE_KEY_SECTION_HIDDEN, 'false')
  }

  /** 顶栏下拉：切换初始化引导模块显示/隐藏 */
  function toggleGuideSectionVisible() {
    guideSectionHidden.value = !guideSectionHidden.value
    localStorage.setItem(STORAGE_KEY_SECTION_HIDDEN, String(guideSectionHidden.value))
  }

  return {
    guideCollapsed,
    guideSectionHidden,
    toggleGuideCollapsed,
    hideGuideSection,
    showGuideSection,
    toggleGuideSectionVisible
  }
})
