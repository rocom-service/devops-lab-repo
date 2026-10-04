# Lab 03 – Ressourcen-Governance-Challenge

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/03_Ressourcen_Governance_Challenge.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Akteur für alle Schritte:** du mit deinem persönlichen Basic-Kurskonto im Teilnehmerprojekt aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md). Lab01/02 sind abgeschlossen; du besitzt Project-Administrator-Rechte und die vier Rollengruppen sind eingerichtet. Dein Konto übernimmt hier Repository-, Pipeline- und Environment-Verwaltung.

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Eigenes privates Projekt und die Gruppen aus [Lab 02](Lab02.md). Verwendet euer reguläres Teilnehmerkonto mit Repos-Zugang (Basic) und den Verwaltungsrechten für das eigene Trainingsprojekt. Verwendet dasselbe Konto wie in der Ein-Konto-Übung Lab02. Ein zweiter Zugang oder ein Partner ist nicht erforderlich.

## Ziel und Ablauf

Schützt Repository, Branch, Pipeline und Environments jeweils an ihrer eigenen Grenze. Erstellt nachvollziehbare Regeln und prüft sie mit erlaubten und unerlaubten Aktionen. Arbeitet ausschließlich im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Branch und PR | 20 Min | Verbindliche Review- und Kommentarregeln |
| Ressourcenrollen und Autorisierung | 20 Min | Geschützte Trainings-Environments |
| Einzeltests und Protokoll | 15 Min | Nachweise und klar markierte Restpunkte |

`orderflow-ci` entsteht erst in Lab04 und erhält in Lab05 den vollständigen Build. Deshalb bleibt Build Validation im Erstablauf hier **noch unkonfiguriert**; du richtest sie am Ende von Lab04 ein. Deploymenttests folgen mit `orderflow-release` in Lab06. Ein noch nicht ausgeführter Test zählt nicht als erfolgreich.

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

**Nachweis:** Gespeicherte Reviewer- und Kommentar-Policy sowie die Bypass-Konfiguration der Entwicklergruppe. Dies ist eine Konfigurationsprüfung; ein Verhaltenstest mit einer eingeschränkten Entwickleridentität gehört nicht zur Abnahme. Ändert für die Tests weder eure Administratorrolle noch eure eigenen Bypass-Rechte.

## 2. Build Validation vorbereiten

1. Prüfe auf der Policy-Seite **Build Validation**. Beim Erstablauf ist noch keine `orderflow-ci` angelegt; füge hier keine fremde Pipeline hinzu.
2. Notiere im Protokoll: `Lab04, Abschnitt 5: orderflow-ci als Required/Automatic hinzufügen, Path filter leer, Build expiration Immediately when main is updated`.
3. Bei einer Wiederholung nach Lab04 bleibt der bereits vorhandene Eintrag aktiv. Ein neuer PR muss dann auch diesen Pflichtbuild bestehen; schalte ihn nicht für die Wiederholung aus.
4. Für Azure Repos Git stammt die PR-Validierung aus dieser Branch Policy; ein YAML-`pr:`-Eintrag ersetzt sie nicht.

## 3. Pipeline-Verantwortung festlegen

1. Dokumentiert `orderflow-ci` als Build-/PR-Pipeline und `orderflow-release` als spätere Deployment-Pipeline.
2. Sobald `orderflow-ci` existiert, öffnet **Pipelines → Pipelines → orderflow-ci → … → Manage security** und übernehmt die Pipeline-Rechte aus Lab02.
3. Das Modell erlaubt Developers Queue/View. Du bist mit deinem bestehenden Project-Administrator-Konto der konkrete Pipeline-Verantwortliche. Die leeren Fachrollengruppen bekommen keine zusätzliche Administration.
4. Halte getrennt fest: Du startest Runs, die Build-Service-Identität greift auf Ressourcen zu und `orderflow-release` wird später als konkrete Pipeline an Environments autorisiert. In Lab04 belegt der erfolgreiche Checkout den Ressourcenzugriff. Die organisationsweite Prüfung des Jobautorisierungsbereichs übernimmt Wolfgang gemäß der Vorab-Checkliste; ein konkreter Build-Service-Name wird nicht aus deinem Anmeldekonto abgeleitet.

