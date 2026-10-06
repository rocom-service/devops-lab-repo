# Lab 05 – Pipeline schrittweise erweitern

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 70 Minuten · **Arbeitsform:** Einzelarbeit mit kurzen Prüfschritten  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Umgebung:** Persönliches Kurskonto im zugeordneten Projekt; Lab04 ist abgeschlossen. `orderflow-ci` verwendet `/azure-pipelines.yml` und der Startlauf ist erfolgreich. Ein gemeinsamer Microsoft-hosted Paralleljob: wartende Runs weiterverwenden.

## Ziel und Ablauf

Erweitert den Startstand zu einer Pipeline mit CI-Trigger, Konfigurationsvariable, Quellprüfung, Paketierung und herunterladbarem Artefakt. Erarbeitet die Abschnitte 2–4 in einem Editorvorgang und committet den vollständigen Aufbau einmal. Prüft danach die einzelnen Steps im selben Run. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Trigger, Variable, Test und Paketierung aufbauen | 25 Min | Vollständige YAML mit Stage und Job, ein gemeinsamer Commit |
| Ersten CI-Run und Artefakt prüfen | 20 Min | Konfiguration, Quellprüfung und Paketinhalt geprüft |
| Negativtest, Merge und CI-Pfadfilter | 25 Min | Fehler behoben, geprüfter Stand übernommen und Pfadfilter geprüft |

## 1. Feature-Branch und aktive Datei prüfen

