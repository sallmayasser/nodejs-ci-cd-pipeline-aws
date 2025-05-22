const express = require("express");
const app = express();
const port = 3000;

const mysql = require("mysql");
const pool = mysql.createPool({
  host: process.env.RDS_HOSTNAME,
  user: process.env.RDS_USERNAME,
  password: process.env.RDS_PASSWORD,
  port: process.env.RDS_PORT,
  ssl: true,
  connectionLimit: 10, // adjust as needed
});

app.get("/db", (req, res) => {
  pool.getConnection(function (err, connection) {
    if (err) {
      res.send("db connection failed");
      console.error("Database connection failed: " + err.stack);
      return;
    }
    res.send("db connection successful finished pipeline");
    console.log("Connected to database.");
    connection.release(); // release back to the pool
  });
});

const redis = require("redis");
const client = redis.createClient({
  host: process.env.REDIS_HOSTNAME,
  port: process.env.REDIS_PORT,
});

client.on("error", (err) => {
  console.log("Error " + err);
});

app.get("/redis", (req, res) => {
  client.set("foo", "bar", (error, rep) => {
    if (error) {
      console.log(error);
      res.send("redis connection failed");
      return;
    }
    if (rep) {
      //JSON objects need to be parsed after reading from redis, since it is stringified before being stored into cache
      console.log(rep);
      res.send("redis is successfuly connected");
    }
  });
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