## 4. Zwei leere Trainings-Environments anlegen

1. Öffnet **Pipelines → Environments → New environment** beziehungsweise **Create environment**.
2. Erstellt `orderflow-staging` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Staging-Deployment`.
3. Erstellt analog `orderflow-prod` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Produktionsdeployment`.
4. Existieren die Environments bereits im eigenen Trainingsprojekt, prüft und ergänzt sie. Fügt weder virtuelle Maschinen noch Kubernetes-Ressourcen hinzu; die folgenden Labs simulieren die Deployments.
5. Öffnet jedes Environment → **… → Security**.
6. Öffne **User permissions**. Prüfe dein eigenes Konto als **Administrator** des von dir erstellten Environments. Füge `OrderFlow Release Managers` mit **Reader** hinzu. Diese Gruppe bleibt im Erstablauf leer; sie demonstriert die Fachrolle. In Lab06 wird ausdrücklich dein eigenes Konto direkt als Approver eingetragen.
7. Dokumentiere die angezeigten Rollen und ihre Vererbung. Behalte deine Administratorrolle und die für das private Teilnehmerprojekt geerbten Verwaltungsrollen. Vergib den vier Fachrollengruppen keine User- oder Administratorrolle; ihre Freigaberolle allein benötigt diese Rechte nicht. Die Übung setzt keine Änderung der globalen Environment-Security voraus.
8. Unter **Pipeline permissions** beschränkst du den Zugriff. Zeigt der neue Dialog Open access, wähle **Restrict permission**. Im Erstablauf bleibt die Liste leer, weil `orderflow-release` erst in Lab06 entsteht. Autorisiere weder `orderflow-ci` noch eine fremde Pipeline. In Lab06 fügst du genau `orderflow-release` hinzu.

**Nachweis:** Namen, Resource None, Benutzerrollen/Vererbung und eingeschränkte Pipeline permissions beider Environments. Approval-Konfiguration folgt in Lab06.

## 5. Service-Connection-Entscheidung dokumentieren

**Akteur: du.** In diesem Kurs wird keine Service Connection verwendet oder angelegt. `orderflow-release` führt ausschließlich Skripte auf dem Microsoft-hosted Agent aus und benötigt keinen Zugriff auf ein Azure-Abonnement. Es gibt deshalb weder eine auszuwählende Trainingsverbindung noch einen Anmeldeauftrag für einen weiteren Dienst.

Öffne **Project settings → Service connections**, dokumentiere die Ansicht deines neu angelegten Projekts und ergänze im Entscheidungsprotokoll:

| Schutzobjekt | Entscheidung für diesen Kurs | Verantwortlicher | Nachweis |
|---|---|---|---|
| Service Connection | Nicht erforderlich und nicht anzulegen; keine Cloudbereitstellung | Du als Projektverwalter | Simulations-YAML in `azure-pipelines.multistage.yml` verwendet nur PowerShell und Pipeline-Artefakte |

Begründe zusätzlich fachlich: Bei einer späteren echten Azure-Bereitstellung wären sowohl die gezielte Pipeline-Autorisierung der Verbindung als auch die Azure-Rechte der Verbindungsidentität zu prüfen. Das ist eine Modellbetrachtung, keine weitere Ausführungsaufgabe dieses Labs.

## 6. Mit dem eigenen Konto prüfen

Alle folgenden Schritte erfolgen mit demselben Teilnehmerkonto im eigenen Projekt. Der direkte Push-/Commit-Negativtest mit einem eingeschränkten Entwicklerkonto entfällt. Ihr prüft die Policy-Auswertung im PR und später die Autorisierung der Pipeline. Das belegt keinen Schutz vor einem Administrator, der Einstellungen verändert oder Policies bewusst umgeht.

