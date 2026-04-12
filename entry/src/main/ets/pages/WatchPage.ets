import { NetworkService, AlertItem } from '../services/NetworkService'

@Component
export struct WatchPage {
  userName: string = ''
  selectedProfile: string = 'Blind'
  onBack: () => void = () => {}
  onNavigate: () => void = () => {}
  onSOS: () => void = () => {}

  @State activeProfile: string = 'Blind'
  @State currentAlert: AlertItem | null = null

  aboutToAppear() {
    this.activeProfile = this.selectedProfile
    this.loadAlert()
  }

  async loadAlert() {
    this.currentAlert = await NetworkService.fetchCurrentAlert()
  }

  private profileChip(label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(Color.White)
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(14)
      .backgroundColor(this.activeProfile === label ? '#243653' : '#1A2740')
      .onClick(() => {
        this.activeProfile = label
      })
  }

  private getBodyText(): string {
    if (this.currentAlert === null) {
      return 'No active alert. Trigger an alert from Admin Panel to see adaptive response.'
    }

    if (this.activeProfile === 'Blind') {
      return 'Fire alert. Audio guidance active. Exit is ahead.'
    }
    if (this.activeProfile === 'Deaf') {
      return 'FIRE ALERT. EVACUATE NOW.'
    }
    if (this.activeProfile === 'Speech') {
      return 'Tap SOS to send silent help request.'
    }
    if (this.activeProfile === 'Mobility') {
      return 'Accessible route active. Avoid stairs.'
    }
    return 'Stay calm. Follow one step at a time.'
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('< Back')
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(() => this.onBack())

          Blank()

          Button('Refresh')
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(() => {
              this.loadAlert()
            })
        }
        .width('100%')

        Text('Watch Simulator')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text(this.userName === '' ? 'No profile set' : this.userName + ' • ' + this.activeProfile)
          .fontSize(16)
          .fontColor('#90A1BC')

        Column({ space: 10 }) {
          Text(this.activeProfile.toUpperCase() + ' MODE')
            .fontSize(14)
            .fontColor('#8FA2C0')

          Text(this.currentAlert === null ? 'NO ALERT' : this.currentAlert.type)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6A5E')

          Text(this.getBodyText())
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .fontColor(Color.White)

          if (this.activeProfile === 'Blind') {
            Text('🔊 Audio guidance active')
              .fontSize(14)
              .fontColor('#8FD3FF')
          }

          if (this.activeProfile === 'Deaf') {
            Text('⚡ Visual mode active')
              .fontSize(14)
              .fontColor('#F1C75B')
          }

          Row({ space: 10 }) {
            Button('NAVIGATE')
              .layoutWeight(1)
              .backgroundColor('#356CFF')
              .fontColor(Color.White)
              .borderRadius(14)
              .onClick(() => this.onNavigate())

            Button('SOS')
              .layoutWeight(1)
              .backgroundColor('#E13333')
              .fontColor(Color.White)
              .borderRadius(14)
              .onClick(() => this.onSOS())
          }
        }
        .width(280)
        .padding(18)
        .borderRadius(30)
        .backgroundColor('#050C18')
        .border({
          width: 2,
          color: '#253651'
        })
        .alignItems(HorizontalAlign.Center)

        Row({ space: 8 }) {
          this.profileChip('Blind')
          this.profileChip('Deaf')
          this.profileChip('Speech')
          this.profileChip('Mobility')
          this.profileChip('Elderly')
        }
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}