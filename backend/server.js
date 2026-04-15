const express = require("express");
const cors = require("cors");
const path = require("path");
const crypto = require("crypto");

const app = express();
const PORT = process.env.PORT || 3000;
const DEMO_USER_ID = "demo-user-1";

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
};

const typeToTitle = {
  fire: "Fire Alert",
  gas: "Gas Leak Alert",
  evacuation: "Evacuation Alert",
};

const typeToMessage = {
  fire: "Evacuate immediately. Smoke or fire risk detected.",
  gas: "Possible gas leak detected. Leave the area and avoid sparks.",
  evacuation: "Evacuation required. Follow the nearest safe route.",
};

function normalizeEmergencyType(rawType = "") {
  const input = String(rawType).toLowerCase();
  if (input.includes("gas")) return "gas";
  if (input.includes("evac")) return "evacuation";
  return "fire";
}

function serializeState() {
  return {
    userId: state.userId,
    profile: state.profile,
    contacts: state.contacts,
    activeEmergency: state.activeEmergency,
    sos: state.sos,
    history: state.history,
  };
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

function buildSosMessagePayload({ source = "watch", message, location, emergencyType }) {
  const outgoingMessage =
    message ||
    `SOS from ${state.userName || state.userId}. Emergency: ${emergencyType || "unknown"}. Location: ${location || "not-provided"}.`;

  const notifiedContacts = state.contacts.map((contact) => {
    const delivery = {
      id: id("delivery"),
      contactId: contact.id,
      contactName: contact.name,
      contactPhone: contact.phone,
      relation: contact.relation,
      primary: contact.primary,
      channel: "sms",
      status: "queued",
      attemptedAt: nowIso(),
      message: outgoingMessage,
      source,
    };
    state.deliveryLogs.unshift(delivery);
    return delivery;
  });

  return { outgoingMessage, notifiedContacts };
}

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "safepulse-sync-backend", time: nowIso() });
});

app.get("/api/sync/state", (_req, res) => {
  res.json({ success: true, state: serializeState() });
});

app.put("/api/profile", (req, res) => {
  const { userId, profile, userName } = req.body || {};
  if (userId && userId !== DEMO_USER_ID) {
    return res.status(400).json({ success: false, message: "Only demo-user-1 is supported in MVP" });
  }
  if (!profile || typeof profile !== "string") {
    return res.status(400).json({ success: false, message: "profile is required" });
  }
  state.profile = profile;
  if (typeof userName === "string") state.userName = userName;
  return res.json({ success: true, profile: state.profile, userName: state.userName });
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
  return res.json({ success: true, contacts: state.contacts });
});

app.post("/api/emergency/trigger", (req, res) => {
  const { type, severity = "high", title, message } = req.body || {};
  const normalizedType = normalizeEmergencyType(type);
  state.activeEmergency = {
    id: id("e"),
    type: normalizedType,
    severity,
    title: title || typeToTitle[normalizedType],
    message: message || typeToMessage[normalizedType],
    status: "active",
    createdAt: nowIso(),
  };
  return res.status(201).json({ success: true, activeEmergency: state.activeEmergency });
});

app.post("/api/emergency/resolve", (req, res) => {
  if (!state.activeEmergency) {
    return res.json({ success: true, message: "No active emergency", activeEmergency: null, history: state.history });
  }
  const resolved = {
    ...state.activeEmergency,
    status: "resolved",
    resolvedAt: nowIso(),
  };
  state.history.unshift(resolved);
  state.activeEmergency = null;
  return res.json({ success: true, resolved, history: state.history });
});

app.get("/api/history", (_req, res) => {
  res.json({ success: true, history: state.history });
});

app.post("/api/sos", (req, res) => {
  const {
    source = "watch",
    message,
    location = null,
    emergencyType = state.activeEmergency?.type || "unknown",
    userName,
  } = req.body || {};

  if (typeof userName === "string" && userName.trim()) {
    state.userName = userName.trim();
  }

  const { outgoingMessage, notifiedContacts } = buildSosMessagePayload({
    source,
    message,
    location,
    emergencyType,
  });

  const sosEvent = {
    id: id("sos"),
    sent: true,
    time: nowIso(),
    location,
    message: outgoingMessage,
    source,
    emergencyType,
    notifiedContacts,
    status: "sent",
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

  return res.status(201).json({
    success: true,
    sos: state.sos,
    notifiedContacts: state.sos.notifiedContacts,
    deliveryCount: state.sos.notifiedContacts.length,
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
  if (state.activeEmergency) {
    const resolved = { ...state.activeEmergency, status: "resolved", resolvedAt: nowIso(), resolvedBy: "watch-safe" };
    state.history.unshift(resolved);
    state.activeEmergency = null;
  }
  return res.json({ success: true, activeEmergency: null, history: state.history });
});

// Compatibility aliases for existing demo flows.
app.get("/api/health", (_req, res) => res.json({ success: true, message: "SafePulse backend is running" }));
app.get("/api/profile", (_req, res) =>
  res.json({
    success: true,
    profile: {
      userId: state.userId,
      name: state.userName,
      profile: state.profile,
      updatedAt: nowIso(),
    },
  })
);
app.post("/api/profile", (req, res) => {
  const { name, profile } = req.body || {};
  if (typeof name === "string") state.userName = name;
  if (typeof profile === "string") state.profile = profile;
  return res.json({ success: true, profile: { userId: state.userId, name: state.userName, profile: state.profile, updatedAt: nowIso() } });
});
app.get("/api/alert", (_req, res) => res.json({ success: true, alert: state.activeEmergency }));
app.get("/api/alerts", (_req, res) => res.json({ success: true, alerts: state.history }));
app.post("/api/trigger-alert", (req, res) => {
  const { type, severity, instruction } = req.body || {};
  const normalizedType = normalizeEmergencyType(type);
  state.activeEmergency = {
    id: id("e"),
    type: type || normalizedType.toUpperCase(),
    severity: severity || "HIGH",
    instruction: instruction || typeToMessage[normalizedType],
    locationName: "Demo Building",
    timestamp: nowIso(),
    active: true,
    acknowledged: false,
    resolved: false,
    status: "active",
  };
  return res.json({ success: true, alert: state.activeEmergency });
});
app.post("/api/clear-alerts", (_req, res) => {
  state.activeEmergency = null;
  return res.json({ success: true });
});
app.get("/api/logs", (_req, res) =>
  res.json({
    success: true,
    logs: state.sosLogs.map((log) => ({
      id: log.id,
      userName: state.userName,
      profile: state.profile,
      alertType: log.emergencyType,
      latitude: 1.3521,
      longitude: 103.8198,
      message: log.message,
      time: log.time,
      status: "ACTIVE",
      source: log.source,
    })),
    stats: {
      total: state.sosLogs.length,
      active: state.sosLogs.length,
      acknowledged: 0,
      resolved: 0,
    },
  })
);

app.listen(PORT, "0.0.0.0", () => {
  console.log(`SafePulse sync backend running on port ${PORT}`);
});