# Lab 06 – Multi-Stage-Pipeline, Environments und Approval

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Umgebung:** Persönliches Kurskonto mit Projektadministratorrechten; Lab05 ist abgeschlossen. Die Environments `orderflow-staging` und `orderflow-prod` aus Lab03 besitzen Resource None und noch keinen Approval. Du verwaltest beide Environments.

## Ziel und Aufbau

Baut ein Paket einmal und verwendet es im selben Run für Staging und Produktion. Vergleicht einen Lauf ohne Approval mit einem Lauf, dessen Produktionsstage auf Freigabe wartet. Die Deployments sind **Simulationen**: Sie zeigen Paketdateien und lesen die Version. Es werden keine echten Cloudressourcen bereitgestellt.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Release-Pipeline und Ressourcen | 20 Min | Drei Stages, gezielte Autorisierung |
| Lauf ohne Approval | 10 Min | Staging und Produktion automatisch erfolgreich |
| Approval und Autorisierungs-Negativtest | 10 Min | Eigener Approver konfiguriert, Wirkung fehlender Staging-Autorisierung beobachtet |
| Wiederherstellung, Approval und Auswertung | 15 Min | Staging erfolgreich, Produktion wartet und wird genehmigt; Artefaktidentität und History geprüft |

Die Build-/PR-Pipeline `orderflow-ci` bleibt für Branch Validation erhalten. Für dieses Lab legt ihr `orderflow-release` mit der bereits importierten Datei `azure-pipelines.multistage.yml` an. So wartet ein PR-Build nicht auf die Produktionsfreigabe. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

Die Übung verwendet **zwei erfolgreiche vollständige Runs und einen Autorisierungs-Negativversuch**. Der zweite erfolgreiche Run prüft gleichzeitig Wiederherstellung und Approval. In Lab07 besprecht ihr den Unterschied zwischen diesen beiden Mechanismen.

## 1. Multi-Stage-YAML prüfen

1. Öffnet **Repos → Files → orderflow-app → main → azure-pipelines.multistage.yml**.
2. Vergleicht die vorhandene Datei mit dem folgenden Stand. Fehlende Anpassungen erfolgen über Feature-Branch, Commit und PR nach den bestehenden Regeln.

```yaml
name: $(Date:yyyyMMdd).$(Rev:r)

trigger: none

pool:
  vmImage: ubuntu-latest

variables:
  buildConfiguration: Release

stages:
- stage: Build
  jobs:
  - job: VerifyAndPackage
    steps:
    - checkout: self
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
      inputs:
        targetPath: $(Build.ArtifactStagingDirectory)/package
        artifact: orderflow-package

- stage: Deploy_Staging
  displayName: Deploy to staging
  dependsOn: Build
  jobs:
  - deployment: DeployStaging
    environment: orderflow-staging
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: orderflow-package
          - pwsh: |
              Write-Host 'Deploying the promoted package to staging'
              Get-ChildItem -Recurse '$(Pipeline.Workspace)/orderflow-package'
            displayName: Simulate staging deployment

- stage: Deploy_Production
  displayName: Deploy to production
  dependsOn: Deploy_Staging
  condition: succeeded()
  jobs:
  - deployment: DeployProduction
    environment: orderflow-prod
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: orderflow-package
          - pwsh: |
              Write-Host 'Deploying the same promoted package to production'
              Get-Content '$(Pipeline.Workspace)/orderflow-package/version.txt'
            displayName: Simulate production deployment
```

3. Findet in der Datei: `trigger: none`, `Build`, `Deploy_Staging`, `Deploy_Production`, die `dependsOn`-Kette sowie die beiden `deployment:`-Jobs mit ihren `environment:`-Namen.
4. Prüft, dass beide Downloads `current` und `orderflow-package` verwenden. `scripts/build.ps1` darf nur in Build vorkommen.

## 2. Release-Pipeline speichern

1. Öffnet **Pipelines → New pipeline → Azure Repos Git → orderflow-app → Existing Azure Pipelines YAML file**.
2. Wählt **Branch: main**, **Path: /azure-pipelines.multistage.yml**, dann **Continue**.
3. Wählt möglichst **Save** im Run-Dropdown. Benennt die Pipeline anschließend unter **… → Rename/move** in `orderflow-release` um. Falls der Assistent bereits einen Run startet, zählt dieser erst nach vollständig geprüften Ressourcen als Vergleichslauf.
4. Kontrolliere unter **… → Settings** den Pfad `/azure-pipelines.multistage.yml` und den Default Branch `refs/heads/main`. Öffne **… → Manage security**: Setze für **OrderFlow Release Managers** `View builds`, `View build pipeline` und `Queue builds` auf Allow. `Edit build pipeline` und `Administer build permissions` bleiben für diese Fachgruppe Not set.
5. Lasst die Build-Validation-Policy auf `main` weiterhin auf **orderflow-ci** zeigen. Wählt dort nicht die Release-Pipeline aus.

