import { HomePage } from './HomePage'
import { ProfilePage } from './ProfilePage'
import { AlertPage } from './AlertPage'
import { SOSPage } from './SOSPage'
import { NavigationPage } from './NavigationPage'
import { ProfileService } from '../services/ProfileService'
import { AlertService } from '../services/AlertService'
import { HapticService } from '../services/HapticService'
import { NetworkService } from '../services/NetworkService'

@Entry
@Component
struct Index {
  @State currentPage: string = 'home'
  @State selectedProfile: string = 'Vision'
  @State locationText: string = 'Location shared successfully'
  @State directionText: string = 'Move straight and turn slightly left'
  @State distanceText: string = 'Safe exit: 120m ahead'
  @State currentAlertType: string = 'FIRE ALERT'

  build() {
    Column() {
      if (this.currentPage === 'home') {
        HomePage({
          profileName: this.selectedProfile,
          onProfile: () => {
            this.currentPage = 'profile'
          },
          onAlert: () => {
            this.currentAlertType = 'FIRE ALERT'
            HapticService.trigger(this.selectedProfile)
            console.info(AlertService.getAlertMessage(this.selectedProfile))
            this.currentPage = 'alert'
          },
          onCheckBackend: () => {
            const alertType = NetworkService.fetchAlertMock()
            if (alertType !== 'NONE') {
              this.currentAlertType = alertType
              HapticService.trigger(this.selectedProfile)
              this.currentPage = 'alert'
            } else {
              console.info('No active backend alert')
            }
          },
          onSOS: () => {
            HapticService.trigger(this.selectedProfile)
            this.locationText = 'Live location shared with emergency contact (' + this.selectedProfile + ' mode)'
            this.currentPage = 'sos'
          },
          onNavigate: () => {
            if (this.selectedProfile === 'Mobility') {
              this.directionText = 'Use ramp access and continue straight'
              this.distanceText = 'Accessible exit: 90m ahead'
            } else if (this.selectedProfile === 'Vision') {
              this.directionText = 'Move straight and turn slightly left'
              this.distanceText = 'Safe exit: 120m ahead'
            } else if (this.selectedProfile === 'Hearing') {
              this.directionText = 'Follow arrow to exit ahead'
              this.distanceText = 'Exit: 120m ahead'
            } else if (this.selectedProfile === 'Speech') {
              this.directionText = 'Proceed to safe zone and keep SOS ready'
              this.distanceText = 'Help point: 100m ahead'
            } else {
              this.directionText = 'Follow one step at a time to the safe exit'
              this.distanceText = 'Safe exit: 80m ahead'
            }
            this.currentPage = 'navigation'
          }
        })
      } else if (this.currentPage === 'profile') {
        ProfilePage({
          onSelect: (profile: string) => {
            this.selectedProfile = profile
            ProfileService.setProfile(profile)
            this.currentPage = 'home'
          },
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      } else if (this.currentPage === 'alert') {
        AlertPage({
          profileName: this.selectedProfile,
          alertType: this.currentAlertType,
          onBack: () => {
            this.currentPage = 'home'
          },
          onSOS: () => {
            HapticService.trigger(this.selectedProfile)
            this.locationText = 'SOS sent from emergency alert screen (' + this.selectedProfile + ' mode)'
            this.currentPage = 'sos'
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
          directionText: this.directionText,
          distanceText: this.distanceText,
          onBack: () => {
            this.currentPage = 'home'
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
@Preview
@Component
struct IndexPreview {
  build() {
    Index()
  }
}