1. Öffnet **Repos → Files → orderflow-app → main**. Prüft, dass `scripts/test.ps1`, `scripts/build.ps1` und die beiden Dateien unter `src/` vorhanden sind.
2. Erstellt `feature/lab05-<kuerzel>` aus `main`.
3. Öffnet `azure-pipelines.yml → Edit`. Verwendet von Anfang an die Stage `Build`, den Job `VerifyAndPackage` und dessen Step-Liste aus dem vollständigen Kernstand in Abschnitt 4. Erarbeitet die folgenden Änderungen innerhalb dieser Struktur. Die Datei `azure-pipelines.solution.yml` ist eine Referenz; Änderungen ausschließlich an dieser Referenz würden die aktive Pipeline nicht erweitern.
4. Prüfe den aktuellen Inhalt von `src/version.txt`. Für die spätere Wiederherstellung kannst du ihn über die Dateihistorie erneut öffnen; im unveränderten Starter lautet er `1.0.0`.

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
   - pwsh: |
       Write-Host "Build configuration: $env:BUILD_CONFIGURATION"
     displayName: Show build configuration
     env:
       BUILD_CONFIGURATION: $(buildConfiguration)
   ```

4. Lasst den Editor geöffnet und ergänzt Abschnitte 3 und 4 vor dem gemeinsamen Commit. Ordnet alle gezeigten Step-Ausschnitte unter `stages → jobs → steps` ein; die vollständige Einrückung zeigt der Kernstand in Abschnitt 4. Gebt keine geheimen Variablen aus.

## 3. Quellprüfung hinzufügen

1. Ergänzt hinter der Konfigurationsausgabe:

   ```yaml
   - task: PowerShell@2
     displayName: Validate source
     inputs:
       filePath: scripts/test.ps1
       pwsh: true
   ```

2. Lest `scripts/test.ps1` in einem zweiten Tab, ohne den ungespeicherten YAML-Editor zu verlassen, und erklärt die Prüfungen: drei numerische Versionsbestandteile, vorhandene Release Notes und keine Platzhalter `TODO`, `CHANGEME` oder `SECRET` darin. Das Skript bildet nicht die gesamte SemVer-Spezifikation ab. Den Task prüft ihr im gemeinsamen Run nach Abschnitt 4.

## 4. Paket erstellen und veröffentlichen

1. Ergänzt hinter dem Testtask den Buildtask und die Veröffentlichung:

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

2. Vergleicht die gesamte Datei mit dem folgenden Kernstand einschließlich Stage und Job. Committet den Aufbau aus Abschnitten 2–4 einmal auf dem Feature-Branch. Öffnet **Pipelines → orderflow-ci → Runs** und prüft den automatisch gestarteten CI-Run für diesen Commit. Falls er fehlt, kontrolliert Branchname, aktiven YAML-Pfad und deaktivierte/überschriebene Trigger unter den Pipeline-Einstellungen. Ein manueller Run ersetzt keinen CI-Nachweis. Wartet auf den erfolgreichen Run und prüft darin `Build configuration: Release`, `Validation successful for version …` sowie die erfolgreiche Paketierung und Veröffentlichung.
3. Öffnet dessen **Summary → Artifacts** beziehungsweise **Published** und dann `orderflow-package`.
4. Prüfe die Dateien `version.txt`, `release-notes.txt` und `build-metadata.json`. Wähle im Artefaktmenü **Download artifacts**, entpacke das heruntergeladene Archiv und öffne `build-metadata.json` in einem Texteditor. `configuration` muss `Release` enthalten; `builtAtUtc` muss einen Zeitstempel enthalten. Vergleiche die Dateiliste und die Werte mit dem erwarteten Ergebnis.
5. Falls sich das Artefakt nicht herunterladen oder öffnen lässt, bitte den Trainer um Unterstützung.

6. Die explizite Bedingung `succeeded()` verhindert Veröffentlichung nach einem fehlgeschlagenen Vorgängerschritt. Ersetzt sie nicht durch einen isolierten Branchvergleich.

### Vollständiger Kernstand zum Abgleich

Dieser vollständige Stand ist das Ziel des ersten gemeinsamen Commits aus Abschnitten 2–4. Stage und Job gehören bereits zum ersten Aufbau; ein späterer Strukturumbau mit zusätzlichem Run entfällt. Die Datei aus dem Repository [`azure-pipelines.solution.yml`](../azure-pipelines.solution.yml) enthält die Basis; hier sind zusätzlich die sichtbare Konfigurationsausgabe und Veröffentlichungsbedingung enthalten.

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

1. Ersetzt auf eurem Branch `feature/lab05-<kuerzel>` den Inhalt von `src/version.txt` durch `ungueltig` (ohne Anführungszeichen) und committet.
2. Öffnet den automatisch gestarteten Run: **Validate source** muss am Versionsformat scheitern; es darf kein Paket veröffentlicht werden. Lest die Fehlermeldung und prüft den zugehörigen Commit.
3. Stellt die vorherige gültige Version wieder her und committet erneut. Prüft, dass Test, Paketierung und Veröffentlichung wieder erfolgreich sind. Erst den korrigierten Stand nach `main` übernehmen.

## 6. Geprüften Stand übernehmen und CI-Pfadfilter prüfen

1. Prüft den erfolgreichen Reparaturlauf aus Abschnitt 5 und vergleicht dessen Commit mit dem aktuellen Stand von `feature/lab05-<kuerzel>`. Test, Paketierung und Veröffentlichung müssen für diesen Stand erfolgreich sein.
2. Erstellt einen PR vom Feature-Branch nach `main`. Prüft die Änderungen und führt ihn unter Beachtung der geltenden Reviewer- und Kommentarregeln regulär zusammen. Kontrolliert vor dem Merge selbst den erfolgreichen CI-Lauf für den aktuellen Commit; verwendet keinen Policy-Bypass.
3. Öffnet den nach dem Merge automatisch gestarteten CI-Run auf `main` und prüft dessen erfolgreichen Abschluss.

4. Für den CI-Pfadfilter erstellt einen separaten Branch `feature/lab05-docs-<kuerzel>` aus dem nun aktualisierten `main`. Ändert nur `README.md`, committet und erstellt keinen PR. Erwartet keinen **CI**-Run für diesen Commit. Prüft Commit und Run-Liste nach Aktualisierung; andere Run-Gründe separat prüfen.
5. Verwendet für den positiven Pfadfiltertest die bereits vorhandenen Versionsänderungen aus Abschnitt 5 auf `feature/lab05-<kuerzel>`. Prüft im Commit-Diff, dass jeweils nur `src/version.txt` geändert wurde, und ordnet den automatisch gestarteten CI-Run dem Commit zu. Der fehlerhafte und der reparierte Run zeigen beide den Trigger; der Reparaturlauf zeigt zusätzlich den erfolgreichen Abschluss. Ein zusätzlicher Quelltext-Commit ist nicht nötig.

**Run-Abfolge ohne Bonus oder Reparatur eines unerwarteten Fehlers:** vier CI-Runs – ein gemeinsamer Aufbau-Run, ein absichtlicher Fehler-Run, ein Reparatur-Run und der main-CI-Run nach dem Merge. Der README-Test erzeugt keinen CI-Run. Startet keine zusätzlichen manuellen Kontrollläufe für bereits geprüfte Ergebnisse.

## 7. Ergebnis prüfen

Gehe die vorhandenen Runs und den PR direkt im Portal durch:

- [ ] Die gültige Quelle führt zu erfolgreichen Tests und `orderflow-package` mit drei Dateien.
- [ ] Die ungültige Version lässt den Test scheitern; es wird kein neues Paket veröffentlicht.
- [ ] Nach Wiederherstellung der Version ist der Run wieder erfolgreich.
- [ ] Die Änderungen an `src/version.txt` starten CI; die reine README-Änderung ohne PR startet keinen CI-Run.
- [ ] Vor dem Merge wurde der erfolgreiche CI-Lauf für den aktuellen Feature-Branch-Commit geprüft; der anschließende main-CI-Run ist erfolgreich.

Besprecht kurz: Warum startet eine Versionsänderung einen CI-Run, eine reine README-Änderung dagegen nicht?

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

- [Azure Repos Git und CI-Trigger](https://learn.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops)
- [Pipelinebedingungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions?view=azure-devops)
- [Pipeline-Artefakte](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops)
