# Lab 02 – Benutzer, Gruppen und Berechtigungen

**Start:** Beginne dieses Lab nach Aufforderung des Trainers.
**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit, gemeinsame mündliche Auswertung
**Umgebung:** Persönliches Basic-Kurskonto mit Projektadministratorrechten im [zugeordneten Projekt](../KURSSTART.md#teilnehmerprojekte-und-kürzel); Lab01 ist abgeschlossen.

## Ziel und Ablauf

Konfiguriere vier Rollengruppen und unterscheide Access Level, Gruppenmitgliedschaft und Ressourcenberechtigung. Die Gruppen bleiben leer. Dein administrativer Zugriff prüft dein eigenes Konto; die Wirkung auf die Fachrollen besprecht ihr anhand der Fälle in Abschnitt 6. Die Auswahl einer Gruppe im Security-Dialog wechselt nicht die angemeldete Identität.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Konto und Gruppen | 15 Min | Basic-Zugang und vier Rollengruppen geprüft |
| Area- und Repositoryrechte | 30 Min | Rechte gespeichert und Vererbung betrachtet |
| Zugriff und mündliche Auswertung | 15 Min | Eigenen Zugriff geprüft und Rollenwirkung verstanden |

## 1. Konto und Access Level prüfen

1. Öffne [Organization settings → Users](https://dev.azure.com/ppedv-courses/_settings/users), suche dein Konto und prüfe **Basic**.
2. Prüfe im Projekt unter **Project settings → Permissions → Project Administrators → Members** deine Mitgliedschaft.
3. Besprecht kurz: Worin unterscheiden sich der Featurezugang durch Basic und die Berechtigungen im Projekt?

## 2. Vier Projektgruppen anlegen

1. Öffne **Project settings → Permissions → New group**.
2. Erstelle die folgenden Gruppen mit passender **Description**:

   | Gruppe | Zweck |
   |---|---|
   | `OrderFlow Developers` | App-Code entwickeln, Feature-Branches beitragen, Builds starten |
   | `OrderFlow QA` | Code, Builds und Testergebnisse lesen |
   | `OrderFlow Release Managers` | Releases prüfen und freigeben |
   | `OrderFlow External Reviewers` | App-Code lesen und Pull Requests prüfen |

3. Prüfe jeweils **Members** und **Member of**. Füge weder dein Konto noch übergeordnete Standardgruppen hinzu. Vorhandene Mitgliedschaften bei einer Wiederaufnahme zunächst mit dem Trainer klären.
4. Setze **View project-level information: Allow**. Lasse Projektadministration, Löschen und Berechtigungsverwaltung ohne zusätzliches Allow.
5. Prüfe vorhandene Vererbung: **Not set** hebt ein Allow aus einer anderen Quelle nicht auf.

## 3. Work-Item-Bereich konfigurieren

1. Lege unter **Project settings → Project configuration → Areas** den Bereich `Lab02-Permissions` direkt unter dem Projekt an.
2. Öffne dort **… → Security** und konfiguriere:

   | Recht | OrderFlow Developers | OrderFlow QA |
   |---|---|---|
   | View work items in this node | Allow | Allow |
   | Edit work items in this node | Allow | Deny |

3. Öffne den Dialog nach dem Speichern erneut. Prüfe Bereich, Gruppe und Werte; untersuche die Vererbung über **Why?**, soweit angeboten.

Das Deny gilt ausschließlich für diesen Übungsbereich. Setze kein Deny für dein eigenes Konto. Die Produkt-Areas bleiben unverändert. Die Frage, weshalb hier Not set nicht dasselbe wie Deny bewirkt, besprecht ihr in Abschnitt 6.

## 4. Repositoryrechte konfigurieren

1. Öffne **Project settings → Repositories → orderflow-app → Security**.
2. Setze bzw. prüfe die folgende Matrix einschließlich geerbter Rechte. **A = Allow, N = Not set**; bei N soll kein zusätzliches Allow aus anderen Quellen bestehen.

   | Recht | Developers | QA | Release Managers | External Reviewers |
   |---|---|---|---|---|
   | Read | A | A | A | A |
   | Contribute | A | N | N | N |
   | Create branch | A | N | N | N |
   | Contribute to pull requests | A | N | N | A |
   | Force push | N | N | N | N |
   | Manage permissions / Edit policies | N | N | N | N |
   | Bypass policies when pushing / when completing pull requests | N | N | N | N |

3. Öffne dieselbe Ansicht für `orderflow-infra`. Keine der vier Fachgruppen erhält im Basisszenario ein zusätzliches Allow.
4. Bei unerwünschtem geerbtem Allow suche zuerst dessen Quelle. Besprich die gezielte Korrektur mit dem Trainer, statt ein pauschales Deny zu setzen.
5. Prüfe nach dem Speichern die Werte erneut. Besprecht den Unterschied zwischen **Contribute** und **Contribute to pull requests**.

Die konkreten Pipelinerechte richtest du in Lab04 an der dann vorhandenen Pipeline ein.

## 5. Eigenen Zugriff kurz prüfen

1. Öffne **Boards → Work Items → New Work Item → Task**.
2. Verwende `Lab02 – Zugriff prüfen <kuerzel>` als Titel und `<projekt>\Lab02-Permissions` als Area Path. Speichere das Task.
3. Ändere den Titel auf `Lab02 – Zugriff geprüft <kuerzel>`, speichere und lade neu. Prüfe in **History** die Änderung.

Der Erfolg gilt für dein administratives Konto. Bei einer Sperre unterstützt dich der Trainer.

## 6. Rollenwirkung gemeinsam besprechen

Der Trainer geht die folgenden Annahmen mit der Gruppe durch. Nennt jeweils mündlich das erwartete Verhalten und die entscheidende Berechtigungsgrenze. Gemeint sind nichtadministrative Benutzer mit Projektzugang und ohne weitere widersprechende Rechte.

| Fall | Annahme und Aktion |
|---|---|
| A | Stakeholder ausschließlich in Developers: Work Item im Testbereich lesen und ändern |
| B | Stakeholder ausschließlich in QA: dasselbe Work Item lesen und ändern |
| C | QA erhält zusätzlich ein Edit-Allow aus einer anderen Gruppe; das Area-Deny bleibt |
| D | Stakeholder mit Git-Read-Allow versucht das private App-Repository zu öffnen |

Vergleicht die Antworten anschließend mit der [Musterlösung](../solutions/Lab02.md).

## Ergebnis prüfen

- [ ] Vier Rollengruppen besitzen die vorgesehenen Projekt- und Repositoryrechte.
- [ ] Allow und Deny sind am Übungsbereich gespeichert; die Vererbung wurde geprüft.
- [ ] Das Task lässt sich mit deinem Konto erstellen und ändern.
- [ ] Access Level und Ressourcenberechtigung lassen sich mündlich unterscheiden.

## Portalhilfe

- [Stakeholder-Funktionsumfang](https://learn.microsoft.com/en-us/azure/devops/organizations/security/stakeholder-access?view=azure-devops)
- [Permissions für Work Items und Area Paths](https://learn.microsoft.com/en-us/azure/devops/organizations/security/set-permissions-access-work-tracking?view=azure-devops)
- [Git-Berechtigungen](https://learn.microsoft.com/en-us/azure/devops/organizations/security/default-git-permissions?view=azure-devops)
