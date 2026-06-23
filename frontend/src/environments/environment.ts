function resolverApiUrlRuntime() {
  if (typeof window === 'undefined') {
    return '';
  }

  if (window.location.hostname === 'hqhub-frontend.onrender.com') {
    return 'https://hqhub-backend.onrender.com';
  }

  return '';
}

export const environment = {
  production: false,
  apiUrl: resolverApiUrlRuntime(),
};
