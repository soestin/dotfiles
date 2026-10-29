#!/usr/bin/env python3
"""AirPods 4 ANC Waybar/Wofi client for airpods-tui's framed JSON IPC.

Protocol verified against annoyedmilk/airpods-tui main (2026-10-01).
The daemon owns Bluetooth; this client only reads events and sends settings.
"""

import json
import os
from pathlib import Path
import shutil
import socket
import struct
import subprocess
import sys
import time

MODEL = 0x201B
AIRPODS_MAC = "F4:78:AC:E2:A4:AB"
MODES = {1: "Off", 2: "ANC", 3: "Transparency", 4: "Adaptive"}


def connect():
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(3)
    try:
        client.connect(str(Path(runtime) / "airpods-tui.sock"))
    except OSError:
        client.close()
        raise
    return client


class Reader:
    def __init__(self, client):
        self.client = client
        self.buffer = bytearray()

    def read(self):
        while True:
            if len(self.buffer) >= 4:
                length = struct.unpack("!I", self.buffer[:4])[0]
                if length > 16 * 1024 * 1024:
                    raise ValueError("AirPods IPC message too large")
                if len(self.buffer) >= length + 4:
                    data = bytes(self.buffer[4:length + 4])
                    del self.buffer[:length + 4]
                    return json.loads(data)
            data = self.client.recv(65536)
            if not data:
                raise ConnectionError("AirPods daemon disconnected")
            self.buffer.extend(data)


def update(devices, event):
    for kind in ("DeviceConnected", "DeviceNearby"):
        if kind in event:
            info = event[kind]
            if info["product_id"] == MODEL:
                devices[info["mac"]] = {
                    "name": info["name"], "connected": kind == "DeviceConnected",
                    "battery": {}, "controls": {},
                }
            return
    if "DeviceDisconnected" in event:
        devices.pop(event["DeviceDisconnected"], None)
    if "AACPEvent" not in event:
        return
    mac, data = event["AACPEvent"]
    device = devices.get(mac)
    if device is None:
        return
    if "BatteryInfo" in data:
        for battery in data["BatteryInfo"]:
            component = battery["component"]
            if battery["status"] != 4 and 0 <= battery["level"] <= 100:
                device["battery"][component] = battery
            elif component != 8:
                device["battery"].pop(component, None)
    if "ControlCommand" in data:
        command = data["ControlCommand"]
        if command["value"]:
            device["controls"][command["identifier"]] = command["value"][0]
    if data == "ConnectionLost":
        device["connected"] = False


def selected(devices):
    return next(((mac, d) for mac, d in devices.items() if d["connected"]),
                next(iter(devices.items()), (None, None)))


def render(devices):
    _, device = selected(devices)
    if device is None or not device["connected"]:
        return {"text": "", "class": "disconnected", "tooltip": ""}
    batteries = device["battery"]
    battery_text = " ".join(
        f"{label} {batteries[component]['level']}%" if component in batteries else f"{label} —"
        for component, label in ((4, "L"), (2, "R"))
    )
    controls = device["controls"]
    mode = MODES.get(controls.get(13), "…") if device["connected"] else "nearby"
    tooltip = [device["name"], f"Mode: {mode}"]
    for component, name in ((4, "Left"), (2, "Right"), (8, "Case (last reported)")):
        if component in batteries:
            b = batteries[component]
            tooltip.append(f"{name}: {b['level']}%" + (" · charging" if b["status"] == 1 else ""))
    awareness = controls.get(40)
    if awareness in (1, 2) and device["connected"]:
        tooltip.append("Conversation Awareness: " + ("on" if awareness == 1 else "off"))
    tooltip.append("Left-click: mode menu\nRight-click: all settings")
    return {"text": f"󰋋 {battery_text} · {mode}", "tooltip": "\n".join(tooltip),
            "class": "connected" if device["connected"] else "nearby"}


def watch():
    last = None
    while True:
        try:
            with connect() as client:
                client.settimeout(1)
                reader, devices = Reader(client), {}
                while True:
                    try:
                        update(devices, reader.read())
                    except socket.timeout:
                        pass
                    output = json.dumps(render(devices), ensure_ascii=False)
                    if output != last:
                        print(output, flush=True)
                        last = output
        except (OSError, ValueError, KeyError, TypeError):
            output = json.dumps({"text": "", "class": "unavailable", "tooltip": ""})
            if output != last:
                print(output, flush=True)
                last = output
            time.sleep(5)


def notify(message):
    if shutil.which("notify-send"):
        subprocess.run(["notify-send", "AirPods", message], check=False)
    print(message, file=sys.stderr)


