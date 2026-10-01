# Lab 02 – Benutzer, Gruppen und Berechtigungen

**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Euer privates Projekt mit `orderflow-app` und `orderflow-infra` aus [Lab 01 Teil B](Lab01-Teil-B.md) ist vorhanden.

## Ziel und Vorbereitung

Konfiguriert vier Rollen nach dem Least-Privilege-Prinzip und belegt erlaubte und verweigerte Aktionen. Alle Änderungen erfolgen im eigenen Trainingsprojekt. Nutzt vorbereitete Testidentitäten; ladet keine fremden Personen ein. Euer Administrationskonto bleibt für die Einrichtung verfügbar und dient nicht als Beweis für die Rechte einer eingeschränkten Persona.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Gruppen und Access Levels | 15 Min | Vier Gruppen, dokumentierte Mitgliedschaften |
| Projekt-, Repo- und Pipelinerechte | 25 Min | Rechte am passenden Scope |
| Wirkung prüfen und dokumentieren | 20 Min | Positive und negative Tests |

Fehlen Testkonten, richtet die Gruppen ein und lasst den Trainer mit seinem vorbereiteten Konto testen. Kennzeichnet noch nicht ausgeführte Tests als offen. Bleibt in **ppedv-courses**.

## 1. Vier Projektgruppen anlegen

1. Öffnet euer Projekt → **Project settings → Permissions → New group**.
2. Erstellt nacheinander die folgenden Gruppen. Tragt den jeweiligen Zweck in **Description** ein.

   | Gruppe | Zweck |
   |---|---|
   | `OrderFlow Developers` | App-Code entwickeln, Feature-Branches beitragen, Builds starten |
   | `OrderFlow QA` | Code, Builds und Testergebnisse lesen |
   | `OrderFlow Release Managers` | Releases prüfen und freigeben; Ressourcenverwaltung nur bei ausdrücklichem Auftrag |
   | `OrderFlow External Reviewers` | Nur App-Code lesen und Pull Requests kommentieren/prüfen |

3. Öffnet jede Gruppe → **Members → Add** und ordnet die vom Trainer genannten vorhandenen Testkonten zu.
4. Prüft **Member of**. Fügt die vier Gruppen nicht pauschal zu `Contributors`, `Readers` oder `Project Administrators` hinzu: Solche Mitgliedschaften können Rechte für weitere Repositories vererben.
5. Dokumentiert auch die sonstigen direkten und verschachtelten Gruppen der Testkonten. Entfernt breite Mitgliedschaften nur bei den für dieses Lab vorgesehenen Testkonten und nach der Kursvorgabe; verändert keine gemeinsam genutzten Organisationsgruppen.

**Nachweis:** Gruppenliste, Mitglieder und übergeordnete Gruppen jeder Persona.

## 2. Access Level getrennt von Permissions prüfen

1. Öffnet auf Organisationsebene **Organization settings → Users** und sucht die Testkonten.
2. Notiert den vorhandenen **Access level**. Für private Git-Repositories benötigen die Testkonten **Basic** oder einen passenden höherwertigen Zugriff. **Stakeholder** genügt hier nicht.
3. Fehlt die passende Zuweisung oder die Berechtigung für diese Seite, lasst den Trainer den Zugang prüfen. Bucht selbst keine kostenpflichtigen Lizenzen.
4. Erstellt folgende Tabelle. Tragt tatsächliche Werte ein.

   | Persona/Testkonto | Access Level | Direkte Gruppen | Geerbte Gruppen | Erwartete Rolle |
   |---|---|---|---|---|
   | Entwickler | | | | App-Code beitragen |
   | QA | | | | Nur lesen |
   | Release Manager | | | | Release prüfen/freigeben |
   | Externer Reviewer | | | | Nur App-Repository prüfen |

Ein Access Level schaltet Funktionen frei. Eine Permission erlaubt eine Aktion an einer Ressource. **Basic** ist deshalb kein Schreibrecht.

## 3. Minimale Projektrechte setzen

