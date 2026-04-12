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
  onSOS: () => void = () => {}
  onNavigate: () => void = () => {}

  build() {
    Column({ space: 14 }) {
      Text('SAFEPULSE')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text('Emergency Support Watch')
        .fontSize(16)
        .fontColor('#CCCCCC')
      Text('Source: Local demo backend')
        .fontSize(14)
        .fontColor('#AAAAAA')


      Text('Profile: ' + this.profileName)
        .fontSize(18)
        .fontColor('#FFA726')

      Text('System Ready • Demo Connected')
        .fontSize(18)
        .fontColor('#4CAF50')
        .margin({ top: 4, bottom: 12 })

      BigButton({ text: 'Select Profile', bgColor: '#1565C0', onTap: this.onProfile })
      BigButton({ text: 'Simulate Alert', bgColor: '#EF6C00', onTap: this.onAlert })
      BigButton({ text: 'Check Backend Alert', bgColor: '#7B1FA2', onTap: this.onCheckBackend })
      BigButton({ text: 'SOS', bgColor: '#C62828', onTap: this.onSOS })
      BigButton({ text: 'Navigate', bgColor: '#2E7D32', onTap: this.onNavigate })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#0B1020')
    .padding(16)
  }
}