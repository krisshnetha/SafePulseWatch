import { HomePage } from './HomePage'
import { ProfilePage } from './ProfilePage'
import { AlertPage } from './AlertPage'
import { SOSPage } from './SOSPage'
import { NavigationPage } from './NavigationPage'
import { AdminPage } from './AdminPage'
import { WatchPage } from './WatchPage'
import { SOSLogPage } from './SOSLogPage'
import { ProfileService } from '../services/ProfileService'
import { HapticService } from '../services/HapticService'
import { NetworkService } from '../services/NetworkService'
import { GuardianAudioService } from '../services/GuardianAudioService'
import { AlertPersonalizationService } from '../services/AlertPersonalizationService'
import { SmsNotificationService } from '../services/SmsNotificationService'

@Entry
@Component
struct Index {
  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State currentAlertType: string = 'FIRE'
  @State currentAlertInstruction: string = 'Evacuate immediately via nearest exit.'
  @State locationText: string = 'SOS sent successfully'
  @State monitoringEnabled: boolean = true
  @State monitorEventText: string = 'No suspicious audio pattern detected yet'
  syncTimer: number = -1

  aboutToAppear(): void {
    this.monitoringEnabled = GuardianAudioService.isMonitoringEnabled()
    this.pullSharedState()
    this.syncTimer = setInterval(() => {
      this.pullSharedState()
    }, 4000)
  }

  aboutToDisappear(): void {
    if (this.syncTimer !== -1) {
      clearInterval(this.syncTimer)
      this.syncTimer = -1
    }
  }

  async pullSharedState(): Promise<void> {
    await this.loadInitialProfile()
    const alert = await NetworkService.fetchCurrentAlert()
    if (alert) {
      this.currentAlertType = alert.type
      this.currentAlertInstruction = alert.instruction
    }
  }

  async loadInitialProfile(): Promise<void> {
    const profile = await NetworkService.fetchProfile()
    if (profile) {
      if (profile.profile) {
        this.selectedProfile = profile.profile
        ProfileService.setProfile(profile.profile)
      }
      if (profile.name) {
        this.userName = profile.name
        ProfileService.setName(profile.name)
      }
    }
  }

  async checkBackendAlert(): Promise<void> {
    const alert = await NetworkService.fetchCurrentAlert()
    if (alert) {
      this.currentAlertType = alert.type
      this.currentAlertInstruction = alert.instruction
      HapticService.trigger(this.selectedProfile)
      this.currentPage = 'alert'
    } else {
      this.monitorEventText = 'No active backend alert right now.'
    }
  }

  async sendSOS(message: string): Promise<void> {
    const ok = await NetworkService.sendSOS(
      this.userName === '' ? 'Unknown User' : this.userName,
      this.selectedProfile,
      this.currentAlertType,
      1.4448,
      103.8246,
      message
    )

    if (ok) {
      const channel = AlertPersonalizationService.getPrimaryChannel(this.selectedProfile)
      this.locationText = 'Live location and SOS were sent successfully (' + channel + ' priority)'
    } else {
      this.locationText = 'Failed to send SOS to backend'
    }

    this.currentPage = 'sos'
  }

  build() {
    Column() {
      if (this.currentPage === 'home') {
        HomePage({
          profileName: this.selectedProfile,
          userName: this.userName,
          monitoringEnabled: this.monitoringEnabled,
          monitorEventText: this.monitorEventText,
          onProfile: () => {
            this.currentPage = 'profile'
          },
          onAdmin: () => {
            this.currentPage = 'admin'
          },
          onWatch: () => {
            this.currentPage = 'watch'
          },
          onNavigate: () => {
            this.currentPage = 'navigation'
          },
          onSOSLog: () => {
            this.currentPage = 'soslog'
          },
          onCheckBackend: () => {
            this.checkBackendAlert()
          },
          onSOS: () => {
            HapticService.trigger(this.selectedProfile)
            this.sendSOS('I need emergency assistance from dashboard.')
          },
          onToggleMonitoring: () => {
            const enabled = GuardianAudioService.toggleMonitoring()
            this.monitoringEnabled = enabled
            if (enabled) {
              this.monitorEventText = 'Monitoring resumed. Local microphone classifier is active.'
            } else {
              this.monitorEventText = 'Monitoring paused by user. Tap resume to reactivate protection.'
            }
          },
          onSimulateAudioDetection: () => {
            const result = GuardianAudioService.simulateAudioPattern('fire-alarm')
            if (result.detected) {
              const channel = AlertPersonalizationService.getPrimaryChannel(this.selectedProfile)
              this.monitorEventText = 'Fire-alarm pattern detected locally at ' + result.detectedAt
              this.currentAlertType = 'FIRE ALARM DETECTED'
              this.currentAlertInstruction = 'Detected local alarm pattern. Move to safe route and request help if needed.'
              HapticService.trigger(this.selectedProfile)
              console.info('Guardian channel selection: ' + channel)
              this.currentPage = 'alert'
            } else {
              this.monitorEventText = result.reason
            }
          },
          onSendTestSms: () => {
            const sent = SmsNotificationService.sendTestNotification(
              '+6500000000',
              NetworkService.getMockLocationString(),
              this.selectedProfile
            )
            this.monitorEventText = sent
              ? 'Test SMS event queued for caregiver notification.'
              : 'SMS notification skipped due to offline simulation.'
          }
        })
      } else if (this.currentPage === 'profile') {
        ProfilePage({
          initialProfile: this.selectedProfile,
          initialName: this.userName,
          onSave: async (name: string, profile: string) => {
            this.userName = name
            this.selectedProfile = profile
            ProfileService.setName(name)
            ProfileService.setProfile(profile)
            await NetworkService.saveProfile(name, profile)
            this.currentPage = 'home'
          },
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'admin') {
        AdminPage({
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'watch') {
        WatchPage({
          userName: this.userName,
          selectedProfile: this.selectedProfile,
          onBack: () => {
            this.currentPage = 'home'
          },
          onNavigate: () => {
            this.currentPage = 'navigation'
          },
          onSOS: () => {
            this.sendSOS('I need emergency assistance.')
          }
        })
      } else if (this.currentPage === 'alert') {
        AlertPage({
          profileName: this.selectedProfile,
          alertType: this.currentAlertType,
          alertInstruction: this.currentAlertInstruction,
          onBack: () => {
            this.currentPage = 'home'
          },
          onSOS: () => {
            HapticService.trigger(this.selectedProfile)
            this.sendSOS('SOS triggered from emergency alert screen.')
          },
          onSafe: async () => {
            await NetworkService.markSafe()
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'sos') {
        SOSPage({
          locationText: this.locationText,
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'navigation') {
        NavigationPage({
          profileName: this.selectedProfile,
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'soslog') {
        SOSLogPage({
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}

@Preview
@Component
struct IndexPreview {
  build() {
    Index()
  }
}
