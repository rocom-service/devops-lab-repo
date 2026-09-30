# OrderFlow Lab Repository

Dieses kleine Repository dient ausschließlich den Pipeline-Labs. Es benötigt keine zusätzliche Programmiersprache und läuft mit PowerShell Core auf `ubuntu-latest`.

## Dateien

- `src/version.txt` – zu prüfende Produktversion
- `src/release-notes.txt` – Beispielinhalt für das Paket
- `scripts/test.ps1` – prüft das Versionsformat und verbotene Platzhalter
- `scripts/build.ps1` – erzeugt ein kleines auslieferbares Paket
- `azure-pipelines.start.yml` – Startpunkt für Lab 04
- `azure-pipelines.solution.yml` – Referenz für Lab 05
- `azure-pipelines.multistage.yml` – Referenz für Lab 06
- `templates/build-steps.yml` – Bonuslösung für Wiederverwendung
- `broken/` – absichtlich fehlerhafte Fälle für Lab 07

## Import

Den Inhalt dieses Verzeichnisses als Wurzel des Azure-Repos `orderflow-app` importieren oder initial committen.