## 3. Environments und Pipeline permissions prüfen

1. Öffne **Pipelines → Environments** in deinem Teilnehmerprojekt. Öffne nacheinander die in Lab03 angelegten Environments `orderflow-staging` und `orderflow-prod`, jeweils **Resource: None**. Kontrolliere den Projektnamen in der Adresszeile.
2. Öffnet jeweils **… → Security → Pipeline permissions**. Entfernt Open access über **Restrict permission**, falls aktiv.
3. Füge über **+** genau **orderflow-release** hinzu. Die Liste war nach Lab03 leer und soll jetzt genau diese Release-Pipeline enthalten. `orderflow-ci` wird für diese beiden Environments nicht autorisiert. Prüfe den gespeicherten Endstand beider Listen.
4. Prüfe **User permissions**: dein Konto **Administrator**, `OrderFlow Release Managers` **Reader**, weitere geerbte Rollen wie in Lab03 geprüft.
5. Öffne bei `orderflow-prod` **Approvals and checks**. Im Erstablauf ist die Liste gemäß Lab03 leer. Führe erst den Vergleichslauf in Abschnitt 4 und danach die Einrichtung in Abschnitt 5 aus. Bei einer Wiederaufnahme nutze den vorhandenen ersten Run in der Run-Liste; entferne einen eingerichteten Approval nicht zur Wiederholung.


## 4. Erster Run ohne Approval

1. Öffnet **Pipelines → orderflow-release → Run pipeline → main → Run**.
2. Prüft den Stage-Verlauf: zuerst **Build**, dann **Deploy_Staging**, dann **Deploy_Production**.
3. Alle drei Stages sollen ohne manuelle Freigabe erfolgreich enden. Falls eine Autorisierungsanforderung erscheint, prüft die Pipeline-Zuordnung aus Schritt 3; ein fehlendes Agentkontingent ist ein gesondertes Queue-Problem.
4. Öffnet **Summary → Artifacts → orderflow-package**. Prüft den zugehörigen Commit sowie `version.txt` und `build-metadata.json`.
5. Öffnet in den Deployment Jobs den Download und den Simulationsstep. Staging listet das Paket auf, Produktion liest dessen Version.
6. Öffnet **Pipelines → Environments → orderflow-staging/orderflow-prod → Deployments**. Folgt dem jeweiligen Eintrag zurück zum gleichen Run.

**Sollzustand:** Ein Build, zwei Downloads aus `current`, kein erneuter Build in Produktion. Die Run-ID und der Artefaktname sind für beide Deployments identisch.

## 5. Produktions-Approval außerhalb von YAML konfigurieren

1. Öffnet **Pipelines → Environments → orderflow-prod → Approvals and checks → + → Approvals**.
2. Wähle im Feld **Approvers** dein persönliches Kurskonto direkt aus; die leere Gruppe `OrderFlow Release Managers` kann die Freigabe nicht übernehmen.
3. Tragt als Prüfanweisung ein: `Commit, Build-Ergebnis, orderflow-package und erfolgreiches Staging prüfen. Danach bewusst freigeben oder ablehnen.`
4. **Trainingsausnahme:** Aktiviere **Allow approvers to approve their own runs**. Im Echtbetrieb prüft eine andere berechtigte Person die Bereitstellung; dort bleibt die Selbstfreigabe ausgeschaltet.
5. Setze **Timeout: 1 hour** bzw. **60 minutes**, entsprechend der im Eingabefeld angezeigten Einheit. Speichere den Check.
6. Öffne den gespeicherten Check erneut und kontrolliere dein direkt benanntes Konto, Prüfanweisung, eingeschaltete Selbstfreigabe und den Timeout von einer Stunde.

Die Approval-Liste wird beim Start der Checks bestimmt. Korrigiere eine falsch eingetragene Identität vor dem nächsten Run. Eine nachträgliche Kontozuordnung wird nicht als automatische Änderung eines bereits wartenden Checks vorausgesetzt.

## 6. Wirkung der Pipeline-Autorisierung prüfen

