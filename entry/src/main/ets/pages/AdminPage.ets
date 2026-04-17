import { NetworkService } from '../services/NetworkService'

@Component
export struct AdminPage {
  onBack: () => void = () => {}

  @State statusText: string = 'Ready to trigger fire alert.'
  @State isSending: boolean = false

  private async triggerFireAlert(): Promise<void> {
    if (this.isSending) {
      return
    }

    this.isSending = true
    this.statusText = 'Triggering fire alert...'

    const ok: boolean = await NetworkService.triggerAlert(
      'FIRE ALERT',
      'HIGH',
      'Fire detected nearby. Send alert to your emergency contact immediately.',
      'Demo Zone'
    )

    this.isSending = false
    this.statusText = ok ? 'Fire alert triggered successfully.' : 'Failed to trigger fire alert.'
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Blank().height(14)

        Text('ALERT CONTROL')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)

        Text(' Fire Trigger')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(11)
          .fontColor('#D3E2FF')

        Column({ space: 10 }) {
          Text('Fire Alert is detected.')
            .fontSize(12)
            .fontColor('#FFE7DD')
            .textAlign(TextAlign.Center)
            .width('100%')
            .maxLines(3)

          Text(this.statusText)
            .fontSize(11)
            .fontColor('#FFF1EB')
            .textAlign(TextAlign.Center)
            .width('100%')
            .maxLines(3)
        }
        .width('100%')
        .padding(16)
        .borderRadius(20)
        .backgroundColor('#C94E1E')

        Button(this.isSending ? 'Triggering...' : 'Trigger Fire Alert')
          .width('100%')
          .height(46)
          .enabled(!this.isSending)
          .backgroundColor('#FFE3D3')
          .fontColor('#7A2500')
          .fontSize(13)
          .borderRadius(18)
          .onClick(() => {
            this.triggerFireAlert()
          })

        Button('Back')
          .width('100%')
          .height(42)
          .backgroundColor('#2A3D5C')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.onBack()
          })

        Blank().height(36)
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 18 })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}