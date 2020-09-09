const express = require("express");
const app = express();
const Shell = require('node-powershell');

const bodyParser = require("body-parser");
app.use(bodyParser.json());


function stopVM(resourceId) {

  const ps = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });

  ps.addCommand(' Get-Location');
  ps.addCommand('cd Powershell_Scripts');
  ps.addCommand('.\\Main.ps1');
  ps.addCommand("StopVM " + resourceId);
  // ps.addCommand("ExucuteCreateVM");
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
  res.send("You made a GET Request to the NodePS-Srvr2 !");
});

app.post("/hi", function (req, res) {

  var body = req.body;
  console.log(body);

  try {

    // console.log("Printing Condition: " + body.data.alertContext.condition)

    // console.log("Printing alertTargetIDs: " + body.data.essentials.alertTargetIDs)
    let firstVM = body.data.essentials.alertTargetIDs[0]
    // console.log("Printing alertTargetIDs[0]: " + firstVM)
    // console.log("Printing allOf[0].dimensions: " + body.data.alertContext.condition.allOf[0].dimensions)

    // let metricName = body.data.alertContext.condition.allOf[0].metricName // 'Percentage CPU'
    // console.log("metric name: " + metricName)
    let resourceIds = body.data.essentials.alertTargetIDs
    // stopVM(firstVM)

    body.data.essentials.alertTargetIDs.forEach(resName => {
      console.log("resource name is: " + resName)
      stopVM(resName)
    });


  


  } catch (err) {
    console.error(err);
  }

  res.send("You made a POST Request to the NodePS-Srvr2 !");
});

app.listen(3000, function () {
  console.log("Server is listening on port 3000...");
});

/*

{
  schemaId: 'azureMonitorCommonAlertSchema',
  data: {
    essentials: {
      alertId: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/providers/Microsoft.AlertsManagement/alerts/cdbee921-16dd-4580-9c89-a421f276f09a',
      alertRule: 'VM26_alert',
      severity: 'Sev3',
      signalType: 'Metric',
      monitorCondition: 'Fired',
      monitoringService: 'Platform',
      alertTargetIDs: [Array],
      originAlertId: '8efc1d1b-ff8c-4646-8b64-027cd8f131fc_TSI-Test-RG_microsoft.insights_metricAlerts_VM26_alert_869486483',
      firedDateTime: '2020-09-08T05:56:29.1563179Z',
      description: 'some desc',
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
      threshold: '2',
      timeAggregation: 'Maximum',
      dimensions: [Array],
      metricValue: 22.99,
      webTestName: null
    },
    {
      metricName: 'Percentage CPU',
      metricNamespace: 'Microsoft.Compute/virtualMachines',
      operator: 'GreaterThan',
      threshold: '5',
      timeAggregation: 'Count',
      dimensions: [Array],
      metricValue: 7,
      webTestName: null
    }
  ],
  windowStartTime: '2020-09-08T05:48:14.295Z',
  windowEndTime: '2020-09-08T05:53:14.295Z'
}



[
  '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourcegroups/tsi-test-rg/providers/microsoft.compute/virtualmachines/d1vm26'
]




[
  {
    name: 'microsoft.resourceId',
    value: '/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/Microsoft.Compute/virtualMachines/D1VM26'
  },
  {
    name: 'microsoft.resourceType',
    value: 'Microsoft.Compute/virtualMachines'
  }
]

*/