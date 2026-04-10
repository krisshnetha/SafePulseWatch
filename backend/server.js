const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

let currentAlert = {
  type: 'NONE',
  severity: 'LOW',
  message: 'No active alerts'
};

let sosLogs = [];

app.get('/api/alert', (req, res) => {
  res.json(currentAlert);
});

app.post('/api/trigger-alert', (req, res) => {
  const { type, severity, message } = req.body;
  currentAlert = {
    type: type || 'FIRE ALERT',
    severity: severity || 'HIGH',
    message: message || 'Evacuate immediately'
  };
  console.log('Alert triggered:', currentAlert);
  res.json({ success: true, alert: currentAlert });
});

app.post('/api/sos', (req, res) => {
  const payload = {
    time: new Date().toISOString(),
    ...req.body
  };
  sosLogs.push(payload);
  console.log('SOS received:', payload);
  res.json({ success: true, received: payload });
});

app.get('/api/logs', (req, res) => {
  res.json(sosLogs);
});

app.listen(3000, () => {
  console.log('Backend running on http://localhost:3000');
});