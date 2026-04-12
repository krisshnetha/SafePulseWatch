import { NetworkService } from '../services/NetworkService'

@Component
export struct AdminPage {

  @State statusMessage: string = 'Ready'

  async trigger(type: string) {
    const success = await NetworkService.triggerAlert(
      type,
      'HIGH',
      'Evacuate immediately via nearest exit',
      'Demo Building'
    )

    this.statusMessage = success ? `${type} alert triggered` : 'Failed to trigger alert'
  }

  async clearAll() {
    await NetworkService.clearAllAlerts()
    this.statusMessage = 'All alerts cleared'
  }

  build() {
    Column({ space: 20 }) {

      // 🔴 Title
      Text('SafePulse Control Panel')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text('Trigger emergency scenarios for demo')
        .fontSize(14)
        .fontColor('#B0C4DE')

      // 🚨 Alert Buttons
      Column({ space: 12 }) {

        this.alertButton('🔥 FIRE', '#E53935')
        this.alertButton('🌊 FLOOD', '#1E88E5')
        this.alertButton('🌎 EARTHQUAKE', '#FBC02D')
        this.alertButton('🚑 MEDICAL', '#D81B60')
        this.alertButton('🚨 SECURITY', '#546E7A')

      }
      .width('100%')

      // 🧹 Clear Button
      Button('Clear All Alerts')
        .backgroundColor('#333')
        .fontColor(Color.White)
        .borderRadius(16)
        .padding(12)
        .onClick(() => this.clearAll())

      // 📢 Status Box
      Column() {
        Text('Status')
          .fontSize(14)
          .fontColor('#B0C4DE')

        Text(this.statusMessage)
          .fontSize(16)
          .fontColor(Color.White)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#0E1A2F')
      .borderRadius(16)

    }
    .padding(20)
    .backgroundColor('#071224')
    .width('100%')
    .height('100%')
  }

  // 🔥 Custom Button Component
  alertButton(label: string, color: string) {
    return Button(label)
      .width('100%')
      .backgroundColor(color)
      .fontColor(Color.White)
      .borderRadius(20)
      .padding(16)
      .onClick(() => {
        const type = label.split(' ')[1]
        this.trigger(type)
      })
  }
}