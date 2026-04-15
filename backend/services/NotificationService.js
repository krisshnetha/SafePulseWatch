class NotificationService {
  constructor() {
    this.provider = process.env.NOTIFICATION_PROVIDER || "simulated";
  }

  createEmergencyMessage({ userId, emergencyType, location }) {
    const lat = location?.latitude ?? "unknown";
    const lng = location?.longitude ?? "unknown";
    return `Emergency alert from WaySafe: User ${userId} has triggered SOS during a ${emergencyType} emergency. Last known location: latitude ${lat}, longitude ${lng}. Immediate assistance may be required.`;
  }

  dispatchToContacts({ contacts, message, source, emergencyType, location }) {
    const timestamp = new Date().toISOString();
    return contacts.map((contact) => ({
      id: `delivery-${Date.now()}-${contact.id}`,
      provider: this.provider,
      channel: "sms",
      status: "queued",
      timestamp,
      source,
      emergencyType,
      location,
      contactId: contact.id,
      contactName: contact.name,
      contactPhone: contact.phone,
      relation: contact.relation,
      primary: contact.primary,
      message,
    }));
  }
}

module.exports = { NotificationService };
