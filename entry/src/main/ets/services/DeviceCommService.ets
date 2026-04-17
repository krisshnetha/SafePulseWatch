import { NetworkService, FireAlertPayload } from './NetworkService'

interface DistributedAlertSender {
  send(payload: FireAlertPayload): Promise<boolean>
}

interface SafePulseDistributedBusAdapter {
  publish?: (message: string) => void
}

declare const SafePulseDistributedBus: SafePulseDistributedBusAdapter | undefined

class HarmonyDistributedSender implements DistributedAlertSender {
  async send(payload: FireAlertPayload): Promise<boolean> {
    try {
      const bus = SafePulseDistributedBus

      if (bus !== undefined && bus.publish !== undefined) {
        bus.publish(JSON.stringify(payload))
        console.info('Distributed fire alert sent successfully')
        return true
      }

      console.warn('Distributed bus unavailable; fire alert not sent via device channel')
      return false
    } catch (error) {
      console.error('DeviceCommService distributed send failed: ' + JSON.stringify(error as Object))
      return false
    }
  }
}

export class DeviceCommService {
  private readonly sender: DistributedAlertSender

  constructor(sender?: DistributedAlertSender) {
    this.sender = sender ? sender : new HarmonyDistributedSender()
  }

  async sendFireAlert(confidence: number): Promise<boolean> {
    const payload: FireAlertPayload = {
      type: 'FIRE_ALERT',
      timestamp: new Date().toISOString(),
      confidence
    }

    const distributedOk = await this.sender.send(payload)
    if (distributedOk) {
      console.info('Fire alert delivered through distributed channel')
      return true
    }

    console.info('Falling back to backend /api/phone/fire-alert')
    const backendOk = await NetworkService.sendPhoneFireAlert(payload)

    if (backendOk) {
      console.info('Fire alert delivered through backend fallback')
      return true
    }

    console.error('Fire alert delivery failed on both distributed and backend paths')
    return false
  }
}