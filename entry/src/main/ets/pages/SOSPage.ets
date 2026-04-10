@Component
export struct SOSPage {
  locationText: string = 'Location shared successfully'
  onBack: () => void = () => {}

  build() {
    Column({ space: 18 }) {
      Text('SOS SENT')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')

      Text('Help request sent successfully')
        .fontSize(18)
        .fontColor(Color.White)

      Text(this.locationText)
        .fontSize(16)
        .fontColor('#CCCCCC')
        .textAlign(TextAlign.Center)

      Button('Return Home')
        .width('80%')
        .height(56)
        .fontSize(20)
        .backgroundColor('#1565C0')
        .fontColor(Color.White)
        .borderRadius(16)
        .onClick(() => this.onBack())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#0B1020')
    .padding(16)
  }
}