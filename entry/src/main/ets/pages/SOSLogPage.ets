import { NetworkService, SosItem } from '../services/NetworkService'

@Component
export struct SOSLogPage {
  onBack: () => void = () => {}

  @State logs: Array<SosItem> = []
  @State selectedFilter: string = 'ALL'
  @State totalCount: number = 0
  @State activeCount: number = 0
  @State acknowledgedCount: number = 0
  @State resolvedCount: number = 0

  aboutToAppear() {
    this.loadLogs()
  }

  async loadLogs() {
    const data = await NetworkService.fetchSOSLogs()
    this.logs = (data['logs'] as Array<SosItem>) || []

    const stats = data['stats'] as Record<string, number>
    if (stats) {
      this.totalCount = stats['total'] || 0
      this.activeCount = stats['active'] || 0
      this.acknowledgedCount = stats['acknowledged'] || 0
      this.resolvedCount = stats['resolved'] || 0
    }
  }

  private getFilteredLogs(): Array<SosItem> {
    if (this.selectedFilter === 'ALL') {
      return this.logs
    }
    return this.logs.filter((item: SosItem) => item.status === this.selectedFilter)
  }

  private chip(label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(Color.White)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(14)
      .backgroundColor(this.selectedFilter === label ? '#F1362D' : '#23324D')
      .onClick(() => {
        this.selectedFilter = label
      })
  }

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

          Button('Refresh')
            .backgroundColor('#1A2740')
            .fontColor(Color.White)
            .borderRadius(14)
            .onClick(() => {
              this.loadLogs()
            })
        }
        .width('100%')

        Text('SOS Dashboard')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Row({ space: 18 }) {
          this.statCard(this.totalCount.toString(), 'Total', '#FFFFFF')
          this.statCard(this.activeCount.toString(), 'Active', '#FF7262')
          this.statCard(this.acknowledgedCount.toString(), 'Acknowledged', '#F4D047')
          this.statCard(this.resolvedCount.toString(), 'Resolved', '#53E08C')
        }
        .width('100%')

        Row({ space: 8 }) {
          this.chip('ALL')
          this.chip('ACTIVE')
          this.chip('ACKNOWLEDGED')
          this.chip('RESOLVED')
        }

        ForEach(this.getFilteredLogs(), (item: SosItem) => {
          Column({ space: 10 }) {
            Row() {
              Text(item.userName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text(item.status)
                .fontSize(12)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(10)
                .backgroundColor(item.status === 'ACTIVE' ? '#8A1D1D' : item.status === 'ACKNOWLEDGED' ? '#8C650F' : '#156B3A')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row({ space: 8 }) {
              Text(item.profile)
                .fontSize(12)
                .fontColor('#D7E2F1')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(10)
                .backgroundColor('#23324D')

              Text(item.alertType)
                .fontSize(12)
                .fontColor('#D7E2F1')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(10)
                .backgroundColor('#23324D')
            }

            Text(item.message)
              .fontSize(15)
              .fontColor('#D7E2F1')

            Text(item.latitude.toString() + ', ' + item.longitude.toString())
              .fontSize(13)
              .fontColor('#8FA2C0')

            Text(item.time)
              .fontSize(13)
              .fontColor('#8FA2C0')

            if (item.status === 'ACTIVE') {
              Button('Acknowledge')
                .backgroundColor('#B67606')
                .fontColor(Color.White)
                .borderRadius(14)
                .onClick(async () => {
                  await NetworkService.acknowledgeSOS(item.id)
                  await this.loadLogs()
                })
            }

            if (item.status === 'ACKNOWLEDGED') {
              Button('Resolve')
                .backgroundColor('#1B8D49')
                .fontColor(Color.White)
                .borderRadius(14)
                .onClick(async () => {
                  await NetworkService.resolveSOS(item.id)
                  await this.loadLogs()
                })
            }
          }
          .width('100%')
          .padding(16)
          .borderRadius(20)
          .backgroundColor('#0F1B30')
          .border({
            width: 1,
            color: '#23324D'
          })
        }, (item: SosItem) => item.id)
      }
      .padding(20)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }

  @Builder
  private statCard(value: string, label: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(13)
        .fontColor('#8FA2C0')
    }
    .padding(12)
    .borderRadius(16)
    .backgroundColor('#0F1B30')
  }
}