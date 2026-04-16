import { NetworkService, SosItem } from '../services/NetworkService'

@Component
export struct SOSLogPage {
  onBack: () => void = () => {}

  @State logs: SosItem[] = []
  @State selectedFilter: string = 'ALL'
  @State totalCount: number = 0
  @State activeTotal: number = 0
  @State acknowledgedCount: number = 0
  @State resolvedCount: number = 0

  aboutToAppear() {
    this.loadLogs()
  }

  async loadLogs() {
    const data = await NetworkService.fetchSOSLogs()
    if (data === null) {
      this.logs = []
      this.totalCount = 0
      this.activeTotal = 0
      this.acknowledgedCount = 0
      this.resolvedCount = 0
      return
    }
    this.logs = data.logs
    this.totalCount = data.stats.total
    this.activeTotal = data.stats.active
    this.acknowledgedCount = data.stats.acknowledged
    this.resolvedCount = data.stats.resolved
  }

  private getFilteredLogs(): SosItem[] {
    if (this.selectedFilter === 'ALL') {
      return this.logs
    }
    return this.logs.filter((item: SosItem) => item.status === this.selectedFilter)
  }

  @Builder
  statCard(value: string, label: string, glow: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(label)
        .fontSize(9)
        .fontColor('#BFD2F4')
    }
    .width('48%')
    .padding(12)
    .borderRadius(18)
    .linearGradient({
      angle: 135,
      colors: [['#16315F', 0.0], ['#0C1830', 1.0]]
    })
    .shadow({
      radius: 14,
      color: glow,
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  filterChip(label: string) {
    Text(label)
      .fontSize(9)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .padding({ left: 8, right: 8, top: 5, bottom: 5 })
      .borderRadius(10)
      .backgroundColor(this.selectedFilter === label ? '#3E8BFF' : '#17284A')
      .shadow({
        radius: this.selectedFilter === label ? 10 : 0,
        color: this.selectedFilter === label ? '#3E8BFF66' : '#00000000',
        offsetX: 0,
        offsetY: 0
      })
      .onClick(() => {
        this.selectedFilter = label
      })
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Blank().height(18)

        Text('SOS Log')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textShadow({
            radius: 10,
            color: '#5BA3FF',
            offsetX: 0,
            offsetY: 0
          })

        Row({ space: 8 }) {
          Button('Refresh')
            .layoutWeight(1)
            .height(34)
            .backgroundColor('#2A4F9B')
            .fontColor(Color.White)
            .borderRadius(16)
            .onClick(() => {
              this.loadLogs()
            })

          Button('Back')
            .layoutWeight(1)
            .height(34)
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(16)
            .onClick(() => {
              this.onBack()
            })
        }
        .width('100%')

        Row({ space: 8 }) {
          this.statCard(this.totalCount.toString(), 'Total', '#5BA3FF33')
          this.statCard(this.activeTotal.toString(), 'Active', '#FF6A5A33')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 8 }) {
          this.statCard(this.acknowledgedCount.toString(), 'Ack', '#FFD05A33')
          this.statCard(this.resolvedCount.toString(), 'Done', '#38D67A33')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 6 }) {
          this.filterChip('ALL')
          this.filterChip('ACTIVE')
          this.filterChip('ACKNOWLEDGED')
          this.filterChip('RESOLVED')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        ForEach(this.getFilteredLogs(), (item: SosItem) => {
          Column({ space: 6 }) {
            Row() {
              Text(item.userName)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Blank()

              Text(item.status)
                .fontSize(9)
                .fontColor(Color.White)
                .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                .borderRadius(8)
                .backgroundColor(
                  item.status === 'ACTIVE'
                    ? '#C54535'
                    : item.status === 'ACKNOWLEDGED'
                    ? '#B98916'
                    : '#1E9A57'
                )
            }
            .width('100%')

            Text(item.profile + ' • ' + item.alertType)
              .fontSize(9)
              .fontColor('#BFD2F4')

            Text(item.message)
              .fontSize(10)
              .fontColor('#E7EEFF')
              .maxLines(2)

            Text(item.time)
              .fontSize(9)
              .fontColor('#8FA8D8')

            if (item.status === 'ACTIVE') {
              Button('Acknowledge')
                .width('100%')
                .height(32)
                .backgroundColor('#D59A1A')
                .fontColor(Color.White)
                .fontSize(10)
                .borderRadius(14)
                .onClick(() => {
                  NetworkService.acknowledgeSOS(item.id).then(() => {
                    this.loadLogs()
                  })
                })
            }

            if (item.status === 'ACKNOWLEDGED') {
              Button('Resolve')
                .width('100%')
                .height(32)
                .backgroundColor('#1E9A57')
                .fontColor(Color.White)
                .fontSize(10)
                .borderRadius(14)
                .onClick(() => {
                  NetworkService.resolveSOS(item.id).then(() => {
                    this.loadLogs()
                  })
                })
            }
          }
          .width('100%')
          .padding(12)
          .borderRadius(20)
          .linearGradient({
            angle: 135,
            colors: [['#12284C', 0.0], ['#0A162B', 1.0]]
          })
          .border({
            width: 1,
            color: '#233C66'
          })
        }, (item: SosItem) => item.id)

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