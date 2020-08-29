const express = require('express');
const app = express();


const bodyParser = require('body-parser');
app.use(bodyParser.json());

app.get('/', function (req, res) {
    res.send("Hello world!")
})

app.post('/hi', function (req, res) {
    var dog = req.body;
    console.log(dog);
    res.send("Dog added!");
});

app.listen(3000, function () {
    console.log("Server is listening on port 3000...");
});