### 6.1 Drei Pflichtprüfungen am eigenen Pull Request

1. Öffnet **Repos → Branches → New branch** und erstellt `feature/lab03-<kuerzel>` aus `main`. Legt unter **Repos → Files** auf diesem Feature-Branch die Datei `docs/lab03-governance-<kuerzel>.md` mit dem Text `Lab03: Review und Kommentarauflösung im eigenen Trainingsprojekt prüfen.` an und committet sie mit `docs: add governance exercise`.
2. Erstellt über **Repos → Pull requests → New pull request** einen aktiven PR vom Feature-Branch nach `main`. Verwendet keinen Draft und aktiviert kein Auto-Complete. Stimmt zunächst noch nicht zu.
3. **Test A – Zustimmung fehlt:** Öffnet im PR die Registerkarte **Overview** und dort die angezeigten Pflichtprüfungen. Die Mindestanzahl von einem Reviewer ist noch nicht erfüllt. Dokumentiert diesen Status und den PR-Link. Falls euer Administratorkonto eine Option zum Übersteuern anbietet, verwendet sie nicht. Entscheidend ist der Policy-Status, nicht allein die Verfügbarkeit der Schaltfläche **Complete**.
4. **Test B – Offener Kommentar:** Fügt selbst einen Kommentar hinzu, zum Beispiel `Lab03: Trainingsnotiz vor Abschluss prüfen`, und lasst ihn im Status **Active**. Genehmigt anschließend euren eigenen PR über **Approve**. Die Reviewer-Policy ist nun erfüllt, die verpflichtende Kommentarauflösung weiterhin nicht. Dokumentiert beide Statuswerte. Bei abweichendem Ergebnis prüft die gespeicherten Policies aus Abschnitt 1.
5. **Optional – Neue Änderung setzt Zustimmung zurück:** Ändert die Trainingsnotiz auf demselben Feature-Branch und committet erneut. Ladet den PR neu: Die Zustimmung muss zurückgesetzt sein. Dokumentiert den Befund und stimmt anschließend erneut über **Approve** zu. Lasst den Kommentar für diesen Test noch offen.
6. **Test C – Regulärer Abschluss:** Prüft die Trainingsnotiz und setzt euren Kommentar auf **Resolved**. Reviewer- und Kommentar-Policy müssen jetzt erfüllt sein. Falls Build Validation bereits eingerichtet ist, wartet zusätzlich auf den erfolgreichen Pflichtbuild; bei Fehlern korrigiert die Ursache, statt die Policy abzuschalten. Schließt den PR erst bei erfüllten Pflichtprüfungen über **Complete** regulär ab, ohne **Override branch policies** oder eine andere Bypass-Option. Prüft danach die Datei auf `main` und dokumentiert den abgeschlossenen PR.

Im Erstablauf prüft dieser PR nur Reviewer und Kommentare. Den Build-Validation-Schritt erledigst du am Ende von Lab04. Bei einer späteren Wiederholung bleibt eine bereits aktive Build Validation verpflichtend.

### 6.2 Pipeline-Autorisierung ab Lab06 mit demselben Konto testen

Diese Prüfungen werden erst ausgeführt, wenn `orderflow-release` einen funktionsfähigen Deployment Job für das leere Trainings-Environment `orderflow-staging` besitzt. Bis dahin dokumentiert ihr sie als **offen bis Lab06/07**; sie sind keine Voraussetzung für den Abschluss von Lab03. Ein zweites Benutzerkonto und eine zweite Pipeline sind nicht nötig.

In Lab06 wird diese Prüfung in dessen Ablauf eingebettet: Der erste erfolgreiche Run ohne Approval ist bereits der Positivbeleg. Nach Einrichtung des Production-Approvals folgen Negativtest und Wiederherstellung; der anschließende erfolgreiche Run belegt zugleich die Wiederherstellung und den Approval. Führt die folgende Liste nicht zusätzlich zu Lab06 aus. Für Lab07 Fall F sichert ihr Meldung, Hypothese und geplanten Minimalfix vor der Wiederherstellung und verwendet danach dieselben eigenen Nachweise weiter.

