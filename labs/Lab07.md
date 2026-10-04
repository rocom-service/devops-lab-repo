# Lab 07 – Troubleshooting Challenge

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/07_Troubleshooting_Challenge.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 50 Minuten · **Arbeitsform:** Einzelarbeit mit einem Zugang  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Akteur:** du mit dem persönlichen Basic-Kurskonto im Teilnehmerprojekt aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md). **Voraussetzung:** Lab01–06 abgeschlossen, Project-Administrator-Rechte, Repo **orderflow-app**, Pool **Azure Pipelines**, Image **ubuntu-latest**. Fall F verwendet exakt **orderflow-release** und **orderflow-staging** aus [Lab06](Lab06.md).

## Ziel und Regeln

Bearbeitet im Pflichtpfad **Fall A und Fall F** und speichert zwei eigene Diagnoseprotokolle in eurer Lab07-Ablage. Fall A führt ihr hier neu aus; für Fall F verwendet ihr eure eigenen Fehler- und Reparaturnachweise aus Lab06 einschließlich der vor dem Fix notierten Hypothese. Arbeitet ausschließlich in eurem eigenen Trainingsprojekt in **ppedv-courses** mit eurem regulären Teilnehmerkonto. Ein weiterer Zugang, ein Partner oder eine Erklärung gegenüber einem anderen Team sind nicht erforderlich.

Fall A benötigt keine Environments: Die fehlerhafte YAML wird im Validierungsdialog belegt, der korrigierte Stand einmal auf dem Agent ausgeführt. Fall F erzeugt bei vollständigen eigenen Belegen aus Lab06 keine weiteren Runs. Fälle B–E sind Vertiefung nach Aufforderung des Trainers. Fehlt ein eigener Nachweis für F, vervollständigt ihn mit dem Trainer anhand des Ablaufs in Lab06, statt einen fremden Run zu verwenden. Für eigene PRs gilt die Selbstfreigabe aus Lab03: eigene Zustimmung erlaubt, mindestens eine Zustimmung und die übrigen Pflichtprüfungen bleiben bestehen, kein Bypass. Für einen eigenen Production-Run muss euer Konto gemäß Lab06 als Approver benannt und Selbstfreigabe aktiviert sein.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Fall A: Testaufbau, Schemafehler und Reparatur | 20 Min | Validierungsfehler belegt, korrigierter Stand einmal erfolgreich ausgeführt |
| Fall F: eigene Belege aus Lab06 auswerten | 20 Min | Zweites vollständiges Diagnoseprotokoll ohne erneuten Fehler-/Reparaturlauf |
| Erklärung und Abnahme | 10 Min | Ursache, Minimalfix und Vorbeugung nachvollziehbar |

Die Hinweise zur Korrektur sind unten eingeklappt. Öffnet sie erst nach eigener Hypothese. Erwartete Fehlermeldungen sind Anhaltspunkte; dokumentiert die tatsächlich angezeigte Meldung aus eurem Run.

## 1. Testpipeline und Branches für A–E vorbereiten

Für Fall F verwendet ihr direkt das dort beschriebene Setup mit `orderflow-release`; dafür legt ihr keine zweite Release-Pipeline an.

