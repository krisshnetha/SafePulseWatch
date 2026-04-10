@Component
export struct NavigationPage {
  profileName: string = 'Vision'
  directionText: string = 'Move straight and turn slightly left'
  distanceText: string = 'Safe exit: 120m ahead'
  onBack: () => void = () => {}

  private getHeader(): string {
    if (this.profileName === 'Mobility') {
      return 'ACCESSIBLE ROUTE'
    }
    return 'SAFE ROUTE'
  }

  private getHint(): string {
    if (this.profileName === 'Vision') {
      return 'Audio/haptic guidance active'
    }
    if (this.profileName === 'Hearing') {
      return 'Visual route guidance active'
    }
    if (this.profileName === 'Mobility') {
      return 'Ramp/elevator route selected'
    }
    if (this.profileName === 'Speech') {
      return 'Silent assistance mode active'
    }
    return 'Step-by-step guidance active'
  }

  build() {
    Column({ space: 18 }) {
      Text(this.getHeader())
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')

      Text('→')
        .fontSize(48)
        .fontColor(Color.White)

      Text(this.getHint())
        .fontSize(16)
        .fontColor('#FFD54F')

      Text(this.directionText)
        .fontSize(20)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)

      Text(this.distanceText)
        .fontSize(18)
        .fontColor('#CCCCCC')

      Button('Back')
        .width('60%')
        .height(48)
        .fontSize(18)
        .backgroundColor('#555555')
        .fontColor(Color.White)
        .borderRadius(14)
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