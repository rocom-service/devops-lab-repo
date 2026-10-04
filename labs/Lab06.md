# Lab 06 – Multi-Stage-Pipeline, Environments und Approval

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/06_Multistage_Environments.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Akteur für Einrichtung, Run und Approval:** du mit deinem persönlichen Basic-Kurskonto im Teilnehmerprojekt aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md). **Voraussetzung:** [Lab05](Lab05.md) abgeschlossen; du bist Project Administrator und Administrator der in [Lab03](Lab03.md) angelegten Environments `orderflow-staging` und `orderflow-prod`. Beide sind Resource None, bisher ohne Approval. Dein eigenes Konto wird in Abschnitt 5 direkt als Approver benannt; kein zweiter Zugang erforderlich.

## Ziel und Aufbau

Baut ein Paket einmal und verwendet es im selben Run für Staging und Produktion. Vergleicht einen Lauf ohne Approval mit einem Lauf, dessen Produktionsstage auf Freigabe wartet. Die Deployments sind **Simulationen**: Sie zeigen Paketdateien und lesen die Version. Es werden keine echten Cloudressourcen bereitgestellt.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Release-Pipeline und Ressourcen | 20 Min | Drei Stages, gezielte Autorisierung |
| Lauf ohne Approval | 10 Min | Staging und Produktion automatisch erfolgreich |
| Approval und Autorisierungs-Negativtest | 10 Min | Eigener Approver konfiguriert, fehlende Staging-Autorisierung belegt und wiederhergestellt |
| Gemeinsamer Wiederherstellungs-/Approval-Lauf und Nachweise | 15 Min | Staging erfolgreich, Produktion wartet und wird genehmigt; Artefaktidentität und History belegt |

Die Build-/PR-Pipeline `orderflow-ci` bleibt für Branch Validation erhalten. Für dieses Lab legt ihr `orderflow-release` mit der bereits importierten Datei `azure-pipelines.multistage.yml` an. So wartet ein PR-Build nicht auf die Produktionsfreigabe. Bleibt im eigenen Trainingsprojekt in **ppedv-courses**.

Die Pflichtfolge umfasst **zwei erfolgreiche vollständige Runs und einen Autorisierungs-Negativversuch**. Der zweite erfolgreiche Run belegt zugleich die wiederhergestellte Staging-Autorisierung und den Produktions-Approval. Der Negativversuch kann bereits vor der Jobausführung scheitern. Sichert dafür Hypothese und geplanten Minimalfix vor der Wiederherstellung; diese eigenen Belege verwendet ihr in Lab07 als Fall F weiter.

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
4. Kontrolliere unter **… → Settings** den Pfad `/azure-pipelines.multistage.yml` und den Default Branch `refs/heads/main`. Öffne **… → Manage security**: Setze für **OrderFlow Release Managers** `View builds`, `View build pipeline` und `Queue builds` auf Allow. `Edit build pipeline` und `Administer build permissions` bleiben für diese Fachgruppe Not set. Du verwaltest die Pipeline über deine bestehende Projektadministration; ein Mitglied der leeren Modellgruppe muss nicht angemeldet werden.
5. Lasst die Build-Validation-Policy auf `main` weiterhin auf **orderflow-ci** zeigen. Wählt dort nicht die Release-Pipeline aus.

## 3. Environments und Pipeline permissions prüfen