1. Öffnet **Project settings → Permissions** und wählt die erste neue Gruppe.
2. Setzt **View project-level information** auf **Allow**.
3. Lasst Projektadministration, Berechtigungsverwaltung und Löschen von Ressourcen ohne zusätzliches Allow. Wiederholt das für alle vier Gruppen.
4. Kontrolliert, ob die Oberfläche ein geerbtes Allow anzeigt. **Not set** entfernt kein Allow aus einer anderen Mitgliedschaft. Unnötige breite Mitgliedschaften sind zuerst zu bereinigen.

**Nachweis:** Projektberechtigungen jeder Gruppe mit sichtbarem Gruppennamen.

## 4. Repositoryrechte konfigurieren

1. Öffnet **Project settings → Repositories → orderflow-app → Security**. Achtet darauf, das einzelne Repository und nicht „All repositories“ zu bearbeiten.
2. Sucht jede der vier Gruppen und setzt die Rechte entsprechend dieser Sollmatrix.

   **A = Allow. N = Not set ohne geerbtes Allow.** Prüft den effektiven Zustand zusätzlich; N ist kein ausdrückliches Deny.

   | Recht auf `orderflow-app` | Developers | QA | Release Managers | External Reviewers |
   |---|---|---|---|---|
   | Read | A | A | A für Release-Prüfung | A |
   | Contribute | A | N | N | N |
   | Create branch | A | N | N | N |
   | Contribute to pull requests | A | N | N | A |
   | Force push | N | N | N | N |
   | Manage permissions / Edit policies | N | N | N | N |
   | Bypass policies when pushing / when completing pull requests | N | N | N | N |

3. Öffnet **orderflow-infra → Security**. Der externe Reviewer und QA erhalten hier kein Read-Allow. Entwicklern und Release Managern gebt ihr nur dann Zugriff, wenn die konkrete Kursaufgabe ihn erfordert.
4. Falls eine Persona weiterhin ein geerbtes Allow besitzt, ermittelt seine Herkunft. Vermeidet pauschale Deny-Regeln. Ein gezieltes Deny kommt erst infrage, wenn eine notwendige Ausnahme von einem nicht entfernbaren Allow begründet ist.
5. Prüft insbesondere den Reviewer: **Contribute to pull requests** erlaubt Review-Aktivitäten; **Contribute** für Commit-/Pushzugriff bleibt ohne Allow.

**Nachweis:** Rechte aller vier Gruppen auf `orderflow-app` sowie Read-Recht des Reviewers auf `orderflow-infra`.

## 5. Pipelinerechte vorbereiten oder setzen

Die Pipeline `orderflow-ci` entsteht in [Lab 04](Lab04.md). Existiert sie noch nicht, notiert die folgende Matrix als offene Konfiguration und holt sie direkt nach deren Erstellung nach.

1. Öffnet **Pipelines → Pipelines → orderflow-ci → … → Manage security**; je nach Oberfläche heißt der Menüpunkt **Security**.
2. Sucht die Gruppen und setzt die Rechte auf dieser Pipeline.

   | Recht | Developers | QA | Release Managers | External Reviewers |
   |---|---|---|---|---|
   | View builds / View build pipeline | A | A | A | N |
   | Queue builds | A | N | A | N |
   | Edit build pipeline | N | N | N | N |
   | Administer build permissions | N | N | N | N |

3. Benennt mit dem Trainer einen kleinen Kreis von Pipeline-Verantwortlichen, der Definition und Rechte verwalten darf. Die Fachrollen erhalten dafür keine Projektadministratorrolle.
4. Haltet fest: Wer YAML im Repository ändern darf, kann Pipelineverhalten beeinflussen. Portalrechte allein schützen diesen Code nicht; die Branch Policies folgen in [Lab 03](Lab03.md).

Environments und Approval-Rollen werden in Lab03/06 eingerichtet. Für die reine Freigaberolle sind dort **Reader** plus die Benennung als Approver vorgesehen. Eine echte Verwaltungsaufgabe benötigt gesonderte Ressourcenrechte und ist ausdrücklich zu dokumentieren.

