## 1. Was bedeutet `docker build -t`?

**Befehl:**

```bash
docker build -t <image-name> .
```

**Erklärung:**

- `docker build` erzeugt ein Docker-Image basierend auf:
  - dem **Dockerfile**
  - Dateien im aktuellen Ordner
  - Build-Anweisungen
- `-t` steht für **Tag** (Name des Images)

**Beispiel:**

```bash
docker build -t vite-frontend .
```

→ erstellt ein Image mit dem Namen: `vite-frontend:latest`

**Warum ist das wichtig?**

- Du kannst das Image **starten**
- Du kannst es in **Docker Hub pushen**
- Du kannst logisch **versionieren** (z. B. `1.0.1`, `prod`, `dev`, `commit-sha`)

> **Ohne `-t`** würde Docker das Image zwar bauen, aber es hätte nur eine zufällige ID (z. B. `sha256:29ad30kd...`).
>
> ⛔ **Unbrauchbar zum Arbeiten!**

---

## 2. Was bedeutet `docker run -p`

**Befehl:**

```bash
docker run -p <host-port>:<container-port> <image-name>
```

**Erklärung:**

- `docker run` startet einen Container aus einem bestehenden Image.
- `-p` steht für **Port Mapping** oder **Port-Weiterleitung**.

**Syntax:**

```bash
-p <host-port>:<container-port>
```

**Beispiel:**

```bash
docker run -p 8080:80 vite-frontend
```

**Bedeutet:**

- **8080** (Host/Mac/Windows/PC) → Port, auf den du im Browser gehst
- **80** (Container) → Port, auf dem z. B. nginx läuft
