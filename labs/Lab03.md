# Lab 03 – Ressourcen-Governance-Challenge

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit
**Umgebung:** Persönliches Basic-Kurskonto mit Projektadministratorrechten im [zugeordneten Projekt](../KURSSTART.md#teilnehmerprojekte-und-kürzel); Lab01/02 sind abgeschlossen.

## Ziel und Ablauf

Schützt `main` durch PR-Regeln, prüft deren Wirkung und bereitet zwei Trainings-Environments vor.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Branch und PR | 20 Min | Verbindliche Review- und Kommentarregeln |
| Ressourcenrollen und Autorisierung | 20 Min | Geschützte Trainings-Environments |
| PR-Tests und Auswertung | 15 Min | Wirkung der Reviewer- und Kommentarregeln |

`orderflow-ci` entsteht in Lab04. Dort richtest du Build Validation ein; die Pipeline-Autorisierung der Environments prüfst du in Lab06.

## 1. `main` durch Branch Policies schützen

1. Öffnet **Repos → Branches**, wählt `orderflow-app` und bei `main` **… → Branch policies**.
2. Aktiviert **Require a minimum number of reviewers** und konfiguriert:

   | Einstellung | Sollwert |
   |---|---|
   | Minimum number of reviewers | `1` |
   | Allow requestors to approve their own changes | Ein |
   | Prohibit the most recent pusher from approving their own changes | Aus |
   | Allow completion even if some reviewers vote to wait or reject | Aus |
   | When new changes are pushed | **Reset all approval votes** |

**Trainingsausnahme:** Diese Einstellungen gelten für die PRs im eigenen Lab-Projekt und erlauben eure bewusste Selbstfreigabe. Im Echtbetrieb wird das Vier-Augen-Prinzip verwendet: Selbstfreigabe aus, zuletzt pushende Person ausgeschlossen. Die Pflichtprüfungen bleiben im Training aktiv; ihr verwendet keinen Policy-Bypass.

3. Aktiviert **Check for comment resolution** als **Required**.
4. Verlasst die Seite erst, wenn die Speicherung bestätigt ist. Öffnet sie erneut und prüft die Werte.
5. Unter **Repos → Branches → main → … → Branch security** kontrolliert ihr für `OrderFlow Developers`: **Bypass policies when pushing** und **Bypass policies when completing pull requests** besitzen kein effektives Allow. Prüft auch geerbte Gruppenrechte.
6. Lasst Entwickler weiterhin auf Feature-Branches beitragen. Ein pauschales `Contribute: Deny` auf `main` ist für dieses Modell nicht nötig und kann die gewünschte PR-Abnahme behindern.

## 2. Hinweis zur Build Validation

Beim Erstablauf bleibt **Build Validation** leer. In Lab04 ergänzt du die neu erstellte `orderflow-ci` als Pflichtprüfung. Eine bereits eingerichtete Build Validation bleibt bei einer Wiederholung aktiv.

## 3. Hinweis zu den Pipelines

`orderflow-ci` übernimmt Build und PR-Prüfung ab Lab04. `orderflow-release` führt die simulierten Deployments ab Lab06 aus. Die jeweiligen Rechte richtest du bei der Erstellung dieser Pipelines ein.

## 4. Zwei leere Trainings-Environments anlegen

1. Öffnet **Pipelines → Environments → New environment** beziehungsweise **Create environment**.
2. Erstellt `orderflow-staging` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Staging-Deployment`.
3. Erstellt analog `orderflow-prod` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Produktionsdeployment`.
4. Existieren die Environments bereits im eigenen Trainingsprojekt, prüft und ergänzt sie. Fügt weder virtuelle Maschinen noch Kubernetes-Ressourcen hinzu; die folgenden Labs simulieren die Deployments.
5. Öffnet jedes Environment → **… → Security**.
6. Öffne **User permissions**. Prüfe dein eigenes Konto als **Administrator** des von dir erstellten Environments. Füge `OrderFlow Release Managers` mit **Reader** hinzu. Diese Gruppe bleibt im Erstablauf leer; sie demonstriert die Fachrolle. In Lab06 wird ausdrücklich dein eigenes Konto direkt als Approver eingetragen.
7. Prüfe die angezeigten Rollen und ihre Vererbung. Vergib den vier Fachrollengruppen keine zusätzliche User- oder Administratorrolle. Die globalen Environment-Einstellungen bleiben unverändert.
8. Unter **Pipeline permissions** beschränkst du den Zugriff. Zeigt der neue Dialog Open access, wähle **Restrict permission**. Im Erstablauf bleibt die Liste leer, weil `orderflow-release` erst in Lab06 entsteht. Autorisiere weder `orderflow-ci` noch eine fremde Pipeline. In Lab06 fügst du genau `orderflow-release` hinzu.

## 5. Hinweis zu Service Connections

In diesem Kurs ist keine Service Connection erforderlich. `orderflow-release` führt Skripte auf dem Microsoft-hosted Agent aus und verarbeitet Pipeline-Artefakte. Die Deployments sind Simulationen ohne Zugriff auf ein Azure-Abonnement. Eine Trainingsverbindung wird daher weder bereitgestellt noch angelegt.

## 6. PR-Regeln praktisch prüfen

Prüfe die Policy-Auswertung direkt an deinem PR. Verwende dabei keinen administrativen Bypass.

### Drei Prüfungen am Pull Request

1. Öffnet **Repos → Branches → New branch** und erstellt `feature/lab03-<kuerzel>` aus `main`. Öffnet auf diesem Feature-Branch `src/release-notes.txt`, ergänzt `PR-Regeln im Trainingsprojekt eingerichtet.` und committet mit `lab03: update release notes`.
2. Erstellt über **Repos → Pull requests → New pull request** einen aktiven PR vom Feature-Branch nach `main`. Verwendet keinen Draft und aktiviert kein Auto-Complete. Stimmt zunächst noch nicht zu.
3. **Test A – Zustimmung fehlt:** Öffnet im PR die Registerkarte **Overview** und dort die angezeigten Pflichtprüfungen. Die Mindestanzahl von einem Reviewer ist noch nicht erfüllt. Prüft den angezeigten Status. Falls euer Administratorkonto eine Option zum Übersteuern anbietet, verwendet sie nicht. Entscheidend ist der Policy-Status, nicht allein die Verfügbarkeit der Schaltfläche **Complete**.
4. **Test B – Offener Kommentar:** Fügt selbst einen Kommentar hinzu, zum Beispiel `Bitte die Release-Notiz vor Abschluss prüfen`, und lasst ihn im Status **Active**. Genehmigt anschließend euren eigenen PR über **Approve**. Die Reviewer-Policy ist nun erfüllt, die verpflichtende Kommentarauflösung weiterhin nicht. Vergleicht die beiden Statuswerte. Bei abweichendem Ergebnis prüft die gespeicherten Policies aus Abschnitt 1.
5. **Optional – Neue Änderung setzt Zustimmung zurück:** Ergänzt die Release-Notiz auf demselben Feature-Branch und committet erneut. Ladet den PR neu: Die Zustimmung muss zurückgesetzt sein. Prüft die Rücksetzung und stimmt anschließend erneut über **Approve** zu. Lasst den Kommentar für diesen Test noch offen.
6. **Test C – Regulärer Abschluss:** Prüft die Änderung und setzt euren Kommentar auf **Resolved**. Reviewer- und Kommentar-Policy müssen jetzt erfüllt sein. Falls Build Validation bereits eingerichtet ist, wartet zusätzlich auf den erfolgreichen Pflichtbuild; bei Fehlern korrigiert die Ursache, statt die Policy abzuschalten. Schließt den PR erst bei erfüllten Pflichtprüfungen über **Complete** regulär ab, ohne **Override branch policies** oder eine andere Bypass-Option. Prüft danach die Änderung auf `main` und den Status **Completed** am PR.

Im Erstablauf prüft dieser PR nur Reviewer und Kommentare. Den Build-Validation-Schritt erledigst du am Ende von Lab04. Bei einer späteren Wiederholung bleibt eine bereits aktive Build Validation verpflichtend.

## 7. Ergebnis prüfen

- [ ] Vor der Zustimmung war die Reviewer-Policy unerfüllt.
- [ ] Nach der Zustimmung blieb die Kommentar-Policy wegen des offenen Kommentars unerfüllt.
- [ ] Nach Kommentarauflösung ließ sich der PR regulär ohne Bypass abschließen.
- [ ] Die Bypass-Konfiguration der Entwicklergruppe ist einschließlich Vererbung geprüft.
- [ ] Beide Environments besitzen Resource None, die vorgesehenen Rollen und eingeschränkte Pipeline permissions.

Besprecht kurz: Welche Prüfung verhinderte jeweils den PR-Abschluss?

## Portalhilfe

- [Branch Policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
- [Environments, Rollen und Pipeline permissions](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
