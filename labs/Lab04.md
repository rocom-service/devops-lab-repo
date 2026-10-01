# Lab 04 – Erste YAML-Pipeline

**Dauer:** 30 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** `orderflow-app` mit den importierten Lab-Dateien; vorbereiteter Agentzugang und die Branch Policies aus [Lab 03](Lab03.md).

## Ziel und Ablauf

Legt eine Pipeline aus einer vorhandenen YAML-Datei an, führt sie manuell aus und erklärt Agent, Checkout, Task und Variablen. Alle Arbeiten erfolgen im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| YAML im Repository | 10 Min | `azure-pipelines.yml` auf main |
| Pipeline erstellen und ausführen | 10 Min | `orderflow-ci`, erster Run |
| Logs erklären und dokumentieren | 10 Min | Run-ID, Agent und Ausgaben belegt |

## 1. Startdatei als aktive Pipeline-Datei anlegen

1. Öffnet **Repos → Files → orderflow-app** und wählt `main`.
2. Öffnet [`azure-pipelines.start.yml`](../azure-pipelines.start.yml). Vergleicht den Inhalt mit dem folgenden Startstand.
3. Erstellt im Branch-Auswahlmenü **New branch** den Branch `feature/lab04-<kuerzel>` auf Basis von `main`.
4. Wählt im Repository-Wurzelverzeichnis **… → New → File**, nennt die Datei `azure-pipelines.yml` und fügt diesen Inhalt ein:

   ```yaml
   trigger: none

   pool:
     vmImage: ubuntu-latest

   variables:
     greeting: Hallo aus Azure Pipelines

   steps:
   - checkout: self
   - task: PowerShell@2
     displayName: Umgebung anzeigen
     inputs:
       targetType: inline
       pwsh: true
       script: |
         Write-Host "$(greeting)"
         Write-Host "Build ID: $(Build.BuildId)"
         Write-Host "Agent: $(Agent.OS)"
   ```

5. Committet mit `lab04: add initial pipeline` auf dem Feature-Branch. Bei einer bereits vorhandenen aktiven Datei prüft erst ihren Stand, statt sie ungeprüft zu überschreiben.
6. Erstellt einen PR nach `main`, lasst ihn gemäß den vorhandenen Policies unabhängig prüfen und führt ihn nach erfüllten Regeln zusammen. Falls eine vorbereitete Build-Validation den erstmaligen Aufbau blockiert, klärt mit dem Trainer die initiale Pipeline-Zuordnung; umgeht die Policies nicht eigenmächtig.
7. Kontrolliert danach die Datei unter **Repos → Files → main**. Die nächsten Labs erweitern genau diesen Pfad.

**Nachweis:** Gespeicherte YAML-Datei auf `main`, Commit-/PR-Link. Optional kann die vorhandene Startdatei direkt im Pipeline-Assistenten ausgewählt werden; vor Lab05 muss der aktive Pfad dann auf `azure-pipelines.yml` umgestellt werden.

## 2. Pipeline aus Azure Repos Git erstellen

1. Öffnet **Pipelines → Pipelines → New pipeline** bzw. **Create pipeline**.
2. Wählt **Azure Repos Git**, anschließend **orderflow-app**.
3. Wählt **Existing Azure Pipelines YAML file**.
4. Setzt **Branch: main** und **Path: /azure-pipelines.yml**. Wählt **Continue**.
5. Kontrolliert den angezeigten YAML-Inhalt. Wählt am Run-Button den Dropdown-Eintrag **Save**, sofern angeboten. Wenn nur **Run** angeboten wird, erstellt und startet dieser die Pipeline direkt.
6. Öffnet anschließend die Pipeline → **… → Rename/move** und nennt sie `orderflow-ci`.
7. Prüft unter **… → Settings** den YAML-Dateipfad. Für einen neuen manuellen Run muss `main` ausgewählt sein; dokumentiert einen gegebenenfalls abweichenden Standardbranch.
8. Holt die Rechte aus Lab02 nach: **… → Manage security** → Entwickler dürfen Queue/View builds, QA darf lesen, nur benannte Pipeline-Verantwortliche dürfen die Definition und Berechtigungen verwalten.

**Nachweis:** Ausgewähltes Repository, Branch, Dateipfad, Pipelinename und konkrete Pipeline-Rechte.

## 3. Manuell starten und Agent prüfen

