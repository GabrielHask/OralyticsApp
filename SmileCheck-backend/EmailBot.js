// Initialize Firebase Admin
const admin = require('firebase-admin');
const serviceAccount = require('./path-to-your-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://your-project-id.firebaseio.com'
});


const nodemailer = require('nodemailer');

// Create a transporter using Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'your-email@gmail.com', // Your email
    pass: 'your-email-password',  // Your email password (Consider using App Password for security)
  },
});

const db = admin.firestore();

async function sendEmails() {
  try {
    // Fetch all users' emails from Firebase
    const usersRef = db.collection('users'); // Adjust the path to your collection
    const snapshot = await usersRef.get();

    if (snapshot.empty) {
      console.log('No users found.');
      return;
    }

    // Loop through each user document and send an email
    snapshot.forEach((doc) => {
      const userEmail = doc.data().email; // Adjust to match your schema

      const mailOptions = {
        from: 'ghask056@gmail.com',
        to: userEmail,
        subject: 'Your Subject Here',
        text: 'Your Email Body Here',
      };

      // Send the email
      transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
          console.log('Error sending email to:', userEmail, error);
        } else {
          console.log('Email sent to:', userEmail, info.response);
        }
      });
    });
  } catch (error) {
    console.error('Error fetching users or sending emails:', error);
  }
}

sendEmails();
