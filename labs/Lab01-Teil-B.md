# Lab 01 – Teil B: Organisation, Projekt und Ressourcen

**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit

**Vor Beginn:** Verwende dein persönliches Basic-Kurskonto und das zugeordnete Projekt aus den [Kursvoraussetzungen](../KURSSTART.md). Behalte deine Projektadministratorrechte für die technischen Labs.

## Ziel

Ein privates Projekt mit Teams, Areas, Sprints und Repositories für OrderFlow einrichten.

## Einstieg

Beginne Teil B nach der gesonderten Aufforderung des Trainers. Prüfe im Kontomenü deinen Namen und verwende in **ppedv-courses** den Projektnamen aus der [Teilnehmerzuordnung](../KURSSTART.md#teilnehmerprojekte-und-kürzel).

## 1. Privates Projekt erstellen

1. Öffne [ppedv-courses](https://dev.azure.com/ppedv-courses) → **New project**.
2. Setze **Project name** auf deinen zugeteilten Projektnamen, **Description** auf `devops-2 – persönliches OrderFlow-Trainingsprojekt`, **Visibility: Private**, **Advanced → Version control: Git**, **Work item process: Basic**. Dies ist die Prozessauswahl für Boards, unabhängig vom ebenfalls Basic genannten Access Level deines Kontos. Wähle **Create**.
3. Öffne **Project settings → Overview** und prüfe Name, Private, Git und Basic. Boards, Repos und Pipelines bleiben aktiviert.
4. Öffne **Project settings → Permissions → Project Administrators → Members** und prüfe deine Mitgliedschaft. Sie wird für die weiteren Konfigurationsaufgaben benötigt; behalte sie während des Kurses.
5. Prüfe die Projektbezeichnung oben links.

Bei einer Unterbrechung setzt du im vorhandenen Projekt am ersten unvollständigen Schritt fort. Bei einem Fehler der Projektanlage unterstützt dich der Trainer.

## 2. Teams und eigene Mitgliedschaft

1. Öffne **Project settings → Teams**, öffne das automatisch angelegte Standardteam und benenne es unter **Settings** in `OrderFlow Product` um.
2. Öffne **Members** und prüfe, dass dein persönliches Kurskonto Mitglied ist. Füge über **Add** genau dein Konto hinzu, wenn die Mitgliederliste nach der Anlage leer ist. Kontrolliere den vollständigen Kontonamen im Suchergebnis.
3. Erstelle unter **Teams → New team** zusätzlich `Platform Enablement`. Deaktiviere die automatische Team-Area-Anlage im Erstellungsdialog; die Areas werden im nächsten Schritt mit festen Namen erstellt. Füge dein eigenes Konto als Mitglied hinzu.

## 3. Areas zuordnen

1. Öffne **Project settings → Project configuration → Areas**. Erstelle über **Projektknoten → … → New child** die Areas `OrderFlow` und `Platform` direkt unter dem Projekt.
2. Öffne **Project settings → Team configuration → Areas** und wähle oben **OrderFlow Product**.
3. Füge über **Select area(s)** `<projekt>\OrderFlow` hinzu und setze diesen Pfad über **… → Set as default** als Standard.
4. Entferne den Projektwurzel-Pfad aus der **Teamzuordnung**, sobald der neue Standard gesetzt ist. Lösche keinen Area Path aus dem Projekt. Die Liste des Teams soll nur `OrderFlow` enthalten.
5. Wiederhole die Zuordnung für **Platform Enablement** mit `<projekt>\Platform` als einzigem Standardeintrag.
6. Öffne beide Teamseiten erneut und prüfe jeweils Teamname und zugeordnete Area.

## 4. Feste Kurssprints einstellen

1. Öffne **Project settings → Project configuration → Iterations**.
2. Erstelle unter dem Projektknoten die folgenden Iterationen und setze über **Edit** die Termine im Kalender:

   | Iteration | Start | Ende |
   |---|---|---|
   | Sprint 01 | 28.09.2026 | 09.10.2026 |
   | Sprint 02 | 12.10.2026 | 23.10.2026 |

3. Öffne **Team configuration → Iterations → OrderFlow Product**. Setze **Backlog iteration** auf den Projektwurzel-Pfad, füge über **Select iteration(s)** beide Sprints hinzu und setze **Default iteration: @CurrentIteration**.
4. Wiederhole diese Einstellungen für **Platform Enablement**.
5. Öffne **Boards → Sprints**, wähle das jeweilige Team und kontrolliere Termine und Zuordnung. An den Kurstagen 5./6. Oktober ist Sprint 01 aktuell. Eine spätere Wiederholung verändert die angegebenen Kurstermine nicht; außerhalb des Zeitraums ist eine fehlende aktuelle Iteration erwartbar.

## 5. App-Repository importieren

1. Öffne **Repos → Files → Repositoryauswahl → Import repository**.
2. Setze **Repository type: Git**, **Clone URL: `https://github.com/rocom-service/devops-lab-repo.git`**, **Name: `orderflow-app`**. **Requires authorization** bleibt ausgeschaltet: die Kursquelle ist öffentlich.
3. Wähle **Import** und warte auf den Abschluss. Importiere nicht über bereits befüllte Dateien; bei Wiederaufnahme prüfst du zunächst deren Bestand.
4. Wähle `orderflow-app` und `main`. Kontrolliere diese 14 Dateien direkt ab Repositorywurzel:

   ```text
   README.md
   azure-pipelines.start.yml
   azure-pipelines.solution.yml
   azure-pipelines.multistage.yml
   scripts/build.ps1
   scripts/test.ps1
   src/version.txt
   src/release-notes.txt
   templates/build-steps.yml
   broken/01_yaml_structure.yml
   broken/02_wrong_path.yml
   broken/03_missing_variable.yml
   broken/04_artifact_name.yml
   broken/05_condition.yml
   ```

   Zusätzliche Anleitungen unter `labs/` sind zulässig. `scripts/` und die Pipeline-Dateien dürfen nicht unter einem zusätzlichen `lab-repo/`-Unterordner liegen. Die aktive Datei `azure-pipelines.yml` legst du erst in Lab04 an.
5. Öffne **Repos → Branches**. Markiere `main` über **… → Set as default branch** als Standard; eine reine Auswahl im Dateibrowser genügt nicht. Bereits gesetzter Standard bleibt bestehen.
6. Öffne `src/version.txt` und prüfe `1.0.0`. Die fehlerhaften Dateien unter `broken/` bleiben zunächst unverändert.

**Falls der Import fehlschlägt:** Bitte den Trainer um Unterstützung, bevor du mit dem Repository weiterarbeitest.

## 6. Infrastruktur-Repository anlegen

1. Öffne **Repos → Files → Repositoryauswahl → New repository**. Wähle **Git**, Name **orderflow-infra**, **Add a README**, und erstelle das Repository.
2. Prüfe **Repos → Branches → main** als Default. Erzeugt die Initialisierung einen anders benannten Branch, erstelle `main` aus dessen aktuellem Stand und setze `main` als Default.
3. Prüfe selbst den Zwischenstand: privates Basic-Projekt, zwei Teams mit eigenen Areas, beide Sprints je Team und beide Repositories.

Das Infra-Repository steht im Szenario für Infrastrukturdefinitionen und Umgebungskonfigurationen. Für die simulierten Kursdeployments bleibt die erzeugte README ausreichend.

## 7. NextFlow ergänzen

**Szenario:** Eine zweite Produktlinie nutzt denselben Basic-Prozess, dieselbe Projektverwaltung und dieselben Plattformdienste. Für diese Übung wird deshalb ein weiteres Team im bestehenden Projekt angelegt.

1. Besprecht kurz: Welche zusätzliche Anforderung würde für NextFlow ein eigenes Projekt nötig machen?
2. Öffne **Project settings → Teams → New team**. Erstelle **NextFlow Product**, ohne automatische Area-Anlage, und füge ausschließlich dein eigenes Kurskonto als Mitglied hinzu.
3. Erstelle unter **Project configuration → Areas** die Area `NextFlow` direkt unter dem Projektknoten.
4. Setze unter **Team configuration → NextFlow Product → Areas** `<projekt>\NextFlow` als einzigen Standardpfad.
5. Setze unter **Iterations** die Projektwurzel als Backlog iteration, `@CurrentIteration` als Default und wähle Sprint 01 und Sprint 02 aus.
6. Öffne **Boards → Boards** und **Boards → Sprints** für OrderFlow Product und NextFlow Product. Prüfe die getrennten Teamansichten und die Termine. Ein Team oder Area Path erteilt keine eigenen Repositoryrechte.

## Ergebnis prüfen

Gehe die folgenden Punkte direkt im Portal durch:

- [ ] Projektübersicht mit deinem Projektnamen, Private, Git und Basic.
- [ ] Drei Teams mit deinem eigenen Konto als Mitglied.
- [ ] Area-Baum und eindeutige Standardarea jedes Teams.
- [ ] Sprinttermine und beide zugewiesenen Sprints je Team.
- [ ] App-Repo mit den 14 Originaldateien auf `main` und Default-Branch-Markierung.
- [ ] Infra-Repo mit README und `main` als Default Branch.
- [ ] Getrennte Teamansichten für OrderFlow und NextFlow.

Zurück zum [Partnergespräch in Teil A](Lab01-Teil-A.md).
