import { BigButton } from '../components/BigButton'

@Component
export struct ProfilePage {
  onSelect: (profile: string) => void = (_profile: string) => {}
  onBack: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Text('Select Profile')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 12 })

      BigButton({ text: 'Vision', bgColor: '#3949AB', onTap: () => this.onSelect('Vision') })
      BigButton({ text: 'Hearing', bgColor: '#3949AB', onTap: () => this.onSelect('Hearing') })
      BigButton({ text: 'Speech', bgColor: '#3949AB', onTap: () => this.onSelect('Speech') })
      BigButton({ text: 'Mobility', bgColor: '#3949AB', onTap: () => this.onSelect('Mobility') })
      BigButton({ text: 'Cognitive', bgColor: '#3949AB', onTap: () => this.onSelect('Cognitive') })

      Button('Back')
        .width('60%')
        .height(50)
        .fontSize(18)
        .backgroundColor('#555555')
        .fontColor(Color.White)
        .borderRadius(14)
        .margin({ top: 12 })
        .onClick(() => this.onBack())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#0B1020')
    .padding(16)
  }
}