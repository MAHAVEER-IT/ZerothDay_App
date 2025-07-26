// Student model with validation and helper functions
class Student {
  constructor({
    uid,
    name,
    Rollnumber = null,
    email,
    Hosterler = null,
    Block = null,
    Roomnumber = null,
    department,
    year,
    Gender = null,
    lastLoginTime = new Date(),
    createdAt = null
  }) {
    this.uid = uid;
    this.name = name;
    this.Rollnumber = Rollnumber;
    this.email = email;
    this.Hosterler = Hosterler;
    this.Block = Block;
    this.Roomnumber = Roomnumber;
    this.department = department;
    this.year = year;
    this.Gender = Gender;
    this.lastLoginTime = lastLoginTime;
    this.createdAt = createdAt;
  }

  // Convert to Firestore document format
  toFirestoreDocument() {
    const doc = {
      uid: this.uid,
      name: this.name,
      email: this.email,
      department: this.department,
      year: this.year,
      Rollnumber: this.Rollnumber,
      Hosterler: this.Hosterler,
      Block: this.Block,
      Roomnumber: this.Roomnumber,
      Gender: this.Gender,
      lastLoginTime: this.lastLoginTime
    };
    
    // Only add createdAt if it exists
    if (this.createdAt) {
      doc.createdAt = this.createdAt;
    }
    
    return doc;
  }

  // Create Student from Firestore document
  static fromFirestoreDocument(doc) {
    const data = doc.data();
    
    // Use direct data pass-through to avoid duplicating all properties
    return new Student(data);
  }

  // Validate required fields for login
  static validateLoginData({ uid, name, email, department, year }) {
    const errors = [];
    const validations = [
      { value: uid, condition: val => val && typeof val === 'string', message: 'Valid UID is required' },
      { value: name, condition: val => val && typeof val === 'string' && val.trim().length > 0, message: 'Valid name is required' },
      { value: email, condition: val => val && typeof val === 'string' && val.includes('@'), message: 'Valid email is required' },
      { value: department, condition: val => val && typeof val === 'string', message: 'Valid department is required' },
      { value: year, condition: val => val && typeof val === 'string' && /^\d{4}$/.test(val), message: 'Valid year (4 digits) is required' }
    ];
    
    validations.forEach(validation => {
      if (!validation.condition(validation.value)) {
        errors.push(validation.message);
      }
    });
    
    return {
      isValid: errors.length === 0,
      errors: errors
    };
  }

  // Validate profile update data
  static validateProfileUpdateData(updateData) {
    const errors = [];
    const allowedFields = ['Rollnumber', 'Hosterler', 'Block', 'Roomnumber', 'Gender'];
    
    // Check for forbidden fields
    const forbiddenFields = ['uid', 'email', 'name', 'department', 'year', 'createdAt'];
    forbiddenFields.forEach(field => {
      if (updateData.hasOwnProperty(field)) {
        errors.push(`Field '${field}' cannot be updated`);
      }
    });
    
    // Field-specific validation rules
    const validations = {
      Rollnumber: {
        condition: val => val === null || (typeof val === 'string' && val.trim().length > 0),
        message: 'Roll number must be a non-empty string'
      },
      Hosterler: {
        condition: val => val === null || ['Yes', 'No'].includes(val),
        message: 'Hosterler must be either "Yes" or "No"'
      },
      Gender: {
        condition: val => val === null || ['Male', 'Female', 'Other'].includes(val),
        message: 'Gender must be "Male", "Female", or "Other"'
      }
    };
    
    // Validate fields if present
    Object.entries(validations).forEach(([field, validation]) => {
      const value = updateData[field];
      if (value !== undefined && !validation.condition(value)) {
        errors.push(validation.message);
      }
    });
    
    // If hosteler is No, Block and Roomnumber should be null
    if (updateData.Hosterler === 'No') {
      updateData.Block = null;
      updateData.Roomnumber = null;
    }
    
    // If hosteler is Yes, validate Block and Roomnumber
    if (updateData.Hosterler === 'Yes') {
      if (!updateData.Block || updateData.Block.trim().length === 0) {
        errors.push('Block is required for hostelers');
      }
      if (!updateData.Roomnumber || updateData.Roomnumber.trim().length === 0) {
        errors.push('Room number is required for hostelers');
      }
    }
    
    return {
      isValid: errors.length === 0,
      errors: errors,
      sanitizedData: updateData
    };
  }

  // Clean data for API response (remove sensitive fields if needed)
  toApiResponse() {
    // Simply reuse the toFirestoreDocument method since we don't have any sensitive fields to remove
    return this.toFirestoreDocument();
  }
}

module.exports = Student;
