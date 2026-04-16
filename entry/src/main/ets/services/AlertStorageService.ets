import dataPreferences from '@ohos.data.preferences'

export interface FireAlertRecord {
  id: string
  timestamp: string
  confidence: number
  detectionMethod: string
}

export class AlertStorageService {
  private static readonly STORE_NAME: string = 'fire_alert_store'
  private static readonly ALERTS_KEY: string = 'fire_alerts'
  private static initialized: boolean = false
  private static context: any = null
  private static preferences: any = null
  private static memoryFallback: Array<FireAlertRecord> = []

  static async initialize(context: any): Promise<void> {
    if (AlertStorageService.initialized) {
      return
    }

    AlertStorageService.context = context
    try {
      // ArkTS typing for Preferences is strict; use `any` to avoid compiler overload issues.
      const pref = await dataPreferences.getPreferences(
        context,
        AlertStorageService.STORE_NAME
      ) as any
      AlertStorageService.preferences = pref
      AlertStorageService.initialized = true
    } catch (error) {
      console.error(
        'AlertStorageService initialize fallback mode: ' + JSON.stringify(error as any)
      )
      AlertStorageService.initialized = true
    }
  }

  static async saveAlert(confidence: number, detectionMethod: string): Promise<FireAlertRecord> {
    const record: FireAlertRecord = {
      id: 'fire-' + Date.now().toString(),
      timestamp: new Date().toISOString(),
      confidence,
      detectionMethod
    }

    const current = await AlertStorageService.getAlerts()
    const updated = [record, ...current].slice(0, 200)

    if (AlertStorageService.preferences !== null) {
      await AlertStorageService.preferences.put(AlertStorageService.ALERTS_KEY, JSON.stringify(updated))
      await AlertStorageService.preferences.flush()
    } else {
      AlertStorageService.memoryFallback = updated
    }

    return record
  }

  static async getAlerts(): Promise<Array<FireAlertRecord>> {
    if (AlertStorageService.preferences === null) {
      return [...AlertStorageService.memoryFallback]
    }

    try {
      const json = await AlertStorageService.preferences.get(AlertStorageService.ALERTS_KEY, '[]')
      const parsed = JSON.parse(json) as Array<FireAlertRecord>
      return parsed
    } catch (error) {
      console.error('AlertStorageService getAlerts error: ' + JSON.stringify(error as any))
      return []
    }
  }
}
