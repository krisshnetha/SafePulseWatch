import { NetworkService, AlertItem } from '../services/NetworkService'

@Component
export struct HomePage {
  profileName: string = 'Blind'
  userName: string = ''
  onProfile: () => void = () => {}
  onAdmin: () => void = () => {}
  onWatch: () => void = () => {}
  onNavigate: () => void = () => {}
  onSOSLog: () => void = () => {}
  onCheckBackend: () => void = () => {}

  @State currentAlert: AlertItem | null = null

  aboutToAppear() {
    this.loadAlert()
  }

  async loadAlert() {
    this.currentAlert = await NetworkService.fetchCurrentAlert()
  }

  private card(title: string, subtitle: string, color: string, onTap: () => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text(subtitle)
        .fontSize(14)
        .fontColor('#9FB0C9')
    }
    .width('45%')
    .height(120)
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#0E1A2F')
    .border({
      width: 1,
      color: color
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => onTap())
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 10 }) {
          Text('SafePulse')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('Adaptive emergency alerts for every accessibility need. Real-time SOS. GPS navigation to safety.')
            .fontSize(18)
            .fontColor('#B9C8DF')

          Text('Profile: ' + this.profileName + (this.userName !== '' ? ' • ' + this.userName : ''))
            .fontSize(16)
            .fontColor('#FF8A80')
        }
        .width('100%')
        .padding(20)
        .borderRadius(20)
        .backgroundColor('#0E1A34')

        if (this.currentAlert !== null) {
          Row() {
            Column({ space: 4 }) {
              Text(this.currentAlert!.type + ' ALERT')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(this.currentAlert!.instruction)
                .fontSize(16)
                .fontColor(Color.White)
            }
            .layoutWeight(1)

            Button('VIEW')
              .backgroundColor('#FFB380')
              .fontColor(Color.White)
              .borderRadius(16)
              .onClick(() => this.onCheckBackend())
          }
          .width('100%')
          .padding(20)
          .borderRadius(20)
          .backgroundColor('#FF5A1F')
        }

        Row({ space: 14 }) {
          this.card('My Profile', 'Set up now', '#3F7BFF', this.onProfile)
          this.card('Alert Control', 'Trigger & manage', '#FF3D3D', this.onAdmin)
        }

        Row({ space: 14 }) {
          this.card('Watch View', 'Adaptive display', '#8A3FFC', this.onWatch)
          this.card('Navigation', 'Safe exits', '#21C45D', this.onNavigate)
        }

        Row({ space: 14 }) {
          this.card('SOS Events', 'Live dashboard', '#FF8A00', this.onSOSLog)
          this.card('Refresh Alert', 'Check backend', '#E0B000', this.onCheckBackend)
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