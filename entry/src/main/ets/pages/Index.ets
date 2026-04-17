import { HomePage } from './HomePage'
import { ProfilePage } from './ProfilePage'
import { AlertPage } from './AlertPage'
import { SOSPage } from './SOSPage'
import { NavigationPage } from './NavigationPage'
import { AdminPage } from './AdminPage'
import { WatchPage } from './WatchPage'
import { SOSLogPage } from './SOSLogPage'
import { FireHistoryPage } from './FireHistoryPage'

import common from '@ohos.app.ability.common'

import { HapticService } from '../services/HapticService'
import { AlertPersonalizationService } from '../services/AlertPersonalizationService'
import { AlertStorageService } from '../services/AlertStorageService'
import { AlertManager, MonitoringSnapshot, FireDetectionAlert } from '../services/AlertManager'
import { NetworkService, ProfileItem, AlertItem } from '../services/NetworkService'

@Entry
@Component
struct Index {
  private readonly alertManager: AlertManager = new AlertManager()
  private alertPollTimer: number = -1

  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State emergencyContactName: string = 'Demo Caregiver'
  @State emergencyContactNumber: string = '+6500000000'

  @State currentAlertType: string = 'FIRE ALERT'
  @State currentAlertInstruction: string = 'Fire detected nearby. Alert your emergency contact immediately.'
  @State currentAlertConfidence: number = 0
  @State currentDetectionMethod: string = 'frequency+pattern+ai'

  @State monitoringEnabled: boolean = true
  @State monitorEventText: string = 'Monitoring is initializing...'
  @State lastFireConfidence: number = 0

  @State currentAlert: AlertItem | null = null
  @State locationText: string = 'SOS sent successfully'
  @State syncStatusText: string = 'Polling backend'
  @State alertStatusText: string = 'Ready to send fire emergency alert.'
  @State isSendingAlert: boolean = false

  aboutToAppear(): void {
    this.initializeFireMonitoring()
    this.loadInitialProfile()
    this.startAlertPolling()
  }

  aboutToDisappear(): void {
    this.stopAlertPolling()
    this.alertManager.stop()
  }

  private startAlertPolling(): void {
    if (this.alertPollTimer !== -1) {
      return
    }

    this.syncStatusText = 'Polling backend'

    this.alertPollTimer = setInterval(() => {
      this.pollCurrentAlert()
    }, 1500)

    this.pollCurrentAlert()
  }

  private stopAlertPolling(): void {
    if (this.alertPollTimer !== -1) {
      clearInterval(this.alertPollTimer)
      this.alertPollTimer = -1
    }
  }

  private async pollCurrentAlert(): Promise<void> {
    const alert: AlertItem | null = await NetworkService.fetchCurrentAlert()

    if (alert !== null && alert.active) {
      this.currentAlert = alert
      this.currentAlertType = 'FIRE ALERT'
      this.currentAlertInstruction = alert.instruction
      this.currentDetectionMethod = 'backend-poll'
      this.alertStatusText =
        'Backend fire alert received. Ready to alert emergency contact.'
      if (this.currentPage !== 'sos') {
        this.currentPage = 'alert'
      }
    } else {
      this.currentAlert = null
    }
  }

  async initializeFireMonitoring(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext
      await AlertStorageService.initialize(context)
    } catch (error) {
      console.error('Failed to initialize alert storage context: ' + JSON.stringify(error))
    }

    this.alertManager.onSnapshot = (snapshot: MonitoringSnapshot): void => {
      this.applySnapshot(snapshot)
    }

    this.alertManager.onAlert = (alert: FireDetectionAlert): void => {
      this.handleFireAlert(alert)
    }

