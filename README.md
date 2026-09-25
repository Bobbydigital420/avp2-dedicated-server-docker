# Aliens versus Predator 2 (2001) Dedicated Server 

A lightweight, multi-architecture (**AMD64 / ARM64**) Docker container for hosting classic Aliens versus Predator 2 dedicated multiplayer servers. This image supports both the base game and the Primal Hunt expansion through an environment configuration flag, utilizing **VNC/noVNC/Fluxbox** to display the server console GUI directly inside your web browser.

---

## Environment Variables & Configuration Keys

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| **`GAME_MODE`** | `base` | Determines which variant to host. Use `base` for original AvP2 or `primal_hunt` for the expansion. |
| **`SERVER_ARGS`** | *(Blank)* | Additional execution arguments passed straight to the LithTech server binary (e.g., `-options serveroptions.txt`). |

---

## Volume Mount Paths

| Container Path | Description |
| :--- | :--- |
| **`/avp2`** | Map this to your local host folder containing your base AVP2 dedicated server assets and game files. |
| **`/avp2ph`** | Map this to your local host folder containing your AVP2: Primal Hunt expansion game files. |

*(Note: The container will automatically route to and check the appropriate directory depending on your active `GAME_MODE` variable selection).*

---

## Web-VNC Diagnostic Console & Server Monitoring

This container runs completely headless utilizing an internal virtual framebuffer layout (**Xvfb** and **Fluxbox**). However, it exposes a built-in **noVNC web interface** so you can physically view the container's desktop layer to configure options, monitor cycles, and read live game engine outputs.

### How to Access the Visual Console:
1. Map port **`8080`** out of your container.
2. Open any standard web browser on your computer and navigate to:
   ```text
   http://[YOUR_SERVER_IP]:8080/vnc.html
   ```
3. Click the blue **Connect** button on the browser window interface. You will be dropped straight onto the container desktop workspace.

---

## Quick Start Command Line (Copy & Paste)

Run this command from your terminal to stand up a fully verified server instance instantly. 

```bash
docker run -d -it --rm \
  --name avp2-server \
  -e GAME_MODE="base" \
  -e SERVER_ARGS="-options server.txt" \
  -v "/mnt/user/appdata/avp2:/avp2" \
  -v "/mnt/user/appdata/avp2ph:/avp2ph" \
  -p 27888:27888/udp \
  -p 8080:8080 \
  bobbydigital420/avp2-dedicated-server:latest
```

*(Note: Remember to replace `/mnt/user/appdata/avp2` and `/avp2ph` with the true paths to your local game asset storage configurations).*

---

## Networking & Client Connectivity Notes

1. **WAN Connectivity:** Forward Port **`27888` UDP** from your router's WAN interface directly to your host machine's local IP address. 
2. **Connecting to your Server:** Players should navigate to **Multiplayer > Internet > Find Internet Games** inside the *Aliens versus Predator 2* game menu and select your server or input your public IP address in join specific IP.

When hosting a LAN game you must type in the hosts IP address because legacy DirectPlay discovery relies heavily on network broadcasts that are blocked by default Docker network bridging configuration.

## Game Files

I highly recommend to get your game files from and follow the instructions on https://avpunknown.com/avp2aio/ to setup your dedicated server. Make sure to install the master server patches if you would like your server to be listed in the avpunknown master server list.
