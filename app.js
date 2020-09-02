const express = require("express");
const app = express();
const Shell = require('node-powershell');

const bodyParser = require("body-parser");
app.use(bodyParser.json());


function executePS() {
  const ps = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });
   
  ps.addCommand(' Get-Location');
  ps.addCommand('cd Powershell_Scripts');
  ps.addCommand('.\\Main.ps1');
  ps.addCommand("StopVM 'NodeServer' 'TSI-TEST-RG'");
  ps.addCommand(' Get-Location');
  ps.invoke()
  .then(output => {
    console.log(output);
  })
  .catch(err => {
    console.log(err);
  });
}

app.get("/", function (req, res) {
  res.send("Hello world!");
 executePS() 
});

app.post("/hi", function (req, res) {
  var body = req.body;
  console.log(body);

  try {
    
    console.log(body.data.alertContext.condition)
  } catch (err) {
    console.error(err);
  }

  res.send("user added!");
});

app.listen(3001, function () {
  console.log("Server is listening on port 3000...");
});

/*
{
  schemaId: 'AzureMonitorMetricAlert',
  data: {
    version: '2.0',
    properties: null,
    status: 'Deactivated',
    context: {
      timestamp: '2020-08-29T16:25:41.7828985Z',
      id: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/microsoft.insights/metricAlerts/28-Aug-2020Alert',
      name: '28-Aug-2020Alert',
      description: '',
      conditionType: 'MultipleResourceMultipleMetricCriteria',
      severity: '4',
      condition: [Object],
      subscriptionId: '8efc1d1b-ff8c-4646-8b64-027cd8f131fc',
      resourceGroupName: 'TSI-Test-RG',
      resourceName: 'D1VM26',
      resourceType: 'Microsoft.Compute/virtualMachines',
      resourceId: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/Microsoft.Compute/virtualMachines/D1VM26',
      portalLink: 'https://portal.azure.com/#resource/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/Microsoft.Compute/virtualMachines/D1VM26'
    }
  }
}
{
  schemaId: 'AzureMonitorMetricAlert',
  data: {
    version: '2.0',
    properties: null,
    status: 'Activated',
    context: {
      timestamp: '2020-08-29T16:48:05.5020778Z',
      id: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/microsoft.insights/metricAlerts/webhooktest',
      name: 'webhooktest',
      description: '',
      conditionType: 'MultipleResourceMultipleMetricCriteria',
      severity: '4',
      condition: [Object],
      subscriptionId: '8efc1d1b-ff8c-4646-8b64-027cd8f131fc',
      resourceGroupName: 'TSI-Test-RG',
      resourceName: 'NodeServer',
      resourceType: 'Microsoft.Compute/virtualMachines',
      resourceId: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/Microsoft.Compute/virtualMachines/NodeServer',
      portalLink: 'https://portal.azure.com/#resource/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/Microsoft.Compute/virtualMachines/NodeServer'
    }
  }
}
*/
