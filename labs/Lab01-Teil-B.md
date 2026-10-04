# Lab 01 – Organisation, Projekt und Ressourcen

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/01_Organisation_Projekt_Ressourcen.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Vor Beginn:** [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md) lesen. **Akteur Teil B:** du mit deinem persönlichen Basic-Kurskonto. Projektname und Kürzel stehen in der Tabelle „Teilnehmerprojekte und Kürzel“ in den Kursvoraussetzungen.

## Ziel

Eine sinnvolle Azure-DevOps-Struktur für ein Produktteam entwerfen und die wichtigsten Projektressourcen einrichten.

Gesamtzeit: 85 Minuten in zwei Teilen.

- Teil A: 25 Minuten DevOps-/Struktur-Entscheidung
- Teil B: 60 Minuten Konfiguration im Portal

## Arbeitsform

- Teil A wird zu zweit bearbeitet.
- Teil B bearbeitet jeder Teilnehmer einzeln in seinem eigenen Trainingsprojekt.

## Szenario

Contoso entwickelt den Dienst „OrderFlow“. Ein Produktteam aus Entwicklung, QA und Betrieb liefert gemeinsam. Zusätzlich arbeitet ein externer Reviewer zeitweise mit.

## Teil A – DevOps-Gesundheitscheck

Beginnt Teil A nach der Aufforderung des Trainers.

Arbeitsvorlage: [Teilnehmer-Template (SVG)](../../labs/01_Teil_A_DevOps_Gesundheitscheck_Template.svg). Ergänzt die freien Felder und passt Rollen und fachliche Grenzen bei Bedarf an. Markiert den Wartepunkt direkt am Wertstrom. Unter Windows: Öffne die SVG im Browser, nimm die Vorlage mit `Windows+Umschalt+S` auf, öffne Paint und füge sie mit `Strg+V` ein. Ergänze Textfelder und Markierungen mit den Text-/Zeichenwerkzeugen und speichere `lab01-gesundheitscheck.png` in `devops-2-nachweise/lab01-durchfuehrung`. Bei Partnerarbeit bespricht ihr die Inhalte gemeinsam; jeder kann sie direkt in seiner eigenen Kopie eintragen.

**Akteure:** du und eine weitere teilnehmende Person. Bearbeitet gemeinsam dieselbe Skizze; jeder speichert eine Kopie in seiner eigenen Lab01-Ablage. Es werden weder Kurskonten noch Kennwörter geteilt. Bearbeitet zu zweit:

1. Skizziert den Wertstrom von einer Anforderung bis zum Feedback aus dem Betrieb.
2. Markiert die längste Wartezeit und ein fehlendes oder verspätetes Feedbacksignal.
3. Zeichnet beteiligte Teams, fachliche Verantwortungsgrenzen und wichtige Ressourcen ein.
4. Formuliert eine kleine, testbare Verbesserung für den wahrscheinlichsten Engpass.

### Abnahme

Die Skizze enthält mindestens:

- den Weg einer Änderung bis zum Betriebsfeedback,
- den wahrscheinlichsten Wartepunkt,
- ein fehlendes oder verspätetes Feedbacksignal,
- beteiligte Teams oder Rollen und ihre fachlichen Verantwortungsgrenzen,
- eine testbare Verbesserungshypothese.

Die konkrete Abbildung mit Azure-DevOps-Projekten, Teams und Area Paths folgt nach der Einführung dieser Begriffe in Teil B.

## Teil B – Projekt und Ressourcen im Portal einrichten

