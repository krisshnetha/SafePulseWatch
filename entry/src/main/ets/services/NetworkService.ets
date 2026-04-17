import http from '@ohos.net.http'

export interface AlertItem {
  id: string
  type: string
  normalizedType?: string
  severity: string
  instruction: string
  locationName: string
  timestamp: string
  active: boolean
  acknowledged: boolean
  resolved: boolean
}

export interface ProfileItem {
  userId: string
  name: string
  profile: string
  contactName: string
  contactNumber: string
  updatedAt: string
}

export interface SosItem {
  id: string
  userName: string
  profile: string
  alertType: string
  latitude: number
  longitude: number
  message: string
  time: string
  status: string
  source?: string
}

export interface SosStats {
  total: number
  active: number
  acknowledged: number
  resolved: number
}

export interface SosLogsResponse {
  success: boolean
  logs: SosItem[]
  stats: SosStats
}

export interface SyncState {
  userId: string
  userName: string
  profile: string
  contacts: Object[]
  activeEmergency: AlertItem | null
  sos: Object
  history: AlertItem[]
  stateRevision: number
}

export interface FireAlertPayload {
  type: string
  timestamp: string
  confidence: number
}

interface SyncStateResponse {
  success: boolean
  state: SyncState
}

export class NetworkService {
  static BASE_URL: string = 'http://172.20.10.2:3000'
  static WS_URL: string = 'ws://172.20.10.2:3000/ws'

  private static async request(
    path: string,
    method: http.RequestMethod,
    body: string | null = null
  ): Promise<string | null> {
    let httpRequest = http.createHttp()

    try {
      const options: http.HttpRequestOptions = {
        method: method,
        expectDataType: http.HttpDataType.STRING
      }

      if (body !== null) {
        options.header = {
          'Content-Type': 'application/json'
        }
        options.extraData = body
      }

      const response = await httpRequest.request(`${NetworkService.BASE_URL}${path}`, options)
      if (response.responseCode < 200 || response.responseCode >= 300) {
        console.error(`Request failed for ${path}: ` + response.responseCode)
        console.error('Response: ' + String(response.result))
        return null
      }

      return String(response.result)
    } catch (error) {
      console.error(`Network request failed for ${path}: ` + JSON.stringify(error))
      return null
    } finally {
      httpRequest.destroy()
    }
  }

  static async fetchSyncState(): Promise<SyncState | null> {
    const raw = await NetworkService.request('/api/sync/state', http.RequestMethod.GET)
    if (raw === null) {
      return null
    }

    const data = JSON.parse(raw) as SyncStateResponse
    return data.state || null
  }

  static async fetchCurrentAlert(): Promise<AlertItem | null> {
    const state = await NetworkService.fetchSyncState()
    return state?.activeEmergency || null
  }

  static async fetchAlertHistory(): Promise<AlertItem[]> {
    const raw = await NetworkService.request('/api/alerts', http.RequestMethod.GET)
    if (raw === null) {
      return []
    }

    const data = JSON.parse(raw) as Record<string, Object>
    return (data['alerts'] as AlertItem[]) || []
  }

  static async triggerAlert(
    type: string,
    severity: string,
    instruction: string,
    locationName: string
  ): Promise<boolean> {
    const raw = await NetworkService.request(
      '/api/trigger-alert',
      http.RequestMethod.POST,
      JSON.stringify({
        type,
        severity,
        instruction,
        locationName
      })
    )
    return raw !== null
  }

  static async clearAllAlerts(): Promise<boolean> {
    const raw = await NetworkService.request('/api/clear-alerts', http.RequestMethod.POST)
    return raw !== null
  }

  static async acknowledgeAlert(alertId: string): Promise<boolean> {
    const raw = await NetworkService.request(
      '/api/alert/acknowledge',
      http.RequestMethod.POST,
      JSON.stringify({
        alertId,
        source: 'wearable'
      })
    )
    return raw !== null
  }

  static async fetchProfile(): Promise<ProfileItem | null> {
    const raw = await NetworkService.request('/api/profile', http.RequestMethod.GET)
    if (raw === null) {
      return null
    }

    const data = JSON.parse(raw) as Record<string, Object>
    return (data['profile'] as ProfileItem) || null
  }

  static async saveProfile(
    name: string,
    profile: string,
    contactName: string,
    contactNumber: string
  ): Promise<boolean> {
    const raw = await NetworkService.request(
      '/api/profile',
      http.RequestMethod.POST,
      JSON.stringify({
        name,
        profile,
        contactName,
        contactNumber
      })
    )
    return raw !== null
  }

  static async sendSOS(
    userName: string,
    profile: string,
    alertType: string,
    latitude: number,
    longitude: number,
    message: string
  ): Promise<boolean> {
    const raw = await NetworkService.request(
      '/api/sos',
      http.RequestMethod.POST,
      JSON.stringify({
        userName,
        profile,
        emergencyType: alertType,
        latitude,
        longitude,
        message,
        source: 'wearable'
      })
    )
    return raw !== null
  }

  static async fetchSOSLogs(): Promise<SosLogsResponse | null> {
    const raw = await NetworkService.request('/api/logs', http.RequestMethod.GET)
    if (raw === null) {
      return null
    }

    return JSON.parse(raw) as SosLogsResponse
  }

  static async acknowledgeSOS(logId: string): Promise<boolean> {
    const raw = await NetworkService.request(
      `/api/logs/${logId}/acknowledge`,
      http.RequestMethod.POST,
      JSON.stringify({ source: 'wearable' })
    )
    return raw !== null
  }

  static async resolveSOS(logId: string): Promise<boolean> {
    const raw = await NetworkService.request(
      `/api/logs/${logId}/resolve`,
      http.RequestMethod.POST,
      JSON.stringify({ source: 'wearable' })
    )
    return raw !== null
  }

  static async sendPhoneFireAlert(payload: FireAlertPayload): Promise<boolean> {
    const raw = await NetworkService.request(
      '/api/phone/fire-alert',
      http.RequestMethod.POST,
      JSON.stringify(payload)
    )
    return raw !== null
  }

  static getMockLocationString(): string {
    return '1.3521, 103.8198'
  }
}