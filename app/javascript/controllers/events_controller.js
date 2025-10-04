import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="events"
export default class extends Controller {
  static targets = ["genderSelect", "eventItem", "trackSection", "fieldSection", "notice"]

  connect() {
    // 页面加载时执行一次过滤
    this.filterByGender()
  }

  filterByGender() {
    const selectedGender = this.genderSelectTarget.value
    
    if (!selectedGender) {
      this.hideAllEvents()
      return
    }

    this.showFilteredEvents(selectedGender)
  }

  hideAllEvents() {
    // 隐藏所有项目并禁用复选框
    this.eventItemTargets.forEach(item => {
      item.style.display = 'none'
      const checkbox = item.querySelector('input[type="checkbox"]')
      if (checkbox) {
        checkbox.checked = false
        checkbox.disabled = true
      }
    })

    // 隐藏径赛和田赛分类
    if (this.hasTrackSectionTarget) {
      this.trackSectionTarget.style.display = 'none'
    }
    if (this.hasFieldSectionTarget) {
      this.fieldSectionTarget.style.display = 'none'
    }
    
    // 显示提示信息
    if (this.hasNoticeTarget) {
      this.noticeTarget.style.display = 'block'
    }
  }

  showFilteredEvents(selectedGender) {
    let hasTrackEvents = false
    let hasFieldEvents = false

    // 根据性别过滤项目
    this.eventItemTargets.forEach(item => {
      const eventGender = item.dataset.gender
      const eventType = item.dataset.eventType
      const checkbox = item.querySelector('input[type="checkbox"]')
      
      // 显示匹配性别的项目（包括混合项目）
      if (eventGender === selectedGender || eventGender === '混合') {
        item.style.display = 'flex'
        if (checkbox) checkbox.disabled = false
        
        if (eventType === 'track') hasTrackEvents = true
        if (eventType === 'field') hasFieldEvents = true
      } else {
        item.style.display = 'none'
        if (checkbox) {
          checkbox.checked = false
          checkbox.disabled = true
        }
      }
    })

    // 根据是否有可用项目来显示/隐藏分类标题
    if (this.hasTrackSectionTarget) {
      this.trackSectionTarget.style.display = hasTrackEvents ? 'block' : 'none'
    }
    if (this.hasFieldSectionTarget) {
      this.fieldSectionTarget.style.display = hasFieldEvents ? 'block' : 'none'
    }
    
    // 隐藏提示信息
    if (this.hasNoticeTarget) {
      this.noticeTarget.style.display = 'none'
    }
  }
}
