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

export class NetworkService {
  static BASE_URL: string = 'http://192.168.229.136:3000'

  static async fetchCurrentAlert(): Promise<AlertItem | null> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/alert`)
      const data = await response.json() as Record<string, Object>
      return (data['alert'] as AlertItem) || null
    } catch (error) {
      console.error('fetchCurrentAlert error: ' + JSON.stringify(error))
      return null
    }
  }

  static async fetchAlertHistory(): Promise<Array<AlertItem>> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/alerts`)
      const data = await response.json() as Record<string, Object>
      return (data['alerts'] as Array<AlertItem>) || []
    } catch (error) {
      console.error('fetchAlertHistory error: ' + JSON.stringify(error))
      return []
    }
  }

  static async triggerAlert(type: string, severity: string, instruction: string, locationName: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/trigger-alert`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          type,
          severity,
          instruction,
          locationName
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
      const response = await fetch(`${NetworkService.BASE_URL}/api/clear-alerts`, {
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
      const response = await fetch(`${NetworkService.BASE_URL}/api/profile`)
      const data = await response.json() as Record<string, Object>
      return (data['profile'] as ProfileItem) || null
    } catch (error) {
      console.error('fetchProfile error: ' + JSON.stringify(error))
      return null
    }
  }

  static async saveProfile(name: string, profile: string, contactName: string = 'Demo Caregiver', contactNumber: string = '+6500000000'): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/profile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: 'demo-user',
          name,
          profile,
          contactName,
          contactNumber
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
          userName,
          profile,
          alertType,
          latitude,
          longitude,
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
      const response = await fetch(`${NetworkService.BASE_URL}/api/logs`)
      return await response.json() as Record<string, Object>
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

  static async acknowledgeSOS(id: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/logs/${id}/acknowledge`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('acknowledgeSOS error: ' + JSON.stringify(error))
      return false
    }
  }

  static async resolveSOS(id: string): Promise<boolean> {
    try {
      const response = await fetch(`${NetworkService.BASE_URL}/api/logs/${id}/resolve`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json() as Record<string, Object>
      return !!data['success']
    } catch (error) {
      console.error('resolveSOS error: ' + JSON.stringify(error))
      return false
    }
  }
}