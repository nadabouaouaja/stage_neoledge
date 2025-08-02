import api from './api';

export default {
  register({ email, password, firstName, lastName }) {
    return api.post('/api/user/register', { email, password, firstName, lastName });
  },

  login({ email, password }) {
    return api.post('/api/user/login', { email, password });
  },

  getUserDetails(userId) {
    return api.get(`/api/user/${userId}`);
  },

  updateProfile(userId, { email, firstName, lastName }) {
    return api.put(`/api/user/${userId}/profile`, { email, firstName, lastName });
  }
};