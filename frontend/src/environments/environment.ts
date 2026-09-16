function resolverApiUrlRuntime() {
  if (typeof window === 'undefined') {
    return '';
  }

  if (['hqhub-frontend.onrender.com', 'hqhub.space', 'www.hqhub.space'].includes(window.location.hostname)) {
    return 'https://hqhub-backend.onrender.com';
  }

  return '';
}

export const environment = {
  production: false,
  apiUrl: resolverApiUrlRuntime(),
  compartilhamentoUrl: 'https://hqhub-backend.onrender.com/api/compartilhar',
};
