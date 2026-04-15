export class AlertService {
  static getAlertType(): string {
    return 'FIRE ALERT'
  }

  static getAlertMessage(profile: string): string {
    if (profile === 'Blind') {
      return 'Audio and vibration guidance enabled.'
    }
    if (profile === 'Deaf') {
      return 'Visual and vibration emergency mode active.'
    }
    if (profile === 'Speech') {
      return 'Silent help request with audio and vibration enabled.'
    }
    if (profile === 'Mobility') {
      return 'Accessible route with audio and vibration activated.'
    }
    return 'Step-by-step calm guidance with audio and vibration active.'
  }

  static shouldVibrate(): boolean {
    return true
  }

  static shouldBeep(profile: string): boolean {
    return profile !== 'Deaf'
  }
}