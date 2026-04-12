@Component
export struct ProfilePage {
  initialProfile: string = 'Blind'
  initialName: string = ''
  onSave: (name: string, profile: string) => void = (_name: string, _profile: string) => {}
  onBack: () => void = () => {}

  @State step: number = 1
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''

  aboutToAppear() {
    this.selectedProfile = this.initialProfile
    this.userName = this.initialName
  }

  private getProfileColor(profile: string): string {
    if (profile === 'Blind') {
      return '#2D7DFF'
    }
    if (profile === 'Deaf') {
      return '#A84CFF'
    }
    if (profile === 'Speech') {
      return '#12D97B'
    }
    if (profile === 'Mobility') {
      return '#FF8A00'
    }
    return '#FF4FBF'
  }

  private profileCard(title: string, desc: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(desc)
        .fontSize(16)
        .fontColor('#A8B7D1')
    }
    .width('100%')
    .padding(20)
    .borderRadius(20)
    .backgroundColor('#0F1B30')
    .border({
      width: this.selectedProfile === value ? 2 : 1,
      color: this.selectedProfile === value ? this.getProfileColor(value) : '#23324D'
    })
    .onClick(() => {
      this.selectedProfile = value
    })
  }

  build() {
    Column() {
      if (this.step === 1) {
        Scroll() {
          Column({ space: 16 }) {
            Text('Accessibility Profile')
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text('What describes you? SafePulse adapts every alert to your specific needs.')
              .fontSize(18)
              .fontColor('#A8B7D1')

            this.profileCard('Blind / Visually Impaired', 'Audio + haptic alerts. Voice navigation guidance.', 'Blind')
            this.profileCard('Deaf / Hearing Impaired', 'Intense vibration + flashing screen. Large visual text.', 'Deaf')
            this.profileCard('Speech Impaired / Mute', 'One-tap silent SOS. Pre-set help messages.', 'Speech')
            this.profileCard('Mobility Impaired / Wheelchair', 'Accessible route guidance. Avoids stairs.', 'Mobility')
            this.profileCard('Elderly / Cognitive Support', 'Step-by-step calm guidance. Simple language.', 'Elderly')

            Button('Continue')
              .width('100%')
              .height(56)
              .backgroundColor('#23324D')
              .fontColor(Color.White)
              .borderRadius(18)
              .onClick(() => {
                this.step = 2
              })

            Button('Back')
              .width('100%')
              .height(52)
              .backgroundColor('#16233C')
              .fontColor(Color.White)
              .borderRadius(18)
              .onClick(() => this.onBack())
          }
          .padding(20)
          .width('100%')
        }
      } else {
        Column({ space: 18 }) {
          Text('Your name')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('Used in SOS messages sent to emergency contacts.')
            .fontSize(18)
            .fontColor('#A8B7D1')

          TextInput({ text: this.userName, placeholder: 'Enter your full name' })
            .width('100%')
            .height(60)
            .backgroundColor('#0F1B30')
            .fontColor(Color.White)
            .placeholderColor('#6B7C99')
            .borderRadius(18)
            .onChange((value: string) => {
              this.userName = value
            })

          Column({ space: 8 }) {
            Text('SELECTED PROFILE')
              .fontSize(16)
              .fontColor('#C2CBE0')

            Text(this.selectedProfile)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .width('100%')
          .padding(20)
          .borderRadius(20)
          .backgroundColor('#2A0A18')
          .border({
            width: 2,
            color: this.getProfileColor(this.selectedProfile)
          })

          Row({ space: 14 }) {
            Button('Back')
              .layoutWeight(1)
              .height(56)
              .backgroundColor('#1C2A42')
              .fontColor(Color.White)
              .borderRadius(18)
              .onClick(() => {
                this.step = 1
              })

            Button('Save & Launch')
              .layoutWeight(1)
              .height(56)
              .backgroundColor('#23324D')
              .fontColor(Color.White)
              .borderRadius(18)
              .enabled(this.userName !== '')
              .opacity(this.userName !== '' ? 1 : 0.5)
              .onClick(() => {
                this.onSave(this.userName, this.selectedProfile)
              })
          }
        }
        .padding(20)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}