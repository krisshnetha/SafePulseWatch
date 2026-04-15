export interface AlertItem {
  id: string
  type: string
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

export class NetworkService {
  static BASE_URL: string = 'http://192.168.229.136:3000'
  static USER_ID: string = 'demo-user-1'

  static profileToBackend(profile: string): string {
    if (profile === 'Blind') return 'vision'
    if (profile === 'Deaf') return 'hearing'
    if (profile === 'Speech') return 'speech'
    if (profile === 'Mobility') return 'mobility'
    return 'cognitive'
  }

  static profileFromBackend(profile: string): string {
    if (profile === 'vision') return 'Blind'
    if (profile === 'hearing') return 'Deaf'
    if (profile === 'speech') return 'Speech'
    if (profile === 'mobility') return 'Mobility'
    return 'Elderly'
  }

  static async fetchCurrentAlert(): Promise<AlertItem | null> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/sync/state`)
      const data = await response.json() as Record<string, Object>
      const state = data['state'] as Record<string, Object>
      const emergency = (state && state['activeEmergency']) as Record<string, Object> | undefined
      if (!emergency) return null
      return {
        id: String(emergency['id'] || ''),
        type: String(emergency['title'] || emergency['type'] || 'ALERT'),
        severity: String(emergency['severity'] || 'HIGH'),
        instruction: String(emergency['message'] || 'Follow emergency instructions'),
        locationName: 'Shared backend',
        timestamp: String(emergency['createdAt'] || new Date().toISOString()),
        active: true,
        acknowledged: false,
        resolved: false
      }
    } catch (error) {
      console.error('fetchCurrentAlert error: ' + JSON.stringify(error))
      return null
    }
  }

  static async fetchAlertHistory(): Promise<Array<AlertItem>> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/history`)
      const data = await response.json() as Record<string, Object>
      const history = (data['history'] as Array<Record<string, Object>>) || []
      return history.map((item: Record<string, Object>) => ({
        id: String(item['id'] || ''),
        type: String(item['title'] || item['type'] || 'ALERT'),
        severity: String(item['severity'] || 'HIGH'),
        instruction: String(item['message'] || 'Follow emergency instructions'),
        locationName: 'Shared backend',
        timestamp: String(item['resolvedAt'] || item['createdAt'] || new Date().toISOString()),
        active: false,
        acknowledged: true,
        resolved: true
      }))
    } catch (error) {
      console.error('fetchAlertHistory error: ' + JSON.stringify(error))
      return []
    }
  }

  static async triggerAlert(type: string, severity: string, instruction: string, locationName: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/emergency/trigger`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: NetworkService.USER_ID,
          type: type.toLowerCase(),
          severity: severity.toLowerCase(),
          title: type,
          message: instruction + ' @ ' + locationName
        })
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('triggerAlert error: ' + JSON.stringify(error))
      return false
    }
  }

  static async clearAllAlerts(): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/emergency/resolve`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('clearAllAlerts error: ' + JSON.stringify(error))
      return false
    }
  }

  static async fetchProfile(): Promise<ProfileItem | null> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/sync/state`)
      const data = await response.json() as Record<string, Object>
      const state = data['state'] as Record<string, Object>
      if (!state) return null
      return {
        userId: String(state['userId'] || NetworkService.USER_ID),
        name: '',
        profile: NetworkService.profileFromBackend(String(state['profile'] || 'vision')),
        updatedAt: new Date().toISOString()
      }
    } catch (error) {
      console.error('fetchProfile error: ' + JSON.stringify(error))
      return null
    }
  }

  static async saveProfile(name: string, profile: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/profile`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: NetworkService.USER_ID,
          userName: name,
          profile: NetworkService.profileToBackend(profile)
        })
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('saveProfile error: ' + JSON.stringify(error))
      return false
    }
  }

  static async sendSOS(userName: string, profile: string, alertType: string, latitude: number, longitude: number, message: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/sos`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: NetworkService.USER_ID,
          userName,
          profile: NetworkService.profileToBackend(profile),
          emergencyType: alertType.toLowerCase(),
          location: `${latitude},${longitude}`,
          message,
          source: 'watch'
        })
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('sendSOS error: ' + JSON.stringify(error))
      return false
    }
  }

  static async fetchSOSLogs(): Promise<Record<string, Object>> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/sos/latest`)
      const data = await response.json() as Record<string, Object>
      const latest = data['latestEvent'] as Record<string, Object>
      if (!latest) {
        return {
          success: true,
          logs: [],
          stats: { total: 0, active: 0, acknowledged: 0, resolved: 0 }
        }
      }
      const log: SosItem = {
        id: String(latest['id'] || ''),
        userName: 'Demo User',
        profile: String(latest['source'] || 'watch'),
        alertType: String(latest['emergencyType'] || 'unknown'),
        latitude: 1.3521,
        longitude: 103.8198,
        message: String(latest['message'] || ''),
        time: String(latest['time'] || new Date().toISOString()),
        status: 'ACTIVE',
        source: String(latest['source'] || 'watch')
      }
      return {
        success: true,
        logs: [log],
        stats: { total: 1, active: 1, acknowledged: 0, resolved: 0 }
      }
    } catch (error) {
      console.error('fetchSOSLogs error: ' + JSON.stringify(error))
      return {
        success: false,
        logs: [],
        stats: {
          total: 0,
          active: 0,
          acknowledged: 0,
          resolved: 0
        }
      }
    }
  }

  static async acknowledgeSOS(_id: string): Promise<boolean> {
    return true
  }

  static async resolveSOS(_id: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/safe`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: NetworkService.USER_ID,
          source: 'watch'
        })
      })
      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('resolveSOS error: ' + JSON.stringify(error))
      return false
    }
  }

  static async markSafe(): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/safe`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: NetworkService.USER_ID,
          source: 'watch'
        })
      })
      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('markSafe error: ' + JSON.stringify(error))
      return false
    }
  }

  static getMockLocationString(): string {
    return '1.3521, 103.8198'
  }
}