## 6. Effektive Rechte mit getrennten Testidentitäten prüfen

1. Öffnet am Repository **Security**, sucht das konkrete Entwickler-Testkonto und prüft `Read`, `Contribute` und `Create branch` einschließlich Vererbung. Nutzt **Why?**, **Permissions** oder die angezeigte effektive Berechtigung, soweit verfügbar.
2. Wiederholt das für QA oder den externen Reviewer. Prüft zusätzlich den verweigerten Infra-Zugriff.
3. Meldet euch für Verhaltenstests mit dem jeweiligen Testkonto in einem separaten Browserprofil oder privaten Fenster an. Kontrolliert den sichtbaren Kontonamen. Eine Gruppenauswahl im Adminportal wechselt nicht die angemeldete Identität.
4. **Positivtest Entwickler:** Unter **Repos → Files → orderflow-app** einen Branch `feature/lab02-<kuerzel>` aus `main` erstellen. Eine harmlose Datei `lab02-permission-test.md` mit dem Text `Berechtigungstest Lab 02` anlegen und auf diesen Branch committen. Notiert Commit und Branch. Alternativ führt einen echten Git-Push mit dem vorbereiteten Entwicklerkonto aus.
5. **Negativtest QA:** Versucht mit QA dieselbe Datei auf dem Testbranch zu ändern und zu committen. Die Aktion muss fehlen oder verweigert werden. Kein Wechsel zum Administrationskonto als „Reparatur“.
6. **Reviewtest:** Öffnet als Entwickler einen PR vom Testbranch nach `main`. Der vorbereitete Reviewer kann ihn lesen und einen sachlichen Testkommentar hinterlassen, aber keinen Code pushen.
7. **Abgrenzungstest:** Öffnet als externer Reviewer `orderflow-infra`. Erwartet fehlenden Zugriff. Eine Repositoryliste allein ist kein vollständiger Beweis; prüft auch den direkten Repo-Link.
8. Sobald die Pipeline existiert: QA öffnet einen Run und dessen Logs, versucht aber nicht erfolgreich die Pipeline zu bearbeiten.
9. Der Test-PR muss für dieses Lab nicht zusammengeführt werden. Kennzeichnet ihn als Test und schließt ihn nach der Kursabnahme ohne Merge, wenn seine Datei nicht benötigt wird.

## 7. Abnahme

| Test | Identität | Erwartung | Tatsächliches Ergebnis | Beleg/Link |
|---|---|---|---|---|
| Feature-Branch/Commit | Entwickler | erlaubt | | |
| Code committen | QA | verweigert | | |
| PR kommentieren | Reviewer | erlaubt | | |
| Infra-Repo lesen | Reviewer | verweigert | | |
| Build/Logs ansehen | QA | erlaubt, sobald Pipeline vorhanden | | |
| Pipeline bearbeiten | QA | verweigert | | |

- [ ] Gruppenrechte sind am passenden Scope gesetzt; breite Vererbung ist geprüft.
- [ ] Die effektiven Rechte von zwei Personas wurden geprüft.
- [ ] Mindestens ein positiver und ein negativer Verhaltenstest sind belegt.
- [ ] Offene Pipeline-Tests sind für Lab04 vermerkt.

**Reflexion:** Was passiert bei Allow aus `Contributors` plus Deny? Warum genügt Stakeholder trotz Allow nicht? Wie ersetzt ihr ein Einzelrecht durch eine Gruppe ohne Zugriffsunterbrechung?

## Portalhilfe

- [Berechtigungsreferenz](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)
- [Git-Standardberechtigungen](https://learn.microsoft.com/en-us/azure/devops/organizations/security/default-git-permissions?view=azure-devops)
- [Zugriff auf Pull Requests](https://learn.microsoft.com/en-us/azure/devops/repos/git/about-pull-requests?view=azure-devops)
