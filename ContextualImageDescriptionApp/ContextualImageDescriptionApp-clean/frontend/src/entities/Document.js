export default class Document {
  constructor({
    documentID,
    userID,
    title,
    filePath,
    category,
    uploadDate,
    content,
    status,
    images = [],
    user = null
  }) {
    this.documentID = documentID;
    this.userID = userID;
    this.title = title;
    this.filePath = filePath;
    this.category = category; 
    this.uploadDate = uploadDate ? new Date(uploadDate) : null;
    this.content = content;
    this.status = status; 
    this.images = images; 
    this.user = user; 
  }
}