def settings():
    if not shutil.which("airpods-tui"):
        notify("Install airpods-tui-bin and start airpods-tui.service first.")
        return
    subprocess.Popen(["kitty", "--class", "airpods-settings", "--title", "AirPods", "airpods-tui"])


def hotkey():
    """Connect only when BlueZ reports disconnected; otherwise toggle ANC."""
    try:
        info = subprocess.run(["bluetoothctl", "info", AIRPODS_MAC],
                              capture_output=True, text=True, timeout=5)
        if info.returncode:
            notify("Could not read the AirPods connection status.")
            return
        lines = {line.strip() for line in info.stdout.splitlines()}
        if "Connected: no" in lines:
            result = subprocess.run(["bluetoothctl", "--timeout", "15", "connect", AIRPODS_MAC],
                                    capture_output=True, text=True, timeout=20)
            if result.returncode:
                notify("Could not connect AirPods. " + result.stdout.strip())
            return
        if "Connected: yes" not in lines:
            notify("AirPods connection status is unknown.")
            return
        with connect() as client:
            client.settimeout(0.3)
            reader, devices = Reader(client), {}
            deadline = time.monotonic() + 3
            mode = None
            while time.monotonic() < deadline:
                try:
                    update(devices, reader.read())
                except socket.timeout:
                    pass
                device = devices.get(AIRPODS_MAC, {})
                mode = device.get("controls", {}).get(13)
                if device.get("connected") and mode in MODES:
                    break
            else:
                notify("AirPods are connected, but their listening mode is unavailable.")
                return
            value = 3 if mode == 2 else 2
            payload = json.dumps([AIRPODS_MAC, {"ControlCommand": [13, [value]]}]).encode()
            client.sendall(struct.pack("!I", len(payload)) + payload)
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline:
                try:
                    update(devices, reader.read())
                except socket.timeout:
                    continue
                if devices.get(AIRPODS_MAC, {}).get("controls", {}).get(13) == value:
                    return
            notify("Mode change sent, but the AirPods have not confirmed it.")
    except (OSError, ValueError, subprocess.TimeoutExpired):
        notify("AirPods control unavailable. Check airpods-tui.service.")


def menu():
    try:
        with connect() as client:
            client.settimeout(0.3)
            reader, devices = Reader(client), {}
            deadline = time.monotonic() + 2
            while time.monotonic() < deadline:
                try:
                    update(devices, reader.read())
                except socket.timeout:
                    break
    except (OSError, ValueError, KeyError, TypeError):
        notify("AirPods daemon unavailable. Start airpods-tui.service first.")
        return
    mac, device = selected(devices)
    actions = {"All AirPods settings": None}
    if device and device["connected"]:
        actions = {"Noise Cancellation": (13, 2), "Transparency": (13, 3),
                   "Adaptive": (13, 4)}
        if device["controls"].get(52) == 1:
            actions["Off"] = (13, 1)
        actions.update({"Conversation Awareness: on": (40, 1),
                        "Conversation Awareness: off": (40, 2),
                        "All AirPods settings": None})
    result = subprocess.run(["wofi", "--dmenu", "--prompt", "AirPods", "--width", "360",
                             "--height", "340", "--hide-scroll"],
                            input="\n".join(actions), text=True, capture_output=True)
    choice = result.stdout.strip()
    if result.returncode or choice not in actions:
        return
    action = actions[choice]
    if action is None:
        settings()
        return
    identifier, value = action
    try:
        with connect() as client:
            # Re-read after the picker closes: the AirPods may have disconnected.
            client.settimeout(0.3)
            reader, latest = Reader(client), {}
            deadline = time.monotonic() + 2
            while time.monotonic() < deadline:
                try:
                    update(latest, reader.read())
                except socket.timeout:
                    break
            if not latest.get(mac, {}).get("connected"):
                notify("AirPods disconnected before the setting could be sent.")
                return
            payload = json.dumps([mac, {"ControlCommand": [identifier, [value]]}]).encode()
            client.sendall(struct.pack("!I", len(payload)) + payload)
            client.settimeout(0.5)
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline:
                try:
                    event = reader.read()
                except socket.timeout:
                    continue
                if "AACPEvent" in event:
                    event_mac, data = event["AACPEvent"]
                    if isinstance(data, dict):
                        control = data.get("ControlCommand", {})
                        if (event_mac == mac and control.get("identifier") == identifier
                                and control.get("value") and control["value"][0] == value):
                            return
            notify("Setting sent, but the AirPods have not confirmed it. Check the bar.")
    except (OSError, ValueError):
        notify("Could not send AirPods setting. Check the daemon and connection.")


if __name__ == "__main__":
    try:
        {"watch": watch, "menu": menu, "settings": settings, "hotkey": hotkey}[sys.argv[1]]()
    except BrokenPipeError:
        pass
