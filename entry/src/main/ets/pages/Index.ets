import { HomePage } from './HomePage'
import { ProfilePage } from './ProfilePage'
import { AlertPage } from './AlertPage'
import { SOSPage } from './SOSPage'
import { NavigationPage } from './NavigationPage'
import { AdminPage } from './AdminPage'
import { WatchPage } from './WatchPage'
import { SOSLogPage } from './SOSLogPage'
import { FireHistoryPage } from './FireHistoryPage'

import { HapticService } from '../services/HapticService'
import { AlertPersonalizationService } from '../services/AlertPersonalizationService'
import { AlertStorageService } from '../services/AlertStorageService'
import { AlertManager, MonitoringSnapshot, FireDetectionAlert } from '../services/AlertManager'
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
// import { NetworkService, ProfileItem, AlertItem } from '../services/NetworkService'
=======
>>>>>>> 04fc1ea (edited)
import common from '@ohos.app.ability.common'

import { AlertSyncService } from '../services/AlertSyncService'
import { NetworkService, ProfileItem, AlertItem, SyncState } from '../services/NetworkService'

<<<<<<< HEAD
=======
=======
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
import { NetworkService, ProfileItem, AlertItem } from '../services/NetworkService'
import { common } from '@kit.AbilityKit'

=======
>>>>>>> 04fc1ea (edited)
@Entry
@Component
struct Index {
  private readonly alertManager: AlertManager = new AlertManager()
  private syncService: AlertSyncService = AlertSyncService.getInstance()

  private syncListener = (state: SyncState, _reason: string): void => {
    this.applySyncState(state)
  }

  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State emergencyContactName: string = 'Demo Caregiver'
  @State emergencyContactNumber: string = '+6500000000'
<<<<<<< HEAD

=======
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
  @State currentAlertType: string = 'FIRE'
  @State currentAlertInstruction: string = 'Evacuate immediately via nearest exit.'
  @State currentAlertConfidence: number = 0
  @State currentDetectionMethod: string = 'frequency+pattern+ai'

  @State monitoringEnabled: boolean = true
  @State monitorEventText: string = 'Monitoring is initializing...'
  @State lastFireConfidence: number = 0

<<<<<<< HEAD
  @State currentAlert: AlertItem | null = null
  @State locationText: string = 'SOS sent successfully'
  @State syncStatusText: string = 'Connecting'
  @State isAcknowledging: boolean = false

  aboutToAppear(): void {
    this.initializeFireMonitoring()
    this.loadInitialProfile()
    this.syncService.subscribe(this.syncListener)
    this.syncService.start()
    this.refreshAlertState()
=======
  aboutToAppear() {
    this.initializeFireMonitoring()
    this.loadInitialProfile()
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
  }

  aboutToDisappear(): void {
    this.syncService.unsubscribe(this.syncListener)
    this.alertManager.stop()
  }

  async initializeFireMonitoring(): Promise<void> {
    try {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
      const hostContext = getContext(this).getHostContext() as common.BaseContext
=======
      const hostContext = getContext(this) as common.BaseContext
>>>>>>> 04fc1ea (edited)
      await AlertStorageService.initialize(hostContext)
    } catch (error) {
      console.error('Failed to initialize alert storage context: ' + JSON.stringify(error))
=======
=======
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
      const context = getContext(this) as common.UIAbilityContext
      await AlertStorageService.initialize(context)
    } catch (error) {
      console.error(
        'Failed to initialize alert storage context: ' + JSON.stringify(error as Object)
      )
    }

    this.alertManager.onSnapshot = (snapshot: MonitoringSnapshot) => {
      this.applySnapshot(snapshot)
    }

    this.alertManager.onAlert = (alert: FireDetectionAlert) => {
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
    this.currentAlertType = 'FIRE ALARM DETECTED'
    this.currentAlertInstruction =
      'Fire alarm detected nearby. Follow the safest route and notify emergency contacts.'
    this.currentAlertConfidence = alert.confidence
    this.currentDetectionMethod = alert.method
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
      this.emergencyContactName = profile.contactName
      this.emergencyContactNumber = profile.contactNumber
    }
  }

<<<<<<< HEAD
  async checkBackendAlert(): Promise<void> {
=======
  async checkBackendAlert() {
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
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

<<<<<<< HEAD
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

  async sendSOS(message: string): Promise<void> {
=======
  async sendSOS(message: string) {
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
    const ok: boolean = await NetworkService.sendSOS(
      this.userName === '' ? 'Unknown User' : this.userName,
      this.selectedProfile,
      this.currentAlertType,
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

  build() {
    Column() {
      if (this.currentPage === 'home') {
        HomePage({
          profileName: this.selectedProfile,
          userName: this.userName,
          monitoringEnabled: this.monitoringEnabled,
          monitorEventText: this.monitorEventText,
          lastFireConfidence: this.lastFireConfidence,
<<<<<<< HEAD
          currentAlert: this.currentAlert,
          systemStatus: this.currentAlert !== null ? 'Alert Active' : 'Protected',
          syncStatusText: this.syncStatusText,

=======
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
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
          onToggleMonitoring: () => {
            this.toggleFireMonitoring()
          },
          onViewFireHistory: () => {
            this.currentPage = 'fireHistory'
<<<<<<< HEAD
            this.refreshAlertState()
=======
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
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
          profileName: this.selectedProfile,
<<<<<<< HEAD
          alertType: this.currentAlert?.type || this.currentAlertType,
          alertSeverity: this.currentAlert?.severity || 'HIGH',
          alertInstruction:
          this.currentAlert?.instruction || this.currentAlertInstruction,
          alertConfidence: this.currentAlertConfidence,
          detectionMethod: this.currentDetectionMethod,
          syncStatusText: this.syncStatusText,
          isAcknowledging: this.isAcknowledging,

=======
          alertType: this.currentAlertType,
          alertInstruction: this.currentAlertInstruction,
          alertConfidence: this.currentAlertConfidence,
          detectionMethod: this.currentDetectionMethod,
>>>>>>> 4a9f382 (fix: clean ArkTS merge leftovers)
          onBack: () => {
            this.currentPage = 'home'
          },
          onSOS: () => {
            this.sendSOS('SOS triggered from emergency alert screen.')
          },
          onNavigate: () => {
            this.currentPage = 'navigation'
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