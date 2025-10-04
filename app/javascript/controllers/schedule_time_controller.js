import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["heatSelect", "dateInput", "timeInput", "endTimeDisplay", "scheduledAtHidden", "endAtHidden", "avgTimeDisplay"]

  connect() {
    this.heatsData = JSON.parse(this.heatSelectTarget.dataset.heats || "[]")
    this.updateAvgTime()
    this.calculateEndTime()
  }

  updateAvgTime() {
    const heatId = parseInt(this.heatSelectTarget.value)
    const heat = this.heatsData.find(h => h.id === heatId)
    
    if (heat && heat.avg_time) {
      this.avgTime = heat.avg_time
      this.avgTimeDisplayTarget.textContent = this.avgTime
    } else {
      this.avgTime = 0
      this.avgTimeDisplayTarget.textContent = "--"
    }
    
    this.calculateEndTime()
  }

  calculateEndTime() {
    if (!this.hasDateInputTarget || !this.hasTimeInputTarget || !this.avgTime) {
      return
    }

    const date = this.dateInputTarget.value
    const time = this.timeInputTarget.value

    if (!date || !time) {
      return
    }

    try {
      // 组合日期和时间（作为本地时间）
      const startDateTime = new Date(`${date}T${time}`)
      
      // 格式化为本地日期时间字符串（Rails 可以解析的格式）
      const year = startDateTime.getFullYear()
      const month = String(startDateTime.getMonth() + 1).padStart(2, '0')
      const day = String(startDateTime.getDate()).padStart(2, '0')
      const hours = String(startDateTime.getHours()).padStart(2, '0')
      const minutes = String(startDateTime.getMinutes()).padStart(2, '0')
      const seconds = String(startDateTime.getSeconds()).padStart(2, '0')
      
      // 设置 scheduled_at 隐藏字段（本地时间格式）
      this.scheduledAtHiddenTarget.value = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
      
      // 添加平均时长（分钟）
      const endDateTime = new Date(startDateTime.getTime() + this.avgTime * 60000)
      
      // 格式化显示
      const endTimeStr = endDateTime.toLocaleTimeString('zh-CN', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: false
      })
      
      this.endTimeDisplayTarget.value = endTimeStr
      
      // 设置 end_at 隐藏字段（本地时间格式）
      const endYear = endDateTime.getFullYear()
      const endMonth = String(endDateTime.getMonth() + 1).padStart(2, '0')
      const endDay = String(endDateTime.getDate()).padStart(2, '0')
      const endHours = String(endDateTime.getHours()).padStart(2, '0')
      const endMinutes = String(endDateTime.getMinutes()).padStart(2, '0')
      const endSeconds = String(endDateTime.getSeconds()).padStart(2, '0')
      
      this.endAtHiddenTarget.value = `${endYear}-${endMonth}-${endDay} ${endHours}:${endMinutes}:${endSeconds}`
    } catch (e) {
      console.error("计算结束时间失败:", e)
    }
  }
}
