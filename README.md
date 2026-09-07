# Red Faction (2001) Dedicated Server 

A lightweight, multi-architecture (**AMD64 / ARM64**) Docker container for hosting classic Red Faction dedicated multiplayer servers. This image features integrated **Dash Faction** multiplayer tracker broadcasting hooks and leverages **VNC/noVNC/Fluxbox** for a server console in your web browser.

---

##  Environment Variables & Configuration Keys

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| **`SERVER_NAME`** | `Multiarch Faction Server` | The public server title that will display globally in the master server browser list. |
| **`TRACKER_PORT`** | `7755` | The primary gameplay and outbound tracker heartbeat port (**UDP**). Maps directly to your WAN firewalls. |
| **`EXTRA_FLAGS`** | `-np` | Additional execution arguments passed straight to the game engine (e.g., `-np` for no-pure asset check, `-maxplayers 24`, etc.). |

---

##  Volume Mount Path

| Container Path | Description |
| :--- | :--- |
| **`/redfaction`** | Map this to your local host folder containing your base Red Faction game assets. |

---

##  Web-VNC Diagnostic Console & Server Monitoring

This container runs completely headless utilizing an internal virtual framebuffer layout (**Xvfb** and **Fluxbox**). However, it exposes a built-in **noVNC web interface** so you can physically look inside the container's desktop layer to monitor the live server console window.

### How to Access the Visual Console:
1. Map port **`8080`** out of your container.
2. Open any standard web browser on your computer and navigate to:
   ```text
   http://[YOUR_SERVER_IP]:8080/vnc.html
   ```
3. Click the blue **Connect** button on the browser window interface. You will be dropped straight onto the container desktop workspace.


---

##  Quick Start Command Line (Copy & Paste)

Run this command from your terminal to stand up a fully verified server instance instantly. 

```bash
docker run -d -it --rm \
  --name redfaction-server \
  -e SERVER_NAME="Bobbys Destructible GeoMod Arena" \
  -e TRACKER_PORT=7755 \
  -e EXTRA_FLAGS="-np -maxplayers 16" \
  -v "/mnt/user/appdata/redfaction:/redfaction" \
  -p 7755:7755 \
  -p 8080:8080 \
  bobbydigital420/redfaction-dedicated-server:latest
```

*(Note: Remember to replace `/mnt/user/appdata/redfaction` with the true path to your local game files folder and change the server name to your liking)*

---

##  Critical Firewall Settings (OPNsense / pfSense)
Because Red Faction's retro master tracking server requires inbound verification pings to match your outbound registration source port exactly, standard symmetric NAT port randomization will prevent your instance from verifying.

1. **Inbound Port Forward (NAT):** Forward Port **`7755` UDP** from your WAN interface directly to your host server's local IP address. Ensure your firewall rule association is set to **Pass** or **Register NAT Rule** (do not leave it on manual).
2. **Outbound / Source NAT Rule:** Create a custom rule at the absolute top of your Outbound/Source NAT settings for your server's local IP address. Check the box to enable **Static-port**. This explicitly forces your router to preserve port `7755` as packets leave your home network instead of randomizing them.
