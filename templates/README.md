# Vier Template-Arten

Die Beispiele zu Folie 16 verwenden die vorhandenen OrderFlow-Skripte. Die drei Include-Templates werden unter `steps:`, `jobs:` oder `stages:` eingebunden. Das Extends Template wird über `extends:` zum Rahmen der Pipeline.

| Art | Datei | Enthält |
| --- | --- | --- |
| Step Template | [build-steps.yml](build-steps.yml) | Quellcode prüfen und Paket erstellen |
| Job Template | [build-jobs.yml](build-jobs.yml) | Agent Pool, Checkout, Build-Schritte und Paket veröffentlichen |
| Stage Template | [build-stages.yml](build-stages.yml) | Eine Build-Stage mit dem Job Template |
| Extends Template | [pipeline-extends.yml](pipeline-extends.yml) | Vorgegebener Pipeline-Aufbau mit begrenzten Eingaben |

Die Wiederverwendung verläuft so:

```text
pipeline-extends.yml
  build-stages.yml
    build-jobs.yml
      build-steps.yml
```

## Einbindung ausprobieren

Jedes der folgenden Beispiele ist eine **eigene Alternative** für eine Pipeline-YAML in der Wurzel des Lab-Repositorys. Die Template-Dateien selbst werden nicht als Einstiegspunkt ausgewählt. `trigger: none` ermöglicht einen manuellen Start ohne CI-Trigger.

### 1. Step Template

Der Aufrufer stellt den Agent Pool und den Checkout bereit. Das Template fügt zwei Tasks ein. Dieses Beispiel erstellt das Paket auf dem Agent, veröffentlicht es aber noch nicht als Pipeline-Artefakt.

```yaml
trigger: none

pool:
  vmImage: ubuntu-latest

steps:
- checkout: self
- template: templates/build-steps.yml
  parameters:
    configuration: Release
```

### 2. Job Template

Das Template liefert einen vollständigen Job einschließlich Agent Pool und Artefaktveröffentlichung.

```yaml
trigger: none

jobs:
- template: templates/build-jobs.yml
  parameters:
    jobName: VerifyAndPackage
    configuration: Debug
```

### 3. Stage Template

Das Template fügt eine vollständige Stage ein. Weitere Stages können in der aufrufenden Pipeline ergänzt werden.

```yaml
trigger: none

stages:
- template: templates/build-stages.yml
  parameters:
    stageName: Build
    configuration: Release
```

### 4. Extends Template

Das Template bestimmt den Pipeline-Aufbau. In diesem Beispiel ist nur `configuration` mit den Werten `Debug` und `Release` als Eingabe vorgesehen. Agent Pool, Stage und Build-Ablauf sind festgelegt. Zusätzliche frei übergebene Steps, Jobs oder Stages sind nicht vorgesehen.

```yaml
trigger: none

extends:
  template: templates/pipeline-extends.yml
  parameters:
    configuration: Release
```

Ein Extends Template enthält kein eigenes `extends:`-Schlüsselwort als Typkennzeichnung. Entscheidend ist, dass die aufrufende Pipeline es über `extends:` verwendet.

## Hinweise

- Template-Verweise sind relativ zur jeweiligen YAML-Datei. Deshalb steht im Job Template nur `build-steps.yml`. Die Skriptpfade beziehen sich auf das ausgecheckte Repository.
- Alle Beispiele verwenden standardmäßig `ubuntu-latest` und benötigen einen verfügbaren Microsoft-hosted Agent.
- Bei mehrmaliger Einbindung eindeutige Job- bzw. Stage-Namen und unterschiedliche `artifactName`-Werte vergeben.
- Für verbindliche Vorgaben müssen auch die Templates geschützt werden. Ein konfigurierter **Required template check** an einer geschützten Ressource kann deren Nutzung an ein bestimmtes Extends Template binden. Die bloße Existenz der Datei erzwingt dies nicht.

[Microsoft-Dokumentation zu Templates](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops)
