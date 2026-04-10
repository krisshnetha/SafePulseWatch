@Component
export struct BigButton {
  text: string = ''
  bgColor: string = '#1565C0'
  onTap: () => void = () => {}

  build() {
    Button(this.text)
      .width('85%')
      .height(60)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .backgroundColor(this.bgColor)
      .fontColor(Color.White)
      .borderRadius(18)
      .margin({ top: 10, bottom: 10 })
      .onClick(() => {
        this.onTap()
      })
  }
}