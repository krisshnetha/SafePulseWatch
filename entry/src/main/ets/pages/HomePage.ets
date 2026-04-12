import { BigButton } from '../components/BigButton'

@Component
export struct HomePage {
  profileName: string = 'Blind'
  userName: string = ''
  monitoringEnabled: boolean = true
  monitorEventText: string = 'No suspicious audio pattern detected yet'
  onProfile: () => void = () => {}
  onAdmin: () => void = () => {}
  onWatch: () => void = () => {}
  onNavigate: () => void = () => {}
  onSOSLog: () => void = () => {}
  onCheckBackend: () => void = () => {}
  onSOS: () => void = () => {}
  onToggleMonitoring: () => void = () => {}
  onSimulateAudioDetection: () => void = () => {}
  onSendTestSms: () => void = () => {}

  private readonly appBg: string = '#08111F'
  private readonly panelBg: string = '#12243A'
  private readonly panelSoft: string = '#1A2F49'

  private getProfileHint(): string {
    if (this.profileName === 'Blind') {
      return 'Voice + strong haptic guidance enabled'
    }
    if (this.profileName === 'Deaf') {
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

          Text(this.userName === '' ? 'Emergency support watch mode' : this.userName + ' • Emergency support watch mode')
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
            .fontColor('#3DDC84')

          Text(this.getProfileHint())
            .fontSize(14)
            .fontColor('#D2E7FF')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.panelBg)
        .borderRadius(16)

        Column({ space: 8 }) {
          Text('How Guardian Alert Works')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('24/7 Audio Monitoring')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E4EEFF')
          Text('Guardian Alert continuously listens for fire alarm sounds on-device.')
            .fontSize(15)
            .fontColor('#CBD9EE')

          Text('Personalized Alerts')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E4EEFF')
          Text('Alert channel adapts to accessibility profile: visual, audio, or vibration first.')
            .fontSize(15)
            .fontColor('#CBD9EE')

          Text('SMS Notifications')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E4EEFF')
          Text('When danger is detected, emergency contacts receive location-aware SMS notifications.')
            .fontSize(15)
            .fontColor('#CBD9EE')

          Text('Privacy First')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E4EEFF')
          Text('Audio is processed locally. Raw microphone data is never stored or uploaded.')
            .fontSize(15)
            .fontColor('#CBD9EE')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#202F46')
        .borderRadius(16)

        Column({ space: 4 }) {
          Text('Guardian Monitor: ' + (this.monitoringEnabled ? 'ON' : 'OFF'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.monitoringEnabled ? '#7CFC9A' : '#FFAB91')

          Text(this.monitorEventText)
            .fontSize(14)
            .fontColor('#D2E2F6')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#17304E')
        .borderRadius(16)

        BigButton({ text: this.monitoringEnabled ? 'Pause Audio Monitoring' : 'Resume Audio Monitoring', bgColor: '#00897B', onTap: this.onToggleMonitoring })
        BigButton({ text: 'Simulate Fire Alarm Sound', bgColor: '#5E35B1', onTap: this.onSimulateAudioDetection })
        BigButton({ text: 'Send Test SMS Notification', bgColor: '#6D4C41', onTap: this.onSendTestSms })

        BigButton({ text: 'SOS NOW', bgColor: '#D32F2F', onTap: this.onSOS })
        BigButton({ text: 'Check Live Alerts', bgColor: '#F57C00', onTap: this.onCheckBackend })
        BigButton({ text: 'Watch Simulator', bgColor: '#3949AB', onTap: this.onWatch })
        BigButton({ text: 'Safe Route', bgColor: '#2E7D32', onTap: this.onNavigate })
        BigButton({ text: 'SOS Dashboard', bgColor: '#8E24AA', onTap: this.onSOSLog })
        BigButton({ text: 'Accessibility Profile', bgColor: '#1976D2', onTap: this.onProfile })
        BigButton({ text: 'Admin Panel', bgColor: '#455A64', onTap: this.onAdmin })

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
      }
      .width('100%')
      .padding(14)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.appBg)
  }
}
