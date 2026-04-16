const express = require("express");
const cors = require("cors");
const http = require("http");
const path = require("path");
const crypto = require("crypto");
const { WebSocketServer } = require("ws");
const { NotificationService } = require("./services/NotificationService");

const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: "/ws" });
const PORT = process.env.PORT || 3000;
const DEMO_USER_ID = "demo-user-1";
const notificationService = new NotificationService();

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

const nowIso = () => new Date().toISOString();
const id = (prefix) => `${prefix}-${crypto.randomUUID().slice(0, 8)}`;

const defaultContacts = [
  { id: "c1", name: "Ananya", phone: "+6591234567", relation: "Sister", primary: true },
  { id: "c2", name: "Ravi", phone: "+6598765432", relation: "Father", primary: false },
];

const state = {
  userId: DEMO_USER_ID,
  userName: "Demo User",
  profile: "vision",
  contacts: [...defaultContacts],
  activeEmergency: null,
  sos: {
    sent: false,
    time: null,
    location: null,
    message: null,
    source: null,
    notifiedContacts: [],
  },
  history: [],
  sosLogs: [],
  deliveryLogs: [],
  phoneFireAlertLogs: [],

  stateRevision: 0,

};

const typeToTitle = {
  fire: "Fire Alert",
  gas: "Gas Leak Alert",
  evacuation: "Evacuation Alert",
  flood: "Flood Alert",
  quake: "Earthquake Alert",
  medical: "Medical Alert",
  security: "Security Alert",
};

const typeToMessage = {
  fire: "Evacuate immediately. Smoke or fire risk detected.",
  gas: "Gas leak detected. Leave the area immediately and avoid sparks.",
  evacuation: "Emergency evacuation in progress. Proceed to the nearest safe exit.",
  flood: "Move to higher ground and avoid flooded routes.",
  quake: "Drop, cover, and hold. Evacuate when the shaking stops.",
  medical: "Medical assistance required. Stay calm and wait for responders.",
  security: "Security incident reported. Follow lockdown guidance immediately.",
};

const typeToSeverity = {
  fire: "HIGH",
  gas: "CRITICAL",
  evacuation: "HIGH",
  flood: "HIGH",
  quake: "CRITICAL",
  medical: "HIGH",
  security: "HIGH",
};

function normalizeEmergencyType(rawType = "") {
  const input = String(rawType).toLowerCase();
  if (input.includes("gas")) return "gas";
  if (input.includes("evac")) return "evacuation";
  if (input.includes("flood")) return "flood";
  if (input.includes("quake") || input.includes("earth")) return "quake";
  if (input.includes("medical")) return "medical";
  if (input.includes("security")) return "security";
  return "fire";
}

function getPrimaryContact() {
  return state.contacts.find((contact) => contact.primary) || state.contacts[0] || null;
}

function serializeProfile() {
  const primaryContact = getPrimaryContact();
  return {
    userId: state.userId,
    name: state.userName,
    profile: state.profile,
    contactName: primaryContact?.name || "",
    contactNumber: primaryContact?.phone || "",
    updatedAt: nowIso(),
  };
}

function getActiveEmergency() {
  if (!state.activeEmergency || state.activeEmergency.status !== "active") {
    return null;
  }
  return state.activeEmergency;
}

function serializeState() {
  return {
    userId: state.userId,
    userName: state.userName,
    profile: state.profile,
    contacts: state.contacts,
    activeEmergency: getActiveEmergency(),
    sos: state.sos,
    history: state.history,
    stateRevision: state.stateRevision,
  };
}

function sendSocketMessage(socket, payload) {
  if (socket.readyState === 1) {
    socket.send(JSON.stringify(payload));
  }
}

function broadcastState(reason) {
  state.stateRevision += 1;
  const payload = {
    type: "state.updated",
    reason,
    sentAt: nowIso(),
    state: serializeState(),
  };
  wss.clients.forEach((client) => {
    if (client.readyState === 1) {
      client.send(JSON.stringify(payload));
    }
  });
}

