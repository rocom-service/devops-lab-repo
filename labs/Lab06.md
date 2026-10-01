# Lab 06 – Multi-Stage-Pipeline, Environments und Approval

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Erfolgreicher Build aus [Lab 05](Lab05.md), Environment-Konfiguration aus [Lab 03](Lab03.md), vorbereitete Freigabeidentität.

## Ziel und Aufbau

Baut ein Paket einmal und verwendet es im selben Run für Staging und Produktion. Vergleicht einen Lauf ohne Approval mit einem Lauf, dessen Produktionsstage auf Freigabe wartet. Die Deployments sind **Simulationen**: Sie zeigen Paketdateien und lesen die Version. Es werden keine echten Cloudressourcen bereitgestellt.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Release-Pipeline und Ressourcen | 20 Min | Drei Stages, gezielte Autorisierung |
| Lauf ohne Approval | 10 Min | Staging und Produktion automatisch erfolgreich |
| Approval und zweiter Lauf | 15 Min | Produktion wartet und wird bewusst freigegeben/abgelehnt |
| Nachweise | 10 Min | Artefaktidentität und Deployment History |

Die Build-/PR-Pipeline `orderflow-ci` bleibt für Branch Validation erhalten. Für dieses Lab legt ihr `orderflow-release` mit der bereits importierten Datei `azure-pipelines.multistage.yml` an. So wartet ein PR-Build nicht auf die Produktionsfreigabe. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

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

3. Markiert in der Datei: `trigger: none`, `Build`, `Deploy_Staging`, `Deploy_Production`, die `dependsOn`-Kette sowie die beiden `deployment:`-Jobs mit ihren `environment:`-Namen.
4. Prüft, dass beide Downloads `current` und `orderflow-package` verwenden. `scripts/build.ps1` darf nur in Build vorkommen.

## 2. Release-Pipeline speichern

1. Öffnet **Pipelines → New pipeline → Azure Repos Git → orderflow-app → Existing Azure Pipelines YAML file**.
2. Wählt **Branch: main**, **Path: /azure-pipelines.multistage.yml**, dann **Continue**.
3. Wählt möglichst **Save** im Run-Dropdown. Benennt die Pipeline anschließend unter **… → Rename/move** in `orderflow-release` um. Falls der Assistent bereits einen Run startet, zählt dieser erst nach vollständig geprüften Ressourcen als Vergleichslauf.
4. Kontrolliert den Dateipfad unter **… → Settings** und die Security der neuen Pipeline. Release Manager benötigen für die Prüfung mindestens View builds/View build pipeline; Queue builds nur, wenn sie selbst Läufe starten sollen. Portaladministration bleibt beim benannten Kreis.
5. Lasst die Build-Validation-Policy auf `main` weiterhin auf **orderflow-ci** zeigen. Wählt dort nicht die Release-Pipeline aus.

## 3. Environments und Pipeline permissions prüfen

1. Öffnet **Pipelines → Environments**. Prüft `orderflow-staging` und `orderflow-prod`; legt fehlende Trainings-Environments mit **Resource: None** an.
2. Öffnet jeweils **… → Security → Pipeline permissions**. Entfernt Open access über **Restrict permission**, falls aktiv.
3. Fügt über **+** genau **orderflow-release** hinzu. Falls `orderflow-ci` in einem vorherigen Übungsschritt vorübergehend autorisiert wurde, entfernt dessen Zuordnung für diese Deployment-Ressourcen, sofern keine weitere Kursaufgabe sie braucht. Notiert den Endstand.
4. Prüft **User permissions** einschließlich Vererbung: Ressourcenverantwortliche verwalten die Konfiguration; `OrderFlow Release Managers` erhält für die reine Freigabe **Reader**. Breite User-/Adminrollen dürfen die Check-Verwaltung nicht unbeabsichtigt öffnen.
5. Öffnet bei `orderflow-prod` **Approvals and checks**. Der erste Vergleichslauf setzt voraus, dass dort noch kein Approval eingerichtet ist. Entfernt keine bestehenden Schutzregeln einer gemeinsam genutzten Ressource. Falls das vorbereitete Trainings-Environment bereits Checks besitzt, verwendet mit dem Trainer ein separates leeres Vergleichs-Environment und passt dessen Namen in eurer Trainingsdatei an; dokumentiert diese Abweichung.

**Nachweis:** Beide Ressourcennamen, Benutzerrollen, Vererbung und Liste der autorisierten Pipelines. Approval-Zustand vor dem ersten Run.

## 4. Erster Run ohne Approval

1. Öffnet **Pipelines → orderflow-release → Run pipeline → main → Run**.
2. Prüft den Stage-Verlauf: zuerst **Build**, dann **Deploy_Staging**, dann **Deploy_Production**.
3. Alle drei Stages sollen ohne manuelle Freigabe erfolgreich enden. Falls eine Autorisierungsanforderung erscheint, prüft die Pipeline-Zuordnung aus Schritt 3; ein fehlendes Agentkontingent ist ein gesondertes Queue-Problem.
4. Öffnet **Summary → Artifacts → orderflow-package**. Notiert Run-ID, Commit, `version.txt` und `build-metadata.json`.
5. Öffnet in den Deployment Jobs den Download und den Simulationsstep. Staging listet das Paket auf, Produktion liest dessen Version.
6. Öffnet **Pipelines → Environments → orderflow-staging/orderflow-prod → Deployments**. Folgt dem jeweiligen Eintrag zurück zum gleichen Run.

