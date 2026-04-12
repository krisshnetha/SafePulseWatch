export class AlertService {
  static getAlertType(): string {
    return 'FIRE ALERT'
  }

  static getAlertMessage(profile: string): string {
    if (profile === 'Blind') {
      return 'Audio and vibration guidance enabled.'
    }
    if (profile === 'Deaf') {
      return 'Visual emergency mode active.'
    }
    if (profile === 'Speech') {
      return 'Silent help request available.'
    }
    if (profile === 'Mobility') {
      return 'Accessible route activated.'
    }
    return 'Step-by-step calm guidance active.'
  }
}