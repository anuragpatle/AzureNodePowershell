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
    
    console.log(body.data.essentials.alertTargetIDs)
    console.log(body.data.alertContext.condition.allOf[0].dimensions)

  } catch (err) {
    console.error(err);
  }

  res.send("user added!");
});

app.listen(3000, function () {
  console.log("Server is listening on port 3000...");
});

/*

{
  schemaId: 'azureMonitorCommonAlertSchema',
  data: {
    essentials: {
      alertId: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/providers/Microsoft.AlertsManagement/alerts/d8caa4ba-4c03-4e7f-9eb2-53f42c21e10c',
      alertRule: 'webhooktest',
      severity: 'Sev4',
      signalType: 'Metric',
      monitorCondition: 'Resolved',
      monitoringService: 'Platform',
      alertTargetIDs: [Array],
      originAlertId: '8efc1d1b-ff8c-4646-8b64-027cd8f131fc_TSI-Test-RG_microsoft.insights_metricAlerts_webhooktest_-1302684072',
      firedDateTime: '2020-09-02T12:34:17.5011792Z',
      resolvedDateTime: '2020-09-02T12:42:30.4414967Z',
      description: '',
      essentialsVersion: '1.0',
      alertContextVersion: '1.0'
    },
    alertContext: {
      properties: null,
      conditionType: 'MultipleResourceMultipleMetricCriteria',
      condition: [Object]
    }
  }
}
{
  windowSize: 'PT5M',
  allOf: [
    {
      metricName: 'Percentage CPU',
      metricNamespace: 'Microsoft.Compute/virtualMachines',
      operator: 'GreaterThan',
      threshold: '1',
      timeAggregation: 'Maximum',
      dimensions: [Array],
      metricValue: 0.52,
      webTestName: null
    }
  ],
  windowStartTime: '2020-09-02T12:34:07.22Z',
  windowEndTime: '2020-09-02T12:39:07.22Z'
}

*/