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

export interface SosLogsResponse {
  success: boolean
  logs: SosItem[]
  stats: SosStats
}

export class NetworkService {
  private static profileData: ProfileItem = {
    userId: 'demo-user',
    name: 'Krisshnetha',
    profile: 'Blind',
    contactName: 'Demo Caregiver',
    contactNumber: '+6500000000',
    updatedAt: 'Saved just now'
  }

  private static currentAlertData: AlertItem | null = {
    id: 'alert-1',
    type: 'FIRE',
    severity: 'HIGH',
    instruction: 'Evacuate immediately using the nearest safe exit.',
    locationName: 'Demo Building',
    timestamp: '1 min ago',
    active: true,
    acknowledged: false,
    resolved: false
  }

  private static sosLogData: SosItem[] = [
    {
      id: 'sos-1',
      userName: 'Demo User',
      profile: 'Blind',
      alertType: 'FIRE',
      latitude: 1.3521,
      longitude: 103.8198,
      message: 'Need emergency help now.',
      time: '2 min ago',
      status: 'ACTIVE',
      source: 'watch'
    }
  ]

  private static makeTimeText(): string {
    let d: Date = new Date()
    let h: string = d.getHours().toString()
    let m: string = d.getMinutes().toString()
    if (m.length === 1) {
      m = '0' + m
    }
    return h + ':' + m
  }

  static async fetchCurrentAlert(): Promise<AlertItem | null> {
    return NetworkService.currentAlertData
  }

  static async fetchAlertHistory(): Promise<AlertItem[]> {
    if (NetworkService.currentAlertData === null) {
      return []
    }
    return [NetworkService.currentAlertData]
  }

  static async triggerAlert(
    type: string,
    severity: string,
    instruction: string,
    locationName: string
  ): Promise<boolean> {
    NetworkService.currentAlertData = {
      id: 'alert-' + Date.now().toString(),
      type: type,
      severity: severity,
      instruction: instruction,
      locationName: locationName,
      timestamp: 'Just now',
      active: true,
      acknowledged: false,
      resolved: false
    }
    return true
  }

  static async clearAllAlerts(): Promise<boolean> {
    NetworkService.currentAlertData = null
    return true
  }

  static async fetchProfile(): Promise<ProfileItem | null> {
    return NetworkService.profileData
  }

  static async saveProfile(
    name: string,
    profile: string,
    contactName: string,
    contactNumber: string
  ): Promise<boolean> {
    NetworkService.profileData = {
      userId: 'demo-user',
      name: name,
      profile: profile,
      contactName: contactName,
      contactNumber: contactNumber,
      updatedAt: 'Saved at ' + NetworkService.makeTimeText()
    }
    return true
  }

  static async sendSOS(
    userName: string,
    profile: string,
    alertType: string,
    latitude: number,
    longitude: number,
    message: string
  ): Promise<boolean> {
    let newItem: SosItem = {
      id: 'sos-' + Date.now().toString(),
      userName: userName,
      profile: profile,
      alertType: alertType,
      latitude: latitude,
      longitude: longitude,
      message: message,
      time: 'Sent at ' + NetworkService.makeTimeText(),
      status: 'ACTIVE',
      source: 'watch'
    }
    NetworkService.sosLogData.unshift(newItem)
    return true
  }

  static async fetchSOSLogs(): Promise<SosLogsResponse> {
    let activeNum: number = 0
    let acknowledgedNum: number = 0
    let resolvedNum: number = 0

    for (let i: number = 0; i < NetworkService.sosLogData.length; i++) {
      let item: SosItem = NetworkService.sosLogData[i]
      if (item.status === 'ACTIVE') {
        activeNum += 1
      } else if (item.status === 'ACKNOWLEDGED') {
        acknowledgedNum += 1
      } else if (item.status === 'RESOLVED') {
        resolvedNum += 1
      }
    }

    return {
      success: true,
      logs: NetworkService.sosLogData,
      stats: {
        total: NetworkService.sosLogData.length,
        active: activeNum,
        acknowledged: acknowledgedNum,
        resolved: resolvedNum
      }
    }
  }

  static async acknowledgeSOS(id: string): Promise<boolean> {
    for (let i: number = 0; i < NetworkService.sosLogData.length; i++) {
      if (NetworkService.sosLogData[i].id === id) {
        NetworkService.sosLogData[i].status = 'ACKNOWLEDGED'
        return true
      }
    }
    return false
  }

  static async resolveSOS(id: string): Promise<boolean> {
    for (let i: number = 0; i < NetworkService.sosLogData.length; i++) {
      if (NetworkService.sosLogData[i].id === id) {
        NetworkService.sosLogData[i].status = 'RESOLVED'
        return true
      }
    }
    return false
  }

  static getMockLocationString(): string {
    return '1.3521, 103.8198'
  }
}