Beginne Teil B erst nach der gesonderten Aufforderung des Trainers. Melde dich mit deinem persönlichen Kurskonto gemäß [Konto und Anmeldung](../../VORAUSSETZUNGEN.md#konto-und-anmeldung) an und prüfe deinen Namen im Kontomenü.

**Akteur für alle folgenden Schritte: du.** Verwende die Organisation **ppedv-courses** und den Projektnamen aus [Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md#teilnehmerprojekte-und-kürzel). `orderflow-solutions` ist das bestehende Lösungsprojekt und wird nicht bearbeitet. Der Kursadministrator hat die in den [Voraussetzungen](../../VORAUSSETZUNGEN.md) genannten organisationsweiten Aufgaben vor Kursbeginn zu erledigen.

### 1. Privates Projekt erstellen

1. Öffne [ppedv-courses](https://dev.azure.com/ppedv-courses) → **New project**.
2. Setze **Project name** auf deinen Tabellennamen, **Description** auf `devops-2 – persönliches OrderFlow-Trainingsprojekt`, **Visibility: Private**, **Advanced → Version control: Git**, **Work item process: Basic**. Dies ist die Prozessauswahl für Boards, unabhängig vom ebenfalls Basic genannten Access Level deines Kontos. Wähle **Create**.
3. Öffne **Project settings → Overview** und prüfe Name, Private, Git und Basic. Boards, Repos und Pipelines bleiben aktiviert.
4. Öffne **Project settings → Permissions → Project Administrators → Members** und prüfe deine Mitgliedschaft. Sie wird für die weiteren Konfigurationsaufgaben benötigt; behalte sie während des Kurses.
5. Speichere die Projekt-URL in deinem Lab01-Protokoll. Kontrolliere in jedem weiteren Lab die Projektbezeichnung oben links.

Bei einer Wiederaufnahme nach Unterbrechung öffnest du dein bereits erstelltes Projekt aus der Tabelle und setzt am ersten unvollständigen Schritt fort. Erstelle kein zweites gleichnamiges Projekt und lösche keine vorhandenen Inhalte. Ein tatsächlicher Fehler bei der Projektanlage wird nach dem Fehlerweg in den Kursvoraussetzungen behoben; die Anleitung setzt kein unbekanntes Ersatzprojekt voraus.

### 2. Teams und eigene Mitgliedschaft

1. Öffne **Project settings → Teams**, öffne das automatisch angelegte Standardteam und benenne es unter **Settings** in `OrderFlow Product` um.
2. Öffne **Members** und prüfe, dass dein persönliches Kurskonto Mitglied ist. Füge über **Add** genau dein Konto hinzu, wenn die Mitgliederliste nach der Anlage leer ist. Kontrolliere den vollständigen Kontonamen im Suchergebnis.
3. Erstelle unter **Teams → New team** zusätzlich `Platform Enablement`. Deaktiviere die automatische Team-Area-Anlage im Erstellungsdialog; die Areas werden im nächsten Schritt mit festen Namen erstellt. Füge dein eigenes Konto als Mitglied hinzu.
4. Notiere dich als Verantwortlichen beider Teams. Weitere Teilnehmerkonten werden nicht hinzugefügt.

### 3. Areas zuordnen

1. Öffne **Project settings → Project configuration → Areas**. Erstelle über **Projektknoten → … → New child** die Areas `OrderFlow` und `Platform` direkt unter dem Projekt.
2. Öffne **Project settings → Team configuration → Areas** und wähle oben **OrderFlow Product**.
3. Füge über **Select area(s)** `<projekt>\OrderFlow` hinzu und setze diesen Pfad über **… → Set as default** als Standard.
4. Entferne den Projektwurzel-Pfad aus der **Teamzuordnung**, sobald der neue Standard gesetzt ist. Lösche keinen Area Path aus dem Projekt. Die Liste des Teams soll nur `OrderFlow` enthalten.
5. Wiederhole die Zuordnung für **Platform Enablement** mit `<projekt>\Platform` als einzigem Standardeintrag.
6. Öffne beide Teamseiten erneut und sichere jeweils einen Screenshot mit Teamname und Area.

### 4. Feste Kurssprints einstellen

1. Öffne **Project settings → Project configuration → Iterations**.
2. Erstelle unter dem Projektknoten die folgenden Iterationen und setze über **Edit** die Termine im Kalender:

   | Iteration | Start | Ende |
   |---|---|---|
   | Sprint 01 | 28.09.2026 | 09.10.2026 |
   | Sprint 02 | 12.10.2026 | 23.10.2026 |

3. Öffne **Team configuration → Iterations → OrderFlow Product**. Setze **Backlog iteration** auf den Projektwurzel-Pfad, füge über **Select iteration(s)** beide Sprints hinzu und setze **Default iteration: @CurrentIteration**.
4. Wiederhole diese Einstellungen für **Platform Enablement**.
5. Öffne **Boards → Sprints**, wähle das jeweilige Team und kontrolliere Termine und Zuordnung. An den Kurstagen 5./6. Oktober ist Sprint 01 aktuell. Eine spätere Wiederholung verändert die angegebenen Kurstermine nicht; außerhalb des Zeitraums ist eine fehlende aktuelle Iteration erwartbar.

### 5. App-Repository importieren

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

**Nur bei tatsächlich fehlgeschlagenem GitHub-Import:** Verwende die mit diesem Kurspaket gelieferten Originaldateien im Ordner [lab-repo](..). Lege unter **Repos → Files → Repositoryauswahl → New repository** das Git-Repo `orderflow-app` mit README an; verwende ein durch den fehlgeschlagenen Import bereits entstandenes leeres Ziel weiter. Ersetze dessen README durch die mitgelieferte README. Lege die übrigen 13 Textdateien jeweils über **… → New → File** mit exakt den oben aufgeführten Pfaden an, kopiere den vollständigen Inhalt der gleichnamigen lokalen Datei und committe auf `main`. Verzeichnisse entstehen aus dem Dateipfad. Kontrolliere danach dieselbe Dateiliste und den Default Branch. Dies ist ein eigenständig ausführbarer Portalweg ohne Git-CLI, PAT oder weiteren Zugang. Eine vorhandene befüllte Lösungsdatei wird nicht ungeprüft überschrieben.

### 6. Infrastruktur-Repository anlegen

1. Öffne **Repos → Files → Repositoryauswahl → New repository**. Wähle **Git**, Name **orderflow-infra**, **Add a README**, und erstelle das Repository.
2. Öffne `README.md → Edit` und speichere diesen Text mit Commit-Nachricht `docs: describe infrastructure repository`:

   ```markdown
   # OrderFlow Infrastructure

   Zweck: Infrastrukturdefinitionen und Umgebungskonfigurationen für OrderFlow.
   Verantwortlich: OrderFlow Product, unterstützt durch Platform Enablement.
   Trainings-Environments: orderflow-staging und orderflow-prod.
   Die Kursdeployments sind Simulationen ohne Azure-Ressourcen.
   Geheimnisse werden nicht im Repository gespeichert.
   ```

3. Prüfe **Repos → Branches → main** als Default. Erzeugt die Initialisierung einen anders benannten Branch, erstelle `main` aus dessen aktuellem Stand und setze `main` als Default.
4. Prüfe selbst den Zwischenstand: privates Basic-Projekt, zwei Teams mit eigenen Areas, beide Sprints je Team und beide Repositories. Sichere die Nachweise in deiner Lab01-Ablage.

### 7. NextFlow ergänzen

**Szenario:** Eine zweite Produktlinie nutzt denselben Basic-Prozess, dieselbe Projektverwaltung und dieselben Plattformdienste. Für diese Übung wird deshalb ein weiteres Team im bestehenden Projekt angelegt.

1. Schreibe zwei bis drei Sätze, weshalb getrennte Backlogs hier genügen und unter welchen fachlichen Anforderungen ein eigenes Projekt sinnvoll wäre.
2. Öffne **Project settings → Teams → New team**. Erstelle **NextFlow Product**, ohne automatische Area-Anlage, und füge ausschließlich dein eigenes Kurskonto als Mitglied hinzu.
3. Erstelle unter **Project configuration → Areas** die Area `NextFlow` direkt unter dem Projektknoten.
4. Setze unter **Team configuration → NextFlow Product → Areas** `<projekt>\NextFlow` als einzigen Standardpfad.
5. Setze unter **Iterations** die Projektwurzel als Backlog iteration, `@CurrentIteration` als Default und wähle Sprint 01 und Sprint 02 aus.
6. Öffne **Boards → Boards** und **Boards → Sprints** für OrderFlow Product und NextFlow Product. Prüfe die getrennten Teamansichten und die Termine. Ein Team oder Area Path erteilt keine eigenen Repositoryrechte.

## Abnahme und Ablage

Speichere in `lab01-durchfuehrung` deine Skizze aus Teil A, das Protokoll und Screenshots dieser Einstellungen:

- [ ] Projektübersicht mit deinem Projektnamen, Private, Git und Basic.
- [ ] Drei Teams mit deinem eigenen Konto als Mitglied.
- [ ] Area-Baum und eindeutige Standardarea jedes Teams.
- [ ] Sprinttermine und beide zugewiesenen Sprints je Team.
- [ ] App-Repo mit den 14 Originaldateien auf `main` und Default-Branch-Markierung.
- [ ] Infra-Repo mit gespeicherter Zweckbeschreibung.
- [ ] Schriftliche Begründung für NextFlow im selben Projekt.

