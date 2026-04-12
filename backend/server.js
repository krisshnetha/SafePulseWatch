const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let currentProfile = {
  userId: 'demo-user',
  name: '',
  profile: '',
  contactName: 'Demo Caregiver',
  contactNumber: '+6500000000',
  updatedAt: new Date().toISOString()
};

let currentAlert = null;
let alertHistory = [];
let sosLogs = [];
let smsLogs = [];

function createInstruction(type) {
  switch (type) {
    case 'FIRE':
      return 'Evacuate immediately via nearest exit. Do not use elevators.';
    case 'EARTHQUAKE':
      return 'Drop, Cover, Hold On. Move away from windows.';
    case 'FLOOD':
      return 'Move to higher ground and avoid low-lying areas.';
    case 'EVACUATION':
      return 'Proceed to Exit B and follow staff instructions.';
    case 'MEDICAL':
      return 'Medical emergency nearby. Keep the route clear.';
    case 'SECURITY':
      return 'Security incident reported. Remain calm and await guidance.';
    default:
      return 'Follow emergency instructions carefully.';
  }
}

function buildStats() {
  return {
    total: sosLogs.length,
    active: sosLogs.filter((log) => log.status === 'ACTIVE').length,
    acknowledged: sosLogs.filter((log) => log.status === 'ACKNOWLEDGED').length,
    resolved: sosLogs.filter((log) => log.status === 'RESOLVED').length
  };
}

app.get('/api/health', (_req, res) => {
  res.json({ success: true, message: 'SafePulse backend is running' });
});

app.get('/api/profile', (_req, res) => {
  res.json({ success: true, profile: currentProfile });
});

app.post('/api/profile', (req, res) => {
  const { userId, name, profile, contactName, contactNumber } = req.body || {};

  currentProfile = {
    userId: userId || 'demo-user',
    name: name || '',
    profile: profile || '',
    contactName: contactName || 'Demo Caregiver',
    contactNumber: contactNumber || '+6500000000',
    updatedAt: new Date().toISOString()
  };

  res.json({
    success: true,
    message: 'Profile saved successfully',
    profile: currentProfile
  });
});

app.get('/api/alert', (_req, res) => {
  res.json({
    success: true,
    alert: currentAlert
  });
});

app.get('/api/alerts', (_req, res) => {
  res.json({
    success: true,
    alerts: alertHistory
  });
});

app.post('/api/trigger-alert', (req, res) => {
  const { type, severity, instruction, locationName } = req.body || {};

  const alert = {
    id: Date.now().toString(),
    type: type || 'FIRE',
    severity: severity || 'HIGH',
    instruction: instruction || createInstruction(type || 'FIRE'),
    locationName: locationName || 'Main Building',
    timestamp: new Date().toISOString(),
    active: true,
    acknowledged: false,
    resolved: false
  };

  currentAlert = alert;
  alertHistory.unshift(alert);

  res.json({
    success: true,
    message: 'Alert triggered successfully',
    alert
  });
});

app.post('/api/clear-alert', (_req, res) => {
  currentAlert = null;
  res.json({
    success: true,
    message: 'Current alert cleared'
  });
});

app.post('/api/clear-alerts', (_req, res) => {
  currentAlert = null;
  alertHistory = [];
  res.json({
    success: true,
    message: 'All alerts cleared'
  });
});

app.post('/api/sos', (req, res) => {
  const { userName, profile, alertType, latitude, longitude, message, source } = req.body || {};

  const log = {
    id: Date.now().toString(),
    userName: userName || currentProfile.name || 'Unknown User',
    profile: profile || currentProfile.profile || 'Unknown',
    alertType: alertType || (currentAlert ? currentAlert.type : 'NONE'),
    latitude: latitude ?? 1.3521,
    longitude: longitude ?? 103.8198,
    message: message || 'I need emergency assistance.',
    time: new Date().toISOString(),
    status: 'ACTIVE',
    source: source || 'watch'
  };

  sosLogs.unshift(log);

  const smsPayload = {
    id: 'sms-' + Date.now().toString(),
    time: new Date().toISOString(),
    contactNumber: currentProfile.contactNumber,
    contactName: currentProfile.contactName,
    message: `SOS from ${log.userName} (${log.profile}) at (${log.latitude}, ${log.longitude})`,
    linkedSosId: log.id,
    source: 'auto-from-sos'
  };

  smsLogs.unshift(smsPayload);

  res.json({
    success: true,
    message: 'SOS logged successfully',
    received: log,
    smsNotification: smsPayload
  });
});

app.post('/api/sms-notify', (req, res) => {
  const { contactNumber, contactName, location, message, profile, source } = req.body || {};

  const payload = {
    id: 'sms-' + Date.now().toString(),
    time: new Date().toISOString(),
    contactNumber: contactNumber || currentProfile.contactNumber,
    contactName: contactName || currentProfile.contactName,
    location: location || '1.3521,103.8198',
    profile: profile || currentProfile.profile,
    message: message || 'SafePulseWatch test caregiver notification',
    source: source || 'watch'
  };

  smsLogs.unshift(payload);

  res.json({
    success: true,
    message: 'SMS notification queued successfully',
    queued: payload
  });
});

app.get('/api/sms-logs', (_req, res) => {
  res.json({
    success: true,
    count: smsLogs.length,
    logs: smsLogs
  });
});

app.get('/api/logs', (_req, res) => {
  res.json({
    success: true,
    stats: buildStats(),
    logs: sosLogs
  });
});

app.patch('/api/logs/:id/acknowledge', (req, res) => {
  const { id } = req.params;
  const log = sosLogs.find((item) => item.id === id);

  if (!log) {
    return res.status(404).json({ success: false, message: 'Log not found' });
  }

  log.status = 'ACKNOWLEDGED';
  res.json({ success: true, log, stats: buildStats() });
});

app.patch('/api/logs/:id/resolve', (req, res) => {
  const { id } = req.params;
  const log = sosLogs.find((item) => item.id === id);

  if (!log) {
    return res.status(404).json({ success: false, message: 'Log not found' });
  }

  log.status = 'RESOLVED';
  res.json({ success: true, log, stats: buildStats() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`SafePulse backend running on http://0.0.0.0:${PORT}`);
});
