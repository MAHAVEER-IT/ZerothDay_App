const admin = require("../firebase/firebaseConfig");
const Student = require("../models/Student");

// Function to parse student info from email
const parseStudentEmail = (email) => {
  // Validate email domain
  if (!email || typeof email !== 'string') {
    throw new Error('Email is required and must be a string');
  }

  const emailParts = email.toLowerCase().split('@');
  if (emailParts.length !== 2 || emailParts[1] !== 'sece.ac.in') {
    throw new Error('Invalid email domain. Only @sece.ac.in emails are allowed.');
  }

  const localPart = emailParts[0]; // e.g., "mahaveer.k2023it"
  
  // Extract name (everything before the year) and year+department
  const match = localPart.match(/^(.+?)(\d{4})([a-z]+)$/i);
  if (!match) {
    throw new Error('Invalid email format. Expected format: name.year+department@sece.ac.in');
  }

  const [, nameWithDot, year, department] = match;
  
  // Convert dots to spaces for name and clean it up
  const name = nameWithDot
    .replace(/\./g, ' ')
    .trim()
    .replace(/\s+/g, ' ') // Replace multiple spaces with single space
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(' ');

  // Validate year (should be reasonable)
  const currentYear = new Date().getFullYear();
  const yearNum = parseInt(year);
  if (yearNum < 2000 || yearNum > currentYear + 10) {
    throw new Error('Invalid year in email. Year should be between 2000 and ' + (currentYear + 10));
  }

  // Validate department (should be reasonable length)
  if (department.length < 2 || department.length > 10) {
    throw new Error('Invalid department code in email');
  }

  return {
    name: name,
    year: year,
    department: department.toUpperCase(),
    email: email.toLowerCase()
  };
};

// Verify Firebase token and store student data
const verifyTokenAndStoreStudent = async (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({ 
        message: "Firebase ID token is required" 
      });
    }

    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { email, uid } = decodedToken;

    // Validate email domain
    if (!email.toLowerCase().endsWith('@sece.ac.in')) {
      return res.status(403).json({ 
        message: "Access denied. Only @sece.ac.in email addresses are allowed." 
      });
    }

    // Parse student information from email
    let studentInfo;
    try {
      studentInfo = parseStudentEmail(email);
    } catch (parseError) {
      return res.status(400).json({ 
        message: parseError.message 
      });
    }

    // Validate parsed data
    const validation = Student.validateLoginData({
      uid: uid,
      name: studentInfo.name,
      email: email,
      department: studentInfo.department,
      year: studentInfo.year
    });

    if (!validation.isValid) {
      return res.status(400).json({ 
        message: "Invalid student data", 
        errors: validation.errors 
      });
    }

    // Create student instance
    const student = new Student({
      uid: uid,
      name: studentInfo.name,
      email: email,
      department: studentInfo.department,
      year: studentInfo.year,
      lastLoginTime: admin.firestore.FieldValue.serverTimestamp()
    });

    // Store/update student in Firestore
    const db = admin.firestore();
    const studentRef = db.collection('Students').doc(uid);
    
    // Check if student already exists
    const studentDoc = await studentRef.get();
    
    if (studentDoc.exists) {
      // Update existing student's last login time
      await studentRef.update({
        lastLoginTime: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Get updated student data
      const updatedDoc = await studentRef.get();
      const existingStudent = Student.fromFirestoreDocument(updatedDoc);
      
      res.status(200).json({ 
        message: "Authentication successful", 
        student: existingStudent.toApiResponse()
      });
    } else {
      // Create new student document
      const studentData = student.toFirestoreDocument();
      studentData.createdAt = admin.firestore.FieldValue.serverTimestamp();
      
      await studentRef.set(studentData);
      
      // Get the created student data
      const createdDoc = await studentRef.get();
      const newStudent = Student.fromFirestoreDocument(createdDoc);
      
      res.status(201).json({ 
        message: "New student registered successfully", 
        student: newStudent.toApiResponse()
      });
    }

  } catch (err) {
    console.error('Authentication error:', err);
    
    if (err.code === 'auth/id-token-expired') {
      return res.status(401).json({ message: "Token expired. Please sign in again." });
    }
    
    if (err.code === 'auth/invalid-id-token') {
      return res.status(401).json({ message: "Invalid token. Please sign in again." });
    }
    
    res.status(500).json({ 
      message: "Authentication failed", 
      error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
  }
};

// Get student profile
const getStudentProfile = async (req, res) => {
  try {
    const { uid } = req.params;
    
    if (!uid) {
      return res.status(400).json({ message: "Student UID is required" });
    }

    const db = admin.firestore();
    const studentDoc = await db.collection('Students').doc(uid).get();

    if (!studentDoc.exists) {
      return res.status(404).json({ message: "Student not found" });
    }

    const student = Student.fromFirestoreDocument(studentDoc);
    res.status(200).json({ 
      message: "Profile retrieved successfully",
      student: student.toApiResponse() 
    });

  } catch (err) {
    console.error('Error fetching student profile:', err);
    res.status(500).json({ 
      message: "Error fetching profile", 
      error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
  }
};

// Update student profile
const updateStudentProfile = async (req, res) => {
  try {
    const { uid } = req.params;
    const updateData = req.body;
    
    if (!uid) {
      return res.status(400).json({ message: "Student UID is required" });
    }

    // Validate update data
    const validation = Student.validateProfileUpdateData(updateData);
    if (!validation.isValid) {
      return res.status(400).json({ 
        message: "Invalid update data", 
        errors: validation.errors 
      });
    }

    const db = admin.firestore();
    const studentRef = db.collection('Students').doc(uid);
    
    // Check if student exists
    const studentDoc = await studentRef.get();
    if (!studentDoc.exists) {
      return res.status(404).json({ message: "Student not found" });
    }
    
    // Update student data
    await studentRef.update({
      ...validation.sanitizedData,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Get updated student data
    const updatedDoc = await studentRef.get();
    const updatedStudent = Student.fromFirestoreDocument(updatedDoc);
    
    res.status(200).json({ 
      message: "Profile updated successfully", 
      student: updatedStudent.toApiResponse()
    });

  } catch (err) {
    console.error('Error updating student profile:', err);
    res.status(500).json({ 
      message: "Error updating profile", 
      error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
  }
};

module.exports = {
  verifyTokenAndStoreStudent,
  getStudentProfile,
  updateStudentProfile
};