    await this.alertManager.start()
    this.monitoringEnabled = true
  }

  private applySnapshot(snapshot: MonitoringSnapshot): void {
    this.monitoringEnabled = snapshot.running
    this.lastFireConfidence = snapshot.aiConfidence
    this.monitorEventText =
      snapshot.lastDecision +
        ' | Pattern confidence: ' +
      snapshot.patternConfidence.toFixed(2) +
        ' | Frames: ' +
      snapshot.framesProcessed.toString()
  }

  private handleFireAlert(alert: FireDetectionAlert): void {
    const channel = AlertPersonalizationService.getPrimaryChannel(this.selectedProfile)
    this.currentAlertType = 'FIRE ALERT'
    this.currentAlertInstruction =
      'Fire alarm frequency detected. Send emergency alert to your contact immediately.'
    this.currentAlertConfidence = alert.confidence
    this.currentDetectionMethod = alert.method
    this.alertStatusText =
      'Fire alarm detected at ' + alert.timestamp + '. Ready to alert emergency contact.'
    this.monitorEventText =
      'Confirmed fire alarm at ' + alert.timestamp + ' via ' + channel + ' priority channel.'

    HapticService.trigger(this.selectedProfile)
    this.currentPage = 'alert'
  }

  async loadInitialProfile(): Promise<void> {
    const profile: ProfileItem | null = await NetworkService.fetchProfile()
    if (profile !== null) {
      this.selectedProfile = profile.profile
      this.userName = profile.name
      this.emergencyContactName = profile.contactName || this.emergencyContactName
      this.emergencyContactNumber = profile.contactNumber || this.emergencyContactNumber
    }
  }

<<<<<<< Updated upstream
  async checkBackendAlert(): Promise<void> {
    const alert: AlertItem | null = await NetworkService.fetchCurrentAlert()

    if (alert !== null) {
      this.currentAlert = alert
      this.currentAlertType = alert.type
      this.currentAlertInstruction = alert.instruction
      this.currentAlertConfidence = 0
      this.currentDetectionMethod = 'backend-alert'
      this.currentPage = 'alert'
    } else {
      this.currentAlert = null
      this.monitorEventText = 'No active backend alert right now.'
    }
  }

  private applySyncState(state: SyncState): void {
    if (!this.isAcknowledging) {
      this.currentAlert = state.activeEmergency
    }

    this.syncStatusText = 'Live Sync'

    if (state.activeEmergency !== null) {
      this.currentAlertType = state.activeEmergency.type
      this.currentAlertInstruction = state.activeEmergency.instruction
      this.currentPage = 'alert'
    } else if (this.currentPage === 'alert' && !this.isAcknowledging) {
      this.currentPage = 'home'
    }
  }

  async refreshAlertState(): Promise<void> {
    this.syncStatusText = 'Syncing'
    const state = await NetworkService.fetchSyncState()

    if (state !== null) {
      this.applySyncState(state)
      return
    }

    this.syncStatusText = 'Offline'
  }

  async acknowledgeCurrentAlert(): Promise<void> {
    if (this.currentAlert === null || this.isAcknowledging) {
      return
    }

    const alertId = this.currentAlert.id
    this.isAcknowledging = true
    this.currentAlert = null
    this.currentPage = 'home'

    const ok = await NetworkService.acknowledgeAlert(alertId)
    this.isAcknowledging = false

    if (!ok) {
      this.syncStatusText = 'Retrying'
      await this.syncService.forceRefresh('acknowledge-failed')
      return
    }

    await this.syncService.forceRefresh('acknowledged')
  }