**Sollzustand:** Ein Build, zwei Downloads aus `current`, kein erneuter Build in Produktion. Die Run-ID und der Artefaktname sind für beide Deployments identisch.

## 5. Produktions-Approval außerhalb von YAML konfigurieren

1. Öffnet **Pipelines → Environments → orderflow-prod → Approvals and checks → + → Approvals**.
2. Wählt als Approver **OrderFlow Release Managers** oder die vom Trainer benannte vorbereitete Identität.
3. Tragt als Prüfanweisung ein: `Commit, Build-Ergebnis, orderflow-package und erfolgreiches Staging prüfen. Danach bewusst freigeben oder ablehnen.`
4. Deaktiviert **Allow approvers to approve their own runs**, sofern das Kurskontenmodell eine unabhängige Freigabe ermöglicht. Fehlt ein zweites Konto, verwendet die Traineridentität; eine ausdrücklich vereinbarte Trainingsausnahme zur Selbstfreigabe ist zu dokumentieren.
5. Setzt einen für die Übung passenden **Timeout**, beispielsweise 60 Minuten, und speichert. Falls eine Zeiteinheit angeboten wird, prüft sie ausdrücklich.
6. Öffnet den gespeicherten Check erneut und kontrolliert Gruppe, Prüfanweisung, Selbstfreigabe und Timeout.

Bei einer Approver-Gruppe reicht normalerweise eine Freigabe durch ein berechtigtes Mitglied. Die Approval-Liste wird beim Start der Checks bestimmt; ändert die Mitgliedschaft daher nicht erst während einer bereits wartenden Freigabe und erwartet davon automatisch eine Änderung des laufenden Checks.

## 6. Zweiter Run mit Approval

1. Startet `orderflow-release` erneut manuell auf `main`.
2. Erwartet: Build erfolgreich, Staging erfolgreich, Produktion **wartet auf Approval**. Die Produktionssteps dürfen noch nicht gelaufen sein.
3. Öffnet **Review** bzw. die ausstehenden Checks im Run. Speichert den Nachweis des Wartezustands vor der Entscheidung.
4. Meldet euch mit der vorgesehenen Freigabeidentität an oder lasst den Trainer prüfen. Kontrolliert Commit, Run-ID, Artefakt, Konfigurationswert und Staging-Ergebnis.
5. Wählt bewusst **Approve** mit kurzem Prüfkommentar. Erwartet, dass Produktion danach dasselbe Paket dieses zweiten Runs lädt und erfolgreich endet.
6. Alternativ könnt ihr **Reject** wählen: Dann darf kein Produktionsdeployment stattfinden. Dokumentiert diesen Status und startet für den vollständigen positiven Nachweis anschließend einen weiteren Run mit Freigabe.
7. Vergleicht die beiden Deployment-History-Einträge mit ihren Runs. Eine Freigabe gibt keinen Zugriff auf ein nicht autorisiertes Environment; Pipeline permission und Approval erfüllen unterschiedliche Aufgaben.

## 7. Offene Autorisierungstests aus Lab03 abschließen

1. Dokumentiert den positiven Fall mit dem erfolgreichen autorisierten Release-Run.
2. Reproduziert den negativen Fall wie in [Lab07, Fall F](Lab07.md#fall-f--environment-autorisierung): Entfernt ausschließlich in eurer Trainingsumgebung gezielt die Pipeline-Zuordnung, startet einen Test und belegt die verweigerte Ressourcennutzung.
3. Stellt unmittelbar danach ausschließlich **orderflow-release** wieder her. Lasst die Produktions-Checks bestehen. Ein anschließend wartendes Approval ist das erwartete Verhalten.

## 8. Abnahme

- [ ] Beide Deployment Jobs referenzieren das richtige Environment.
- [ ] Staging und Produktion verwenden das Paket desselben Runs.
- [ ] Der Approval liegt auf dem Environment und wird nicht als YAML-Warteschritt nachgebaut.
- [ ] Nur die vorgesehene Release-Pipeline ist autorisiert.
- [ ] Wartender und genehmigter bzw. abgelehnter Zustand sind belegt.
- [ ] Branch Validation verwendet weiterhin die Build-Pipeline.

## Bonus und Fallback

**Branch Control:** Fügt am Produktions-Environment unter **Approvals and checks → + → Branch control** nur `refs/heads/main` hinzu. Dokumentiert die Option für geschützte Branches und das Verhalten bei unbekanntem Schutzstatus. Ein manueller Feature-Branch-Run soll Produktion dann nicht erreichen.

**Exclusive lock:** Fügt eine exklusive Sperre hinzu und beobachtet zwei zeitlich überlappende Runs. Dokumentiert, ob `lockBehavior: sequential` oder `runLatest` gilt, statt aus dem bloßen Vorhandensein einer Sperre auf das Verhalten zu schließen.

**Ohne Environment-Rechte:** Stellt die YAML-Datei fertig und analysiert einen vorbereiteten Run. Kennzeichnet die Einrichtung als offen. Benennt die fehlenden externen Konfigurationen: Ressourcenrollen/Pipeline-Autorisierung und Produktions-Approval.

## Portalhilfe

- [Environments und Berechtigungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
- [Deployment Jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs?view=azure-devops)
