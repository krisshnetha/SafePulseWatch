import { AlertStorageService, FireAlertRecord } from '../services/AlertStorageService'

@Component
export struct FireHistoryPage {
  onBack: () => void = () => {}

  @State items: Array<FireAlertRecord> = []

  aboutToAppear(): void {
    this.load()
  }

  async load(): Promise<void> {
    this.items = await AlertStorageService.getAlerts()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('< Back')
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(14)
          .onClick(() => this.onBack())

        Blank()

        Button('Refresh')
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(14)
          .onClick(() => {
            this.load()
          })
      }
      .width('100%')

      Text('Fire Alert History')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(this.items.length === 0 ? 'No alerts recorded yet.' : this.items.length.toString() + ' local alerts stored on watch')
        .fontSize(14)
        .fontColor('#9FB0C9')

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.items, (item: FireAlertRecord) => {
            Column({ space: 8 }) {
              Row() {
                Text('FIRE ALERT')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF8A80')

                Blank()

                Text((item.confidence * 100).toFixed(0) + '%')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FCD34D')
              }
              .width('100%')

              Text('Timestamp: ' + item.timestamp)
                .fontSize(13)
                .fontColor('#D7E2F1')

              Text('Method: ' + item.detectionMethod)
                .fontSize(13)
                .fontColor('#D7E2F1')
            }
            .width('100%')
            .padding(14)
            .borderRadius(16)
            .backgroundColor('#0F1B30')
            .border({
              width: 1,
              color: '#22314B'
            })
          }, (item: FireAlertRecord) => item.id)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#06101F')
  }
}
