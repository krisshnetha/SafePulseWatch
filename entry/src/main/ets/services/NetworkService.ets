export class NetworkService {
  static fetchAlertMock(): string {
    console.info('Mock backend check: FIRE ALERT')
    return 'GAS ALERT'
  }
}