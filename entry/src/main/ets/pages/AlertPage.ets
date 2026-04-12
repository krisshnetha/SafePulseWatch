@Component
export struct AlertPage {
  profileName: string = 'Vision'
  alertType: string = 'FIRE ALERT'
  onBack: () => void = () => {}
  onSOS: () => void = () => {}
  private readonly dangerBg: string = '#2A0F1A'
  private readonly cardBg: string = '#3A1725'
  private readonly accent: string = '#FF6E6E'

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
    Scroll() {
      Column({ space: 12 }) {
        Text('Emergency Alert')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.accent)

        Column({ space: 6 }) {
          Text(this.alertType)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.getSeverityLabel())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFD9D9')

          Text(this.getSubText())
            .fontSize(15)
            .fontColor('#FFE4A3')
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.cardBg)
        .borderRadius(16)

        Text(this.getInstruction())
          .width('100%')
          .fontSize(this.profileName === 'Hearing' ? 22 : 19)
          .fontWeight(this.profileName === 'Hearing' ? FontWeight.Bold : FontWeight.Medium)
          .fontColor('#F7FBFF')
          .textAlign(TextAlign.Start)
          .lineHeight(26)

        Column({ space: 4 }) {
          Text('Recommended Action')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF2C2')

          Text('1. Move to shelter immediately')
            .fontSize(15)
            .fontColor('#E7EEF9')
          Text('2. Keep watch on wrist for live updates')
            .fontSize(15)
            .fontColor('#E7EEF9')
          Text('3. Tap SOS if support is required')
            .fontSize(15)
            .fontColor('#E7EEF9')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#233248')
        .borderRadius(16)

        Button('SEND SOS')
          .width('90%')
          .height(62)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#D32F2F')
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => this.onSOS())

        Button('BACK TO DASHBOARD')
          .width('90%')
          .height(52)
          .fontSize(17)
          .backgroundColor('#546E7A')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => this.onBack())
      }
      .width('100%')
      .padding(14)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.profileName === 'Hearing' ? '#4A1111' : (this.profileName === 'Speech' ? '#0E223E' : (this.profileName === 'Mobility' ? '#1B263B' : this.dangerBg)))
  }
}