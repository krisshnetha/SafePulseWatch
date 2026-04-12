@Component
export struct SOSPage {
  locationText: string = 'Location shared successfully'
  onBack: () => void = () => {}
  private readonly pageBg: string = '#0A182A'
  private readonly okBg: string = '#173B2D'

  build() {
    Column({ space: 14 }) {
      Text('SOS Confirmed')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#74E59A')

      Column({ space: 6 }) {
        Text('Emergency request sent')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F0FFF5')

        Text(this.locationText)
          .fontSize(15)
          .fontColor('#D9F4E2')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(this.okBg)
      .borderRadius(16)

      Column({ space: 4 }) {
        Text('What happens now')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFF8E1')

        Text('1. Your location is shared with responders')
          .fontSize(14)
          .fontColor('#E2ECF7')
        Text('2. The watch will vibrate on status updates')
          .fontSize(14)
          .fontColor('#E2ECF7')
        Text('3. Keep this screen visible if possible')
          .fontSize(14)
          .fontColor('#E2ECF7')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#1B2D45')
      .borderRadius(16)

      Button('RETURN TO DASHBOARD')
        .width('90%')
        .height(58)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#1E88E5')
        .fontColor(Color.White)
        .borderRadius(18)
        .onClick(() => this.onBack())

      Text('Accessibility: voice and haptic confirmations are active.')
        .fontSize(13)
        .fontColor('#BFD0E5')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.pageBg)
    .padding(14)
  }
}