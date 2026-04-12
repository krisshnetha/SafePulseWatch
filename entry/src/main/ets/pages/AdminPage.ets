import { NetworkService, AlertItem } from '../services/NetworkService'

@Component
export struct AdminPage {
  onBack: () => void = () => {}

  @State selectedSeverity: string = 'HIGH'
  @State alerts: Array<AlertItem> = []

  aboutToAppear() {
    this.loadAlerts()
  }

  async loadAlerts() {
    this.alerts = await NetworkService.fetchAlertHistory()
  }

  private getInstruction(type: string): string {
    if (type === 'FIRE') {
      return 'Evacuate immediately via nearest exit. Do not use elevators.'
    }
    if (type === 'EARTHQUAKE') {
      return 'Drop, Cover, Hold On. Move away from windows.'
    }
    if (type === 'FLOOD') {
      return 'Flash flood warning. Move to higher ground.'
    }
    if (type === 'EVACUATION') {
      return 'Proceed to Exit B. Follow staff instructions.'
    }
    if (type === 'MEDICAL') {
      return 'Medical emergency nearby. Keep route clear.'
    }
    return 'Security incident reported. Await further guidance.'
  }

  private async trigger(type: string) {
    await NetworkService.triggerAlert(type, this.selectedSeverity, this.getInstruction(type), 'Main Building')
    await this.loadAlerts()
  }

  private severityChip(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(this.selectedSeverity === text ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(Color.White)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(14)
      .backgroundColor(this.selectedSeverity === text ? '#FF7A1A' : '#23324D')
      .onClick(() => {
        this.selectedSeverity = text
      })
  }

  private alertButton(text: string, color: string) {
    Column({ space: 8 }) {
      Text(text)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text('Trigger')
        .fontSize(13)
        .fontColor('#E6EDF7')
    }
    .width('31%')
    .height(100)
    .borderRadius(18)
    .backgroundColor(color)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.trigger(text)
    })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('< Back')
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(() => this.onBack())

          Blank()

          Button('Clear All')
            .backgroundColor('#3A1A1A')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(async () => {
              await NetworkService.clearAllAlerts()
              await this.loadAlerts()
            })
        }
        .width('100%')

        Text('Admin — Alert Trigger')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('ALERT SEVERITY')
          .fontSize(13)
          .fontColor('#8FA2C0')

        Row({ space: 8 }) {
          this.severityChip('LOW')
          this.severityChip('MEDIUM')
          this.severityChip('HIGH')
          this.severityChip('CRITICAL')
        }

        Text('TRIGGER EMERGENCY ALERT')
          .fontSize(13)
          .fontColor('#8FA2C0')

        Row({ space: 10 }) {
          this.alertButton('FIRE', '#E52626')
          this.alertButton('EARTHQUAKE', '#D39B11')
          this.alertButton('FLOOD', '#2D6CFF')
        }

        Row({ space: 10 }) {
          this.alertButton('EVACUATION', '#943BFF')
          this.alertButton('MEDICAL', '#E7368D')
          this.alertButton('SECURITY', '#697284')
        }

        Text('ACTIVE ALERTS (' + this.alerts.length.toString() + ')')
          .fontSize(13)
          .fontColor('#8FA2C0')

        ForEach(this.alerts, (item: AlertItem) => {
          Column({ space: 6 }) {
            Row() {
              Text(item.type)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF7A7A')
              Text(item.severity)
                .fontSize(12)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(10)
                .backgroundColor('#6B1A1A')
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Text(item.instruction)
              .fontSize(14)
              .fontColor('#D3DDF0')

            Text(item.timestamp)
              .fontSize(12)
              .fontColor('#7F93B5')
          }
          .width('100%')
          .padding(16)
          .borderRadius(18)
          .backgroundColor('#0F1B30')
          .border({
            width: 1,
            color: '#7A1F2A'
          })
        }, (item: AlertItem) => item.id)
      }
      .padding(20)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}