@Component
export struct AlertPage {
  profileName: string = 'Vision'
  alertType: string = 'FIRE ALERT'
  onBack: () => void = () => {}
  onSOS: () => void = () => {}

  private getInstruction(): string {
    if (this.profileName === 'Vision') {
      return 'Fire detected. Audio and vibration guidance enabled.'
    }
    if (this.profileName === 'Hearing') {
      return 'FIRE ALERT. EVACUATE NOW. FOLLOW VISUAL DIRECTION.'
    }
    if (this.profileName === 'Speech') {
      return 'Fire detected. Tap SOS to send silent help request.'
    }
    if (this.profileName === 'Mobility') {
      return 'Accessible route activated. Avoid stairs.'
    }
    return 'Stay calm. Follow one instruction at a time.'
  }

  private getSubText(): string {
    if (this.profileName === 'Vision') {
      return 'Haptic mode active'
    }
    if (this.profileName === 'Hearing') {
      return 'Visual emergency mode active'
    }
    if (this.profileName === 'Speech') {
      return 'Silent communication ready'
    }
    if (this.profileName === 'Mobility') {
      return 'Accessible assistance ready'
    }
    return 'Calm guidance mode active'
  }

  private getBgColor(): string {
    if (this.profileName === 'Hearing') {
      return '#8B0000'
    }
    if (this.profileName === 'Speech') {
      return '#102040'
    }
    if (this.profileName === 'Mobility') {
      return '#1B263B'
    }
    if (this.profileName === 'Cognitive') {
      return '#0E1A2B'
    }
    return '#0B1020'
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