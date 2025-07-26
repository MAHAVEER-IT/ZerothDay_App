const express = require("express");
const { verifyTokenAndStoreStudent, getStudentProfile, updateStudentProfile } = require("../controllers/authController");

const router = express.Router();

// Route to verify Firebase token and store student data
router.post("/verify", verifyTokenAndStoreStudent);

// Route to get student profile
router.get("/profile/:uid", getStudentProfile);

// Route to update student profile
router.put("/profile/:uid", updateStudentProfile);

module.exports = router;
