@Component
export struct AlertPage {
  profileName: string = 'Blind'
  alertType: string = 'FIRE'
  alertInstruction: string = 'Evacuate immediately.'
  onBack: () => void = () => {}
  onSOS: () => void = () => {}

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

  build() {
    Column({ space: 18 }) {
      Text('EMERGENCY ALERT')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B5F')

      Text(this.alertType)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(this.getModeHint())
        .fontSize(16)
        .fontColor('#FFD36B')

      Text(this.alertInstruction)
        .fontSize(this.profileName === 'Deaf' ? 24 : 18)
        .fontWeight(this.profileName === 'Deaf' ? FontWeight.Bold : FontWeight.Normal)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .margin({ left: 18, right: 18 })

      if (this.profileName === 'Blind') {
        Text('🔊 Voice guidance: Exit is ahead.')
          .fontSize(16)
          .fontColor('#8FD3FF')
      }

      Row({ space: 12 }) {
        Button('SEND SOS')
          .layoutWeight(1)
          .height(56)
          .backgroundColor('#E13333')
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => this.onSOS())

        Button('BACK')
          .layoutWeight(1)
          .height(56)
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => this.onBack())
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
    .backgroundColor('#06101F')
  }
}