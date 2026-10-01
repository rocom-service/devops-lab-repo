# Lab 07 – Troubleshooting Challenge

**Dauer:** 50 Minuten · **Arbeitsform:** Zweierarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Lab-Repository mit `broken/`, Agentzugang und für Fall F die Trainings-Environments aus [Lab06](Lab06.md).

## Ziel und Regeln

Löst mindestens **zwei** Fehlerfälle. Beide Teilnehmer lesen die Logs und müssen den Weg von der Hypothese zum Minimalfix erklären können. Arbeitet in einem gemeinsam festgelegten eigenen Trainingsprojekt in **ppedv-courses**; verändert keine fremden Pipelines oder Ressourcen.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Testaufbau und erster Fall | 20 Min | Fehler reproduziert, belegt, korrigiert |
| Zweiter Fall | 20 Min | Zweites vollständiges Diagnoseprotokoll |
| Erklärung und Abnahme | 10 Min | Ursache, Minimalfix und Vorbeugung nachvollziehbar |

Die Hinweise zur Korrektur sind unten eingeklappt. Öffnet sie erst nach eigener Hypothese. Erwartete Fehlermeldungen sind Anhaltspunkte; dokumentiert die tatsächlich angezeigte Meldung aus eurem Run.

## 1. Testpipeline und Branches vorbereiten

1. Öffnet **Repos → Files → orderflow-app → main** und prüft den Ordner [`broken/`](../broken/).
2. Erstellt für jeden gewählten Fall einen eigenen Branch, beispielsweise `feature/lab07-b-<kuerzel>`, aus einem gültigen `main`.
3. Erstellt unter **Pipelines → New pipeline → Azure Repos Git → orderflow-app → Existing Azure Pipelines YAML file** eine separate Testpipeline mit dem gewählten Branch und der Datei des Falls.
4. Benennt sie eindeutig, etwa `orderflow-debug-b-<kuerzel>`. Verändert nicht den YAML-Pfad von `orderflow-ci` oder `orderflow-release` für die Fälle A–E.
5. Startet manuell und wählt ausdrücklich den Testbranch. Die Fehlerdateien verwenden `trigger: none`; ein Commit startet sie nicht automatisch. Nach jedem Fix ist ein neuer manueller Run auf dem korrigierten Commit nötig.
6. Bei Fall A kann die Schemafehler-Prüfung bereits das Speichern/Starten verhindern. Das ist der erwartete Reproduktionsbeleg; eine Run-ID gibt es dann noch nicht.

## 2. Vor jeder Änderung das Diagnoseprotokoll ausfüllen

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

## 3. Die Fehlerfälle bearbeiten

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
4. Für den positiven main-Nachweis übernehmt ihr die korrigierte Übungsdatei per regulärem PR ins eigene Trainingsprojekt, sofern das mit dem Trainer vorgesehen ist. Startet danach explizit **main**. Alternativ analysiert einen vorbereiteten korrigierten main-Run des Trainers; bezeichnet den eigenen Feature-Branch-Run nicht als main-Nachweis.

<details>
<summary>Korrekturhinweis</summary>

```yaml
condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

`Build.SourceBranch` liefert den vollständigen Ref, nicht nur `main`. Behaltet `succeeded()` bei. Vorbeugung: Branchwert, Condition und gewünschtes Verhalten auf beiden Branchtypen getrennt prüfen.
</details>

### Fall F – Environment-Autorisierung

**Setup:** `orderflow-release` und die simulierten Trainings-Environments aus Lab06. Wählt nur euer eigenes Trainings-Environment und stellt sicher, dass gerade kein anderer Kurs-Run darauf angewiesen ist.

1. Sichert unter **Pipelines → Environments → orderflow-prod → … → Security** den Ausgangsstand der **Pipeline permissions**. Notiert den exakten Pipeline-Namen und dass Open access deaktiviert ist.
2. Entfernt ausschließlich die Zuordnung von **orderflow-release**. Lasst Benutzerrollen, Environment und Approval-Check unverändert.
3. Startet einen neuen Release-Run. Erwartet eine Meldung über ein nicht autorisiertes oder nicht auffindbares Environment beziehungsweise eine Autorisierungsanforderung. Der Fehler kann bereits vor der Ausführung der Stages auftreten.
4. Speichert Run/Validierung und die genaue Meldung. Erteilt noch keine pauschale Autorisierung über einen Run-Dialog.
5. Prüft zuerst Schreibweise und Existenz des Environments, dann die gezielte Pipeline Permission.
6. Öffnet als Ressourcenverantwortlicher dieselbe **Security → Pipeline permissions → +** und fügt genau **orderflow-release** wieder hinzu.
7. Startet einen neuen Run. Erwartet erfüllte Ressourcenautorisierung; der Produktions-Approval kann weiterhin warten. Das ist kein fortbestehender Berechtigungsfehler.
8. Belegt den wiederhergestellten Endstand. Kein Open access als Reparatur.

<details>
<summary>Korrekturhinweis</summary>

Benutzerrolle des handelnden Administrators, Pipeline-Autorisierung und menschlicher Approval sind getrennt. Nur die entfernte Pipeline-Zuordnung wiederherstellen. Keine neue Ressource mit ähnlichem Namen und keine zusätzlichen Projektadministratorrechte anlegen.
</details>

## 4. Abnahme

- [ ] Mindestens zwei Fälle wurden vor der Änderung reproduziert.
- [ ] Diagnoseprotokolle enthalten Phase, Meldung, Hypothese und Minimalfix.
- [ ] Nach jedem Fix wurde der neue Commit tatsächlich ausgeführt oder validiert.
- [ ] Grün, erwartetes Warten und erwartetes Überspringen werden unterschieden.
- [ ] Entfernte Autorisierungen sind wiederhergestellt.
- [ ] Beide Teilnehmer können mindestens einen Fall erklären und eine passende Vorbeugung nennen.

Erklärt euren Fall anschließend einem anderen Zweierteam, ohne sofort den korrigierten Code zu zeigen: Beginnt mit Symptom, Phase und Beleg.

## Bonus – Eine begründete Optimierung

Wählt genau eine Änderung an einer grünen Pipeline und belegt den Nutzen: präzisere geheimnisfreie Logs, weniger unnötige CI-Runs, wiederverwendbare Schritte oder tatsächlich unabhängige parallele Tests. Bei Templates muss `templates/*` im relevanten Pfadfilter berücksichtigt werden. Setzt Retries nur bei nachgewiesenen vorübergehenden Fehlern ein; sie beheben weder falsche Pfade noch fehlende Rechte.

## Portalhilfe

- [Pipelinebedingungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions?view=azure-devops)
- [Vordefinierte Variablen](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops)
- [Environment-Autorisierung](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
