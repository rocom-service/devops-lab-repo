# Lab 04 – Erste YAML-Pipeline

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/04_Erste_YAML_Pipeline.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 30 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Akteur:** du mit deinem persönlichen Basic-Kurskonto und Project-Administrator-Rechten im Teilnehmerprojekt aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md). **Voraussetzung:** Lab01–03 abgeschlossen; `orderflow-app/main` enthält die 14 Originaldateien. Reviewer-/Kommentar-Policies sind aktiv. Die Build Validation wird erst am Ende dieses Labs eingerichtet. Pool: **Azure Pipelines**, Image **ubuntu-latest**.

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
6. Erstellt einen PR nach `main`, prüft ihn und genehmigt ihn in der Labumgebung selbst mit **Approve**. Führt ihn erst nach erfüllten Pflichtprüfungen und aufgelösten Kommentaren regulär zusammen. Die Trainingsregel aus Lab03 gilt: mindestens 1 Zustimmung, eigene Zustimmung Ein, Ausschluss des letzten Pushers Aus. Im Echtbetrieb ist unabhängiges Vier-Augen-Review erforderlich. Im Erstablauf gibt es gemäß Lab03 noch keine Build Validation; der erste PR wird durch Reviewer- und Kommentar-Policy geprüft. Bei Wiederholung mit bereits vorhandener Build Validation muss auch deren Run erfolgreich sein. Schalte sie nicht aus.
7. Kontrolliert danach die Datei unter **Repos → Files → main**. Die nächsten Labs erweitern genau diesen Pfad.

**Nachweis:** Gespeicherte YAML-Datei auf `main`, Commit-/PR-Link.

## 2. Pipeline aus Azure Repos Git erstellen

1. Öffnet **Pipelines → Pipelines → New pipeline** bzw. **Create pipeline**.
2. Wählt **Azure Repos Git**, anschließend **orderflow-app**.
3. Wählt **Existing Azure Pipelines YAML file**.
4. Setzt **Branch: main** und **Path: /azure-pipelines.yml**. Wählt **Continue**.
5. Kontrolliert den angezeigten YAML-Inhalt. Wählt am Run-Button den Dropdown-Eintrag **Save**, sofern angeboten. Wenn nur **Run** angeboten wird, erstellt und startet dieser die Pipeline direkt.
6. Öffnet anschließend die Pipeline → **… → Rename/move** und nennt sie `orderflow-ci`.
7. Prüft unter **… → Settings** den YAML-Dateipfad `/azure-pipelines.yml` und setzt **Default branch for manual and scheduled builds** auf `refs/heads/main` bzw. den angebotenen Eintrag `main`. Speichert und öffnet die Einstellung zur Kontrolle erneut.
8. Öffne **… → Manage security** und wähle nacheinander die Gruppen aus Lab02. Setze für **OrderFlow Developers** und **OrderFlow Release Managers** `View builds`, `View build pipeline` und `Queue builds` auf Allow. Für **OrderFlow QA** setze nur die beiden View-Rechte auf Allow; Queue bleibt Not set. Für **OrderFlow External Reviewers** bleiben alle diese Rechte Not set. `Edit build pipeline` und `Administer build permissions` bleiben für alle vier Fachgruppen Not set; prüfe zusätzliche Vererbung. Dein eigenes Project-Administrator-Konto verwaltet Definition und Rechte. Die Gruppen bleiben leer; du führst keinen Rollen-Login durch.

**Nachweis:** Ausgewähltes Repository, Branch, Dateipfad, Pipelinename und konkrete Pipeline-Rechte.

## 3. Ersten Run verwenden und Agent prüfen

1. Öffnet **orderflow-ci → Runs**. Hat der Erstellungsassistent bereits einen Run für `main` und den vorgesehenen Commit aus `/azure-pipelines.yml` gestartet, verwendet genau diesen Run. Auch ein noch wartender passender Run wird weiterverwendet.
2. Nur wenn kein passender Run vorhanden ist, öffnet **Run pipeline**, wählt `main`, lasst die sonstigen Werte unverändert und wählt **Run**. Ein neuer Lauf nach einer notwendigen Fehlerkorrektur ist zulässig; ein zusätzlicher Start allein zur Wiederholung desselben Nachweises entfällt.
3. Fordert der Run tatsächlich eine Repository-Erlaubnis an, öffne **View → Permit** ausschließlich für **orderflow-ci** auf **orderflow-app** deines Projekts. Prüfe die Namen im Dialog. Für den eingebauten Pool **Azure Pipelines** ist keine einzelne Pipeline-Freigabe einzurichten; dessen Pipeline permissions sind laut [Microsoft-Dokumentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops) nicht konfigurierbar. Bei einer tatsächlichen Agent-Zugriffssperre prüft Wolfgang die Benutzer-/Gruppenrollen unter **Project settings → Agent pools → Azure Pipelines → Security** gemäß den [Voraussetzungen](../../VORAUSSETZUNGEN.md). Ein anderes Repository, Environment oder eine Service Connection wird von dieser Startpipeline nicht benötigt.
4. Öffne den Run und seinen Job. Die Organisation teilt **einen Microsoft-hosted Paralleljob** zwischen den Teilnehmern. Bei **Waiting for an agent** lasse den Run in der Warteschlange und beobachte den Status; starte keine Duplikate. Eine Meldung **Permission needed** wird nach Schritt 3 behandelt. Bei einer ausdrücklichen Kontingentsperre prüft Wolfgang **Organization settings → Pipelines → Parallel jobs** und stellt die Kurskapazität im Pool Azure Pipelines wieder her; die YAML-Auswahl bleibt `ubuntu-latest`. Ein wartender Run ist noch kein erfolgreicher Lauf.
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
2. Wählt **orderflow-ci**, **Automatic**, **Required**, keinen Path filter und **Build expiration: Immediately when main is updated**.
3. Speichert und notiert: Dieser erste Build prüft bisher nur den technischen Start. Die fachliche Test- und Paketprüfung folgt in Lab05.
4. Prüft mit eurem eigenen Teilnehmerkonto die gespeicherten Gruppenrechte aus Lab02 einschließlich Vererbung. Zusätzliche Testkonten oder Rollen-Logins sind nicht erforderlich; dies ist eine Konfigurationsprüfung.

## 6. Ergebnisprüfung

Speichere Protokoll und Screenshots in `lab04-durchfuehrung`: Pipeline-Datei/Branch/Pfad, Gruppenrechte, gespeicherte Build Validation sowie Runstatus, Image, Checkout und Task-Ausgabe. Der tatsächliche Erfolg von Checkout belegt die funktionierende Repository-Leseberechtigung der Pipeline. Ein eigener Benutzer-Login ist nicht deren Build-Service-Identität.

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
