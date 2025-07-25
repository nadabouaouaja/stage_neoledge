export default class User {
  constructor({
    userID,
    email,
    password,
    firstName,
    lastName,
    createdAt,
    lastLogin,
    documents = []
  }) {
    this.userID = userID;
    this.email = email;
    this.password = password;
    this.firstName = firstName;
    this.lastName = lastName;
    this.createdAt = createdAt ? new Date(createdAt) : null;
    this.lastLogin = lastLogin ? new Date(lastLogin) : null;
    this.documents = documents; 
  }
}