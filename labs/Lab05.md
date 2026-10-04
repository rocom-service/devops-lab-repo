# Lab 05 – Pipeline schrittweise erweitern

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/05_Pipeline_Erweitern.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 70 Minuten · **Arbeitsform:** Einzelarbeit mit kurzen Prüfschritten  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Akteur:** du mit deinem persönlichen Basic-Kurskonto im Teilnehmerprojekt aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md), weiterhin Project Administrator. **Voraussetzung:** [Lab04](Lab04.md) abgeschlossen: `orderflow-ci` nutzt `/azure-pipelines.yml` in `orderflow-app/main`, der Startlauf ist erfolgreich und Build Validation ist Required/Automatic. Pool **Azure Pipelines**, Image **ubuntu-latest**; ein gemeinsamer Paralleljob, deshalb wartende Runs nicht doppelt starten.

## Ziel und Ablauf

Erweitert den Startstand zu einer Pipeline mit CI-Trigger, Konfigurationsvariable, Quellprüfung, Paketierung und herunterladbarem Artefakt. Erarbeitet die Abschnitte 2–4 in einem Editorvorgang und committet den vollständigen Aufbau einmal. Prüft danach die einzelnen Steps im selben Run. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Trigger, Variable, Test und Paketierung aufbauen | 25 Min | Vollständige YAML mit Stage und Job, ein gemeinsamer Commit |
| Ersten CI-Run und Artefakt prüfen | 20 Min | Konfiguration, Quellprüfung und orderflow-package mit drei Dateien belegt |
| Negativtest und PR-Validierung | 25 Min | Fehler belegt, korrigierter Stand grün |

## 1. Feature-Branch und aktive Datei prüfen

1. Öffnet **Repos → Files → orderflow-app → main**. Prüft, dass `scripts/test.ps1`, `scripts/build.ps1` und die beiden Dateien unter `src/` vorhanden sind.
2. Erstellt `feature/lab05-<kuerzel>` aus `main`.
3. Öffnet `azure-pipelines.yml → Edit`. Verwendet von Anfang an die Stage `Build`, den Job `VerifyAndPackage` und dessen Step-Liste aus dem vollständigen Kernstand in Abschnitt 4. Erarbeitet die folgenden Änderungen innerhalb dieser Struktur. Die Datei `azure-pipelines.solution.yml` ist eine Referenz; Änderungen ausschließlich an dieser Referenz würden die aktive Pipeline nicht erweitern.
4. Notiere den aktuellen Inhalt von `src/version.txt` für die Wiederherstellung. Im unveränderten Starter aus Lab01 lautet er `1.0.0`.

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

2. Vergleicht die gesamte Datei mit dem folgenden Kernstand einschließlich Stage und Job. Committet den Aufbau aus Abschnitten 2–4 einmal auf dem Feature-Branch. Öffnet **Pipelines → orderflow-ci → Runs** und prüft den automatisch gestarteten CI-Run für diesen Commit. Falls er fehlt, kontrolliert Branchname, aktiven YAML-Pfad und deaktivierte/überschriebene Trigger unter den Pipeline-Einstellungen. Ein manueller Run ersetzt keinen CI-Nachweis. Wartet auf den erfolgreichen Run und belegt darin `Build configuration: Release`, `Validation successful for version …` sowie die erfolgreiche Paketierung und Veröffentlichung.
3. Öffnet dessen **Summary → Artifacts** beziehungsweise **Published** und dann `orderflow-package`.
4. Prüfe die Dateien `version.txt`, `release-notes.txt` und `build-metadata.json`. Wähle im Artefaktmenü **Download artifacts**, entpacke das heruntergeladene Archiv und öffne `build-metadata.json` in einem Texteditor. `configuration` muss `Release` enthalten; `builtAtUtc` muss einen Zeitstempel enthalten. Speichere Dateiliste und die beiden gelesenen Werte mit der Run-ID im Protokoll.
5. Liefert der Browser während des Downloads tatsächlich keine lesbare Datei, ergänze vor der Veröffentlichung einen PowerShell-Step, der `$(Build.ArtifactStagingDirectory)/package/build-metadata.json` mit `Get-Content -Raw` liest und ausgibt. Committe, warte auf den neuen Run und sichere dessen Log als Metadatenbeleg. Notiere ausdrücklich, dass dieser Nachweis zum neuen Run gehört.
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
2. Öffnet den automatisch gestarteten Run: **Validate source** muss am Versionsformat scheitern; es darf kein Paket veröffentlicht werden. Notiert Fehlermeldung, Commit und Run-ID.
3. Stellt die vorherige gültige Version wieder her und committet erneut. Prüft, dass Test, Paketierung und Veröffentlichung wieder erfolgreich sind. Erst den korrigierten Stand nach `main` übernehmen.