1. Prüft unter **Pipelines → Environments → orderflow-staging → … → Security**, dass die Pipeline permissions eingeschränkt sind und `orderflow-release` gezielt autorisiert ist. Dokumentiert den Ausgangszustand. Wartet, bis laufende Tests an dieser Ressource beendet sind.
2. **Positivtest:** Startet `orderflow-release` selbst. Erwartet, dass der Staging-Deployment-Job ohne Approval erfolgreich durchläuft; in diesem Kurs wird nur `orderflow-prod` mit einem Approval versehen. Dokumentiert Run-Link und Job-Ergebnis. Ein später wartendes Production-Approval ist getrennt zu beurteilen; in der Einzelübung kann es das eigene Konto gemäß Lab06 freigeben.
3. **Negativtest:** Entfernt ausschließlich die Pipeline-Autorisierung von `orderflow-release` an eurem leeren `orderflow-staging`. Lasst die Benutzerrollen und alle anderen Ressourceneinstellungen unverändert. Startet einen neuen Lauf derselben Pipeline. Erwartet eine fehlende Ressourcenautorisierung: Der Lauf scheitert oder wartet auf Erlaubnis. Dokumentiert die tatsächliche Meldung und den Run-Link. Ein Agenten-, YAML- oder Buildfehler ist kein Nachweis dieser Sperre. Erteilt während des Negativtests keinen Zugriff über **Permit**.
4. Beendet einen noch wartenden Testlauf. Stellt anschließend die gezielte Autorisierung von `orderflow-release` wieder her, auch wenn der Test anders als erwartet verlaufen ist. Kein **Open access** als Reparatur. Startet einen neuen Lauf und bestätigt erneut den erfolgreichen Staging-Job.

Die Tests zeigen die Ressourcennutzung durch eine autorisierte beziehungsweise nicht autorisierte Pipeline. Dasselbe Konto startet beide Läufe; dessen Verwaltungsrechte ersetzen die Pipeline-Autorisierung nicht. Für die simulierten Deployments ist keine Service Connection nötig.

## 7. Entscheidungsprotokoll

Ergänzt für jede Ressource einen Satz: **Schutzobjekt – Identität/Gruppe – erlaubte Aktion – ausgeschlossene Aktion – Prüfnachweis**.

- [ ] Trainingsausnahme für Selbstfreigabe ist gesetzt; mindestens eine Zustimmung und Kommentarauflösung bleiben verpflichtend.
- [ ] Test A: Fehlende eigene Zustimmung als nicht erfüllte Reviewer-Policy belegt.
- [ ] Test B: Eigene Zustimmung erfüllt die Reviewer-Policy; eigener offener Kommentar lässt die Kommentar-Policy unerfüllt.
- [ ] Test C: Eigenen Kommentar aufgelöst und PR nach erfüllten Pflichtprüfungen ohne Bypass abgeschlossen.
- [ ] Bypass-Konfiguration der Entwicklergruppe einschließlich Vererbung geprüft; kein Verhaltenstest mit einem zweiten Konto erforderlich.
- [ ] YAML-Änderungen laufen ebenfalls über den PR-Weg.
- [ ] Environments haben gezielte Rollen und eingeschränkte Pipeline permissions.
- [ ] Restpunkte nennen Lab04/05 bzw. Lab06/07 und wurden nicht als erfolgreiche Tests ausgegeben.

**Protokoll je Prüfung:** Test – angemeldetes Konto bzw. Pipeline – Erwartung – tatsächlicher Policy-/Run-Status – PR-/Run-Link. Kennzeichnet Konfigurationsprüfungen und noch offene Laufzeittests ausdrücklich. Die Pipeline-Tests aus Abschnitt 6.2 werden in Lab06/07 ergänzt.

## Portalhilfe

- [Branch Policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
- [Environments, Rollen und Pipeline permissions](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
