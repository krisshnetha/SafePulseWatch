const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let currentAlert = {
  id: null,
  type: 'NONE',
  severity: 'LOW',
  instruction: 'No active alerts',
  locationName: 'N/A',
  timestamp: null,
  active: false
};

let sosLogs = [];
let userProfileStore = {
  userId: 'demo-user',
  profile: 'Vision',
  contactName: 'Demo Caregiver',
  contactNumber: '+6500000000',
  updatedAt: new Date().toISOString()
};

app.get('/api/health', (_req, res) => {
  res.json({
    success: true,
    message: 'SafePulse backend is running'
  });
});

app.get('/api/alert', (_req, res) => {
  res.json({
    success: true,
    alert: currentAlert
  });
});

app.post('/api/trigger-alert', (req, res) => {
  const { type, severity, instruction, locationName } = req.body || {};

  currentAlert = {
    id: Date.now().toString(),
    type: type || 'FIRE ALERT',
    severity: severity || 'HIGH',
    instruction: instruction || 'Evacuate immediately.',
    locationName: locationName || 'Demo Zone A',
    timestamp: new Date().toISOString(),
    active: true
  };

  console.log('Alert triggered:', currentAlert);

  res.json({
    success: true,
    message: 'Alert triggered successfully',
    alert: currentAlert
  });
});

app.post('/api/clear-alert', (_req, res) => {
  currentAlert = {
    id: null,
    type: 'NONE',
    severity: 'LOW',
    instruction: 'No active alerts',
    locationName: 'N/A',
    timestamp: null,
    active: false
  };

  console.log('Alert cleared');

  res.json({
    success: true,
    message: 'Alert cleared successfully',
    alert: currentAlert
  });
});

app.get('/api/profile', (_req, res) => {
  res.json({
    success: true,
    profile: userProfileStore
  });
});

app.post('/api/profile', (req, res) => {
  const { userId, profile, contactName, contactNumber } = req.body || {};

  userProfileStore = {
    userId: userId || 'demo-user',
    profile: profile || 'Vision',
    contactName: contactName || 'Demo Caregiver',
    contactNumber: contactNumber || '+6500000000',
    updatedAt: new Date().toISOString()
  };

  console.log('Profile stored:', userProfileStore);

  res.json({
    success: true,
    message: 'Profile saved successfully',
    profile: userProfileStore
  });
});

app.post('/api/sos', (req, res) => {
  const {
    profile,
    alertType,
    latitude,
    longitude,
    message,
    source
  } = req.body || {};

  const payload = {
    id: Date.now().toString(),
    time: new Date().toISOString(),
    profile: profile || 'Unknown',
    alertType: alertType || currentAlert.type || 'NONE',
    latitude: latitude ?? 1.3521,
    longitude: longitude ?? 103.8198,
    message: message || 'User requested emergency help',
    source: source || 'watch'
  };

  sosLogs.unshift(payload);

  console.log('SOS received:', payload);

  res.json({
    success: true,
    message: 'SOS logged successfully',
    received: payload
  });
});

app.get('/api/logs', (_req, res) => {
  res.json({
    success: true,
    count: sosLogs.length,
    logs: sosLogs
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend running on http://0.0.0.0:${PORT}`);
});