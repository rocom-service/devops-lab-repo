# OrderFlow Lab Repository

Dieses kleine Repository dient den Azure-DevOps-Labs für Projektkonfiguration und Pipelines. Es benötigt keine zusätzliche Programmiersprache und läuft mit PowerShell Core auf `ubuntu-latest`.

## Lab-Anleitungen

- [Lab 01 Teil A – DevOps-Gesundheitscheck](labs/Lab01-Teil-A.md)
- [Lab 01 Teil B – Organisation, Projekt und Ressourcen](labs/Lab01-Teil-B.md)
- [Lab 02 – Benutzer, Gruppen und Berechtigungen](labs/Lab02.md)
- [Lab 03 – Ressourcen-Governance-Challenge](labs/Lab03.md)
- [Lab 04 – Erste YAML-Pipeline](labs/Lab04.md)
- [Lab 05 – Pipeline erweitern](labs/Lab05.md)
- [Lab 06 – Multi-Stage, Environments und Approval](labs/Lab06.md)
- [Lab 07 – Troubleshooting Challenge](labs/Lab07.md)

Alle Anleitungen enthalten konkrete Schritte und Ergebnisprüfungen im Portal. Die Azure-DevOps-Übungen bleiben in **ppedv-courses**.

Die [Kursvoraussetzungen](KURSSTART.md), die [Wertstrom-Vorlage](labs/01_Teil_A_DevOps_Gesundheitscheck_Template.svg) und die verlinkte [Musterlösung zu Lab02](solutions/Lab02.md) sind enthalten. Persönliche Zugangsdaten und die Teilnehmerzuordnung stellt der Trainer separat bereit. Die Lab-Dateien werden aus dem vollständigen Kurspaket synchronisiert; ihre relativen Links bleiben innerhalb dieses Repositories.

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
