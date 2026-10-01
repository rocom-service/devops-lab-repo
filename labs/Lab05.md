# Lab 05 – Pipeline schrittweise erweitern

**Dauer:** 70 Minuten · **Arbeitsform:** Einzelarbeit mit kurzen Prüfschritten  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** `orderflow-ci` aus [Lab 04](Lab04.md) verwendet `/azure-pipelines.yml` in `orderflow-app`.

## Ziel und Ablauf

Erweitert den Startstand zu einer Pipeline mit CI-Trigger, Konfigurationsvariable, Quellprüfung, Paketierung und herunterladbarem Artefakt. Führt nach jedem größeren Änderungsschritt einen Run aus. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Trigger, Variable, Test | 25 Min | CI startet und prüft den Quellstand |
| Paket und Artefakt | 20 Min | orderflow-package mit drei Dateien |
| Negativtest und PR-Validierung | 25 Min | Fehler belegt, korrigierter Stand grün |

## 1. Feature-Branch und aktive Datei prüfen

1. Öffnet **Repos → Files → orderflow-app → main**. Prüft, dass `scripts/test.ps1`, `scripts/build.ps1` und die beiden Dateien unter `src/` vorhanden sind.
2. Erstellt `feature/lab05-<kuerzel>` aus `main`.
3. Öffnet `azure-pipelines.yml → Edit`. Die Datei `azure-pipelines.solution.yml` ist eine Referenz; Änderungen ausschließlich an dieser Referenz würden die aktive Pipeline nicht erweitern.
4. Notiert den aktuell gültigen Inhalt von `src/version.txt`, damit ihr ihn nach dem Negativtest exakt wiederherstellen könnt.

## 2. CI-Trigger und Variable ergänzen

1. Ersetzt `trigger: none` durch den folgenden Block. Behaltet den vorhandenen `pool` bei.

   ```yaml
   trigger:
     branches:
       include:
       - main
       - feature/*
     paths:
       include:
       - src/*
       - scripts/*
       - azure-pipelines.yml
   ```

2. Ersetzt den bisherigen Variablenblock durch:

   ```yaml
   variables:
     buildConfiguration: Release
   ```

3. Entfernt den bisherigen Begrüßungstask und setzt nach `checkout: self` einen Step zur Ausgabe ein:

   ```yaml
   - pwsh: Write-Host "Configuration = $(buildConfiguration)"
     displayName: Show configuration
   ```

4. Committet auf dem Feature-Branch. Öffnet **Pipelines → orderflow-ci → Runs** und prüft, ob ein CI-Run für diesen Commit gestartet ist. Falls nicht, kontrolliert Branchname, aktiven YAML-Pfad und deaktivierte/überschriebene Trigger unter den Pipeline-Einstellungen. Ein manueller Run prüft den Code, aber nicht den CI-Trigger.
5. Öffnet den Run und belegt `Configuration = Release`. Gebt keine geheimen Variablen aus.

## 3. Quellprüfung hinzufügen

1. Ergänzt hinter der Konfigurationsausgabe:

   ```yaml
   - task: PowerShell@2
     displayName: Validate source
     inputs:
       filePath: scripts/test.ps1
       pwsh: true
   ```

2. Committet und prüft den neuen Run. Im Tasklog muss `Validation successful for version …` erscheinen.
3. Öffnet `scripts/test.ps1` und erklärt die Prüfungen: drei numerische Versionsbestandteile, vorhandene Release Notes und keine Platzhalter `TODO`, `CHANGEME` oder `SECRET` darin. Das Skript bildet nicht die gesamte SemVer-Spezifikation ab.

## 4. Paket erstellen und veröffentlichen

1. Ergänzt nach dem erfolgreichen Test den Buildtask und die Veröffentlichung:

   ```yaml
   - task: PowerShell@2
     displayName: Create package
     inputs:
       filePath: scripts/build.ps1
       arguments: >
         -OutputPath "$(Build.ArtifactStagingDirectory)/package"
         -Configuration "$(buildConfiguration)"
       pwsh: true
   - task: PublishPipelineArtifact@1
     displayName: Publish orderflow package
     condition: succeeded()
     inputs:
       targetPath: $(Build.ArtifactStagingDirectory)/package
       artifact: orderflow-package
   ```

2. Committet und wartet auf einen erfolgreichen Run.
3. Öffnet dessen **Summary → Artifacts** beziehungsweise **Published** und dann `orderflow-package`.
4. Prüft die Dateien `version.txt`, `release-notes.txt` und `build-metadata.json`. Ladet das Artefakt bei Bedarf herunter. In den Metadaten muss `configuration` den Wert `Release` enthalten.
5. Die explizite Bedingung `succeeded()` verhindert Veröffentlichung nach einem fehlgeschlagenen Vorgängerschritt. Ersetzt sie nicht durch einen isolierten Branchvergleich.

### Vollständiger Kernstand zum Abgleich

Nach den einzelnen Prüfschritten könnt ihr die Steps wie folgt in einen expliziten Job und eine Build-Stage einordnen. Validiert und committet diesen Stand ebenfalls. Die Datei aus dem Repository [`azure-pipelines.solution.yml`](../azure-pipelines.solution.yml) enthält die Basis; hier sind zusätzlich die sichtbare Konfigurationsausgabe und Veröffentlichungsbedingung enthalten.

