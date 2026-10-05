# Lab 04 – Erste YAML-Pipeline

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 30 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Umgebung:** Persönliches Basic-Kurskonto mit Projektadministratorrechten im [zugeordneten Projekt](../KURSSTART.md#teilnehmerprojekte-und-kürzel); Lab01–03 sind abgeschlossen. `orderflow-app/main` enthält die Kursdateien, Reviewer- und Kommentar-Policies sind aktiv.

## Ziel und Ablauf

Legt eine Pipeline aus einer vorhandenen YAML-Datei an, führt sie manuell aus und erklärt Agent, Checkout, Task und Variablen. Alle Arbeiten erfolgen im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| YAML und Pipeline anlegen | 10 Min | `orderflow-ci` verwendet die aktive Datei |
| Run und Logs verstehen | 10 Min | Agent, Checkout und Ausgaben zugeordnet |
| Rechte und Build Validation | 10 Min | Pipeline-Zugriff und Pflichtbuild eingerichtet |

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
6. Erstellt einen PR nach `main` und führt ihn nach den Trainingsregeln aus Lab03 mit **Approve** und erfüllten Pflichtprüfungen regulär zusammen. Eine bereits eingerichtete Build Validation bleibt aktiv.
7. Kontrolliert danach die Datei unter **Repos → Files → main**. Die nächsten Labs erweitern genau diesen Pfad.

## 2. Pipeline aus Azure Repos Git erstellen

1. Öffnet **Pipelines → Pipelines → New pipeline** bzw. **Create pipeline**.
2. Wählt **Azure Repos Git**, anschließend **orderflow-app**.
3. Wählt **Existing Azure Pipelines YAML file**.
4. Setzt **Branch: main** und **Path: /azure-pipelines.yml**. Wählt **Continue**.
5. Kontrolliert den angezeigten YAML-Inhalt. Wählt am Run-Button den Dropdown-Eintrag **Save**, sofern angeboten. Wenn nur **Run** angeboten wird, erstellt und startet dieser die Pipeline direkt.
6. Öffnet anschließend die Pipeline → **… → Rename/move** und nennt sie `orderflow-ci`.
7. Prüft unter **… → Settings** den YAML-Dateipfad `/azure-pipelines.yml` und setzt **Default branch for manual and scheduled builds** auf `refs/heads/main` bzw. den angebotenen Eintrag `main`. Speichert und öffnet die Einstellung zur Kontrolle erneut.

## 3. Ersten Run verwenden und Agent prüfen

1. Öffnet **orderflow-ci → Runs**. Hat der Erstellungsassistent bereits einen Run für `main` und den vorgesehenen Commit aus `/azure-pipelines.yml` gestartet, verwendet genau diesen Run. Auch ein noch wartender passender Run wird weiterverwendet.
2. Nur wenn kein passender Run vorhanden ist, öffnet **Run pipeline → main → Run**. Nach einer Fehlerkorrektur startet ihr den korrigierten Stand erneut.
3. Fordert der Run eine Repository-Erlaubnis an, öffne **View → Permit** ausschließlich für **orderflow-ci** auf **orderflow-app**. Prüfe die Namen im Dialog. Bei einem Agent-Zugriffsfehler unterstützt dich der Trainer.
4. Öffne den Run und seinen Job. Bei **Waiting for an agent** lasse ihn in der Warteschlange: Die Gruppe teilt einen Microsoft-hosted Paralleljob. Bei einer Kontingentsperre bitte den Trainer um Unterstützung.
5. Öffnet **Initialize job** und findet das verwendete Agent-Image. Vergleicht es mit `ubuntu-latest` in der YAML.
6. Öffnet **Checkout**. Prüft Repository, Branch/Commit und den erfolgreichen Checkout.
7. Öffnet **Umgebung anzeigen**. Sucht die drei Ausgaben `Hallo aus Azure Pipelines`, `Build ID: …` und `Agent: Linux` bei dem vorgesehenen Ubuntu-Pool.
8. Vergleicht die Build-ID aus dem Log mit dem Run. Prüft den Status des Runs.

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

Ordnet die YAML-Elemente mündlich den passenden Steps, Einstellungen oder Ausgaben im Run zu. `trigger: none` verhindert keine manuelle Ausführung oder eine später eingerichtete Branch-Policy-Validierung.

## 5. Pipeline-Rechte und Build Validation einrichten

1. Öffne **Pipelines → orderflow-ci → … → Manage security**. Setze die Gruppenrechte aus dieser Tabelle; **A = Allow, N = Not set**. Prüfe zusätzlich die Vererbung.

   | Recht | Developers | QA | Release Managers | External Reviewers |
   |---|---|---|---|---|
   | View builds / View build pipeline | A | A | A | N |
   | Queue builds | A | N | A | N |
   | Edit build pipeline | N | N | N | N |
   | Administer build permissions | N | N | N | N |

2. Öffne **Repos → Branches → main → … → Branch policies → Build Validation → +**.
3. Wähle **orderflow-ci**, **Automatic**, **Required**, keinen Path filter und **Build expiration: Immediately when main is updated**. Speichere und prüfe den Eintrag; lege keinen doppelten Eintrag an.

Dieser Build prüft zunächst nur den technischen Start. Die fachliche Quellprüfung und Paketierung ergänzt du in Lab05.

## 6. Ergebnisprüfung

Prüfe direkt im Portal:

- [ ] `orderflow-ci` verwendet `/azure-pipelines.yml` aus `orderflow-app`.
- [ ] Der Run ist erfolgreich; Checkout und Task-Ausgaben sind sichtbar.
- [ ] Agent, Checkout, Task und Build-ID lassen sich mündlich zuordnen.
- [ ] Gruppenrechte und Required/Automatic Build Validation sind gespeichert.

**Bonus:** Ergänzt ganz oben `name: $(Date:yyyyMMdd).$(Rev:r)` über einen Feature-Branch und PR. Startet einen neuen Run und prüft dessen lesbaren Namen.

## Portalhilfe

- [Erste Pipeline erstellen](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops)
- [Azure Repos Git und Trigger](https://learn.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops)
- [Microsoft-hosted Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops)
