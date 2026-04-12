import { BigButton } from '../components/BigButton'

@Component
export struct HomePage {
  profileName: string = 'Vision'
  onProfile: () => void = () => {}
  onAlert: () => void = () => {}
  onCheckBackend: () => void = () => {}
  onSOS: () => void = () => {}
  onNavigate: () => void = () => {}
  private readonly appBg: string = '#08111F'
  private readonly panelBg: string = '#12243A'
  private readonly panelSoft: string = '#1A2F49'
  private readonly caution: string = '#FFB300'
  private readonly ok: string = '#3DDC84'

  private getProfileHint(): string {
    if (this.profileName === 'Vision') {
      return 'Voice + strong haptic guidance enabled'
    }
    if (this.profileName === 'Hearing') {
      return 'Visual emphasis mode with high-contrast alerts'
    }
    if (this.profileName === 'Mobility') {
      return 'Accessible route preference is active'
    }
    if (this.profileName === 'Speech') {
      return 'Silent request templates are available'
    }
    return 'Calm assistance mode is active'
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Column({ space: 3 }) {
          Text('SafePulse Dashboard')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('Emergency support for travelers')
            .fontSize(14)
            .fontColor('#CFD9E8')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text('Profile: ' + this.profileName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFF8E1')
        }
        .width('100%')
        .height(40)
        .padding({ left: 12, right: 12 })
        .backgroundColor('#334B11')
        .borderRadius(14)

        Column({ space: 4 }) {
          Text('Status: Online')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.ok)

          Text(this.getProfileHint())
            .fontSize(14)
            .fontColor('#D2E7FF')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.panelBg)
        .borderRadius(16)

        Column({ space: 6 }) {
          Text('Voice Assistant')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('Listening for: "Call emergency service"')
            .fontSize(14)
            .fontColor('#D9E6F6')

          Text('"Send SOS" • "I need help" • "Emergency assistance"')
            .fontSize(13)
            .fontColor('#AFC5DE')
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.panelSoft)
        .borderRadius(16)

        BigButton({ text: 'SOS NOW', bgColor: '#D32F2F', onTap: this.onSOS })
        BigButton({ text: 'Check Live Alerts', bgColor: '#F57C00', onTap: this.onCheckBackend })
        BigButton({ text: 'Simulate Alert', bgColor: '#EF6C00', onTap: this.onAlert })
        BigButton({ text: 'Safe Route', bgColor: '#2E7D32', onTap: this.onNavigate })
        BigButton({ text: 'Accessibility Profile', bgColor: '#1976D2', onTap: this.onProfile })

        Row({ space: 8 }) {
          Text('Tip')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E1E1E')
            .backgroundColor(this.caution)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)

          Text('Long-press watch crown to quickly return here.')
            .fontSize(13)
            .fontColor('#C8D7EA')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 6 })
      }
      .width('100%')
      .padding(14)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.appBg)
  }
}