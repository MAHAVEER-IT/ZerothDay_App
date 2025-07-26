require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());

app.use("/api/auth", authRoutes);

app.get("/", (req, res) => {
  res.send("Firebase + Express Auth Server");
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