```yaml
name: $(Date:yyyyMMdd).$(Rev:r)

trigger:
  branches:
    include:
    - main
    - feature/*
  paths:
    include:
    - src/*
    - scripts/*
    - azure-pipelines.yml

pool:
  vmImage: ubuntu-latest

variables:
  buildConfiguration: Release

stages:
- stage: Build
  displayName: Test and package
  jobs:
  - job: VerifyAndPackage
    displayName: Verify and package
    steps:
    - checkout: self
    - pwsh: |
        Write-Host "Build configuration: $env:BUILD_CONFIGURATION"
      displayName: Show build configuration
      env:
        BUILD_CONFIGURATION: $(buildConfiguration)
    - task: PowerShell@2
      displayName: Validate source
      inputs:
        filePath: scripts/test.ps1
        pwsh: true
    - task: PowerShell@2
      displayName: Create package
      inputs:
        filePath: scripts/build.ps1
        arguments: >
          -OutputPath "$(Build.ArtifactStagingDirectory)/package"
          -Configuration "$(buildConfiguration)"
        pwsh: true
    - task: PublishPipelineArtifact@1
      displayName: Publish orderflow package
      condition: succeeded()
      inputs:
        targetPath: $(Build.ArtifactStagingDirectory)/package
        artifact: orderflow-package
```

## 5. Fehler gezielt auf dem Feature-Branch erzeugen

1. Bleibt auf `feature/lab05-<kuerzel>` und ändert `src/version.txt` vorübergehend auf `ungueltig`.
2. Committet. Öffnet den automatisch gestarteten Run und den fehlgeschlagenen Task **Validate source**.
3. Notiert die erste aussagekräftige Fehlermeldung, den Commit und die Run-ID. Erwartet einen Hinweis auf das ungültige Versionsformat. Build und Veröffentlichung sollen nicht erfolgreich ausgeführt werden.
4. Stellt die zuvor notierte gültige Version wieder her und committet die Korrektur.
5. Öffnet den neuen Run: Test, Paketierung und Veröffentlichung müssen wieder erfolgreich sein.
6. Übernehmt den ungültigen Stand nicht nach `main`. Für die Abnahme zählt auch der bewusst fehlgeschlagene Run als Diagnosebeleg, aber nicht als fertiger Lieferstand.

## 6. PR-Build-Validation und Pfadfilter nachweisen

1. Öffnet **Repos → Branches → main → … → Branch policies → Build Validation**.
2. Erstellt oder prüft den Eintrag **orderflow-ci**, **Automatic**, **Required**, leerer Path filter. Kein doppelter Eintrag für dieselbe Pipeline.
3. Erstellt nach dem erfolgreichen Reparaturlauf einen PR vom Feature-Branch nach `main`. Die Branch Policy muss einen Validierungsbuild starten. Belegt den verlinkten Build im PR.
4. Lasst den korrigierten Stand unabhängig reviewen und führt den PR nach grünen Policies zusammen.
5. Für den CI-Pfadfilter erstellt einen separaten Branch `feature/lab05-docs-<kuerzel>` aus dem nun aktualisierten `main`. Ändert nur `README.md`, committet und erstellt zunächst keinen PR. Erwartet keinen **CI**-Run für diesen Commit. Belegt Commit und Run-Liste nach Aktualisierung; andere Run-Gründe separat prüfen.
6. Ändert danach auf diesem Branch einen sinnvollen Text in `src/release-notes.txt`, ohne verbotene Platzhalter. Jetzt muss CI starten. Der reine Dokumentationstest darf nicht mit einer ausgelösten PR-Policy verwechselt werden.

Azure Repos Git startet PR-Validierung durch die Branch Policy. Ergänzt dafür keinen YAML-`pr:`-Trigger.

## 7. Abnahme

| Test | Erwartung | Tatsächliches Ergebnis | Commit/Run/Beleg |
|---|---|---|---|
| Gültige Quelle | Test, Build und Artefakt erfolgreich | | |
| Ungültige Version | Test schlägt fehl, kein neues veröffentlichtes Paket | | |
| Korrigierte Version | Neuer Run grün | | |
| Änderung unter src/ | CI startet | | |
| Nur README, kein PR | Kein CI-Start durch diesen Trigger | | |
| PR nach main | Branch Policy startet Validierung | | |

- [ ] `orderflow-ci` verwendet die erweiterte aktive YAML-Datei.
- [ ] `orderflow-package` enthält Version, Release Notes und Metadaten.
- [ ] Fehlgeschlagener und korrigierter Run sind nachvollziehbar belegt.
- [ ] PR-Validierung und CI-Pfadfilter wurden getrennt geprüft.

## Bonus A – Schritte als Template

1. Vergleicht [`templates/build-steps.yml`](../templates/build-steps.yml) mit euren Test-/Buildtasks.
2. Ersetzt diese beiden Tasks im Hauptjob durch:

   ```yaml
   - template: templates/build-steps.yml
     parameters:
       configuration: $(buildConfiguration)
   ```

3. Lasst Checkout, Konfigurationsausgabe und Veröffentlichung in der Hauptpipeline. Fügt `templates/*` zum CI-Pfadfilter hinzu.
4. Committet, prüft den grünen Run und anschließend einen CI-Run nach einer Templateänderung. Erklärt `${{ parameters.configuration }}` bei der Template-Expansion gegenüber dem späteren Makro `$(buildConfiguration)`.

**Bonus B:** Erklärt anhand des Negativtests, warum `condition: succeeded()` sinnvoll ist und ein reiner Branchvergleich den vorherigen Fehler nicht automatisch berücksichtigt.

## Portalhilfe

- [Branch Policies und Build Validation](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
- [Pipelinebedingungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions?view=azure-devops)
- [Pipeline-Artefakte](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops)