1. Öffnet **orderflow-ci → Run pipeline**.
2. Wählt `main`, lasst die sonstigen Werte unverändert und wählt **Run**.
3. Falls eine Ressourcenautorisierung angefordert wird, lest zuerst den konkreten Ressourcen- und Pipelinenamen. Autorisiert nur eine bekannte, für dieses Lab benötigte Ressource und nur diese Pipeline. Die Startpipeline benötigt weder Environment noch Service Connection.
4. Öffnet den Run und seinen Job. Falls er wartet, unterscheidet **Warteschlange**, **fehlende Paralleljob-Kapazität** und **fehlende Autorisierung**. Bei fehlendem Microsoft-hosted-Kontingent verwendet ausschließlich den vom Trainer vorbereiteten Pool; dokumentiert die dadurch geänderte `pool:`-Konfiguration. Ein wartender Run ist noch kein grüner Lauf.
5. Öffnet **Initialize job** und notiert das tatsächlich verwendete Image bzw. dessen Version. `ubuntu-latest` ist ein beweglicher Alias; die genaue Version kommt aus dem Log.
6. Öffnet **Checkout**. Prüft Repository, Branch/Commit und den erfolgreichen Checkout.
7. Öffnet **Umgebung anzeigen**. Sucht die drei Ausgaben `Hallo aus Azure Pipelines`, `Build ID: …` und `Agent: Linux` bei dem vorgesehenen Ubuntu-Pool.
8. Vergleicht die Build-ID aus dem Log mit dem Run. Notiert den Run-Link und seinen tatsächlichen Status.

## 4. YAML mit eigenen Worten erklären

| Element | Aufgabe im Startstand |
|---|---|
| `trigger: none` | Kein CI-Start allein durch Push; manuelle Runs bleiben möglich |
| `pool.vmImage` | Auswahl eines Microsoft-hosted Agent-Images |
| `variables.greeting` | Eigene, nicht geheime Variable |
| `steps` | Step-Liste in einem impliziten Job |
| `checkout: self` | Repository der Pipeline auschecken |
| `PowerShell@2`, `pwsh: true` | Task mit PowerShell Core |
| `$(greeting)` / `$(Build.BuildId)` | Makro-Variablen werden vor der Taskausführung eingesetzt |

Zeigt jedes Element im Editor und seinen sichtbaren Effekt im Log. `trigger: none` verhindert keine manuelle Ausführung oder eine später eingerichtete Branch-Policy-Validierung.

## 5. Build Validation aus Lab03 nachziehen

1. Nach einem erfolgreichen Start öffnet **Repos → Branches → main → … → Branch policies → Build Validation → +**.
2. Wählt **orderflow-ci**, **Automatic**, **Required**, keinen Path filter und möglichst sofortige Neuprüfung bei Änderungen an `main`.
3. Speichert und notiert: Dieser erste Build prüft bisher nur den technischen Start. Die fachliche Test- und Paketprüfung folgt in Lab05.
4. Lasst die Pipeline-Verantwortlichen die offene Rechtekonfiguration aus Lab02 mit den Testkonten prüfen.

## 6. Screenshots und Ergebnisprüfung

Speichert unter `Lab04-Screenshots`.

| Präfix | Inhalt |
|---|---|
| `01-YAML-main` | Vollständiger Startstand, Branch und Commit |
| `02-Pipeline-Zuordnung` | Repository, YAML-Pfad und Pipeline-Name |
| `03-Pipeline-Rechte` | Gruppenrechte auf orderflow-ci |
| `04-Run-Start` | Manueller Run, Branch und Build-ID |
| `05-Agent` | Initialize job mit tatsächlicher Image-Version |
| `06-Checkout` | Repo und ausgecheckter Commit |
| `07-PowerShell` | Begrüßung, Build-ID und Agent.OS |
| `08-Ergebnis-Policy` | Grüner Run sowie Required/Automatic-Build-Validation |

- [ ] Die Pipeline lädt die richtige Datei aus `orderflow-app`.
- [ ] Der Run ist erfolgreich; eventuelle Kapazitätsprobleme sind ausdrücklich offen dokumentiert.
- [ ] Agent, Checkout, Task und Build-ID können erklärt werden.
- [ ] Der fehlende CI-Trigger ist verstanden; Branch-Policy-Runs sind davon getrennt.
- [ ] Rechte- und Policy-Restpunkte aus Lab02/03 sind nachgezogen.

**Bonus:** Ergänzt ganz oben `name: $(Date:yyyyMMdd).$(Rev:r)` über einen Feature-Branch und PR. Startet einen neuen Run und prüft dessen lesbaren Namen.

## Portalhilfe

- [Erste Pipeline erstellen](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops)
- [Azure Repos Git und Trigger](https://learn.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops)
- [Microsoft-hosted Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops)
