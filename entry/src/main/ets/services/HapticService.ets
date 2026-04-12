export class HapticService {
  static trigger(profile: string): void {
    if (profile === 'Blind') {
      console.info('HAPTIC: strong long-short-long pattern')
    } else if (profile === 'Deaf') {
      console.info('HAPTIC: strong continuous vibration')
    } else if (profile === 'Speech') {
      console.info('HAPTIC: short confirmation pulse')
    } else if (profile === 'Mobility') {
      console.info('HAPTIC: two medium pulses')
    } else {
      console.info('HAPTIC: slow calming pulses')
    }
  }
}