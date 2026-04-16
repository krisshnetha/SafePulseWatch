import dataPreferences from '@ohos.data.preferences'

export interface FireAlertRecord {
  id: string
  timestamp: string
  confidence: number
  detectionMethod: string
}

interface PreferencesStoreLike {
  get(key: string, defaultValue: string): Promise<string>
  put(key: string, value: string): Promise<void>
  flush(): Promise<void>
}

export class AlertStorageService {
  private static readonly STORE_NAME: string = 'fire_alert_store'
  private static readonly ALERTS_KEY: string = 'fire_alerts'
  private static initialized: boolean = false
  private static context: Object | null = null
  private static preferences: PreferencesStoreLike | null = null
  private static memoryFallback: Array<FireAlertRecord> = []

  static async initialize(context: Object): Promise<void> {
    if (AlertStorageService.initialized) {
      return
    }

    AlertStorageService.context = context
    try {
      const pref = await dataPreferences.getPreferences(context, AlertStorageService.STORE_NAME) as PreferencesStoreLike
      AlertStorageService.preferences = pref
      AlertStorageService.initialized = true
    } catch (error: Object) {
      console.error('AlertStorageService initialize fallback mode: ' + JSON.stringify(error))
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
    } catch (error: Object) {
      console.error('AlertStorageService getAlerts error: ' + JSON.stringify(error))
      return []
    }
  }
}