1. Im erfolgreichen Run aus Abschnitt 4 hat die Staging-Autorisierung funktioniert. Startet dafür keinen weiteren Run.
2. Wartet, bis laufende Tests beendet sind. Prüft unter **Pipelines → Environments → orderflow-staging → … → Security → Pipeline permissions** den Ausgangsstand: ausschließlich `orderflow-release`, kein Open access. Der Production-Approval aus Abschnitt 5 bleibt unverändert.
3. Überlegt zuerst: Was wird beim nächsten Run passieren? Entfernt dann ausschließlich die Pipeline-Zuordnung `orderflow-release` am leeren Trainings-Environment `orderflow-staging`. Startet einen neuen Run auf `main`. Erwartet eine fehlende Ressourcenautorisierung; sie kann bereits bei der Validierung auftreten. Lest die tatsächliche Meldung im Run oder Validierungsdialog. Unterscheidet sie von YAML-, Agent- oder Buildfehlern. Verwendet während des Negativtests kein **Permit**.
4. Vergleicht mündlich eure Erwartung mit der beobachteten Meldung: Welche Ressource ist gesperrt, und was muss wieder freigegeben werden?
5. Beendet einen noch wartenden Negativlauf. Fügt unter denselben **Pipeline permissions → +** genau `orderflow-release` wieder hinzu und prüft den Endstand, auch wenn der Test anders als erwartet verlaufen ist. Benutzerrollen und Production-Check bleiben unverändert; kein Open access. Den erfolgreichen Folgelauf führt ihr genau einmal in Abschnitt 7 aus.

## 7. Wiederherstellung und Approval in einem Run prüfen

1. Startet nach der Wiederherstellung `orderflow-release` einmal manuell auf `main`. Dies ist der zweite erfolgreiche Vergleichslauf dieses Labs.
2. Erwartet: Build erfolgreich, Staging erfolgreich, Produktion **wartet auf Approval**. Die Produktionssteps dürfen noch nicht gelaufen sein.
3. Öffnet **Review** bzw. die ausstehenden Checks im Run. Prüft den Wartezustand vor der Entscheidung.
4. Kontrolliere vor der Freigabe Commit, Run-ID, `orderflow-package`, Konfigurationswert `Release` und erfolgreiches Staging.
5. Wählt bewusst **Approve**. Erwartet, dass Produktion danach dasselbe Paket dieses Runs lädt und erfolgreich endet. Für diese Übung genehmigt ihr den Run; ein zusätzlicher Reject-Versuch gehört nur zur optionalen Vertiefung nach Aufforderung des Trainers.
6. Vergleicht die Deployment-History-Einträge der beiden erfolgreichen Runs. Besprecht: Weshalb kann ein Approval fehlende Pipeline-Autorisierung nicht ersetzen?

## 8. Ergebnis prüfen

- [ ] Beide Deployment Jobs verwenden ihre vorgesehenen Environments und das Paket desselben Runs.
- [ ] Der erste Run durchläuft alle Stages ohne manuelle Freigabe.
- [ ] Nach Entfernen der Staging-Autorisierung fordert der Run Zugriff an oder scheitert an dieser Grenze.
- [ ] Die gezielte Autorisierung ist wiederhergestellt; Open access bleibt aus.
- [ ] Im zweiten erfolgreichen Run wartet Produktion auf Approval und läuft nach deiner Zustimmung weiter.
- [ ] Branch Validation verwendet weiterhin `orderflow-ci`.

## Bonus: Branch Control

**Akteur: du.** Erst nach Abschluss der Pflichtaufgaben öffnen: **Pipelines → Environments → orderflow-prod → Approvals and checks → + → Branch control**. Erlaube ausschließlich `refs/heads/main` und aktiviere die Anforderung eines geschützten Branches. Bei unbekanntem Schutzstatus darf der Check nicht fortfahren. Speichere und prüfe diese Werte.

Starte `orderflow-release` manuell aus deinem bereits vorhandenen Feature-Branch aus Lab05. Erwartet wird ein blockierter Production-Check; lies dessen Meldung, beende den Testlauf und starte danach `main`. Genehmige den eigenen main-Run nach erfolgreichen Checks. Vergleiche die Check-Ergebnisse beider Runs. Eine Sperre durch Branch Control ist keine fehlende Pipeline-Autorisierung.

Bei einem fehlenden Environment-Verwaltungsrecht unterstützt dich der Trainer.

## Portalhilfe

- [Environments und Berechtigungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
- [Deployment Jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs?view=azure-devops)
