export class ProfileService {
  static currentProfile: string = 'Vision'

  static setProfile(profile: string): void {
    ProfileService.currentProfile = profile
    console.info('ProfileService: profile set to ' + profile)
  }

  static getProfile(): string {
    return ProfileService.currentProfile
  }
}