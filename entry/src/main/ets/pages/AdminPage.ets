import { NetworkService } from '../services/NetworkService'

@Component
export struct AdminPage {
  onBack: () => void = () => {}

  @State statusMessage: string = 'Ready'
  @State selectedSeverity: string = 'HIGH'

  async triggerAlert(type: string) {
    const ok: boolean = await NetworkService.triggerAlert(
      type,
      this.selectedSeverity,
      'Evacuate immediately via nearest exit',
      'Demo Building'
    )
    this.statusMessage = ok ? type + ' alert triggered' : 'Trigger failed'
  }

  async clearAlerts() {
    await NetworkService.clearAllAlerts()
    this.statusMessage = 'All alerts cleared'
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Blank().height(20)

        Text('Admin')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Button('Back')
          .width('100%')
          .height(34)
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.onBack()
          })

        Text('Demo emergency control')
          .fontSize(11)
          .fontColor('#B0C4DE')

        Row({ space: 6 }) {
          Text('LOW')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.selectedSeverity === 'LOW' ? '#E35B44' : '#23324D')
            .onClick(() => {
              this.selectedSeverity = 'LOW'
            })

          Text('HIGH')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.selectedSeverity === 'HIGH' ? '#E35B44' : '#23324D')
            .onClick(() => {
              this.selectedSeverity = 'HIGH'
            })

          Text('CRITICAL')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.selectedSeverity === 'CRITICAL' ? '#E35B44' : '#23324D')
            .onClick(() => {
              this.selectedSeverity = 'CRITICAL'
            })
        }

        Button('FIRE')
          .width('100%')
          .height(38)
          .backgroundColor('#E53935')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.triggerAlert('FIRE')
          })

        Button('FLOOD')
          .width('100%')
          .height(38)
          .backgroundColor('#1E88E5')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.triggerAlert('FLOOD')
          })

        Button('QUAKE')
          .width('100%')
          .height(38)
          .backgroundColor('#F2B705')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.triggerAlert('QUAKE')
          })

        Button('MEDICAL')
          .width('100%')
          .height(38)
          .backgroundColor('#D81B60')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.triggerAlert('MEDICAL')
          })

        Button('SECURITY')
          .width('100%')
          .height(38)
          .backgroundColor('#546E7A')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.triggerAlert('SECURITY')
          })

        Button('Clear All')
          .width('100%')
          .height(38)
          .backgroundColor('#2A4F9B')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.clearAlerts()
          })

        Column({ space: 4 }) {
          Text('STATUS')
            .fontSize(10)
            .fontColor('#B0C4DE')

          Text(this.statusMessage)
            .fontSize(11)
            .fontColor(Color.White)
            .maxLines(2)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#0E1A2F')
        .borderRadius(16)

        Blank().height(36)
      }
      .padding({ left: 22, right: 22 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#071224')
  }
}