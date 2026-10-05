# Lab 07 – Troubleshooting Challenge

**Start:** Beginne dieses Lab nach Aufforderung des Trainers.
**Dauer:** 50 Minuten · **Arbeitsform:** Einzelarbeit, gemeinsame mündliche Auswertung
**Umgebung:** Persönliches Kurskonto im zugeordneten Projekt; Labs01–06 sind abgeschlossen. Verwende `orderflow-app`, den Pool Azure Pipelines und `ubuntu-latest`.

## Ziel und Ablauf

Finde die Ursache eines Fehlers anhand der tatsächlichen Meldung und prüfe eine möglichst kleine Reparatur. Pflicht sind Fall A und das kurze Transfergespräch F. Fälle B–E dienen der Vertiefung nach Aufforderung des Trainers.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Fall A einrichten, untersuchen und reparieren | 20 Min | Korrigierte Pipeline läuft erfolgreich |
| Auswertung und bei ausreichendem Fortschritt ein Fall B–E | 20 Min | Diagnoseweg mündlich erläutert bzw. weiterer Fehler bearbeitet |
| Transfer F und Abschluss | 10 Min | Autorisierung und Approval unterschieden |

## 1. Testpipeline einrichten

1. Öffne **Repos → Files → orderflow-app → main → broken/**.
2. Erstelle für Fall A den Branch `feature/lab07-a-<kuerzel>` aus `main`. Für einen weiteren Fall ersetze `a` durch dessen Buchstaben.
3. Öffne **Pipelines → New pipeline → Azure Repos Git → orderflow-app → Existing Azure Pipelines YAML file**. Wähle den Testbranch und die beim Fall genannte Datei.
4. Speichere die Pipeline als `orderflow-debug-<fall>-<kuerzel>`. Falls die Validierung bereits das Speichern verhindert, beginne mit der angezeigten Fehlermeldung und erstelle die Pipeline nach der Reparatur.
5. Die Fehlerdateien verwenden `trigger: none`. Starte nach jeder Reparatur manuell den korrigierten Commit auf deinem Testbranch. Fall E nennt ausdrücklich die zusätzlichen Prüfungen auf `main`.

Die YAML-Pfade von `orderflow-ci` und `orderflow-release` bleiben unverändert. Einen bereits wartenden passenden Run verwendest du weiter.

## 2. Fehler untersuchen

Gehe bei jedem Fall diese Fragen durch. Besprich deine Vermutung bei Bedarf mündlich mit dem Trainer:

1. In welcher Phase tritt das Problem auf?
2. Welche erste aussagekräftige Meldung oder welcher Status hilft weiter?
3. Welche Ursache vermutest du, und welche kleine Änderung würde sie beheben?
4. Zeigt der nächste Run das gewünschte Verhalten?
5. Wie ließe sich dieser Fehler künftig früher erkennen?

| Phase | Erste Orientierung |
|---|---|
| Parse/Compile | YAML-Hierarchie und Schema |
| Queue | Agent, Pool, Parallelität und Autorisierung |
| Checkout | Repository, Branch und Zugriffsrechte |
| Task | Erste Fehlermeldung im betroffenen Step |
| Artefakt | Veröffentlichung, Download und Abhängigkeiten |
| Deployment | Environment, Pipeline-Autorisierung und Checks |

Die aufklappbaren Hilfen enthalten die Lösungsrichtung. Öffne sie erst, nachdem du eine eigene Vermutung entwickelt hast.

## 3. Fehlerfälle

### Fall A – Pflicht

**Datei:** [`broken/01_yaml_structure.yml`](../broken/01_yaml_structure.yml)

**Symptom:** Die Pipeline lässt sich nicht regulär starten.
**Ziel:** Beide vorgesehenen Textausgaben erscheinen in einem erfolgreichen Run.

1. Wähle **Validate** oder **Run** und lies die tatsächliche Meldung.
2. Untersuche die Datei und überlege, welche kleinste Änderung das Problem beheben könnte.
3. Committe die Reparatur auf deinem Testbranch und starte den korrigierten Stand.
4. Prüfe beide Textausgaben im Log und erläutere mündlich die Ursache.

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

### Fall B – Vertiefung

**Datei:** [`broken/02_wrong_path.yml`](../broken/02_wrong_path.yml)

**Symptom:** Der Run scheitert, bevor die vorgesehene Quellprüfung erfolgreich abgeschlossen ist.
**Ziel:** Die Prüfung der gültigen Quelldateien läuft erfolgreich.

Starte den Fehlerstand, untersuche die erste aussagekräftige Meldung und ändere nur die vermutete Ursache. Committe und prüfe den neuen manuellen Run.

<details>
<summary>Korrekturhinweis</summary>

Ändert `filePath: script/test.ps1` zu `filePath: scripts/test.ps1`. Dies ist ein Task-/Pfadproblem; zusätzliche Berechtigungen oder ein anderer Agent lösen den Tippfehler nicht.
</details>

### Fall C – Vertiefung

**Datei:** [`broken/03_missing_variable.yml`](../broken/03_missing_variable.yml)

**Symptom:** Die Paketkonfiguration entspricht nicht zuverlässig dem vorgesehenen Wert.
**Ziel:** Das Paket enthält `Release` als Konfiguration. Ein abweichender Wert muss in der Prüfung auffallen.

Untersuche Run, Paketmetadaten und YAML gemeinsam. Prüfe auch, ob die bestehende Kontrolle einen falschen Wert tatsächlich erkennen würde. Korrigiere den Stand und starte erneut.

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

### Fall D – Vertiefung

**Datei:** [`broken/04_artifact_name.yml`](../broken/04_artifact_name.yml)

**Symptom:** Build ist erfolgreich, aber die nachfolgende Verarbeitung scheitert.
**Ziel:** Der Job in `Consume` verarbeitet das Paket aus demselben Run.

Untersuche die Meldung und das Ergebnis des Builds. Repariere die Ursache und prüfe den neuen Run.

<details>
<summary>Korrekturhinweis</summary>

Der veröffentlichte Name ist `orderflow-package`; im Download steht fälschlich `orderflow-app`. Ändert den Download auf `artifact: orderflow-package`. Nicht das Repository umbenennen und nicht ein zufällig gleichnamiges Artefakt aus einem fremden Run verwenden.
</details>

### Fall E – Vertiefung

**Datei:** [`broken/05_condition.yml`](../broken/05_condition.yml)

**Symptom:** Auf `main` ist Build erfolgreich, aber Deploy wird übersprungen.
**Ziel:** Nach erfolgreichem Build läuft Deploy auf `main`; auf einem Feature-Branch bleibt Deploy übersprungen.

1. Starte den unveränderten Fehlerstand manuell aus **main** und prüfe die Stage-Status.
2. Untersuche die Ursache und repariere sie auf `feature/lab07-e-<kuerzel>`. Prüfe dort das gewünschte Verhalten.
3. Übernimm die Änderung per regulärem PR nach den Regeln aus Lab03 nach `main`. Warte auf alle Pflichtprüfungen.
4. Starte die Testpipeline aus **main** und vergleiche mit dem Feature-Branch-Run.

<details>
<summary>Korrekturhinweis</summary>

```yaml
condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

`Build.SourceBranch` liefert den vollständigen Ref, nicht nur `main`. Behaltet `succeeded()` bei. Vorbeugung: Branchwert, Condition und gewünschtes Verhalten auf beiden Branchtypen getrennt prüfen.
</details>

### Fall F – Gemeinsamer Transfer aus Lab06

Besprecht zwei Situationen, ohne neue Runs zu starten:

- Eine Pipeline darf das Staging-Environment nicht verwenden. Würde die Zustimmung eines Production-Approvers daran etwas ändern?
- Staging ist erfolgreich, Produktion wartet auf Approval. Muss die Pipeline jetzt zusätzliche Ressourcenrechte erhalten?

Nennt jeweils die relevante Einstellung und den nächsten sinnvollen Prüfschritt. Bei Bedarf seht ihr euch die vorhandenen Runs aus Lab06 an.

<details>
<summary>Auflösung nach dem Gespräch</summary>

Im ersten Fall ist die gezielte Pipeline-Autorisierung am Environment zu prüfen. Ein Approval ersetzt diese Freigabe nicht. Im zweiten Fall wird der eingerichtete Approval geprüft und durch den benannten Approver entschieden; zusätzliche Ressourcenrechte sind dafür keine Reparatur.
</details>

## 4. Ergebnis prüfen

- [ ] Fall A läuft nach der Reparatur erfolgreich und zeigt beide vorgesehenen Ausgaben.
- [ ] Du kannst Fehlerphase, Ursache und Reparatur mündlich erklären.
- [ ] Im Transfergespräch lassen sich Pipeline-Autorisierung und Approval unterscheiden.

## Bonus – Eine Optimierung ausprobieren

Wähle nach Rücksprache eine Änderung an einer grünen Pipeline, etwa verständlichere Logs oder wiederverwendbare Schritte. Prüfe die Wirkung im passenden Run und erläutere den Nutzen mündlich. Bei Templates muss `templates/*` im CI-Pfadfilter berücksichtigt werden. Retries sind nur bei vorübergehenden Fehlern sinnvoll, nicht bei falschen Pfaden oder fehlenden Rechten.

## Portalhilfe

- [Pipelinebedingungen](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions?view=azure-devops)
- [Vordefinierte Variablen](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops)
- [Environment-Autorisierung](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
