import api from './api';

function toFormData(obj) {
  const formData = new FormData();
  Object.entries(obj).forEach(([key, value]) => formData.append(key, value));
  return formData;
}

export default {
  createDocument({ file, title, category }) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('title', title);
    formData.append('category', category);
    return api.post('/api/document', formData);
  },

  getDocument(documentId) {
    return api.get(`/api/document/${documentId}`);
  },

  downloadDocument(documentId) {
    return api.get(`/api/document/${documentId}/download`, { responseType: 'blob' });
  },

  listDocuments() {
    return api.get('/api/document');
  },

  updateDocument(documentId, { title, category }) {
    return api.put(`/api/document/${documentId}`, { title, category });
  },

  deleteDocument(documentId) {
    return api.delete(`/api/document/${documentId}`);
  },

  searchDocuments({ title, category }) {
    const params = {};
    if (title) params.title = title;
    if (category) params.category = category;
    return api.get('/api/document/search', { params });
  }
};