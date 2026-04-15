@Component
export struct NavigationPage {
  profileName: string = 'Blind'
  onBack: () => void = () => {}

  @State currentStep: number = 0
  @State useAlternateRoute: boolean = false
  @State helpRequested: boolean = false

  primarySteps: string[] = [
    'Move straight for 50 m',
    'Turn left toward Exit B',
    'Continue on accessible route',
    'Reach assembly point'
  ]

  alternateSteps: string[] = [
    'Move to side corridor',
    'Turn right toward Exit C',
    'Use open ramp path',
    'Reach assembly point'
  ]

  currentSteps(): string[] {
    return this.useAlternateRoute ? this.alternateSteps : this.primarySteps
  }

  currentDistance(): string {
    if (this.currentStep === 0) {
      return '120 m remaining'
    }
    if (this.currentStep === 1) {
      return '80 m remaining'
    }
    if (this.currentStep === 2) {
      return '35 m remaining'
    }
    return 'Reached'
  }

  routeTag(): string {
    if (this.profileName === 'Mobility') {
      return 'Ramp Route'
    }
    if (this.profileName === 'Blind') {
      return 'Voice Guided'
    }
    if (this.profileName === 'Deaf') {
      return 'Visual Guided'
    }
    return 'Accessible'
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Blank().height(20)

        Text('Navigation')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Button('Back')
          .width('100%')
          .height(34)
          .backgroundColor('#1A2740')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.onBack()
          })

        Column({ space: 4 }) {
          Text(this.useAlternateRoute ? 'Safe Exit C' : 'Safe Exit B')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.currentDistance())
            .fontSize(11)
            .fontColor('#B9C8DF')

          Row({ space: 6 }) {
            Text(this.routeTag())
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor('#1D6E47')

            Text(this.profileName)
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor('#1A2740')
          }

          if (this.helpRequested) {
            Text('Help Requested')
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor('#7A2218')
          }
        }
        .width('100%')
        .padding(14)
        .borderRadius(22)
        .backgroundColor('#0C2140')
        .border({
          width: 1,
          color: '#33D17A'
        })

        Text(this.currentStep < 3 ? '↑' : '✓')
          .fontSize(42)
          .fontColor('#33D17A')
          .textAlign(TextAlign.Center)
          .width('100%')

        Column({ space: 4 }) {
          Text('NEXT STEP')
            .fontSize(10)
            .fontColor('#9DB1D0')

          Text(this.currentSteps()[this.currentStep])
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .maxLines(2)
        }
        .width('100%')
        .padding(14)
        .borderRadius(18)
        .backgroundColor('#0F1B30')

        Row({ space: 8 }) {
          Button('Prev')
            .layoutWeight(1)
            .height(36)
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .fontSize(11)
            .borderRadius(14)
            .enabled(this.currentStep > 0)
            .opacity(this.currentStep > 0 ? 1 : 0.5)
            .onClick(() => {
              if (this.currentStep > 0) {
                this.currentStep -= 1
              }
            })

          Button('Next')
            .layoutWeight(1)
            .height(36)
            .backgroundColor('#37D67A')
            .fontColor(Color.White)
            .fontSize(11)
            .borderRadius(14)
            .enabled(this.currentStep < 3)
            .opacity(this.currentStep < 3 ? 1 : 0.5)
            .onClick(() => {
              if (this.currentStep < 3) {
                this.currentStep += 1
              }
            })
        }
        .width('100%')

        Button(this.useAlternateRoute ? 'Using Alternate Route' : 'Use Alternate Route')
          .width('100%')
          .height(38)
          .backgroundColor('#2A4F9B')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.useAlternateRoute = !this.useAlternateRoute
            this.currentStep = 0
          })

        Button(this.helpRequested ? 'Help Requested' : 'Request Help')
          .width('100%')
          .height(38)
          .backgroundColor('#6A2E1B')
          .fontColor(Color.White)
          .fontSize(12)
          .borderRadius(16)
          .onClick(() => {
            this.helpRequested = true
          })

        Blank().height(36)
      }
      .padding({ left: 22, right: 22 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}