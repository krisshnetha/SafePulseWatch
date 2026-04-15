@Component
export struct AlertPage {
  profileName: string = 'Blind'
  alertType: string = 'FIRE'
  alertInstruction: string = 'Evacuate immediately via nearest exit.'
  onBack: () => void = () => {}
  onSOS: () => void = () => {}
  onNavigate: () => void = () => {}

  @State acknowledged: boolean = false

  getModeLabel(): string {
    if (this.profileName === 'Blind') {
      return 'Audio Priority'
    }
    if (this.profileName === 'Deaf') {
      return 'Visual Priority'
    }
    if (this.profileName === 'Speech') {
      return 'Silent SOS Ready'
    }
    if (this.profileName === 'Mobility') {
      return 'Accessible Route'
    }
    return 'Calm Guidance'
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Blank().height(20)

        Text('Alert')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Button('Back')
          .width('100%')
          .height(34)
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.onBack()
          })

        Column({ space: 8 }) {
          Row() {
            Text('LIVE ALERT')
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFE9DD')

            Blank()

            Text('HIGH')
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(8)
              .backgroundColor('#C94E1E')
          }
          .width('100%')

          Text(this.alertType)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.alertInstruction)
            .fontSize(11)
            .fontColor(Color.White)
            .maxLines(3)
            .width('100%')

          Row({ space: 6 }) {
            Text(this.profileName)
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor('#E98577')

            Text(this.getModeLabel())
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor('#B85B32')
          }
        }
        .width('100%')
        .padding(16)
        .borderRadius(22)
        .backgroundColor('#FF5A1F')

        if (this.acknowledged) {
          Text('Alert acknowledged')
            .fontSize(11)
            .fontColor('#CDEDD9')
        }

        Button('Send SOS')
          .width('100%')
          .height(40)
          .backgroundColor('#FFD9B8')
          .fontColor('#5A2400')
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.onSOS()
          })

        Button('Open Route')
          .width('100%')
          .height(38)
          .backgroundColor('#2A4F9B')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.onNavigate()
          })

        Button(this.acknowledged ? 'Acknowledged' : 'Acknowledge')
          .width('100%')
          .height(38)
          .backgroundColor('#14233A')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.acknowledged = true
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