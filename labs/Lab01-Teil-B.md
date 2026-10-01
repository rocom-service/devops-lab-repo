# Lab 01 · Teil B – Projekt und Ressourcen im Portal einrichten

**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit im eigenen Trainingsprojekt  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Eure Skizze aus Teil A zum Produkt OrderFlow liegt vor.

## Ziel und Ablauf

Übertragt zuerst eure Überlegungen aus Teil A in eine reale Azure-DevOps-Struktur. Nach einer Zwischenabnahme ergänzt ihr eine zweite Produktlinie und begründet die passende Projektgrenze.

| Phase | Zeitrahmen | Ergebnis |
|---|---|---|
| 1. OrderFlow umsetzen – Schritte 1 bis 6 | ca. 25 Minuten | Privates Projekt, Team, Areas, Sprints und zwei Repositories |
| 2. Zweite Produktlinie – Schritt 7 | ca. 20 Minuten | Begründete Strukturentscheidung und zusätzliches Produktteam |
| 3. Dokumentieren und prüfen – Schritte 8 bis 9 | ca. 15 Minuten | Ressourcenlandkarte, Screenshots und Abnahme |

Bleibt während des gesamten Labs in **ppedv-courses**. Erstellt keine neue Organisation. Nutzt ausschließlich euer Trainingsprojekt. Existiert eine Ressource dort schon, prüft und ergänzt sie; legt kein Duplikat an. Fehlen Rechte, verwendet das vom Trainer vorbereitete Projekt und meldet die konkrete fehlende Berechtigung.

Die Portalbezeichnungen sind hier auf Englisch angegeben. Je nach Sprache findet ihr etwa **Project settings / Projekteinstellungen** und **Repos / Repositorys**.

## 1. Privates Projekt erstellen oder prüfen