1. Öffne **Pipelines → Environments** in deinem Teilnehmerprojekt. Öffne nacheinander die in Lab03 angelegten Environments `orderflow-staging` und `orderflow-prod`, jeweils **Resource: None**. Kontrolliere den Projektnamen in der Adresszeile.
2. Öffnet jeweils **… → Security → Pipeline permissions**. Entfernt Open access über **Restrict permission**, falls aktiv.
3. Füge über **+** genau **orderflow-release** hinzu. Die Liste war nach Lab03 leer und soll jetzt genau diese Release-Pipeline enthalten. `orderflow-ci` wird für diese beiden Environments nicht autorisiert. Dokumentiere den gespeicherten Endstand beider Listen.
4. Prüfe **User permissions**: dein Konto **Administrator**, `OrderFlow Release Managers` **Reader**, weitere geerbte Rollen wie in Lab03 dokumentiert. Die Fachgruppe bleibt leer; die tatsächliche eigene Freigabe wird direkt deinem Konto zugeordnet.
5. Öffne bei `orderflow-prod` **Approvals and checks**. Im Erstablauf ist die Liste gemäß Lab03 leer. Führe erst den Vergleichslauf in Abschnitt 4 und danach die Einrichtung in Abschnitt 5 aus. Bei Wiederaufnahme nach bereits eingerichtetem Approval verwendest du den gespeicherten Vergleichslauf aus deinem Protokoll und setzt bei Abschnitt 6 fort; entferne den Check nicht für eine Wiederholung. Ohne belegten ersten Vergleichslauf ist dieser Nachweis noch nicht erbracht.

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
2. Suche im Feld **Approvers** nach deinem eigenen vollständigen Kurskontonamen aus dem Kontomenü. Wähle genau dein persönliches Basic-Konto als direkten Approver. Wähle weder die leere Gruppe `OrderFlow Release Managers` noch Wolfgang oder ein anderes Teilnehmerkonto.
3. Tragt als Prüfanweisung ein: `Commit, Build-Ergebnis, orderflow-package und erfolgreiches Staging prüfen. Danach bewusst freigeben oder ablehnen.`
4. **Trainingsausnahme:** Aktiviert **Allow approvers to approve their own runs**, damit ihr den eigenen simulierten Release-Lauf bewusst freigeben könnt. Dein Konto muss weiterhin direkt als Approver benannt sein. Die Option allein erteilt keine Freigabeberechtigung. **Im Echtbetrieb prüft und genehmigt eine andere berechtigte Person die Produktionsbereitstellung nach dem Vier-Augen-Prinzip; dort ist diese Option ausgeschaltet.** Approval Check, gezielte Pipeline-Autorisierung, Timeout und Artefaktprüfung bleiben auch im Training bestehen.
5. Setze **Timeout: 1 hour** bzw. **60 minutes**, entsprechend der im Eingabefeld angezeigten Einheit. Speichere den Check.
6. Öffne den gespeicherten Check erneut und kontrolliere dein direkt benanntes Konto, Prüfanweisung, eingeschaltete Selbstfreigabe und den Timeout von einer Stunde.

Die Approval-Liste wird beim Start der Checks bestimmt. Korrigiere eine falsch eingetragene Identität vor dem nächsten Run. Eine nachträgliche Kontozuordnung wird nicht als automatische Änderung eines bereits wartenden Checks vorausgesetzt.

## 6. Autorisierungs-Negativtest aus Lab03

1. Verwendet den erfolgreichen Run aus Abschnitt 4 als Positivbeleg der Staging-Autorisierung. Startet dafür keinen weiteren Run.
2. Wartet, bis laufende Tests beendet sind. Sichert unter **Pipelines → Environments → orderflow-staging → … → Security → Pipeline permissions** den Ausgangsstand: ausschließlich `orderflow-release`, kein Open access. Der Production-Approval aus Abschnitt 5 bleibt unverändert.
3. Entfernt ausschließlich die Pipeline-Zuordnung `orderflow-release` am leeren Trainings-Environment `orderflow-staging`. Startet einen neuen Run auf `main`. Erwartet eine fehlende Ressourcenautorisierung; sie kann bereits bei der Validierung auftreten. Belegt Run oder Validierungsdialog mit genauer Meldung. Ein YAML-, Agent- oder Buildfehler belegt diese Sperre nicht. Verwendet während des Negativtests kein **Permit**.
4. Notiert für Fall F: Fehlerphase, Meldung, betroffene Pipeline/Ressource, Hypothese und geplante kleinste Korrektur. Erst danach stellt ihr die Zuordnung wieder her.
5. Beendet einen noch wartenden Negativlauf. Fügt unter denselben **Pipeline permissions → +** genau `orderflow-release` wieder hinzu und dokumentiert den Endstand, auch wenn der Test anders als erwartet verlaufen ist. Benutzerrollen und Production-Check bleiben unverändert; kein Open access. Den erfolgreichen Folgelauf führt ihr genau einmal in Abschnitt 7 aus.

## 7. Wiederherstellung und Approval in einem Run prüfen

