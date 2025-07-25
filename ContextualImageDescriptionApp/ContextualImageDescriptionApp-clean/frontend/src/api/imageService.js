import api from './api';

export default {
  createImage(documentId, file) {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/api/image/${documentId}`, formData);
  },

  getImagesByDocument(documentId) {
    return api.get(`/api/image/document/${documentId}`);
  },

  downloadImage(imageId) {
    return api.get(`/api/image/${imageId}/download`, { responseType: 'blob' });
  }
};