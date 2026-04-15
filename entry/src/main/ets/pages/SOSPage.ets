@Component
export struct SOSPage {
  locationText: string = 'SOS sent successfully'
  onBack: () => void = () => {}

  @State resendCount: number = 0

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Blank().height(20)

        Text('SOS Sent')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Column({ space: 6 }) {
          Text('Emergency request created')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.locationText)
            .fontSize(10)
            .fontColor('#D6E2F5')
            .textAlign(TextAlign.Center)
            .maxLines(4)

          if (this.resendCount > 0) {
            Text('Resent ' + this.resendCount.toString() + ' time(s)')
              .fontSize(10)
              .fontColor('#F9D2B2')
          }
        }
        .width('100%')
        .padding(16)
        .borderRadius(22)
        .backgroundColor('#12284C')

        Column({ space: 6 }) {
          Row({ space: 8 }) {
            Text('✓').fontSize(12).fontColor('#53E08C')
            Text('Location captured').fontSize(11).fontColor(Color.White)
          }
          .width('100%')

          Row({ space: 8 }) {
            Text('✓').fontSize(12).fontColor('#53E08C')
            Text('Emergency contact notified').fontSize(11).fontColor(Color.White)
          }
          .width('100%')

          Row({ space: 8 }) {
            Text('✓').fontSize(12).fontColor('#53E08C')
            Text('Awaiting acknowledgement').fontSize(11).fontColor(Color.White)
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
        .borderRadius(18)
        .backgroundColor('#0E1A30')

        Button('Send Again')
          .width('100%')
          .height(38)
          .backgroundColor('#2A4F9B')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.resendCount += 1
          })

        Button('Back Home')
          .width('100%')
          .height(42)
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .fontSize(13)
          .borderRadius(18)
          .onClick(() => {
            this.onBack()
          })

        Blank().height(36)
      }
      .padding({ left: 22, right: 22 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}