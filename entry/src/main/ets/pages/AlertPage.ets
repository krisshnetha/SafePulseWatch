@Component
export struct AlertPage {
  contactName: string = 'Emergency Contact'
  contactNumber: string = '+6500000000'
  statusText: string = 'Fire detected. Send emergency alert now.'
  isSending: boolean = false

  onSendAlert: () => void = () => {}
  onBack: () => void = () => {}
  onNavigate: () => void = () => {}

  @State flashOn: boolean = true
  private flashTimer: number = -1

  aboutToAppear(): void {
    this.startFlashing()
  }

  aboutToDisappear(): void {
    this.stopFlashing()
  }

  private startFlashing(): void {
    if (this.flashTimer !== -1) {
      return
    }

    this.flashTimer = setInterval(() => {
      this.flashOn = !this.flashOn
    }, 450)
  }

  private stopFlashing(): void {
    if (this.flashTimer !== -1) {
      clearInterval(this.flashTimer)
      this.flashTimer = -1
    }
  }

  build() {
    Column({ space: 12 }) {
      Blank().height(10)

      Text('FIRE')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.flashOn ? '#FFFFFF' : '#FFE2D8')

      Text('ALERT')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.flashOn ? '#FFFFFF' : '#FFD6CC')

      Text('EVACUATE IMMEDIATELY')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFF4EF')
        .maxLines(1)

      Column({ space: 6 }) {
        Text('Emergency Contact')
          .fontSize(10)
          .fontColor('#FFF1EB')

        Text(this.contactName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.contactNumber)
          .fontSize(12)
          .fontColor('#FFF1EB')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(14)
      .borderRadius(18)
      .backgroundColor(this.flashOn ? '#8F1200' : '#B91C00')

      Text(this.statusText)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(11)
        .fontColor('#FFF3EE')
        .maxLines(3)

      Button(this.isSending ? 'Sending...' : 'Alert Emergency Contact')
        .width('100%')
        .height(46)
        .enabled(!this.isSending)
        .backgroundColor('#FFF1EB')
        .fontColor('#8A1800')
        .fontSize(13)
        .borderRadius(18)
        .onClick(() => {
          this.onSendAlert()
        })

      Button('Open Navigation')
        .width('100%')
        .height(40)
        .backgroundColor('#202A44')
        .fontColor(Color.White)
        .fontSize(12)
        .borderRadius(16)
        .onClick(() => {
          this.onNavigate()
        })

      Button('Back')
        .width('100%')
        .height(38)
        .backgroundColor('#5B120A')
        .fontColor(Color.White)
        .fontSize(12)
        .borderRadius(16)
        .onClick(() => {
          this.onBack()
        })

      Blank().layoutWeight(1)
    }
    .padding({ left: 16, right: 16, top: 18, bottom: 18 })
    .width('100%')
    .height('100%')
    .backgroundColor(this.flashOn ? '#E12600' : '#7A0C00')
  }
}