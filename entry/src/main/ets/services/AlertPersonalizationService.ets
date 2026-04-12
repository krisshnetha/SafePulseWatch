export class AlertPersonalizationService {
  static getPrimaryChannel(profile: string): string {
    if (profile === 'Vision') {
      return 'haptic-audio'
    }
    if (profile === 'Hearing') {
      return 'visual'
    }
    if (profile === 'Speech') {
      return 'haptic-text'
    }
    if (profile === 'Mobility') {
      return 'visual-haptic'
    }
    return 'simplified-visual'
  }
}