1. Öffnet [ppedv-courses](https://dev.azure.com/ppedv-courses). Kontrolliert den Organisationsnamen in der Adresszeile.
2. Wählt **New project**. Falls ihr ein vorbereitetes Projekt verwendet, öffnet dieses und prüft seine Einstellungen.
3. Tragt folgende Werte ein. Ersetzt `<gruppe>` durch euer vereinbartes, eindeutiges Kürzel.

   | Feld | Wert |
   |---|---|
   | Project name | `orderflow-<gruppe>` |
   | Description | `Trainingsprojekt für Contoso OrderFlow – Entwicklung, QA und Betrieb` |
   | Visibility | **Private** |
   | Advanced → Version control | **Git** |
   | Advanced → Work item process | **Agile**, sofern der Trainer nichts anderes vorgibt |

4. Wählt **Create**. Öffnet danach **Project settings → Overview** und prüft Name, Sichtbarkeit und Prozess.
5. Lasst Boards, Repos und Pipelines für die folgenden Übungen verfügbar.

**Nachweis:** Screenshot der Projektübersicht mit Name, **Private** und Prozess. Notiert die Projekt-URL.

## 2. OrderFlow-Team einrichten

1. Öffnet **Project settings → Teams**.
2. Verwendet bevorzugt das bei der Projekterstellung angelegte Standardteam: öffnet es, wählt **Settings** und ändert den Teamnamen auf `OrderFlow Product`. Speichert die Änderung.
3. Falls ein vorbereitetes Projekt ein gemeinsam genutztes Standardteam hat, verändert dieses nicht. Legt stattdessen über **New team** das Team `OrderFlow Product` an, sofern es noch fehlt.
4. Prüft unter **Members**, dass euer vorhandenes Kurskonto Mitglied ist. Fügt nur bereits für eure Gruppe vorgesehene Konten hinzu.
5. Optional: Erstellt analog `Platform Enablement`, wenn ihr in Teil A ein eigenes Plattformteam vorgesehen habt.

**Nachweis:** Teamliste sowie Teamdetails mit Namen und vorhandener Mitgliedschaft. Blendet persönliche Angaben vor einer Veröffentlichung der Screenshots aus.

## 3. Area Paths anlegen und dem Team zuordnen

1. Öffnet **Project settings → Project configuration → Areas**.
2. Wählt beim Projektknoten **… → New child** und legt `OrderFlow` an.
3. Legt auf derselben Ebene `Platform` an. Falls die Team-Erstellung bereits einen passenden Area Path erzeugt hat, verwendet diesen, statt ihn doppelt anzulegen.
4. Öffnet **Project settings → Team configuration → Areas**. Wählt oben ausdrücklich das Team **OrderFlow Product**.
5. Wählt **Select area(s)** und fügt `<projekt>\OrderFlow` hinzu.
6. Wählt beim hinzugefügten Pfad **… → Set as default**. Der Standard-Area-Path muss `<projekt>\OrderFlow` sein.
7. Prüft, dass das Team nur seine vorgesehenen Areas umfasst. Entfernt gegebenenfalls den Projektwurzel-Pfad **aus der Teamzuordnung**, nachdem der neue Standard gesetzt wurde. Löscht dabei keinen Area Path aus der Projektkonfiguration. So gelangen `Platform` und später die zweite Produktlinie nicht automatisch in das OrderFlow-Board.
8. Falls ihr `Platform Enablement` angelegt habt, wiederholt die Teamzuordnung mit `<projekt>\Platform` als Standard.

**Sollzustand:** `OrderFlow Product → OrderFlow`; optional `Platform Enablement → Platform`. Für die hier flache Struktur werden keine Unter-Areas benötigt. Area Paths ordnen Work Items fachlich zu; sie vergeben keine Repositoryrechte.

**Nachweis:** Screenshot des Area-Baums und je konfiguriertem Team der Areas mit erkennbarer Standardzuordnung.

## 4. Zwei Sprints konfigurieren

1. Öffnet **Project settings → Project configuration → Iterations**.
2. Legt unter dem Projektknoten über **New child** die Iterationen `Sprint 01` und `Sprint 02` an. Öffnet jeweils **Edit** und setzt Start- und Enddatum.
3. Verwendet die Kursvorgaben. Für den Kurs am 5./6. Oktober 2026 passen beispielsweise:

   | Iteration | Start | Ende |
   |---|---|---|
   | Sprint 01 | 05.10.2026 | 16.10.2026 |
   | Sprint 02 | 19.10.2026 | 30.10.2026 |

   Bearbeitet ihr das Lab an einem anderen Datum, verschiebt beide Zeiträume so, dass der heutige Tag im ersten Sprint liegt und der zweite anschließend folgt. Vermeidet überlappende Sprints. Bei englischem Datumsformat nutzt den Kalender zur eindeutigen Auswahl.
4. Öffnet **Project settings → Team configuration → Iterations** und wählt **OrderFlow Product**.
5. Setzt **Backlog iteration** auf den Projektwurzel-Pfad `<projekt>`. Beide Sprints müssen darunter liegen.
6. Fügt über **Select iteration(s)** sowohl `Sprint 01` als auch `Sprint 02` hinzu.
7. Setzt **Default iteration** auf **@CurrentIteration**. Dadurch verwenden neue Einträge aus dem Team-Board standardmäßig den anhand der Daten aktuellen Sprint.
8. Öffnet **Boards → Sprints**, wählt **OrderFlow Product** und prüft beide Sprints und die Datumsangaben. Wenn kein Sprint als aktuell erscheint, prüft Datum und Teamzuordnung.
9. Bei einem optionalen Plattformteam weist ihr dieselben beiden Iterationen auch diesem Team zu.

**Nachweis:** Projekt-Iterationen mit Datumsangaben und Team-Iterationen mit Backlog-, Default- und ausgewählten Iterationen. Das bloße Anlegen im Projekt weist Sprints noch keinem Team zu.

## 5. App-Repository importieren und `main` prüfen

1. Öffnet **Repos → Files** im Trainingsprojekt.
2. Öffnet oben das Repository-Auswahlmenü und wählt **Import repository**.
3. Tragt ein:

   | Feld | Wert |
   |---|---|
   | Repository type | **Git** |
   | Clone URL | `https://github.com/rocom-service/devops-lab-repo.git` |
   | Requires authorization | Nicht aktivieren; die Quelle ist öffentlich |
   | Name | `orderflow-app` |

4. Startet **Import** und wartet auf den Abschluss. Über diesen Dialog entsteht das neue Repository direkt. Legt vorher keine README und keinen Initial Commit im Ziel an.
5. Falls `orderflow-app` bereits **leer** existiert, wählt stattdessen auf dessen leerer **Files**-Seite **Import** und dieselbe Clone-URL. Ist es bereits befüllt, prüft den Bestand und importiert nicht erneut darüber.
6. Kontrolliert auf dem Branch `main`, dass folgende Inhalte direkt in der Repository-Wurzel vorhanden sind:

   ```text
   README.md
   scripts/
     build.ps1
     test.ps1
   src/
     version.txt
     release-notes.txt
   azure-pipelines.start.yml
   azure-pipelines.solution.yml
   azure-pipelines.multistage.yml
   templates/
   broken/
   ```

   Zusätzliche Lab-Anleitungen im Ordner `labs/` sind in Ordnung. Die Pipeline-Dateien und `scripts/` dürfen nicht unter einem zusätzlichen Ordner `devops-lab-repo/` oder `lab-repo/` liegen.
7. Öffnet **Repos → Branches** und prüft, dass `main` als Standard markiert ist. Falls nötig, öffnet bei `main` **… → Set as default branch**. Eine Auswahl von `main` im Dateibrowser allein ändert den Default Branch nicht.
8. Öffnet zusätzlich **Project settings → Repositories → orderflow-app → Settings** und kontrolliert dort den Default Branch, sofern die Oberfläche ihn anzeigt.

**Nachweis:** Repository-Wurzel auf `main` und Branch-Liste mit Standardmarkierung. Der Import richtet noch keine ausführbare Pipeline ein; diese folgt im Pipeline-Lab.

## 6. Infrastruktur-Repository anlegen

1. Öffnet das Repository-Auswahlmenü unter **Repos → Files → New repository**.
2. Wählt **Git**, den Namen `orderflow-infra` und **Add a README**. Erstellt das Repository.
3. Öffnet `README.md`, wählt **Edit** und ersetzt den Beispieltext durch:

   ```markdown
   # OrderFlow Infrastructure

   Dieses Repository enthält Infrastrukturdefinitionen und
   Umgebungskonfigurationen für OrderFlow.

   Geplante Umgebungen: orderflow-staging und orderflow-prod.
   Zuständig: OrderFlow Product, unterstützt durch Platform Enablement.
   Geheimnisse werden außerhalb des Repositorys verwaltet.
   ```

   Passt den Zuständigkeitssatz an eure tatsächlich angelegten Teams an.
4. Wählt **Commit**, gebt beispielsweise `docs: describe infrastructure repository` ein und bestätigt den Commit auf dem vorhandenen Standardbranch. Verwendet für das Trainingsrepository ebenfalls `main`; falls der initiale Branch anders heißt, erstellt über das Branch-Menü `main` aus diesem Stand und setzt ihn in **Repos → Branches** als Default.

**Nachweis:** Repository-Name, `main` und gespeicherte README mit Zweck.

### Zwischenabnahme nach etwa 25 Minuten

Zeigt dem Trainer das private Projekt, das OrderFlow-Team mit Area/Sprints und beide Repositories. Vergleicht diese Struktur mit den Verantwortlichkeiten aus Teil A. Erst danach bearbeitet ihr die Erweiterung.

## 7. Zweite Produktlinie ergänzen

**Neue Situation:** Contoso führt eine zweite Produktlinie ein. Sie verwendet dasselbe Prozessmodell und dieselben zentralen Plattformdienste wie OrderFlow. Für diese Übung heißt sie `NextFlow`.

1. Notiert eure Entscheidung in zwei bis drei Sätzen: weiteres Team im bestehenden Projekt oder eigenes Projekt? Nennt mindestens ein fachliches und ein administratives Kriterium.
2. Prüft folgende Leitfragen: Braucht die Produktlinie getrennte Zugriffe, unabhängige Administration oder ein anderes Prozessmodell? Oder genügen getrennte Backlogs bei gemeinsamem Prozess und gemeinsamer Verwaltung?
3. **Musterentscheidung für die angegebenen Rahmenbedingungen:** ein weiteres Team und ein eigener Area Path im vorhandenen privaten Projekt. Führt dafür die folgenden Schritte aus:
   - Öffnet **Project settings → Teams → New team** und erstellt `NextFlow Product`.
   - Fügt die vorgesehenen vorhandenen Gruppenmitglieder hinzu.
   - Öffnet **Project configuration → Areas** und legt `NextFlow` direkt unter dem Projektknoten an. Falls automatisch eine Area `NextFlow Product` erzeugt wurde, könnt ihr diese zu `NextFlow` umbenennen, solange sie neu und ungenutzt ist.
   - Wählt **Team configuration → NextFlow Product → Areas** und setzt `<projekt>\NextFlow` als einzigen fachlichen Standardbereich.
   - Öffnet die **Iterations** dieses Teams. Setzt den Projektwurzel-Pfad als Backlog iteration, wählt `Sprint 01` und `Sprint 02` aus und setzt **@CurrentIteration** als Default iteration.
   - Kontrolliert in **Boards → Boards** und **Boards → Sprints**, dass ihr `OrderFlow Product` und `NextFlow Product` getrennt auswählen könnt.
4. **Falls eure begründeten Anforderungen ein eigenes Projekt verlangen:** Legt stattdessen `nextflow-<gruppe>` als privates Git-Projekt in **ppedv-courses** an. Wiederholt dort die Team-, Area- und Sprintkonfiguration aus den Schritten 2 bis 4 für `NextFlow Product` und `NextFlow`. Dokumentiert die zusätzliche Zugriffs- oder Verwaltungsgrenze. Falls euch das Create-Project-Recht fehlt, verwendet ein vorbereitetes Projekt und dokumentiert den offenen Schritt.
5. Prüft erneut die Area-Zuordnung des OrderFlow-Teams: Es soll nicht ungewollt die Work Items von NextFlow übernehmen.

Für diese Erweiterung sind keine weiteren Repositories und keine Cloudressourcen nötig. Ein eigenes Team oder eine Area erzeugt keine isolierten Repositoryrechte. Die konkrete Berechtigungsvergabe folgt im Berechtigungs-Lab.

**Nachweis:** Entscheidungsbegründung, Teamliste sowie Area- und Sprintkonfiguration des zweiten Teams. Bei zwei Projekten zusätzlich dessen Projektübersicht.

## 8. Ressourcenlandkarte und Screenshots erstellen

Ergänzt eure Skizze aus Teil A um die **tatsächlich angelegten Namen**. Verbindet Organisation, Projekt(e), Teams, Areas, Sprints und Repositories. Markiert die Grenze, die ihr für NextFlow gewählt habt.

Tragt folgende Einstellungsorte mit ihrem Zweck ein. Öffnet die erreichbaren Seiten und erstellt je einen Screenshot. Haltet lediglich fest, wo die Einstellungen liegen; die eigentliche Konfiguration der späteren Labs erfolgt dort.

| Thema | Portalpfad | Eintrag in eurer Landkarte |
|---|---|---|
| Benutzer und Access Level | **Organization settings → Users** | Organisationszugang und Lizenz-/Zugriffsstufe; Identität, MFA und Kontolebenszyklus liegen in Microsoft Entra ID |
| Projektgruppen | **Project settings → Permissions** | Projektgruppen und deren Berechtigungen |
| Repositoryrechte | **Project settings → Repositories → orderflow-app → Security** | Berechtigungen am konkreten Repository |
| Branch Policies | **Repos → Branches → main → … → Branch policies** | Qualitätsregeln für Änderungen am Branch |
| Environment-Zugriff | **Pipelines → Environments → <Environment> → Security** | Benutzer-/Gruppenrollen am Environment |
| Pipeline-Autorisierung | **Pipelines → Environments → <Environment> → Pipeline permissions** | Welche Pipelines die Ressource verwenden dürfen |

Environment-Konfiguration folgt in Lab 03/06. Gibt es noch kein Environment, fotografiert die Übersicht und markiert die beiden letzten Pfade in der Landkarte als **geplant**. Legt für den Screenshot kein Environment an. Ist eine Einstellungsseite wegen fehlender Rechte nicht sichtbar, dokumentiert genau dies; erweitert dafür keine Administratorrollen.

Speichert die Nachweise in einem lokalen Ordner `Lab01-Teil-B-Screenshots` mit folgenden Namen. Nehmt lange Einstellungsseiten bei Bedarf in mehreren Bildern auf und achtet darauf, dass Werte und Projekt-/Teamkontext lesbar sind.

| Datei bzw. Präfix | Inhalt |
|---|---|
| `01-Projekt` | Name, Organisation, Private, Prozess |
| `02-Teams` | Teamliste und Mitgliederkonfiguration |
| `03-Areas-Projekt` | Area-Baum |
| `04-Areas-OrderFlow` | Teamzuordnung und Default Area |
| `05-Iterationen-Projekt` | Beide Sprints mit Daten |
| `06-Iterationen-OrderFlow` | Backlog-, Default- und ausgewählte Iterationen |
| `07-App-Dateien` | Repository-Wurzel auf main |
| `08-App-Default-Branch` | main als Standard |
| `09-Infra-README` | Repository, main und Zweck |
| `10-NextFlow` | Zweites Team, Area, Iterationen; ggf. weiteres Projekt |
| `11-Ressourcen-Einstellungen` | Je erreichbarem Einstellungsort aus der Tabelle ein Bild |
| `12-Ressourcenlandkarte` | Endstand mit Strukturentscheidung |

Ergänzt bei einem Plattformteam dessen Area- und Iterationsnachweise. Speichert Personenlisten und Screenshots im Kurskontext; veröffentlicht keine Kontodetails oder Zugangsdaten im öffentlichen GitHub-Repository.

## 9. Ergebnisprüfung und Reflexion

- [ ] Alle Azure-DevOps-Ressourcen liegen in **ppedv-courses**.
- [ ] Das Trainingsprojekt ist privat und verwendet Git sowie den vereinbarten Prozess.
- [ ] `OrderFlow Product` besitzt eine passende Area und zwei zugeordnete, datierte Sprints.
- [ ] `orderflow-app` enthält den Lab-Stand in der Wurzel; `main` ist der Default Branch.
- [ ] `orderflow-infra` enthält eine gespeicherte README mit seinem Zweck.
- [ ] Die zweite Produktlinie wurde erst nach dem OrderFlow-Grundaufbau ergänzt.
- [ ] `NextFlow Product` hat seine eigene Area und Sprintzuordnung; die Projektwahl ist begründet.
- [ ] Ressourcenlandkarte und Screenshots belegen die Einstellungen; fehlende Rechte und geplante Ressourcen sind gekennzeichnet.

Beantwortet abschließend:

1. Was müsste bei einem späteren Projektwechsel migriert oder neu geprüft werden?
2. Warum benötigen produktive Environments und Service Connections klar benannte, eng begrenzte Verantwortliche?
3. Welche Aufgaben gehören nach Microsoft Entra ID statt in die Projektkonfiguration?

**Bonus:** Formuliert eine Namenskonvention für Projekte, Teams, Repositories, Environments und Gruppen.

## Weiterführende Portalhilfe

- [Teams und ihre Konfiguration](https://learn.microsoft.com/en-us/azure/devops/organizations/settings/manage-teams?view=azure-devops)
- [Area Paths und Teamzuordnung](https://learn.microsoft.com/en-us/azure/devops/organizations/settings/set-area-paths?view=azure-devops)
- [Iterationen und Team-Sprints](https://learn.microsoft.com/en-us/azure/devops/organizations/settings/set-iteration-paths-sprints?view=azure-devops)
- [Git-Repository importieren](https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops)

Die Anleitung folgt dem Kurs `devops-2`, Lab 01 Teil B. Der bestehende OrderFlow-Aufbau und die nachfolgende Erweiterung um das zweite Produktteam bilden zwei aufeinanderfolgende Arbeitsschritte.
