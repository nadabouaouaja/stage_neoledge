export default class Image {
  constructor({
    imageID,
    documentID,
    extractedDate,
    description,
    filePath,
    document = null
  }) {
    this.imageID = imageID;
    this.documentID = documentID;
    this.extractedDate = extractedDate ? new Date(extractedDate) : null;
    this.description = description;
    this.filePath = filePath;
    this.document = document; 
  }
}