1. Startet nach der Wiederherstellung `orderflow-release` einmal manuell auf `main`. Dieser Lauf ist zugleich der Folgelauf des Autorisierungstests aus Lab03, Abschnitt 6.2, und der zweite erfolgreiche Vergleichslauf dieses Labs.
2. Erwartet: Build erfolgreich, Staging erfolgreich, Produktion **wartet auf Approval**. Die Produktionssteps dürfen noch nicht gelaufen sein.
3. Öffnet **Review** bzw. die ausstehenden Checks im Run. Speichert den Nachweis des Wartezustands vor der Entscheidung.
4. Bleibe mit demselben persönlichen Kurskonto angemeldet, das du in Abschnitt 5 direkt als Approver eingetragen hast. Kontrolliere Commit, Run-ID, `orderflow-package`, Konfigurationswert `Release` und erfolgreiches Staging.
5. Wählt bewusst **Approve** mit kurzem Prüfkommentar. Erwartet, dass Produktion danach dasselbe Paket dieses Runs lädt und erfolgreich endet. Für die Pflichtabnahme genehmigt ihr den Run; ein zusätzlicher Reject-Versuch gehört nur zur optionalen Vertiefung nach Aufforderung des Trainers.
6. Vergleicht die Deployment-History-Einträge der beiden erfolgreichen Runs. Ergänzt im Diagnoseprotokoll aus Abschnitt 6 den erfolgreichen Folgelauf und eine passende Vorbeugung. Übernehmt diese Belege in Lab07 als Fall F, ohne den Fehler erneut auszulösen. Eine Freigabe gibt keinen Zugriff auf ein nicht autorisiertes Environment; Pipeline permission und Approval erfüllen unterschiedliche Aufgaben.

## 8. Abnahme

Ablage: `lab06-durchfuehrung`. Sichere Pipelinepfad, Benutzerrollen und Pipeline permissions beider Environments, den ersten erfolgreichen Run ohne Approval, die gespeicherte eigene Approval-Zuordnung sowie den Autorisierungs-Negativbeleg und die Wiederherstellung. Der zweite erfolgreiche Run liefert gemeinsam den Folgelauf nach Wiederherstellung, den Approval-Wartezustand und den Erfolg nach eigener Zustimmung. Verweise für diese Nachweise auf dieselbe Run-ID; ein dritter erfolgreicher Vollrun ist nicht gefordert.

- [ ] Beide Deployment Jobs referenzieren das richtige Environment.
- [ ] Staging und Produktion verwenden das Paket desselben Runs.
- [ ] Der Approval liegt auf dem Environment und wird nicht als YAML-Warteschritt nachgebaut.
- [ ] Nur die vorgesehene Release-Pipeline ist autorisiert.
- [ ] Fehlende Staging-Autorisierung und ihre Wiederherstellung sind belegt; Hypothese und Minimalfix wurden vor der Reparatur notiert.
- [ ] Der gemeinsame Folgelauf belegt erfolgreiches Staging, wartende Produktion und den Erfolg nach Genehmigung.
- [ ] Branch Validation verwendet weiterhin die Build-Pipeline.

## Bonus: Branch Control

**Akteur: du.** Erst nach vollständiger Pflichtabnahme öffnen: **Pipelines → Environments → orderflow-prod → Approvals and checks → + → Branch control**. Erlaube ausschließlich `refs/heads/main` und aktiviere die Anforderung eines geschützten Branches. Bei unbekanntem Schutzstatus darf der Check nicht fortfahren. Speichere und dokumentiere diese Werte.

Starte `orderflow-release` manuell aus deinem bereits vorhandenen Feature-Branch aus Lab05. Erwartet wird ein blockierter Production-Check; sichere dessen Meldung, beende den Testlauf und starte danach `main`. Genehmige den eigenen main-Run nach erfolgreichen Checks. Beide Runs und der zusätzliche Check gehören in dein Protokoll. Eine Sperre durch Branch Control ist keine fehlende Pipeline-Autorisierung.

Ein fehlendes eigenes Environment-Verwaltungsrecht ist ein tatsächlicher Einrichtungsfehler: Wolfgang prüft im Teilnehmerprojekt **Project settings → Permissions → Project Administrators** und die **Security** des konkret betroffenen Environments. Danach führst du den blockierten Schritt mit deinem eigenen Konto aus. Ein unbekannter vorbereiteter Run ersetzt deine Abnahme nicht.

## Portalhilfe

- [Environments und Berechtigungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
- [Deployment Jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs?view=azure-devops)
