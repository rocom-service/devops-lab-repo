# OrderFlow Lab Repository

Dieses kleine Repository dient den Azure-DevOps-Labs für Projektkonfiguration und Pipelines. Es benötigt keine zusätzliche Programmiersprache und läuft mit PowerShell Core auf `ubuntu-latest`.

## Lab-Anleitungen

- [Lab 01 – Organisation, Projekt und Ressourcen](labs/Lab01-Teil-B.md): Teil A und Teil B der aktuellen Anleitung; der bisherige Dateiname bleibt für bestehende Verweise erhalten.

- [Lab 02 – Benutzer, Gruppen und Berechtigungen](labs/Lab02.md)
- [Lab 03 – Ressourcen-Governance-Challenge](labs/Lab03.md)
- [Lab 04 – Erste YAML-Pipeline](labs/Lab04.md)
- [Lab 05 – Pipeline erweitern](labs/Lab05.md)
- [Lab 06 – Multi-Stage, Environments und Approval](labs/Lab06.md)
- [Lab 07 – Troubleshooting Challenge](labs/Lab07.md)

Alle Anleitungen enthalten konkrete Schritte, Sollwerte und Prüfnachweise. Die Azure-DevOps-Übungen bleiben in **ppedv-courses**.

Diese lokalen Kopien werden aus den maßgeblichen Anweisungen im vollständigen Kurspaket `devops-2/labs/` synchronisiert. Voraussetzungen, Teilnehmerzuordnung und Arbeitsvorlagen liest du im separat bereitgestellten Kurspaket. Relative Verweise auf diese Begleitdateien funktionieren in dessen lokaler Ordnerstruktur; ein Import dieses Repositories allein enthält sie nicht. Ältere online veröffentlichte Anleitungen ersetzen nicht die aktuelle Kursfassung.

## Dateien

- `src/version.txt` – zu prüfende Produktversion
- `src/release-notes.txt` – Beispielinhalt für das Paket
- `scripts/test.ps1` – prüft das Versionsformat und verbotene Platzhalter
- `scripts/build.ps1` – erzeugt ein kleines auslieferbares Paket
- `azure-pipelines.start.yml` – Startpunkt für Lab 04
- `azure-pipelines.solution.yml` – Referenz für Lab 05
- `azure-pipelines.multistage.yml` – Referenz für Lab 06
- `templates/` – Step-, Job-, Stage- und Extends-Templates mit [YAML-Beispielen zur Einbindung](templates/README.md)
- `broken/` – absichtlich fehlerhafte Fälle für Lab 07

## Import

Den Inhalt dieses Verzeichnisses als Wurzel des Azure-Repos `orderflow-app` importieren oder initial committen.
