# ---------------------------------------------------
# 1. BUILD-STAGE (Alias: builder)
# ---------------------------------------------------
# Wir starten einen Container mit Node.js
# Alpine = kleines Linux ⇒ kleineres Image.
# AS builder gibt diesem Build-Schritt einen Namen.
# → Dadurch können wir später Dateien aus dieser Stage in andere Stages kopieren (--from=builder).
FROM node:20-alpine AS builder

# Legt das Arbeitsverzeichnis *im Container* fest.
# /app existiert vorher nicht – Docker erzeugt es automatisch.
WORKDIR /app

# Kopiert package.json und package-lock.json in den Container.
# WICHTIG: Das passiert VOR dem Rest des Codes, damit Docker Layers cachen kann.
# Wenn du später nur Code änderst, muss er npm install nicht neu machen.
COPY package.json package-lock.json ./

# Installiert Dependencies (nur im Container, nicht bei dir lokal!).
RUN npm install

# Kopiert den Rest des Projektcodes in den Container nach /app.
# Erst jetzt, damit das Layer‑Caching funktioniert.
COPY . .

# Führt den Vite-Build aus (Baut die App) → erzeugt /app/dist
RUN npm run build



# ---------------------------------------------------
# 2. PRODUCTION-STAGE (Alias: production)
# ---------------------------------------------------

# Minimales, schnelles nginx-Image.
# HIER wird die fertige App ausgeliefert – NICHT mehr gebaut.
# Node ist hier NICHT enthalten → kleiner, sicherer, produktionsfähig.
# Node + 600 MB Dependencies → riesige Angriffsfläche.

FROM nginx:1.25-alpine AS production

# Das ist der wichtigste Schritt für Multi‑Stage Builds.
# Kopiert NUR das fertige Build-Verzeichnis (dist aus Stage 1) aus der builder-Stage
# -> in produktion braucht man kein npm, devDependencies, Quellcode, etc.
# Kopiert also nur die fertigen, statischen Dateien der React-App
# → direkt in den nginx HTML Ordner.
# /usr/share/nginx/html ist das Standard-Webverzeichnis von nginx.
COPY --from=builder /app/dist /usr/share/nginx/html

# Kopiert die eigene nginx-Konfiguration, damit React-Routing funktioniert.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Der Container "öffnet" Port 80 nach außen.
EXPOSE 80

# Startet nginx im Vordergrund (sonst würde der Container sofort stoppen).
# "daemon off;" sorgt dafür, dass nginx im Vordergrund läuft.
# Dies ist der Standardbefehl für das nginx-Image.
CMD ["nginx", "-g", "daemon off;"]
