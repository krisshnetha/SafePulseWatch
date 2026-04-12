@Component
export struct AlertPage {
  profileName: string = 'Blind'
  alertType: string = 'FIRE'
  alertInstruction: string = 'Evacuate immediately.'
  onBack: () => void = () => {}
  onSOS: () => void = () => {}
  private readonly dangerBg: string = '#2A0F1A'
  private readonly cardBg: string = '#3A1725'
  private readonly accent: string = '#FF6E6E'

  private getModeHint(): string {
    if (this.profileName === 'Blind') {
      return 'Audio + haptic emergency guidance'
    }
    if (this.profileName === 'Deaf') {
      return 'Large visual emergency mode'
    }
    if (this.profileName === 'Speech') {
      return 'Silent SOS mode active'
    }
    if (this.profileName === 'Mobility') {
      return 'Accessible route guidance active'
    }
    return 'Calm step-by-step mode active'
  }

  private getSeverityLabel(): string {
    if (this.alertType.includes('FIRE')) {
      return 'Severity: Extreme'
    }
    if (this.alertType.includes('FLOOD') || this.alertType.includes('RAIN')) {
      return 'Severity: Severe'
    }
    return 'Severity: Moderate'
  }

  build() {
    Column({ space: 16 }) {
      Text('EMERGENCY ALERT')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF5252')

      Text(this.alertType)
        .fontSize(22)
        .fontColor(Color.White)

      Text(this.getSubText())
        .fontSize(16)
        .fontColor('#FFD54F')

      Text(this.getInstruction())
        .fontSize(this.profileName === 'Hearing' ? 22 : 18)
        .fontWeight(this.profileName === 'Hearing' ? FontWeight.Bold : FontWeight.Normal)
        .fontColor('#EEEEEE')
        .textAlign(TextAlign.Center)
        .margin(12)

      Button('SEND SOS')
        .width('85%')
        .height(60)
        .fontSize(22)
        .backgroundColor('#C62828')
        .fontColor(Color.White)
        .borderRadius(18)
        .onClick(() => this.onSOS())

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
    .backgroundColor(this.getBgColor())
    .padding(18)
  }
}