@Component
export struct ProfilePage {
  initialProfile: string = 'Blind'
  initialName: string = ''
  initialContactName: string = ''
  initialContactNumber: string = ''
  onSave: (name: string, profile: string, contactName: string, contactNumber: string) => void =
    (_name: string, _profile: string, _contactName: string, _contactNumber: string) => {}
  onBack: () => void = () => {}

  @State step: number = 1
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State emergencyContactName: string = ''
  @State emergencyContactNumber: string = ''

  aboutToAppear() {
    this.selectedProfile = this.initialProfile
    this.userName = this.initialName
    this.emergencyContactName = this.initialContactName
    this.emergencyContactNumber = this.initialContactNumber
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

  private getProfilePreview(profile: string): string {
    if (profile === 'Blind') {
      return 'Voice guidance + haptics'
    }
    if (profile === 'Deaf') {
      return 'Visual alerts + vibration'
    }
    if (profile === 'Speech') {
      return 'Silent SOS + quick help'
    }
    if (profile === 'Mobility') {
      return 'Accessible route support'
    }
    return 'Simple calm guidance'
  }

  @Builder
  profileCard(title: string, desc: string, value: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(desc)
        .fontSize(10)
        .fontColor('#A8B7D1')
        .maxLines(2)
    }
    .width('100%')
    .padding(14)
    .borderRadius(18)
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
          Column({ space: 10 }) {
            Blank().height(20)

            Text('Profile')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text('Choose Accessibility Mode')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text('SafePulse adapts alerts to your needs.')
              .fontSize(11)
              .fontColor('#A8B7D1')

            this.profileCard('Blind', 'Voice + haptic guidance', 'Blind')
            this.profileCard('Deaf', 'Visual + vibration alerts', 'Deaf')
            this.profileCard('Speech', 'Silent SOS + quick help', 'Speech')
            this.profileCard('Mobility', 'Accessible route support', 'Mobility')
            this.profileCard('Elderly', 'Calm step-by-step guidance', 'Elderly')

            Column({ space: 4 }) {
              Text('PREVIEW')
                .fontSize(10)
                .fontColor('#C2CBE0')

              Text(this.getProfilePreview(this.selectedProfile))
                .fontSize(11)
                .fontColor(Color.White)
                .maxLines(2)
            }
            .width('100%')
            .padding(12)
            .borderRadius(16)
            .backgroundColor('#14233A')

            Button('Continue')
              .width('100%')
              .height(42)
              .backgroundColor('#2A4F9B')
              .fontColor(Color.White)
              .fontSize(13)
              .borderRadius(16)
              .onClick(() => {
                this.step = 2
              })

            Button('Back')
              .width('100%')
              .height(40)
              .backgroundColor('#16233C')
              .fontColor(Color.White)
              .fontSize(12)
              .borderRadius(16)
              .onClick(() => {
                this.onBack()
              })

            Blank().height(36)
          }
          .padding({ left: 22, right: 22 })
          .width('100%')
        }
      } else {
        Scroll() {
          Column({ space: 10 }) {
            Blank().height(20)

            Text('Profile')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text('Your Details')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            TextInput({ text: this.userName, placeholder: 'Your name' })
              .width('100%')
              .height(42)
              .backgroundColor('#0F1B30')
              .fontColor(Color.White)
              .placeholderColor('#6B7C99')
              .fontSize(12)
              .borderRadius(16)
              .onChange((value: string) => {
                this.userName = value
              })

            TextInput({ text: this.emergencyContactName, placeholder: 'Emergency contact name' })
              .width('100%')
              .height(42)
              .backgroundColor('#0F1B30')
              .fontColor(Color.White)
              .placeholderColor('#6B7C99')
              .fontSize(12)
              .borderRadius(16)
              .onChange((value: string) => {
                this.emergencyContactName = value
              })

            TextInput({ text: this.emergencyContactNumber, placeholder: 'Emergency contact number' })
              .width('100%')
              .height(42)
              .backgroundColor('#0F1B30')
              .fontColor(Color.White)
              .placeholderColor('#6B7C99')
              .fontSize(12)
              .borderRadius(16)
              .onChange((value: string) => {
                this.emergencyContactNumber = value
              })

            Column({ space: 4 }) {
              Text('ACTIVE PROFILE')
                .fontSize(10)
                .fontColor('#C2CBE0')

              Text(this.selectedProfile)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text(this.getProfilePreview(this.selectedProfile))
                .fontSize(10)
                .fontColor('#D4DDF0')
            }
            .width('100%')
            .padding(12)
            .borderRadius(18)
            .backgroundColor('#1E1630')
            .border({
              width: 2,
              color: this.getProfileColor(this.selectedProfile)
            })

            Row({ space: 10 }) {
              Button('Back')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#1C2A42')
                .fontColor(Color.White)
                .fontSize(12)
                .borderRadius(16)
                .onClick(() => {
                  this.step = 1
                })

              Button('Save')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#2A4F9B')
                .fontColor(Color.White)
                .fontSize(12)
                .borderRadius(16)
                .enabled(
                  this.userName !== '' &&
                    this.emergencyContactName !== '' &&
                    this.emergencyContactNumber !== ''
                )
                .opacity(
                  this.userName !== '' &&
                    this.emergencyContactName !== '' &&
                    this.emergencyContactNumber !== '' ? 1 : 0.5
                )
                .onClick(() => {
                  this.onSave(
                    this.userName,
                    this.selectedProfile,
                    this.emergencyContactName,
                    this.emergencyContactNumber
                  )
                })
            }

            Blank().height(36)
          }
          .padding({ left: 22, right: 22 })
          .width('100%')
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}