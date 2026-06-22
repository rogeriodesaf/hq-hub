import { environment } from '../../environments/environment';

export function resolverUrlMidia(url: string | null | undefined, fallback = ''): string {
  if (!url) {
    return fallback;
  }

  if (url.startsWith('http://')) {
    url = url.replace('http://', 'https://');
  }

  if (url.startsWith('https://')) {
    return url;
  }

  if (environment.apiUrl && url.startsWith('/')) {
    return `${environment.apiUrl}${url}`;
  }

  return url;
}
