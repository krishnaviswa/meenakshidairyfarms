/* Account page client island: phone-OTP login, order history, billing.
 * Vanilla JS — same convention as order.js/OrderPage.astro, no framework.
 */

const TOKEN_KEY = "meenakshi_token";
const USER_KEY = "meenakshi_user";

interface Strings {
  [key: string]: string;
}

interface AccountConfig {
  lang: string;
  s: Strings;
  waNumber: string;
}

function getToken(): string | null {
  try {
    return localStorage.getItem(TOKEN_KEY);
  } catch {
    return null;
  }
}

function setSession(token: string, user: unknown): void {
  try {
    localStorage.setItem(TOKEN_KEY, token);
    localStorage.setItem(USER_KEY, JSON.stringify(user));
  } catch {}
}

function clearSession(): void {
  try {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  } catch {}
}

async function api(path: string, options: RequestInit = {}) {
  const token = getToken();
  const headers: Record<string, string> = { "Content-Type": "application/json", ...(options.headers as Record<string, string> | undefined) };
  if (token) headers["Authorization"] = "Bearer " + token;
  const res = await fetch(path, { ...options, headers });
  const data = await res.json().catch(() => ({ ok: false }));
  return { status: res.status, data };
}

function fmtInr(n: number | string): string {
  return "₹" + Math.round(Number(n)).toLocaleString("en-IN");
}

