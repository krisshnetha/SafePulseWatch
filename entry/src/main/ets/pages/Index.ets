import { HomePage } from './HomePage'
import { ProfilePage } from './ProfilePage'
import { AlertPage } from './AlertPage'
import { SOSPage } from './SOSPage'
import { NavigationPage } from './NavigationPage'
import { AdminPage } from './AdminPage'
import { WatchPage } from './WatchPage'
import { SOSLogPage } from './SOSLogPage'
import { NetworkService, ProfileItem, AlertItem } from '../services/NetworkService'

@Entry
@Component
struct Index {
  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State emergencyContactName: string = 'Demo Caregiver'
  @State emergencyContactNumber: string = '+6500000000'
  @State currentAlertType: string = 'FIRE'
  @State currentAlertInstruction: string = 'Evacuate immediately via nearest exit.'
  @State locationText: string = 'SOS sent successfully'

  aboutToAppear() {
    this.loadInitialProfile()
  }

  async loadInitialProfile() {
    const profile: ProfileItem | null = await NetworkService.fetchProfile()
    if (profile !== null) {
      this.selectedProfile = profile.profile
      this.userName = profile.name
      this.emergencyContactName = profile.contactName
      this.emergencyContactNumber = profile.contactNumber
    }
  }

  async checkBackendAlert() {
    const alert: AlertItem | null = await NetworkService.fetchCurrentAlert()
    if (alert !== null) {
      this.currentAlertType = alert.type
      this.currentAlertInstruction = alert.instruction
      this.currentPage = 'alert'
    }
  }

  async sendSOS(message: string) {
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
          alertType: this.currentAlertType,
          alertInstruction: this.currentAlertInstruction,
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
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#06101F')
  }
}