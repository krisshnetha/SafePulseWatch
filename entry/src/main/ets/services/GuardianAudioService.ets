export interface AudioDetectionResult {
  detected: boolean
  detectedAt: string
  reason: string
}

export class GuardianAudioService {
  private static monitoringEnabled: boolean = true

  static isMonitoringEnabled(): boolean {
    return GuardianAudioService.monitoringEnabled
  }

  static toggleMonitoring(): boolean {
    GuardianAudioService.monitoringEnabled = !GuardianAudioService.monitoringEnabled
    console.info('GuardianAudioService monitoring state: ' + GuardianAudioService.monitoringEnabled)
    return GuardianAudioService.monitoringEnabled
  }

  static simulateAudioPattern(patternType: string): AudioDetectionResult {
    if (!GuardianAudioService.monitoringEnabled) {
      return {
        detected: false,
        detectedAt: '-',
        reason: 'Monitoring is paused. Resume monitoring to detect alarms.'
      }
    }

    if (patternType === 'fire-alarm') {
      return {
        detected: true,
        detectedAt: new Date().toISOString(),
        reason: 'Pattern matched local fire-alarm signature.'
      }
    }

    return {
      detected: false,
      detectedAt: new Date().toISOString(),
      reason: 'No hazardous audio signature found.'
    }
  }
}
