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
  @State systemStatus: string = 'Protected'

  aboutToAppear() {
    this.loadAlert()
  }

  async loadAlert() {
    let alert: AlertItem | null = await NetworkService.fetchCurrentAlert()
    this.currentAlert = alert
    this.systemStatus = alert !== null ? 'Alert Active' : 'Protected'
  }

  @Builder
  chip(label: string, bg: string, fg: string) {
    Text(label)
      .fontSize(10)
      .fontColor(fg)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(12)
      .backgroundColor(bg)
  }

  @Builder
  actionCard(title: string, subtitle: string, accent: string, onTap: () => void) {
    Column({ space: 4 }) {
      Row() {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Blank()

        Text('›')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(accent)
      }
      .width('100%')

      Text(subtitle)
        .fontSize(10)
        .fontColor('#B7C7E3')
        .maxLines(2)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .borderRadius(20)
    .backgroundColor('#0E1A30')
    .border({
      width: 1,
      color: accent
    })
    .onClick(() => {
      onTap()
    })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Blank().height(18)

        Text('WAySAFE')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFE44D')

        Text('Adaptive emergency companion')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(10)
          .fontColor('#DCE7FF')
          .maxLines(1)

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            this.chip(
              this.systemStatus,
              this.currentAlert !== null ? '#E14B22' : '#1D7A45',
              '#FFFFFF'
            )

            this.chip(
              this.profileName,
              '#2E6BFF',
              '#FFFFFF'
            )
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Text(this.userName !== '' ? this.userName : 'User not set')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .maxLines(1)

          Text('Adaptive safety active')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(9)
            .fontColor('#BFD2F4')
            .maxLines(1)
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .borderRadius(24)
        .linearGradient({
          angle: 135,
          colors: [
            ['#0D1730', 0.0],
            ['#0A1327', 0.55],
            ['#070E1D', 1.0]
          ]
        })
        .border({
          width: 2,
          color: '#42A5FF'
        })
        .shadow({
          radius: 18,
          color: '#42A5FF55',
          offsetX: 0,
          offsetY: 0
        })

        if (this.currentAlert !== null) {
          Column({ space: 8 }) {
            Row() {
              Text('LIVE ALERT')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFE9DD')

              Blank()

              Text(this.currentAlert!.severity)
                .fontSize(10)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(8)
                .backgroundColor('#C94E1E')
            }
            .width('100%')

            Text(this.currentAlert!.type)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text(this.currentAlert!.instruction)
              .fontSize(11)
              .fontColor(Color.White)
              .maxLines(3)
              .width('100%')

            Button('Open Alert')
              .width('100%')
              .height(36)
              .backgroundColor('#FFD9B8')
              .fontColor('#5A2400')
              .fontSize(12)
              .borderRadius(16)
              .onClick(() => {
                this.onCheckBackend()
              })
          }
          .width('100%')
          .padding(14)
          .borderRadius(20)
          .backgroundColor('#FF5A1F')
        }

        this.actionCard('Profile', 'Accessibility mode and contact', '#4C88FF', this.onProfile)
        this.actionCard('Alert Control', 'Trigger demo emergencies', '#FF6464', this.onAdmin)
        this.actionCard('Watch View', 'Compact wearable actions', '#B073FF', this.onWatch)
        this.actionCard('Navigation', 'Guided safe exit route', '#37D67A', this.onNavigate)
        this.actionCard('SOS Log', 'Emergency history', '#FFB347', this.onSOSLog)
        this.actionCard('Refresh Alert', 'Check live alert now', '#E7D05A', () => {
          this.loadAlert()
          this.onCheckBackend()
        })

        Blank().height(40)
      }
      .padding({ left: 22, right: 22 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}