function ensureSinglePrimary() {
  if (state.contacts.length === 0) return;
  const hasPrimary = state.contacts.some((c) => c.primary);
  if (!hasPrimary) {
    state.contacts[0].primary = true;
  } else {
    let foundPrimary = false;
    state.contacts = state.contacts.map((c) => {
      if (!c.primary) return c;
      if (!foundPrimary) {
        foundPrimary = true;
        return c;
      }
      return { ...c, primary: false };
    });
  }
}

function parseLocation(locationPayload) {
  if (!locationPayload) return { latitude: null, longitude: null, raw: null };
  if (typeof locationPayload === "object") {
    return {
      latitude: locationPayload.latitude ?? locationPayload.lat ?? null,
      longitude: locationPayload.longitude ?? locationPayload.lng ?? null,
      raw: locationPayload,
    };
  }
  if (typeof locationPayload === "string" && locationPayload.includes(",")) {
    const [lat, lng] = locationPayload.split(",").map((value) => Number(value.trim()));
    return {
      latitude: Number.isFinite(lat) ? lat : null,
      longitude: Number.isFinite(lng) ? lng : null,
      raw: locationPayload,
    };
  }
  return { latitude: null, longitude: null, raw: locationPayload };
}

function computeAlertSignature(alert) {
  if (!alert) return "none";
  return [alert.type, alert.severity, alert.instruction, alert.locationName].join("|");
}

function buildActiveEmergency(payload = {}) {
  const normalizedType = normalizeEmergencyType(payload.type);
  const severity = String(payload.severity || typeToSeverity[normalizedType]).toUpperCase();
  const instruction = String(payload.message || payload.instruction || typeToMessage[normalizedType]);
  return {
    id: id("e"),
    type: String(payload.type || normalizedType).toUpperCase(),
    normalizedType,
    severity,
    title: String(payload.title || typeToTitle[normalizedType]),
    message: instruction,
    instruction,
    locationName: String(payload.locationName || "Demo Building"),
    timestamp: nowIso(),
    createdAt: nowIso(),
    active: true,
    acknowledged: false,
    resolved: false,
    status: "active",
  };
}

function archiveActiveEmergency(status, metadata = {}) {
  const current = getActiveEmergency();
  if (!current) {
    return null;
  }

  const archivedAt = nowIso();
  const archived = {
    ...current,
    active: false,
    acknowledged: status === "acknowledged",
    resolved: status === "resolved",
    status,
    updatedAt: archivedAt,
    ...(status === "acknowledged" ? { acknowledgedAt: archivedAt } : {}),
    ...(status === "resolved" ? { resolvedAt: archivedAt } : {}),
    ...metadata,
  };

  state.history.unshift(archived);
  state.activeEmergency = null;
  broadcastState(`alert.${status}`);
  return archived;
}

function triggerEmergency(payload = {}) {
  const nextEmergency = buildActiveEmergency(payload);
  const current = getActiveEmergency();
  if (current && computeAlertSignature(current) === computeAlertSignature(nextEmergency)) {
    return { duplicate: true, alert: current };
  }

  state.activeEmergency = nextEmergency;
  broadcastState("alert.triggered");
  return { duplicate: false, alert: nextEmergency };
}

function summarizeLogStats() {
  return {
    total: state.sosLogs.length,
    active: state.sosLogs.filter((item) => item.status === "ACTIVE").length,
    acknowledged: state.sosLogs.filter((item) => item.status === "ACKNOWLEDGED").length,
    resolved: state.sosLogs.filter((item) => item.status === "RESOLVED").length,
  };
}

function serializeSosLog(log) {
  return {
    id: log.id,
    userName: log.userName || state.userName,
    profile: log.profile || state.profile,
    alertType: log.emergencyType,
    latitude: log.location?.latitude ?? 1.3521,
    longitude: log.location?.longitude ?? 103.8198,
    message: log.message,
    time: log.time,
    status: log.status || "ACTIVE",
    source: log.source,
  };
}