=======
>>>>>>> Stashed changes
  async sendSOS(message: string): Promise<void> {
    const ok: boolean = await NetworkService.sendSOS(
      this.userName === '' ? 'Unknown User' : this.userName,
      this.selectedProfile,
      this.currentAlert?.type || 'FIRE',
      1.4448,
      103.8246,
      message
    )

    if (ok) {
      this.locationText =
        'SOS sent to ' +
        this.emergencyContactName +
          ' (' +
        this.emergencyContactNumber +
          ') with live location.'
    } else {
      this.locationText = 'Failed to send SOS'
    }

    this.currentPage = 'sos'
  }

  async sendFireAlertToContact(): Promise<void> {
    if (this.isSendingAlert) {
      return
    }

    this.isSendingAlert = true
    this.alertStatusText = 'Sending fire emergency alert...'

    const ok: boolean = await NetworkService.sendSOS(
      this.userName === '' ? 'Unknown User' : this.userName,
      this.selectedProfile,
      'FIRE ALERT',
      1.4448,
      103.8246,
      'Fire alert triggered. Please respond immediately.'
    )

    this.isSendingAlert = false

    if (ok) {
      this.alertStatusText =
        'Fire alert sent to ' +
        this.emergencyContactName +
          ' (' +
        this.emergencyContactNumber +
          ').'
      this.locationText =
        'Emergency alert sent to ' +
        this.emergencyContactName +
          ' with live location.'
      this.currentPage = 'sos'
    } else {
      this.alertStatusText = 'Failed to send fire alert. Please try again.'
    }
  }

  build() {
    Column() {
      if (this.currentPage === 'home') {
        HomePage({
          profileName: this.selectedProfile,
          userName: this.userName,
          monitoringEnabled: this.monitoringEnabled,
          monitorEventText: this.monitorEventText,
          lastFireConfidence: this.lastFireConfidence,
          currentAlert: this.currentAlert,
          systemStatus: this.currentAlert !== null ? 'Alert Active' : 'Protected',
          syncStatusText: this.syncStatusText,
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
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
            this.pollCurrentAlert()
          },
          onToggleMonitoring: () => {
            this.toggleFireMonitoring()
          },
          onViewFireHistory: () => {
            this.currentPage = 'fireHistory'
<<<<<<< Updated upstream
            this.refreshAlertState()
=======
>>>>>>> Stashed changes
          }
        })
      } else if (this.currentPage === 'profile') {
        ProfilePage({
          initialProfile: this.selectedProfile,
          initialName: this.userName,
          initialContactName: this.emergencyContactName,
          initialContactNumber: this.emergencyContactNumber,
          onSave: (
            name: string,
            profile: string,
            contactName: string,
            contactNumber: string
          ) => {
            this.userName = name
            this.selectedProfile = profile
            this.emergencyContactName = contactName
            this.emergencyContactNumber = contactNumber
            NetworkService.saveProfile(name, profile, contactName, contactNumber)
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
<<<<<<< Updated upstream
          profileName: this.selectedProfile,
          alertType: this.currentAlert?.type || this.currentAlertType,
          alertSeverity: this.currentAlert?.severity || 'HIGH',
          alertInstruction: this.currentAlert?.instruction || this.currentAlertInstruction,
          alertConfidence: this.currentAlertConfidence,
          detectionMethod: this.currentDetectionMethod,
          syncStatusText: this.syncStatusText,
          isAcknowledging: this.isAcknowledging,

          onBack: () => {
            this.currentPage = 'home'
          },
          onSOS: () => {
            this.sendSOS('SOS triggered from emergency alert screen.')
=======
          contactName: this.emergencyContactName,
          contactNumber: this.emergencyContactNumber,
          statusText: this.alertStatusText,
          isSending: this.isSendingAlert,
          onSendAlert: () => {
            this.sendFireAlertToContact()
>>>>>>> Stashed changes
          },
          onNavigate: () => {
            this.currentPage = 'navigation'
          },
<<<<<<< Updated upstream
          onAcknowledge: () => {
            this.acknowledgeCurrentAlert()
=======
          onBack: () => {
            this.currentPage = 'home'
>>>>>>> Stashed changes
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
      } else if (this.currentPage === 'fireHistory') {
        FireHistoryPage({
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

  private async toggleFireMonitoring(): Promise<void> {
    if (this.monitoringEnabled) {
      await this.alertManager.stop()
      this.monitoringEnabled = false
      this.monitorEventText = 'Monitoring paused by user.'
      return
    }

    await this.alertManager.start()
    this.monitoringEnabled = true
    this.monitorEventText = 'Monitoring resumed. Listening for fire alarm patterns.'
  }
}