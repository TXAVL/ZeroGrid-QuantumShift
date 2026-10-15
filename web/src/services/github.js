// Service fetching latest repository and release details from GitHub API
// Uses session storage caching to avoid hitting GitHub unauthenticated rate limits (60 req/hr)

let cachedTDropVersion = null;

export async function getTDropLatestVersion() {
  if (cachedTDropVersion) {
    return cachedTDropVersion;
  }

  // 1. Check browser session cache (valid for 10 minutes)
  try {
    const sessionSaved = sessionStorage.getItem('tdrop_latest_version');
    const sessionTime = sessionStorage.getItem('tdrop_latest_version_time');
    if (sessionSaved && sessionTime && Date.now() - Number(sessionTime) < 10 * 60 * 1000) {
      cachedTDropVersion = sessionSaved;
      return cachedTDropVersion;
    }
  } catch {
    // ignore sessionStorage errors
  }

  // 2. Query GitHub Releases API
  try {
    const res = await fetch('https://api.github.com/repos/TXAVL/T-Drop/releases/latest', {
      headers: {
        Accept: 'application/vnd.github.v3+json'
      }
    });

    if (res.ok) {
      const data = await res.json();
      const rawTag = data.tag_name || data.name || '';
      if (rawTag) {
        // Ensure format like 'v0.1.6'
        const version = rawTag.startsWith('v') ? rawTag : `v${rawTag}`;
        cachedTDropVersion = version;

        try {
          sessionStorage.setItem('tdrop_latest_version', version);
          sessionStorage.setItem('tdrop_latest_version_time', String(Date.now()));
        } catch {
          // ignore storage quota errors
        }

        return version;
      }
    }
  } catch (err) {
    console.warn('[GitHub API] Failed to fetch T-Drop latest release version:', err);
  }

  // 3. Fallback to latest known release tag if offline / rate limited
  return cachedTDropVersion || 'v0.1.6';
}