function updateSosLogStatus(logId, nextStatus, extra = {}) {
  const index = state.sosLogs.findIndex((log) => log.id === logId);
  if (index === -1) {
    return null;
  }

  state.sosLogs[index] = {
    ...state.sosLogs[index],
    status: nextStatus,
    updatedAt: nowIso(),
    ...extra,
  };
  broadcastState(`sos.${nextStatus.toLowerCase()}`);
  return state.sosLogs[index];
}

wss.on("connection", (socket) => {
  sendSocketMessage(socket, {
    type: "state.snapshot",
    reason: "connected",
    sentAt: nowIso(),
    state: serializeState(),
  });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "safepulse-sync-backend", time: nowIso() });
});

app.get("/api/sync/state", (_req, res) => {
  res.json({ success: true, state: serializeState() });
});

app.put("/api/profile", (req, res) => {
  const { userId, profile, userName, contactName, contactNumber } = req.body || {};
  if (userId && userId !== DEMO_USER_ID) {
    return res.status(400).json({ success: false, message: "Only demo-user-1 is supported in MVP" });
  }
  if (!profile || typeof profile !== "string") {
    return res.status(400).json({ success: false, message: "profile is required" });
  }

  state.profile = profile;
  if (typeof userName === "string" && userName.trim()) state.userName = userName.trim();

  const primaryContact = getPrimaryContact();
  if (primaryContact && (typeof contactName === "string" || typeof contactNumber === "string")) {
    if (typeof contactName === "string" && contactName.trim()) primaryContact.name = contactName.trim();
    if (typeof contactNumber === "string" && contactNumber.trim()) primaryContact.phone = contactNumber.trim();
  }

  broadcastState("profile.updated");
  return res.json({ success: true, profile: serializeProfile() });
});

app.get("/api/contacts", (_req, res) => {
  res.json({ success: true, contacts: state.contacts });
});

app.post("/api/contacts", (req, res) => {
  const { name, phone, relation, primary = false } = req.body || {};
  if (!name || !phone || !relation) {
    return res.status(400).json({ success: false, message: "name, phone, relation are required" });
  }
  const contact = {
    id: id("c"),
    name: String(name),
    phone: String(phone),
    relation: String(relation),
    primary: !!primary || state.contacts.length === 0,
  };
  if (contact.primary) {
    state.contacts = state.contacts.map((c) => ({ ...c, primary: false }));
  }
  state.contacts.unshift(contact);
  ensureSinglePrimary();
  broadcastState("contacts.updated");
  return res.status(201).json({ success: true, contact, contacts: state.contacts });
});

app.put("/api/contacts/:id", (req, res) => {
  const { id: contactId } = req.params;
  const { name, phone, relation, primary } = req.body || {};
  const idx = state.contacts.findIndex((c) => c.id === contactId);
  if (idx === -1) {
    return res.status(404).json({ success: false, message: "Contact not found" });
  }
  const updated = {
    ...state.contacts[idx],
    ...(typeof name === "string" ? { name } : {}),
    ...(typeof phone === "string" ? { phone } : {}),
    ...(typeof relation === "string" ? { relation } : {}),
    ...(typeof primary === "boolean" ? { primary } : {}),
  };
  state.contacts[idx] = updated;
  if (updated.primary) {
    state.contacts = state.contacts.map((c) => (c.id === updated.id ? c : { ...c, primary: false }));
  }
  ensureSinglePrimary();
  broadcastState("contacts.updated");
  return res.json({ success: true, contact: updated, contacts: state.contacts });
});

app.delete("/api/contacts/:id", (req, res) => {
  const { id: contactId } = req.params;
  const idx = state.contacts.findIndex((c) => c.id === contactId);
  if (idx === -1) {
    return res.status(404).json({ success: false, message: "Contact not found" });
  }
  state.contacts.splice(idx, 1);
  ensureSinglePrimary();
  broadcastState("contacts.updated");
  return res.json({ success: true, contacts: state.contacts });
});

app.post("/api/emergency/trigger", (req, res) => {
  const result = triggerEmergency(req.body || {});
  return res.status(result.duplicate ? 200 : 201).json({
    success: true,
    duplicate: result.duplicate,
    activeEmergency: result.alert,
    state: serializeState(),
  });
});