export function initAccountPage(root: HTMLElement, cfg: AccountConfig): void {
  const s = cfg.s || {};

  function render() {
    const token = getToken();
    root.innerHTML = "";
    if (!token) {
      root.appendChild(renderLogin());
    } else {
      root.appendChild(renderLoggedIn());
    }
  }

  function renderLogin(): HTMLElement {
    const wrap = document.createElement("div");
    wrap.className = "card acct-card";

    let phone = "";
    let step: "phone" | "code" = "phone";
    let error = "";
    let busy = false;
    let devCode = "";

    function draw() {
      wrap.innerHTML = "";
      const h = document.createElement("h2");
      h.textContent = s.loginTitle || "Sign in";
      wrap.appendChild(h);

      const p = document.createElement("p");
      p.className = "acct-body";
      p.textContent = step === "phone" ? (s.loginBody || "") : (s.codeLabel || "");
      wrap.appendChild(p);

      if (error) {
        const e = document.createElement("p");
        e.className = "acct-error";
        e.textContent = error;
        wrap.appendChild(e);
      }

      if (devCode) {
        const d = document.createElement("p");
        d.className = "acct-devhint";
        d.textContent = (s.devCodeHint || "Testing mode — code:") + " " + devCode;
        wrap.appendChild(d);
      }

      const form = document.createElement("form");
      form.className = "acct-form";

      if (step === "phone") {
        const input = document.createElement("input");
        input.type = "tel";
        input.inputMode = "numeric";
        input.placeholder = s.phoneLabel || "Mobile number";
        input.value = phone;
        input.autocomplete = "tel";
        form.appendChild(input);

        const btn = document.createElement("button");
        btn.type = "submit";
        btn.className = "btn btn-primary";
        btn.textContent = busy ? (s.sendingCode || "Sending…") : (s.sendCode || "Send code");
        btn.disabled = busy;
        form.appendChild(btn);

        form.addEventListener("submit", async (e) => {
          e.preventDefault();
          const digits = input.value.replace(/\D/g, "");
          if (digits.length < 10) {
            error = s.invalidPhone || "Enter a valid phone number.";
            draw();
            return;
          }
          phone = input.value;
          busy = true;
          error = "";
          draw();
          const { data } = await api("/api/auth/request-otp", {
            method: "POST",
            body: JSON.stringify({ phone }),
          });
          busy = false;
          if (data && data.ok) {
            step = "code";
            devCode = data.devCode || "";
          } else {
            error = (data && data.error) || s.loadError || "Something went wrong.";
          }
          draw();
        });
      } else {
        const input = document.createElement("input");
        input.type = "text";
        input.inputMode = "numeric";
        input.maxLength = 6;
        input.placeholder = s.codeLabel || "Code";
        form.appendChild(input);

        const btn = document.createElement("button");
        btn.type = "submit";
        btn.className = "btn btn-primary";
        btn.textContent = busy ? (s.verifying || "Verifying…") : (s.verify || "Verify");
        btn.disabled = busy;
        form.appendChild(btn);

        const back = document.createElement("button");
        back.type = "button";
        back.className = "btn-link";
        back.textContent = s.changeNumber || "Use a different number";
        back.addEventListener("click", () => {
          step = "phone";
          error = "";
          devCode = "";
          draw();
        });

        form.addEventListener("submit", async (e) => {
          e.preventDefault();
          const code = input.value.trim();
          if (!code) return;
          busy = true;
          error = "";
          draw();
          const { data } = await api("/api/auth/verify-otp", {
            method: "POST",
            body: JSON.stringify({ phone, code }),
          });
          busy = false;
          if (data && data.ok) {
            setSession(data.token, data.user);
            render();
            return;
          }
          error = (data && data.error) || s.invalidCode || "Incorrect code.";
          draw();
        });

        wrap.appendChild(form);
        wrap.appendChild(back);
        return;
      }

      wrap.appendChild(form);
    }

    draw();
    return wrap;
  }

  function renderLoggedIn(): HTMLElement {
    const wrap = document.createElement("div");
    wrap.className = "acct-loggedin";

    const logoutBtn = document.createElement("button");
    logoutBtn.type = "button";
    logoutBtn.className = "btn-link acct-logout";
    logoutBtn.textContent = s.signOut || "Sign out";
    logoutBtn.addEventListener("click", () => {
      clearSession();
      render();
    });
    wrap.appendChild(logoutBtn);

    const ordersCard = document.createElement("div");
    ordersCard.className = "card acct-card";
    ordersCard.innerHTML = `<h2>${escapeHtml(s.ordersTitle || "My Orders")}</h2><p class="acct-loading">…</p>`;
    wrap.appendChild(ordersCard);

    const paymentsCard = document.createElement("div");
    paymentsCard.className = "card acct-card";
    paymentsCard.innerHTML = `<h2>${escapeHtml(s.paymentsTitle || "Payments")}</h2><p class="acct-loading">…</p>`;
    wrap.appendChild(paymentsCard);

    loadOrders(ordersCard);
    loadPayments(paymentsCard);

    return wrap;
  }

  async function loadOrders(card: HTMLElement) {
    const { status, data } = await api("/api/account/orders");
    if (status === 401) {
      clearSession();
      render();
      return;
    }
    if (!data || !data.ok) {
      card.querySelector(".acct-loading")!.textContent = s.loadError || "Couldn't load.";
      return;
    }
    const orders = data.orders || [];
    const body = card.querySelector(".acct-loading") as HTMLElement;
    if (!orders.length) {
      body.textContent = s.noOrders || "No orders yet.";
      return;
    }
    body.remove();
    orders.forEach((o: any) => {
      const row = document.createElement("div");
      row.className = "acct-row";
      const items = (o.items || [])
        .map((it: any) => `${it.litres} L ${it.key === "cow" ? s.cow || "Cow" : s.buffalo || "Buffalo"}`)
        .join(" + ");
      const date = o.created_at ? new Date(o.created_at).toLocaleDateString() : "";
      row.innerHTML = `
        <div class="acct-row-main"><b>${escapeHtml(items)}</b> · ${fmtInr(o.total)}</div>
        <div class="acct-row-sub">${escapeHtml(o.ref || "")} · ${escapeHtml(s.orderedOn || "Ordered")} ${escapeHtml(date)}</div>
      `;
      card.appendChild(row);
    });
  }

  async function loadPayments(card: HTMLElement) {
    const { status, data } = await api("/api/account/payments");
    if (status === 401) {
      clearSession();
      render();
      return;
    }
    if (!data || !data.ok) {
      card.querySelector(".acct-loading")!.textContent = s.loadError || "Couldn't load.";
      return;
    }
    const payments = data.payments || [];
    const body = card.querySelector(".acct-loading") as HTMLElement;
    if (!payments.length) {
      body.textContent = s.noPayments || "Nothing due.";
      return;
    }
    body.remove();
    payments.forEach((p: any) => {
      const row = document.createElement("div");
      row.className = "acct-row";
      const main = document.createElement("div");
      main.className = "acct-row-main";
      main.innerHTML = `<b>${fmtInr(p.amount)}</b> · ${escapeHtml(p.order_ref || "")}`;
      row.appendChild(main);

      if (p.status === "due") {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "btn btn-ghost acct-paybtn";
        btn.textContent = s.markPaid || "I've paid";
        btn.addEventListener("click", async () => {
          btn.disabled = true;
          btn.textContent = s.markingPaid || "Marking as paid…";
          const { data: res } = await api(`/api/account/payments/${p.id}/mark-paid`, { method: "POST" });
          if (res && res.ok) {
            main.innerHTML = `<b>${fmtInr(p.amount)}</b> · ${escapeHtml(p.order_ref || "")} · <span class="acct-paid">${escapeHtml(s.paidSelfReported || "Paid")}</span>`;
            btn.remove();
          } else {
            btn.disabled = false;
            btn.textContent = s.markPaid || "I've paid";
          }
        });
        row.appendChild(btn);
      } else {
        const badge = document.createElement("span");
        badge.className = "acct-paid";
        badge.textContent = s.paidSelfReported || "Paid";
        row.appendChild(badge);
      }
      card.appendChild(row);
    });
  }

  function escapeHtml(str: string): string {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML;
  }

  render();
}
