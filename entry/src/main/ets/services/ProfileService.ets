export class ProfileService {
  static currentProfile: string = 'Blind'
  static currentName: string = ''

  static setProfile(profile: string): void {
    ProfileService.currentProfile = profile
  }

  static getProfile(): string {
    return ProfileService.currentProfile
  }

  static setName(name: string): void {
    ProfileService.currentName = name
  }

  static getName(): string {
    return ProfileService.currentName
  }
}