1. Öffnet in eurem Teilnehmerprojekt **Repos → Files → orderflow-app → main** und prüft den Ordner [`broken/`](../broken).
2. Erstellt für jeden gewählten Fall aus einem gültigen `main` einen eigenen Branch: `feature/lab07-<fall>-<kuerzel>`. Ersetzt `<fall>` durch a, b, c, d oder e und `<kuerzel>` durch euren Eintrag in der [Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md#teilnehmerprojekte-und-kürzel).
3. Erstellt unter **Pipelines → New pipeline → Azure Repos Git → orderflow-app → Existing Azure Pipelines YAML file** eine separate Testpipeline mit dem gewählten Branch und der Datei des Falls.
4. Benennt sie eindeutig, `orderflow-debug-<fall>-<kuerzel>` mit demselben Fallbuchstaben und persönlichen Kürzel. Verändert nicht den YAML-Pfad von `orderflow-ci` oder `orderflow-release` für die Fälle A–E.
5. Startet manuell und wählt ausdrücklich den Testbranch. Die Fehlerdateien verwenden `trigger: none`; ein Commit startet sie nicht automatisch. Nach jedem Fix ist ein neuer manueller Run auf dem korrigierten Commit nötig.
6. Bei Fall A kann die Schemafehler-Prüfung bereits das Speichern/Starten verhindern. Das ist der erwartete Reproduktionsbeleg; eine Run-ID gibt es dann noch nicht.

## 2. Diagnoseprotokoll führen

Reproduziert zuerst den Fehler und füllt die Felder bis einschließlich „Kleinste Änderung“ vor dem Fix aus. Ergänzt „Neuer Commit/Run“ und „Vorbeugung“ nach der erneuten Prüfung.

| Feld | Einzutragen |
|---|---|
| Fall und Datei | Gewählter Fall, YAML-Pfad |
| Branch und Commit | Exakter Stand des Fehlers |
| Run-Link oder Validierungsdialog | Tatsächlicher Nachweis |
| Fehlerphase | Parse/Compile, Queue, Checkout, Task, Artefakt, Deployment |
| Erste aussagekräftige Meldung | Genaue Meldung mit Step-/Stage-Kontext |
| Betroffene Identität/Ressource | Beispielsweise Skriptdatei, Artefakt oder Pipeline-Autorisierung |
| Hypothese | Eine begründete vermutete Ursache |
| Kleinste Änderung | Konkreter geplanter Fix |
| Neuer Commit/Run | Korrigierter Stand mit Status |
| Vorbeugung | Maßnahme passend zur Ursache |

Öffnet **Pipelines → Testpipeline → Run → fehlgeschlagener Job/Step**. Beginnt bei der ersten inhaltlichen Fehlermeldung, nicht bei einem späteren Sammel-Exit-Code. Bei einer übersprungenen Stage prüft zuerst Abhängigkeit und Bedingung.

### Diagnosematrix

| Phase | Typische Indizien | Erste Prüfung |
|---|---|---|
| Parse/Compile | Run startet nicht, YAML-Zeile genannt | Einrückung, Schema, Template-Expansion |
| Queue | Job wartet oder findet keinen Agent | Pool, Parallelität, Demands, Autorisierung |
| Checkout | Repository nicht erreichbar | Build-Service-Identität, Repo-Recht, Branch |
| Task | konkreter Exit Code | erste Fehlermeldung im fehlgeschlagenen Step |
| Artefakt | publish/download findet nichts | Pfad, Name, Stage-Abhängigkeit |
| Deployment | Environment/Connection verweigert | Pipeline Permission, Rolle, Check, Identität |

## 3. Die Fehlerfälle bearbeiten

Die Dateien liegen in deinem Projekt unter **Repos → Files → orderflow-app → main → broken/** und als lokale Originale unter [lab-repo/broken](../broken).

| Fall | Datei / Setup | Schwerpunkt |
|---|---|---|
| A | `01_yaml_structure.yml` | Parse-/Compile-Fehler durch falsche Hierarchie |
| B | `02_wrong_path.yml` | Task-Fehler durch falschen Skriptpfad |
| C | `03_missing_variable.yml` | Runtime-Fehler durch inkonsistenten Variablennamen |
| D | `04_artifact_name.yml` | Artefakt kann wegen Namensabweichung nicht geladen werden |
| E | `05_condition.yml` | Stage wird durch falsche Bedingung übersprungen |
| F | `orderflow-release` an `orderflow-staging` vorübergehend entfernen | Resource Authorization / Permission denied |

### Fall A – YAML-Hierarchie

**Datei:** [`broken/01_yaml_structure.yml`](../broken/01_yaml_structure.yml)

1. Wählt die Datei im Pipeline-Assistenten bzw. Editor und startet **Validate** oder **Run**.
2. Belegt die Meldung über unerwartetes `jobs` unter einem Step. Ordnet den Fehler Parse/Compile zu.
3. Vergleicht die Ebenen Pipeline → Stage → Job → Steps. Formuliert den kleinsten Strukturfix und committet ihn auf eurem Testbranch.
4. Erstellt/startet die Testpipeline erneut und prüft, dass beide beabsichtigten Ausgaben erscheinen.

<details>
<summary>Korrekturhinweis und prüfbarer Zielstand</summary>

`jobs` darf nicht unter einem einzelnen Step stehen. Verwendet beispielsweise einen regulären Job mit beiden Steps:

```yaml
trigger: none
pool:
  vmImage: ubuntu-latest
jobs:
- job: ValidateStructure
  steps:
  - pwsh: Write-Host 'This step is valid'
  - pwsh: Write-Host 'Both steps now belong to the same job'
```

Vorbeugung: Schema-Validierung vor dem Run; bei Umstrukturierung zuerst die Hierarchie prüfen.
</details>

### Fall B – Skriptpfad

**Datei:** [`broken/02_wrong_path.yml`](../broken/02_wrong_path.yml)

1. Startet den fehlerhaften Stand manuell und öffnet **Validate source**.
2. Vergleicht den `filePath` mit dem Verzeichnisbaum unter **Repos → Files** und dem erfolgreichen Checkout.
3. Korrigiert nur den falschen Pfad. Committet und startet erneut auf demselben Testbranch.
4. Erwartet einen erfolgreichen Test bei gültigem `src/`-Stand.

<details>
<summary>Korrekturhinweis</summary>

Ändert `filePath: script/test.ps1` zu `filePath: scripts/test.ps1`. Dies ist ein Task-/Pfadproblem; zusätzliche Berechtigungen oder ein anderer Agent lösen den Tippfehler nicht.
</details>

### Fall C – Variablenname und falscher Prüfvergleich

**Datei:** [`broken/03_missing_variable.yml`](../broken/03_missing_variable.yml)

1. Startet den fehlerhaften Stand und prüft **Create package** sowie **Verify variable expansion**.
2. Vergleicht den deklarierten Variablennamen mit den verwendeten Makros. Prüft zusätzlich, ob der Vergleich im Prüfstep überhaupt falsch werden kann.
3. Dokumentiert beide Ursachen. Eine erfolgreiche Paketierung allein beweist nicht den korrekten Konfigurationswert.
4. Korrigiert den Taskparameter und den Prüfstep. Committet, startet neu und belegt `Release` im Log bzw. in den Paketmetadaten.

<details>
<summary>Korrekturhinweis und Prüfstep</summary>

Die Variable heißt `buildConfiguration`, nicht `buildConfig`. Im Buildtask muss das Argument `-Configuration "$(buildConfiguration)"` lauten. Der ursprüngliche Vergleich derselben Zeichenfolge auf beiden Seiten ist immer wahr; bloßes Umbenennen beider Seiten genügt deshalb nicht.

Ersetzt den Prüfstep durch:

```yaml
- pwsh: |
    if ($env:BUILD_CONFIGURATION -ne 'Release') {
      throw "Unexpected configuration: $env:BUILD_CONFIGURATION"
    }
    $metadata = Get-Content '$(Build.ArtifactStagingDirectory)/package/build-metadata.json' -Raw | ConvertFrom-Json
    if ($metadata.configuration -ne 'Release') {
      throw 'Package metadata does not contain Release'
    }
    Write-Host "Configuration verified: $env:BUILD_CONFIGURATION"
  displayName: Verify variable expansion
  env:
    BUILD_CONFIGURATION: $(buildConfiguration)
```

Vorbeugung: Variablennamen einheitlich verwenden und gegen einen unabhängigen erwarteten Wert prüfen.
</details>

### Fall D – Artefaktname

**Datei:** [`broken/04_artifact_name.yml`](../broken/04_artifact_name.yml)

1. Startet den Fehlerstand. Prüft zunächst, ob **Build** ein Artefakt veröffentlicht hat.
2. Öffnet **Summary → Artifacts** und vergleicht den Namen mit dem Download in der Stage **Consume**.
3. Korrigiert die Namensabweichung, behaltet `download: current` bei und startet einen neuen Run.
4. Belegt, dass der Consume-Job jetzt das Artefakt des gleichen Runs laden kann.

<details>
<summary>Korrekturhinweis</summary>

Der veröffentlichte Name ist `orderflow-package`; im Download steht fälschlich `orderflow-app`. Ändert den Download auf `artifact: orderflow-package`. Nicht das Repository umbenennen und nicht ein zufällig gleichnamiges Artefakt aus einem fremden Run verwenden.
</details>

### Fall E – Stage wird übersprungen

**Datei:** [`broken/05_condition.yml`](../broken/05_condition.yml)

1. Für den Fehlernachweis startet ihr diese unveränderte Fehlerdatei manuell aus **main**. Sie liegt bereits dort im importierten Übungsordner. Erwartet: Build grün, Deploy übersprungen.
2. Prüft die Condition und den tatsächlichen Wert von `Build.SourceBranch`. Für einen Logbeleg könnt ihr auf eurem Testbranch einen reinen Diagnose-Step `Write-Host "Source branch: $(Build.SourceBranch)"` ergänzen.
3. Korrigiert die Branchbedingung auf eurem Testbranch und prüft einen Run dort. Ein bewusst nur für main erlaubtes Deployment soll auf dem Feature-Branch weiterhin übersprungen werden.
4. Für den positiven main-Nachweis übernehmt ihr die korrigierte Übungsdatei per eigenem PR nach `main`. Prüft den Diff, genehmigt den PR selbst gemäß Lab03 und mergt erst nach erfüllten Pflichtprüfungen ohne Bypass. Startet die Testpipeline danach explizit aus **main** und belegt den erfolgreichen Deploy-Job. Der Feature-Branch-Run allein ist kein main-Nachweis.

<details>
<summary>Korrekturhinweis</summary>

```yaml
condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

`Build.SourceBranch` liefert den vollständigen Ref, nicht nur `main`. Behaltet `succeeded()` bei. Vorbeugung: Branchwert, Condition und gewünschtes Verhalten auf beiden Branchtypen getrennt prüfen.
</details>

### Fall F – Environment-Autorisierung

**Setup:** Verwende **orderflow-release** und das leere **orderflow-staging** in deinem eigenen Teilnehmerprojekt. Du verwaltest dieses Environment mit demselben Konto. Prüfe **Pipelines → orderflow-release → Runs** und warte, bis deine bereits gestarteten Runs beendet sind. Die Production-Approval-Konfiguration bleibt unverändert.

Im Pflichtablauf hast du den Staging-Test in Lab06 bereits selbst vollständig durchgeführt. Verwende genau dessen Fehlerbeleg und gemeinsamen Wiederherstellungs-/Approval-Lauf sowie deine vor der Reparatur notierte Hypothese. Ergänze das Diagnoseprotokoll und die Vorbeugung; löse den Fehler nicht erneut aus. Die folgenden Schritte dienen zum Abgleich der Belege und nur bei tatsächlich fehlenden eigenen Nachweisen zur Vervollständigung mit dem Trainer. Eine bloße fremde Referenz genügt nicht.

1. Sichert unter **Pipelines → Environments → orderflow-staging → … → Security** den Ausgangsstand der **Pipeline permissions**. Notiert den exakten Pipeline-Namen und dass Open access deaktiviert ist.
2. Entfernt ausschließlich die Zuordnung von **orderflow-release**. Lasst Benutzerrollen, Environment und Approval-Check unverändert.
3. Startet einen neuen Release-Run. Erwartet eine Meldung über ein nicht autorisiertes oder nicht auffindbares Environment beziehungsweise eine Autorisierungsanforderung. Der Fehler kann bereits vor der Ausführung der Stages auftreten.
4. Speichert Run/Validierung und die genaue Meldung. Erteilt noch keine pauschale Autorisierung über einen Run-Dialog.
5. Prüft zuerst Schreibweise und Existenz des Environments, dann die gezielte Pipeline Permission.
6. Beendet einen noch wartenden Negativlauf. Öffnet mit eurem weiterhin angemeldeten Teilnehmerkonto dieselbe **Security → Pipeline permissions → +** und fügt genau **orderflow-release** wieder hinzu. Stellt den Ausgangszustand auch dann wieder her, wenn der Negativtest anders als erwartet verlief.
7. Startet einen neuen Run. Erwartet erfüllte Ressourcenautorisierung; der Produktions-Approval kann weiterhin warten. Das ist kein fortbestehender Berechtigungsfehler. Prüft Artefakt, Commit und Staging und gebt den eigenen Lauf gemäß Lab06 mit eurem benannten Approver-Konto frei. Belegt danach das erfolgreiche simulierte Deployment. Die Selbstfreigabe-Option ersetzt nicht die Benennung als Approver.
8. Belegt den wiederhergestellten Endstand. Kein Open access als Reparatur.

<details>
<summary>Korrekturhinweis</summary>

Benutzerrolle des handelnden Administrators, Pipeline-Autorisierung und menschlicher Approval sind getrennt. Nur die entfernte Pipeline-Zuordnung wiederherstellen. Keine neue Ressource mit ähnlichem Namen und keine zusätzlichen Projektadministratorrechte anlegen.
</details>

## 4. Abnahme

Speichere beide Diagnoseprotokolle, Fehler-/Reparaturnachweise und die Erklärung in `lab07-durchfuehrung`. Link, Branch, Commit und Run müssen dein eigenes Teilnehmerprojekt bezeichnen. Die Organisation besitzt einen Microsoft-hosted Paralleljob; lasse wartende Runs in der Queue und erzeuge keine Duplikate.

- [ ] Fall A und Fall F sind vor der jeweiligen Korrektur belegt; für F stammen die eigenen Belege aus Lab06.
- [ ] Diagnoseprotokolle enthalten Phase, Meldung, Hypothese und Minimalfix.
- [ ] Nach jedem Fix wurde der neue Commit tatsächlich ausgeführt oder validiert.
- [ ] Grün, erwartetes Warten und erwartetes Überspringen werden unterschieden.
- [ ] Entfernte Autorisierungen sind wiederhergestellt.
- [ ] Alle Schritte wurden mit dem eigenen Teilnehmerkonto durchgeführt.
- [ ] Zu einem Fall liegt eine eigene schriftliche Erklärung mit passender Vorbeugung vor.

Schreibt zu einem der beiden Fälle 5–8 Sätze: Symptom, Fehlerphase, entscheidender Beleg, Ursache, Minimalfix, Ergebnis und Vorbeugung. Verweist auf euren Fehler- und Reparaturnachweis. Prüft selbst, ob eine andere Person die Diagnose anhand dieser Angaben nachvollziehen könnte. Eine tatsächliche Partnerprüfung ist nicht erforderlich.

Lege die zwei Diagnoseprotokolle und diese Erklärung unter `devops-2-nachweise/lab07-durchfuehrung` ab. Ein Upload oder Versand ist für diese Abnahme nicht erforderlich. Ein nur beschriebener oder fremder Reparaturlauf ersetzt euren eigenen Nachweis nicht.

## Bonus – Eine begründete Optimierung

Wählt genau eine Änderung an einer grünen Pipeline und belegt den Nutzen: präzisere geheimnisfreie Logs, weniger unnötige CI-Runs, wiederverwendbare Schritte oder tatsächlich unabhängige parallele Tests. Bei Templates muss `templates/*` im relevanten Pfadfilter berücksichtigt werden. Ein Cache eignet sich nur für wiederherstellbare Abhängigkeiten. Setzt Timeouts passend zur erwarteten Laufzeit und Retries nur bei nachgewiesenen vorübergehenden Fehlern ein; Retries beheben weder falsche Pfade noch fehlende Rechte.

## Portalhilfe

- [Pipelinebedingungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions?view=azure-devops)
- [Vordefinierte Variablen](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops)
- [Environment-Autorisierung](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
