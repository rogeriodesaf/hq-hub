import { environment } from '../../environments/environment';

export function normalizarUrlMidia(url: string | null | undefined): string | null {
  if (!url) {
    return null;
  }

  let valor = url.trim();
  if (!valor) {
    return null;
  }

  if (valor.startsWith('http://')) {
    valor = valor.replace(/^http:\/\//i, 'https://');
  }

  if (environment.apiUrl && valor.startsWith('/api/')) {
    return `${environment.apiUrl}${valor}`;
  }

  if (environment.apiUrl && valor.startsWith('api/')) {
    return `${environment.apiUrl}/${valor}`;
  }

  if (valor.startsWith('https://')) {
    if (!environment.apiUrl) {
      return valor;
    }

    try {
      const urlAbsoluta = new URL(valor);
      const baseApi = environment.apiUrl.replace(/\/$/, '');
      const alvoApi = `${baseApi}/api/`;

      if (urlAbsoluta.pathname.startsWith('/api/') && !valor.startsWith(alvoApi)) {
        return `${baseApi}${urlAbsoluta.pathname}${urlAbsoluta.search}${urlAbsoluta.hash}`;
      }
    } catch {
      return valor;
    }

    return valor;
  }

  return valor;
}

export function resolverUrlMidia(url: string | null | undefined, fallback = ''): string {
  return normalizarUrlMidia(url) || fallback;
}
