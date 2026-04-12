@Component
export struct NavigationPage {
  profileName: string = 'Blind'
  onBack: () => void = () => {}

  @State gpsStatus: string = 'GPS Active: 1.4448, 103.8246'
  @State nearestName: string = 'Assembly Point'
  @State distanceText: string = '1015m'
  @State directionText: string = 'S'
  @State bearingText: string = '184°'

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('< Back')
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(() => this.onBack())

          Blank()
        }
        .width('100%')

        Text('Navigation')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Column({ space: 12 }) {
          Text('NEAREST SAFE POINT')
            .fontSize(14)
            .fontColor('#8FA2C0')

          Text(this.nearestName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Row({ space: 24 }) {
            Column() {
              Text(this.distanceText)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF7A7A')
              Text('Distance')
                .fontSize(14)
                .fontColor('#8FA2C0')
            }

            Column() {
              Text(this.directionText)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text('Direction')
                .fontSize(14)
                .fontColor('#8FA2C0')
            }

            Column() {
              Text(this.bearingText)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text('Bearing')
                .fontSize(14)
                .fontColor('#8FA2C0')
            }
          }
        }
        .width('100%')
        .padding(20)
        .borderRadius(24)
        .backgroundColor('#0F1B30')

        Text(this.gpsStatus)
          .width('100%')
          .padding(16)
          .borderRadius(18)
          .backgroundColor('#0F1B30')
          .fontColor(Color.White)

        Text('SAFE POINTS')
          .fontSize(14)
          .fontColor('#8FA2C0')

        Column({ space: 12 }) {
          this.safePointCard('Assembly Point', '1015m • S', true, true)
          this.safePointCard('Exit A — Main Gate', '1021m • S', true, false)
          this.safePointCard('Help Desk', '1026m • S', false, false)
          this.safePointCard('Accessible Elevator', '1035m • S', true, false)
          this.safePointCard('Exit B — Emergency', '1038m • S', true, false)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }

  @Builder
  private safePointCard(name: string, detail: string, accessible: boolean, selected: boolean) {
    Column({ space: 6 }) {
      Text(name)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row({ space: 8 }) {
        Text(detail)
          .fontSize(14)
          .fontColor('#AFC1DD')

        if (accessible) {
          Text('Accessible')
            .fontSize(14)
            .fontColor('#2FD36F')
        }
      }
    }
    .width('100%')
    .padding(18)
    .borderRadius(20)
    .backgroundColor('#0F1B30')
    .border({
      width: selected ? 2 : 1,
      color: selected ? '#A2212B' : '#23324D'
    })
  }
}