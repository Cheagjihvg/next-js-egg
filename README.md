# Next.js Advanced Pterodactyl Modular Engine 🚀

[![Pterodactyl Engine v2](https://img.shields.io/badge/Pterodactyl-v2_Schema-blue.svg?style=for-the-badge&logo=pterodactyl)](https://pterodactyl.io)
[![Next.js Version](https://img.shields.io/badge/Next.js-16+-black.svg?style=for-the-badge&logo=next.js)](https://nextjs.org)
[![Cloudflare Tunnel](https://img.shields.io/badge/Zero--Trust-Cloudflare-orange.svg?style=for-the-badge&logo=cloudflare)](https://cloudflare.com)

An enterprise-grade, highly automated **Pterodactyl Egg** specifically engineered to deploy, build, secure, and maintain complex **Next.js web applications** inside standard container environments. It features a fully automated modular framework designed to operate seamlessly behind private local networks without requiring open ports or infrastructure access.

---

## 🔥 Key Architectural Capabilities

* 🌐 **Persistent Cloudflare Tunnels (`cloudflared`):** Dynamically downloads and isolates a local binary engine within the node's persistent filesystem storage (`/home/container/cloudflared`). This bypasses standard firewall restrictions, offering zero-trust exposure for your applications straight to your custom domain.
* ⚡ **Conditional Build Engine Integration (`BUILD_NEXT`):** Includes an inline pipeline evaluator. Switch the value to `false` or `0` to instantly stop hot-rebuild loops during runtime boots, saving resources and protecting existing target `.next` distribution caches.
* 📦 **Smart Runtime Node Selector:** Fully compatible with a massive runtime image selection pool ranging from legacy platforms all the way up to cutting-edge **Node.js 26**.
* 🛠️ **Automated Package Management Client:** Includes built-in auto-discovery logic that scans workspaces for lockfile traces (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`), enabling Corepack dynamically to trigger the proper structural compilation tool.
* 🔄 **Upstream Core Synchronizer:** Integrates a background self-maintaining update protocol that forces file updates for script runners straight from your repository on container initialization.
* ⏰ **Isolated System Cron Task Module:** Launches local daemon environments alongside the Next.js process fork loop, letting you execute scheduled functions and operations locally inside your container shell.

---

## ☁️ Custom Domain Deployment via Cloudflare Tunnels

The embedded Zero-Trust module creates a safe, persistent, outbound-only encrypted tunnel connection directly from your Pterodactyl node container to the nearest Cloudflare Edge data center network endpoint. This enables you to host a public web asset **without exposing public IP allocations, messing with reverse proxies, or forwarding ports.**


```

```
                              [ OUTBOUND DATA STREAM ]

```

[ Next.js Server ] ═══> [ cloudflared binary ] ═══> [ Cloudflare Edge ] ═══> [ Custom Domain ]
(localhost:port)        (Persistent Storage)         (Zero Trust Network)     ([suspicious link removed])

```

### Complete Routing Step-by-Step Blueprint:

1. **Generate the Tunnel Instance:**
   * Go to your **[Cloudflare Zero Trust Portal](https://one.dash.cloudflare.com/)**.
   * Navigate to the sidebar panel: **Networks** ➡️ **Tunnels**, and click **Create a Tunnel**.
   * Pick **Cloudflared** as your target connector engine, name your node profile, and hit save.

2. **Acquire the Security Authentication Key:**
   * On the environment installation page, look at the terminal command code snippets displayed for operating environments.
   * Locate the long text sequence following the specific `--token` flag parameters (this long alphabetic hash character array starts with `ey...`). **Copy this token string.**

3. **Configure the Web Application Routing Path:**
   * Inside your tunnel's dashboard profile page, switch to the **Public Hostname** tab configuration index.
   * Click **Add a Public Hostname** and set your custom network settings:
     * **Subdomain/Domain:** Enter your target website routing name (e.g., `dashboard.mycompany.com`).
     * **Type:** Select standard **`HTTP`** from the selection pool.
     * **URL:** Map it to exactly **`localhost:{{SERVER_PORT}}`** (ensure this matches the random port assigned to your server container box instance).

4. **Activate the Panel Variable Configurations:**
   * Open up your Pterodactyl Instance configuration page and select your server's **Startup Parameters** navigation interface.
   * Locate the entry field named **Cloudflared Enable** and switch the operating toggle rule state to **`1`** or **`true`**.
   * Locate the entry field named **Cloudflared Token** and paste your copied authentication hash directly into the string input field block.
   * Click **Start/Restart Server**. Your Next.js web ecosystem will instantly map to your custom domain, secured by a free, automatic edge SSL/TLS certificate!

---

## ⚙️ Core Configuration Variables System

These variables are mapped inside the `.json` blueprint layout. They can be fully customized directly through your panel UI or environment startup profile variables:

| Visual Field Name | Environment Variable Flag | Factory Default Input | Input Validation Validation Matrix | Description & Architectural Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Egg Auto Update** | `EGG_AUTO_UPDATE` | `1` | `required\|boolean` | When active, the egg pulls down your fresh helper automation files from your repository on boot. |
| **Node Version Selector** | `NODE_IMAGE` | `nodejs_20` | `required\|string` | Defines the specific base Docker container image path for execution. |
| **Node ENV** | `NODE_RUN_ENV` | `start` | `required\|string\|in:start,dev` | Standard operational profile target (`start` for optimized production hosting, `dev` for active testing hot-reloads). |
| **Build Next.js Application** | `BUILD_NEXT` | `true` | `required\|string` | Switch to `false` or `0` to entirely skip compilation on boot, preserving your current workspace `.next` assets. |
| **Package Manager** | `PACKAGE_MANAGER` | `auto` | `required\|string\|in:auto,npm,pnpm,yarn` | Explicitly forces a package driver. Leaving it as `auto` handles auto-discovery tracking seamlessly. |
| **Git Repo** | `GIT_URL` | *(Blank String)* | `nullable\|string` | Target workspace endpoint path used to download project structures on the initial initialization run. |
| **Cloudflared Enable** | `CLOUDFLARED_STATUS` | `0` | `required\|boolean` | Activates or kills the background edge proxy tunnel network routing engine process. |
| **Cloudflared Token** | `CLOUDFLARED_TOKEN` | *(Blank String)* | `nullable\|string` | The private authorization key provided by Cloudflare Zero Trust to authenticate your tunnel. |
| **Cron Enable** | `CRON_STATUS` | `0` | `required\|boolean` | Toggles standard system time engine cron tasks to support automated cron jobs inside the platform container. |

---

## 🛠️ Panel Import & Node Setup Procedure

1. **Import the Blueprint Object:**
   * Download your repository's **`nextjs-egg.json`** artifact.
   * Access your **Pterodactyl Administrative Core Dashboard**, select **Nests**, and enter your preferred target workspace nest pool.
   * Click **Import Egg**, upload your local `nextjs-egg.json` file, and hit save to generate your service class template.

2. **Deploy or Assign Your Server Instance:**
   * Create a new server or reassign an existing instance to use this imported template profile.

3. **CRITICAL STEP: Execute Server Reinstallation:**
   * Because Pterodactyl separates installation and running phases into separate, temporary execution layers, any changes to binaries require a data refresh.
   * Inside your client or admin panel server dashboard, navigate to the **Manage** action buttons, and click **Reinstall Server**.
   * This forces Pterodactyl to run the clean setup macro, download the latest version of `cloudflared` directly into your persistent `/mnt/server` storage, establish proper permissions (`chmod +x`), and cleanly map all structural folders (`/logs`, `/tmp`, `/modules`).

4. **Boot Sequence:**
   * Navigate back to your live interactive console window and click **Start**. The network manager, auto-updater, and Next.js instance engines will execute side-by-side cleanly!

```


