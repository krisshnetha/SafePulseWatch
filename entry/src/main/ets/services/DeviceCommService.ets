export interface FireAlertPayload {
  type: string
  timestamp: string
  confidence: number
}

interface DistributedAlertSender {
  send(payload: FireAlertPayload): Promise<boolean>
}

interface SafePulseDistributedBus {
  publish?: (message: string) => void
}

declare const SafePulseDistributedBus: SafePulseDistributedBus | undefined

class HarmonyDistributedSender implements DistributedAlertSender {
  async send(payload: FireAlertPayload): Promise<boolean> {
    try {
      // In production this should call HarmonyOS distributed communication APIs.
      const bus = SafePulseDistributedBus
      if (bus !== undefined && bus.publish !== undefined) {
        bus.publish(JSON.stringify(payload))
        return true
      }

      console.info('Distributed send fallback payload: ' + JSON.stringify(payload))
      return true
    } catch (error) {
      console.error('DeviceCommService send failed: ' + JSON.stringify(error as Object))
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
    return this.sender.send(payload)
  }
}