app.post("/api/emergency/resolve", (req, res) => {
  const resolved = archiveActiveEmergency("resolved", {
    resolvedBy: String(req.body?.source || "backend"),
  });

  return res.json({
    success: true,
    resolved,
    activeEmergency: getActiveEmergency(),
    history: state.history,
    state: serializeState(),
  });
});

app.post("/api/alert/acknowledge", (req, res) => {
  const current = getActiveEmergency();
  if (!current) {
    return res.json({
      success: true,
      acknowledged: null,
      activeEmergency: null,
      history: state.history,
      state: serializeState(),
    });
  }

  const { alertId, source = "device" } = req.body || {};
  if (alertId && alertId !== current.id) {
    return res.status(409).json({
      success: false,
      message: "Alert mismatch. Refresh state before acknowledging.",
      activeEmergency: current,
      state: serializeState(),
    });
  }

  const acknowledged = archiveActiveEmergency("acknowledged", {
    acknowledgedBy: String(source),
  });

  return res.json({
    success: true,
    acknowledged,
    activeEmergency: getActiveEmergency(),
    history: state.history,
    state: serializeState(),
  });
});

app.get("/api/history", (_req, res) => {
  res.json({ success: true, history: state.history });
});

app.post("/api/sos", (req, res) => {
  const {
    source = "watch",
    message,
    location = null,
    latitude = null,
    longitude = null,
    emergencyType = getActiveEmergency()?.normalizedType || getActiveEmergency()?.type || "unknown",
    userName,
    profile,
  } = req.body || {};

  if (typeof userName === "string" && userName.trim()) {
    state.userName = userName.trim();
  }
  if (typeof profile === "string" && profile.trim()) {
    state.profile = profile.trim();
  }

  const locationPayload = parseLocation(
    location || (latitude !== null || longitude !== null ? { latitude, longitude } : null)
  );
  const resolvedEmergencyType = normalizeEmergencyType(emergencyType);
  const outgoingMessage =
    message ||
    notificationService.createEmergencyMessage({
      userId: state.userId,
      emergencyType: resolvedEmergencyType,
      location: locationPayload,
    });

  const notifiedContacts = notificationService.dispatchToContacts({
    contacts: state.contacts,
    message: outgoingMessage,
    source,
    emergencyType: resolvedEmergencyType,
    location: locationPayload,
  });

  notifiedContacts.forEach((delivery) => state.deliveryLogs.unshift(delivery));

  const sosEvent = {
    id: id("sos"),
    sent: true,
    time: nowIso(),
    location: locationPayload,
    message: outgoingMessage,
    source,
    emergencyType: resolvedEmergencyType,
    notifiedContacts,
    userName: state.userName,
    profile: state.profile,
    status: "ACTIVE",
  };

  state.sos = {
    sent: true,
    time: sosEvent.time,
    location: sosEvent.location,
    message: sosEvent.message,
    source: sosEvent.source,
    notifiedContacts: sosEvent.notifiedContacts,
  };
  state.sosLogs.unshift(sosEvent);
  broadcastState("sos.sent");

  return res.status(201).json({
    success: true,
    sent: true,
    timestamp: sosEvent.time,
    emergencyType: resolvedEmergencyType,
    location: locationPayload,
    sos: state.sos,
    latestEvent: sosEvent,
    notifiedContacts,
    deliveryLog: notifiedContacts,
    deliveryCount: notifiedContacts.length,
  });
});

app.get("/api/sos/latest", (_req, res) => {
  res.json({
    success: true,
    sos: state.sos,
    latestEvent: state.sosLogs[0] || null,
  });
});

app.post("/api/safe", (_req, res) => {
  const resolved = archiveActiveEmergency("resolved", { resolvedBy: "watch-safe" });
  return res.json({
    success: true,
    resolved,
    activeEmergency: getActiveEmergency(),
    history: state.history,
    state: serializeState(),
  });
});

