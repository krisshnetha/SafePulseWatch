export class SmsNotificationService {
  static sendTestNotification(contactNumber: string, location: string, profile: string): boolean {
    const payload = {
      contactNumber: contactNumber,
      location: location,
      profile: profile,
      source: 'watch-test',
      message: 'Guardian Alert test notification from SafePulseWatch'
    }

    // In production, this payload should be POSTed to backend /api/sms-notify endpoint.
    console.info('SmsNotificationService payload: ' + JSON.stringify(payload))
    return true
  }
}
