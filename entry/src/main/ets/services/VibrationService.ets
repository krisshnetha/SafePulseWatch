import { HapticService } from './HapticService'

export class VibrationService {
  triggerFireAlarm(): void {
    HapticService.trigger('Blind')
    this.playAlertTone()
  }

  private playAlertTone(): void {
    console.info('ALERT TONE: high-priority safety tone playback')
  }
}
