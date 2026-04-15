@Component
export struct WatchPage {
  selectedProfile: string = 'Blind'
  onBack: () => void = () => {}
  onNavigate: () => void = () => {}
  onSOS: () => void = () => {}

  private getModeLabel(): string {
    if (this.selectedProfile === 'Blind') {
      return 'Audio priority active'
    }
    if (this.selectedProfile === 'Deaf') {
      return 'Visual priority active'
    }
    if (this.selectedProfile === 'Speech') {
      return 'Silent SOS ready'
    }
    if (this.selectedProfile === 'Mobility') {
      return 'Accessible mode active'
    }
    return 'Calm guidance active'
  }

  @Builder
  profileChip(label: string) {
    Text(label)
      .fontSize(10)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedProfile === label ? Color.White : '#D7E4FF')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(12)
      .backgroundColor(this.selectedProfile === label ? '#3E8BFF' : '#17284A')
      .opacity(this.selectedProfile === label ? 1 : 0.9)
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Blank().height(18)

        Text('Watch')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textShadow({
            radius: 10,
            color: '#5BA3FF',
            offsetX: 0,
            offsetY: 0
          })

        Column({ space: 4 }) {
          Text('Wearable Mode')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .width('100%')
            .textShadow({
              radius: 12,
              color: '#4A8CFF',
              offsetX: 0,
              offsetY: 0
            })

          Text(this.getModeLabel())
            .fontSize(11)
            .fontColor('#E4EEFF')
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .borderRadius(22)
        .linearGradient({
          angle: 135,
          colors: [['#245DCC', 0.0], ['#132B56', 0.55], ['#09172E', 1.0]]
        })
        .shadow({
          radius: 20,
          color: '#2E6EFF55',
          offsetX: 0,
          offsetY: 6
        })

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            this.profileChip('Blind')
            this.profileChip('Deaf')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Row({ space: 8 }) {
            this.profileChip('Speech')
            this.profileChip('Mobility')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Row() {
            this.profileChip('Elderly')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding(10)
        .borderRadius(18)
        .backgroundColor('#0C1830')

        Button('Navigate')
          .width('100%')
          .height(40)
          .backgroundColor('#1FD06C')
          .fontColor(Color.White)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .shadow({
            radius: 14,
            color: '#1FD06C66',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => {
            this.onNavigate()
          })

        Button('Send SOS')
          .width('100%')
          .height(42)
          .backgroundColor('#FF5C5C')
          .fontColor(Color.White)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .shadow({
            radius: 14,
            color: '#FF5C5C66',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => {
            this.onSOS()
          })

        Button('Back')
          .width('100%')
          .height(36)
          .backgroundColor('#1A2740')
          .fontColor('#DDE8FF')
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.onBack()
          })

        Blank().height(34)
      }
      .padding({ left: 22, right: 22 })
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}