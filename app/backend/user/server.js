const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const passport = require("passport");
const cors = require('cors');

const user = require("./routes/api/user");
const profile = require("./routes/api/profile");
const post = require("./routes/api/post");

// Logging Configuration
var morgan = require('morgan');
var uuid = require('node-uuid');
morgan.token('id', function getId (req) {
  return req.id
})

const app = express();

app.use(assignId);
app.use(
  morgan(':id :remote-addr :remote-user :method :url [:status] :response-time',{
    skip: function (req, res) { return req.url === "/test" }
  })
);

function assignId (req, res, next) {
  req.id = uuid.v4()
  next()
}

// Body Parser Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

// Database Configuration and Connection
const uri = require("./config/keys").mongoURI.trim();

mongoose.connect(uri, { 
    useNewUrlParser: true,
    useUnifiedTopology: true,
    serverApi: '1'
  })
  .then(() => console.log("Mongo DB Connected."))
  .catch(err => console.log(err.reason));

// Passport Middleware
app.use(passport.initialize());
require("./config/passport")(passport);

app.use("/api/user", user);
app.use("/api/profile", profile);
app.use("/api/post", post);

const port = process.env.PORT || 3020;

app.listen(port, () => console.log(`BACKEND-USER running on http://localhost:${port}`));