## 6. PR-Build-Validation und Pfadfilter nachweisen

1. Öffnet **Repos → Branches → main → … → Branch policies → Build Validation**.
2. Erstellt oder prüft den Eintrag **orderflow-ci**, **Automatic**, **Required**, leerer Path filter. Kein doppelter Eintrag für dieselbe Pipeline.
3. Erstellt nach dem erfolgreichen Reparaturlauf einen PR vom Feature-Branch nach `main`. Die Branch Policy muss einen Validierungsbuild starten. Belegt den verlinkten Build im PR.
4. **Trainingsausnahme aus Lab03:** Prüfe den eigenen korrigierten PR und genehmige ihn mit **Approve**. Die gespeicherten Werte sind: Mindestanzahl **1**, **Allow requestors to approve their own changes: Ein**, **Prohibit the most recent pusher from approving their own changes: Aus**. Build Validation, Kommentarauflösung und Zurücksetzen der Zustimmungen bei neuen Änderungen bleiben bestehen; führt den PR erst nach grünen Pflichtprüfungen zusammen. Die Ausnahme gilt für alle PRs nach `main` im eigenen Trainingsprojekt. **Im Echtbetrieb prüft und genehmigt eine andere berechtigte Person die Änderung nach dem Vier-Augen-Prinzip:** Selbstfreigabe aus, Ausschluss der zuletzt pushenden Person ein.
5. Für den CI-Pfadfilter erstellt einen separaten Branch `feature/lab05-docs-<kuerzel>` aus dem nun aktualisierten `main`. Ändert nur `README.md`, committet und erstellt zunächst keinen PR. Erwartet keinen **CI**-Run für diesen Commit. Belegt Commit und Run-Liste nach Aktualisierung; andere Run-Gründe separat prüfen.
6. Verwendet für den positiven Pfadfiltertest die bereits vorhandenen Versionsänderungen aus Abschnitt 5 auf `feature/lab05-<kuerzel>`. Belegt im Commit-Diff, dass jeweils nur `src/version.txt` geändert wurde, und ordnet den automatisch gestarteten CI-Run dem Commit zu. Der fehlerhafte und der reparierte Run zeigen beide den Trigger; der Reparaturlauf belegt zusätzlich den erfolgreichen Abschluss. Ein zusätzlicher Quelltext-Commit ist nicht nötig. Der reine Dokumentationstest darf nicht mit einer ausgelösten PR-Policy verwechselt werden.

**Run-Abfolge ohne Bonus oder Reparatur eines unerwarteten Fehlers:** ein gemeinsamer Aufbau-Run, ein absichtlicher Fehler-Run, ein Reparatur-Run und ein PR-Validierungsbuild. Nach dem Merge startet außerdem der konfigurierte main-CI-Run; lasst ihn regulär abschließen. Der README-Test erzeugt keinen CI-Run. Startet keine zusätzlichen manuellen Kontrollläufe für bereits vorhandene Nachweise.

Azure Repos Git startet PR-Validierung durch die Branch Policy. Ergänzt dafür keinen YAML-`pr:`-Trigger.

## 7. Abnahme

Ablage: `lab05-durchfuehrung`. Sichere YAML-/Triggerstand, Variablenausgabe, Fehler- und Reparaturlog, Artefaktdateiliste mit Metadaten, PR-Validierung, Merge und beide Pfadfiltertests. Alle Nachweise stammen aus deinem Teilnehmerprojekt und nennen deinen jeweiligen Commit bzw. Run.

| Test | Erwartung | Tatsächliches Ergebnis | Commit/Run/Beleg |
|---|---|---|---|
| Gültige Quelle | Test, Build und Artefakt erfolgreich | | |
| Ungültige Version | Test schlägt fehl, kein neues veröffentlichtes Paket | | |
| Korrigierte Version | Neuer Run grün | | |
| Änderung nur an src/version.txt aus Abschnitt 5 | CI startet; vorhandenen Fehler-/Reparatur-Run verwenden | | |
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
