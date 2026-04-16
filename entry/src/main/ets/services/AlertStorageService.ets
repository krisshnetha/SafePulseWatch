import dataPreferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'

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
  private static context: common.UIAbilityContext | null = null
  private static preferences: dataPreferences.Preferences | null = null
  private static memoryFallback: Array<FireAlertRecord> = []

  static async initialize(context: common.UIAbilityContext): Promise<void> {
    if (AlertStorageService.initialized) {
      return
    }

    AlertStorageService.context = context
    try {
      const pref = await dataPreferences.getPreferences(
        context,
        AlertStorageService.STORE_NAME
      )
      AlertStorageService.preferences = pref
      AlertStorageService.initialized = true
    } catch (error) {
      console.error('AlertStorageService initialize fallback mode: ' + JSON.stringify(error as Object))
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

    if (AlertStorageService.preferences === null) {
      AlertStorageService.memoryFallback = updated
      return record
    }

    try {
      await AlertStorageService.preferences.put(AlertStorageService.ALERTS_KEY, JSON.stringify(updated))
      await AlertStorageService.preferences.flush()
    } catch (error) {
      console.error('AlertStorageService saveAlert fallback mode: ' + JSON.stringify(error as Object))
      AlertStorageService.memoryFallback = updated
    }

    return record
  }

  static async getAlerts(): Promise<Array<FireAlertRecord>> {
    if (AlertStorageService.preferences === null) {
      return [...AlertStorageService.memoryFallback]
    }

    try {
      const json = await AlertStorageService.preferences.get(AlertStorageService.ALERTS_KEY, '[]') as string
      const parsed = JSON.parse(json) as Array<FireAlertRecord>
      return parsed
    } catch (error) {
      console.error('AlertStorageService getAlerts error: ' + JSON.stringify(error as Object))
      return []
    }
  }
}