app.post("/api/logs/:id/acknowledge", (req, res) => {
  const updated = updateSosLogStatus(req.params.id, "ACKNOWLEDGED", {
    acknowledgedBy: String(req.body?.source || "wearable"),
    acknowledgedAt: nowIso(),
  });

  if (!updated) {
    return res.status(404).json({ success: false, message: "SOS log not found" });
  }

  return res.json({ success: true, log: serializeSosLog(updated), stats: summarizeLogStats() });
});

app.post("/api/logs/:id/resolve", (req, res) => {
  const updated = updateSosLogStatus(req.params.id, "RESOLVED", {
    resolvedBy: String(req.body?.source || "wearable"),
    resolvedAt: nowIso(),
  });

  if (!updated) {
    return res.status(404).json({ success: false, message: "SOS log not found" });
  }

  return res.json({ success: true, log: serializeSosLog(updated), stats: summarizeLogStats() });
});

// Compatibility aliases for existing demo flows.
app.get("/api/health", (_req, res) => res.json({ success: true, message: "SafePulse backend is running" }));
app.get("/api/profile", (_req, res) =>
  res.json({
    success: true,
    profile: serializeProfile(),
  })
);
app.post("/api/profile", (req, res) => {
  const { name, profile, contactName, contactNumber } = req.body || {};
  if (typeof name === "string" && name.trim()) state.userName = name.trim();
  if (typeof profile === "string" && profile.trim()) state.profile = profile.trim();

  const primaryContact = getPrimaryContact();
  if (primaryContact) {
    if (typeof contactName === "string" && contactName.trim()) primaryContact.name = contactName.trim();
    if (typeof contactNumber === "string" && contactNumber.trim()) primaryContact.phone = contactNumber.trim();
  }

  broadcastState("profile.updated");
  return res.json({ success: true, profile: serializeProfile() });
});
app.get("/api/alert", (_req, res) => res.json({ success: true, alert: getActiveEmergency(), stateRevision: state.stateRevision }));
app.get("/api/alerts", (_req, res) => res.json({ success: true, alerts: state.history }));
app.post("/api/trigger-alert", (req, res) => {
  const result = triggerEmergency(req.body || {});
  return res.status(result.duplicate ? 200 : 201).json({
    success: true,
    duplicate: result.duplicate,
    alert: result.alert,
    state: serializeState(),
  });
});
app.post("/api/clear-alert", (_req, res) => {
  const resolved = archiveActiveEmergency("resolved", { resolvedBy: "compat-clear" });
  return res.json({ success: true, resolved, state: serializeState() });
});
app.post("/api/clear-alerts", (_req, res) => {
  const resolved = archiveActiveEmergency("resolved", { resolvedBy: "compat-clear-all" });
  return res.json({ success: true, resolved, state: serializeState() });
});
app.get("/api/logs", (_req, res) =>
  res.json({
    success: true,
    logs: state.sosLogs.map(serializeSosLog),
    stats: summarizeLogStats(),
  })
);

app.post('/api/phone/fire-alert', (req, res) => {
  const { type, timestamp, confidence } = req.body || {};

  if (type !== 'FIRE_ALERT') {
    return res.status(400).json({
      success: false,
      message: 'Invalid alert type. Expected FIRE_ALERT.'
    });
  }

  const log = {
    id: id('phone-fire'),
    type,
    timestamp: timestamp || nowIso(),
    confidence: Number(confidence || 0),
    createdAt: nowIso(),
    source: 'watch-distributed-channel'
  };

  state.phoneFireAlertLogs.unshift(log);

  console.log('[PHONE NOTIFICATION] Fire alarm detected nearby. Confidence:', log.confidence);

  return res.json({
    success: true,
    message: 'Phone receiver accepted fire alert and triggered notification',
    log
  });
});

app.get('/api/phone/fire-alerts', (_req, res) => {
  res.json({
    success: true,
    count: state.phoneFireAlertLogs.length,
    logs: state.phoneFireAlertLogs
  });
});

app.use((err, _req, res, _next) => {
  console.error("Unhandled backend error:", err);
  res.status(500).json({ success: false, message: "Internal server error", timestamp: nowIso() });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`SafePulse sync backend running on port ${PORT}`);
});
