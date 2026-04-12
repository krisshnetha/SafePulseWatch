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

@Entry
@Component
struct Index {
  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Blind'
  @State userName: string = ''
  @State currentAlertType: string = 'FIRE'
  @State currentAlertInstruction: string = 'Evacuate immediately via nearest exit.'
  @State locationText: string = 'SOS sent successfully'

  aboutToAppear() {
    this.loadInitialProfile()
  }

  async loadInitialProfile() {
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

  async checkBackendAlert() {
    const alert = await NetworkService.fetchCurrentAlert()
    if (alert) {
      this.currentAlertType = alert.type
      this.currentAlertInstruction = alert.instruction
      HapticService.trigger(this.selectedProfile)
      this.currentPage = 'alert'
    }
  }

  async sendSOS(message: string) {
    const ok = await NetworkService.sendSOS(
      this.userName === '' ? 'Unknown User' : this.userName,
      this.selectedProfile,
      this.currentAlertType,
      1.4448,
      103.8246,
      message
    )

    if (ok) {
      this.locationText = 'Live location and SOS were sent successfully'
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
            this.sendSOS('SOS triggered from emergency alert screen.')
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