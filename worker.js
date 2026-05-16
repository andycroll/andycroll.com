// Cloudflare Pages advanced-mode Worker.
// Implements Markdown for Agents content negotiation: when a request sends
// `Accept: text/markdown`, we serve the pre-generated `.md` twin produced at
// Jekyll build time. Otherwise the request passes through to the static HTML.

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method;

    if (method !== "GET" && method !== "HEAD") {
      return env.ASSETS.fetch(request);
    }

    const accept = request.headers.get("accept") || "";
    const wantsMarkdown = acceptsMarkdown(accept);

    const pathLooksLikePage =
      url.pathname.endsWith("/") ||
      url.pathname.endsWith(".html") ||
      !url.pathname.split("/").pop().includes(".");

    if (wantsMarkdown && pathLooksLikePage) {
      const mdPathname = url.pathname.replace(/\/?$/, "/") + "index.md";
      const mdUrl = new URL(mdPathname, url);
      const mdRequest = new Request(mdUrl.toString(), {
        method: "GET",
        headers: request.headers,
      });
      const mdResponse = await env.ASSETS.fetch(mdRequest);

      if (mdResponse.ok) {
        const body = await mdResponse.text();
        const tokens = Math.ceil(body.length / 4);
        const headers = new Headers({
          "content-type": "text/markdown; charset=utf-8",
          "x-markdown-tokens": String(tokens),
          "cache-control":
            mdResponse.headers.get("cache-control") || "public, max-age=300",
          vary: "Accept",
        });
        return new Response(method === "HEAD" ? null : body, {
          status: 200,
          headers,
        });
      }
      // No markdown twin at this URL — fall through to HTML.
    }

    const response = await env.ASSETS.fetch(request);
    const contentType = response.headers.get("content-type") || "";
    if (contentType.includes("text/html")) {
      const headers = new Headers(response.headers);
      appendVary(headers, "Accept");
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers,
      });
    }
    return response;
  },
};

function acceptsMarkdown(accept) {
  // Split on comma, trim, check each media range for text/markdown with non-zero q.
  return accept.split(",").some((part) => {
    const [mediaRange, ...params] = part.split(";").map((s) => s.trim());
    if (!/^text\/markdown$/i.test(mediaRange)) return false;
    const q = params
      .map((p) => /^q=([\d.]+)$/i.exec(p))
      .find(Boolean);
    return !q || parseFloat(q[1]) > 0;
  });
}

function appendVary(headers, value) {
  const existing = headers.get("vary");
  if (!existing) {
    headers.set("vary", value);
    return;
  }
  const tokens = existing.split(",").map((s) => s.trim().toLowerCase());
  if (tokens.includes(value.toLowerCase())) return;
  headers.set("vary", `${existing}, ${value}`);
}
