# Lab 02 – Benutzer, Gruppen und Berechtigungen

> Synchronisierte Kopie der [maßgeblichen Lab-Anweisung](../../labs/02_Benutzer_Gruppen_Berechtigungen.md). Diese Anleitung verwendet die Voraussetzungen und Vorlagen aus dem vollständigen Kurspaket `devops-2/`. Nach einem Import des Repositories öffnest du diese Begleitdateien im separat bereitgestellten Kurspaket; die relativen Verweise darauf sind für dessen lokale Ordnerstruktur ausgelegt.

**Start:** Beginne dieses Lab erst, wenn der Trainer dazu auffordert.

**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit mit einem Zugang  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Eigenes privates Trainingsprojekt mit `orderflow-app` und `orderflow-infra` aus [Lab01](Lab01-Teil-B.md). Verwendet durchgehend euer reguläres Teilnehmerkonto mit Basic-Zugriff und Verwaltungsrechten im eigenen Projekt.

**Akteur für alle Schritte:** du mit dem persönlichen Basic-Kurskonto aus [Kursvoraussetzungen und Teilnehmerzuordnung](../../VORAUSSETZUNGEN.md). Verwende durchgehend dein dort eindeutig zugeordnetes Teilnehmerprojekt; `<projekt>` und `<kuerzel>` stammen aus dessen Tabelle. [Lab01](Lab01-Teil-B.md) ist abgeschlossen. Du bist Mitglied von **Project Administrators** in deinem Projekt.

## Ziel und Vorbereitung

Konfiguriert vier Rollen nach dem Least-Privilege-Prinzip und unterscheidet Access Level, Gruppenmitgliedschaft und Ressourcen-Permission. Ihr benötigt weder weitere Benutzerkonten noch einen zweiten Browserzugang oder einen Partner. Die vier Rollen werden durch Projektgruppen dargestellt; neue Gruppen dürfen für diese Übung leer bleiben.

Behaltet euren vorhandenen Access Level und eure Administratorrolle. Fügt euch nicht zum Rollenwechsel in die Übungsgruppen ein und sperrt euch nicht selbst aus. Die Auswahl einer Gruppe im Berechtigungsdialog ändert nicht eure angemeldete Identität. Bestehende fremde Mitgliedschaften und organisationsweite Lizenzzuweisungen werden nicht verändert.

Die Abnahme besteht aus **gespeicherter Konfiguration, einem Work-Item-Test mit dem eigenen Konto und einer begründeten Fallanalyse**. Ein echter Verhaltenstest unter eingeschränkten Entwickler- oder QA-Identitäten ist nicht Teil dieser Ein-Konto-Übung. Euer administrativer Zugriff darf nicht als Beweis für die Rechte dieser Rollen ausgegeben werden.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Eigenes Konto und Gruppen | 15 Min | Access Level, Mitgliedschaften und vier Rollengruppen dokumentiert |
| Projekt-, Area- und Repositoryrechte | 25 Min | Gespeicherte Rechte und nachvollziehbare Vererbung |
| Eigener Zugriff und Fallanalyse | 20 Min | Work-Item-Historie, Rollenbewertung und Abnahmeprotokoll |

## 1. Eigenes Konto und Access Level einordnen

1. Prüft im Kontomenü, dass euer reguläres Teilnehmerkonto angemeldet ist.
2. Öffnet [Organization settings → Users](https://dev.azure.com/ppedv-courses/_settings/users), sucht nach eurem Namen und dokumentiert **Basic**. Alle sieben Teilnehmerkonten sind dort mit Basic angelegt; ändert keine Lizenzzuweisung.
3. Öffnet im eigenen Projekt **Project settings → Permissions → Users**, sucht euer Konto und dokumentiert die Mitgliedschaften. Öffnet außerdem **Permissions → Groups → Project Administrators → Members** und belegt eure dortige Mitgliedschaft aus Lab01. Die vorbereitete Organisationsgruppe **DevOps-2 Lab Participants** enthält die Entra-Gruppe **DevOps Lab Participants** und hat **Create new projects: Allow**. Bei allen sieben persönlichen Konten ist dieses Recht einzeln als **Allow (inherited)** bestätigt. Die Anzeige belegt jedoch nicht, dass die konkrete Vererbung über diese Kursgruppe erfolgt; dokumentiert nur tatsächlich angezeigte Mitgliedschaften und Quellen.
4. Erklärt: Basic ermöglicht Repos-Funktionen, erteilt aber nicht automatisch jede Projektberechtigung. Stakeholder kann Work Items entsprechend den Area-Rechten bearbeiten, besitzt im privaten Projekt jedoch keinen Repos-Zugang. Ein Git-Allow hebt diese Featuregrenze nicht auf.

**Nachweis:** Angemeldetes Konto, Access Level mit Quelle, eigene Mitgliedschaften und Herkunft der Verwaltungsrechte. Nicht aufgelöste Mitgliedschaftsketten werden ausdrücklich als solche notiert.

## 2. Vier Projektgruppen anlegen

1. Öffnet **Project settings → Permissions → New group**.
2. Erstellt oder prüft die folgenden Gruppen mit passender **Description**:

   | Gruppe | Zweck |
   |---|---|
   | `OrderFlow Developers` | App-Code entwickeln, Feature-Branches beitragen, Builds starten |
   | `OrderFlow QA` | Code, Builds und Testergebnisse lesen |
   | `OrderFlow Release Managers` | Releases prüfen und freigeben |
   | `OrderFlow External Reviewers` | App-Code lesen und Pull Requests prüfen |

3. Öffnet jeweils **Members** und **Member of**. Neue Gruppen bleiben ohne Benutzerzuordnung; dokumentiert `0 Mitglieder – Rollenkonfiguration`. Bei einer Wiederholung: Sind bereits Mitglieder vorhanden, dokumentiert sie und lasst die Zuordnung unverändert.
4. Fügt die Rollengruppen nicht pauschal zu `Contributors`, `Readers` oder `Project Administrators` hinzu. Dokumentiert vorhandene übergeordnete Gruppen und deren Auswirkung. Bereits genutzte Gruppen werden nicht durch Entfernen von Mitgliedschaften umgebaut.
5. Setzt für jede Rollengruppe **View project-level information: Allow**. Lasst Projektadministration, Löschen und Berechtigungsverwaltung ohne zusätzliches Allow. Kontrolliert, ob Rechte geerbt werden: **Not set** hebt ein Allow aus einer anderen Quelle nicht auf.

**Nachweis:** Vier Gruppen mit Zweck, Mitgliederstand, Member-of und gespeicherten Projektrechten. Eine leere Gruppe ist für diese Konfigurationsprüfung vollständig ausreichend.

## 3. Isolierten Work-Item-Bereich konfigurieren

1. Öffnet **Project settings → Project configuration → Areas** und legt unter dem Projektknoten `Lab02-Permissions` an, falls der Bereich noch nicht existiert.
2. Öffnet ausschließlich dort **… → Security**. Dokumentiert den Ausgangszustand. Projektwurzel und Produkt-Areas aus Lab01 bleiben unverändert.
3. Konfiguriert die beiden Gruppen:

   | Recht am Area Path `Lab02-Permissions` | OrderFlow Developers | OrderFlow QA |
   |---|---|---|
   | View work items in this node | Allow | Allow |
   | Edit work items in this node | Allow | Deny |

4. Schließt den Dialog und öffnet ihn erneut. Prüft Gruppennamen, Area Path und gespeicherte Werte. Untersucht Herkunft/Vererbung über **Why?**, soweit angeboten. Wenn die Oberfläche nur die gesetzten Werte zeigt, bezeichnet sie nicht als vollständig ermittelte effektive Benutzerrechte.
5. Begründet die begrenzte Deny-Ausnahme: Work-Item-Bearbeitung kann aus weiteren Gruppen erlaubt sein; `Not set` würde dieses Allow nicht aufheben. Der Bereich ist ausschließlich eine Berechtigungsübung, keine allgemeine QA-Sperre.
6. Verwendet kein direktes Deny für euer eigenes Konto und fügt euch nicht in `OrderFlow QA` ein. Ein Wechsel eurer Administratorrolle ist nicht erforderlich.

**Nachweis:** Screenshot des konkreten Area-Pfads mit beiden Gruppenwerten, Vererbungsbefund und Begründung. Dies ist eine Konfigurationsprüfung, kein ausgeführter QA-Negativtest.

## 4. Repositoryrechte konfigurieren und auswerten

1. Öffnet **Project settings → Repositories → orderflow-app → Security**.
2. Wählt die Rollengruppen und vergleicht bzw. setzt die folgende Matrix. Prüft zusätzlich geerbte Rechte.

   **A = Allow. N = Not set; das Ziel ist kein effektives Allow aus anderen Quellen. N ist kein ausdrückliches Deny.**

   | Recht auf `orderflow-app` | Developers | QA | Release Managers | External Reviewers |
   |---|---|---|---|---|
   | Read | A | A | A für Release-Prüfung | A |
   | Contribute | A | N | N | N |
   | Create branch | A | N | N | N |
   | Contribute to pull requests | A | N | N | A |
   | Force push | N | N | N | N |
   | Manage permissions / Edit policies | N | N | N | N |
   | Bypass policies when pushing / when completing pull requests | N | N | N | N |

3. Für `orderflow-infra` erhalten QA und External Reviewers kein zusätzliches Read-Allow. Developers und Release Managers bekommen im Basisszenario ebenfalls kein zusätzliches Allow; ein späterer Bedarf muss konkret begründet werden.
4. Wird ein unerwünschtes Allow geerbt, benennt die Quelle und die erforderliche gezielte Korrektur. Vergebt kein pauschales Deny als Ersatz für die Untersuchung. Bei bereits genutzten Gruppen dokumentiert ihr die Abweichung, statt fremde Zugriffe zu verändern.
5. Öffnet die Einstellungsseite erneut und dokumentiert gespeicherte Werte und verbleibende Abweichungen. Erklärt den Unterschied zwischen **Contribute to pull requests** und **Contribute**.

Ein Push oder PR unter eurem administrativen Konto testet nicht das Verhalten der Rollengruppen. Solche Rollen-Verhaltenstests sind hier nicht erforderlich. PR-Policies werden in Lab03 mit demselben Teilnehmerkonto geprüft.

## 5. Pipelinerechte vorbereiten

Im vorgesehenen Erstablauf entsteht `orderflow-ci` erst in Lab04. Dokumentiert jetzt das folgende Rollenmodell. Die Einstellung an der konkreten Pipeline erfolgt in Lab04; dies ist kein offener Rollen-Verhaltenstest. Bei Wiederaufnahme eines bereits weiter bearbeiteten Projekts prüft bzw. konfiguriert ihr unter **Pipelines → orderflow-ci → … → Manage security** die Gruppenwerte:

| Recht | Developers | QA | Release Managers | External Reviewers |
|---|---|---|---|---|
| View builds / View build pipeline | A | A | A | N |
| Queue builds | A | N | A | N |
| Edit build pipeline | N | N | N | N |
| Administer build permissions | N | N | N | N |

Dokumentiert euer Teilnehmerkonto als Verantwortlichen für Definition und Rechte im eigenen Trainingsprojekt; eure vorhandenen Verwaltungsrechte bleiben bestehen. Unterscheidet dieses Einrichtungskonto von den vier Fachrollen. YAML-Schreibrechte können das Pipelineverhalten beeinflussen; Branch Policies folgen in Lab03. Environments und Approvals folgen in Lab03/06 mit demselben Konto.

**Nachweis:** Rollenmatrix im Lab02-Protokoll. In Lab04 konfigurierst du diese Werte selbst an `orderflow-ci`, ohne zusätzliche Testkonten anzumelden.

## 6. Mit dem eigenen Konto praktisch prüfen

1. Bleibt mit eurem Teilnehmerkonto angemeldet. Öffnet **Boards → Work Items → New Work Item → Task**. Das Projekt verwendet seit Lab01 den Work-Item-Prozess **Basic** mit Epic, Issue und Task. Für diesen Test wird **Task** verwendet.
2. Verwendet den Titel `Lab02 – Konfigurationsprüfung <kuerzel>` und den Area Path `<projekt>\Lab02-Permissions`. Speichert.
3. Ändert die Beschreibung auf `Änderung durch eigenes Teilnehmerkonto – kein Rollen-Verhaltenstest` und speichert erneut.
4. Ladet das Work Item neu. Prüft Beschreibung, Area Path und **History** mit eurem Konto als Bearbeiter. Notiert ID/Link und tatsächliches Ergebnis.
5. Erläutert schriftlich, weshalb dieser Erfolg nur euren eigenen Zugriff belegt und keine Aussage über einen Benutzer ausschließlich in `OrderFlow QA` erlaubt.

Bei unerwarteter Sperre prüft Identität, Ziel-Area und eigene Mitgliedschaften. Verschärft keine Sperre und entfernt nicht eure Administratorrolle, um eine Verweigerung künstlich herzustellen. Ein fehlender eigener Zugriff bleibt als tatsächlicher Fehler dokumentiert; er wird nicht als erfolgreicher QA-Test gewertet.

## 7. Rollenwirkung als Fallanalyse beurteilen

Die folgenden Fälle sind **vorgegebene Annahmen, keine ausgeführten Tests**. Geht für A–D von nichtadministrativen Benutzern mit Projektzugang, den angegebenen Gruppen und ohne weitere widersprechende Rechte aus. Benennt jeweils Ergebnis, entscheidende Grenze und einen sinnvollen Prüfschritt.

| Fall | Annahme / Aktion | Eure begründete Erwartung |
|---|---|---|
| A | Stakeholder ausschließlich in Developers: Work Item im Testbereich lesen und ändern | |
| B | Stakeholder ausschließlich in QA: dasselbe Work Item lesen und ändern | |
| C | QA erhält zusätzlich ein Edit-Allow aus einer anderen nichtadministrativen Gruppe; Area-Deny bleibt | |
| D | Stakeholder mit Git-Read-Allow versucht das private App-Repo zu öffnen | |
| E | Euer administratives Basic-Konto kann das Work Item ändern | Welche Aussage über QA ist damit gerade nicht belegt? |

Erklärt zusätzlich, weshalb die Auswahl von `OrderFlow QA` im Security-Dialog keine Anmeldung als QA ist. Vergleicht eure Antworten erst danach mit der [Musterlösung zu Lab02](../../lab-solutions/02_Benutzer_Gruppen_Berechtigungen.md). Die Fallanalyse ersetzt in dieser Aufgabenfassung die früheren Tests unter zusätzlichen Identitäten; diese sind keine ausstehende Abnahmeaufgabe.

## 8. Abnahme

| Nachweisart | Gegenstand | Tatsächlicher Befund / Quelle |
|---|---|---|
| Konfiguration | Eigenes Konto, Access Level, Mitgliedschaften | |
| Konfiguration | Vier Gruppen und Projektrechte | |
| Konfiguration | Area-Pfad und gespeicherte Allow-/Deny-Werte | |
| Konfiguration | App-/Infra-Rechte und Vererbung | |
| Planung oder Konfiguration | Pipeline-Rechte | |
| Eigener Verhaltenstest | Work Item gespeichert, neu geladen und History gelesen | |
| Fallanalyse | Fälle A–E begründet, Grenzen des Nachweises erklärt | |

- [ ] Alle Schritte wurden mit dem eigenen Teilnehmerkonto durchgeführt.
- [ ] Vier Rollengruppen und ihre Mitgliedschafts-/Vererbungsbefunde sind dokumentiert; leere Gruppen sind zulässig.
- [ ] Gespeicherte Projekt-, Area- und Repo-Rechte sind geprüft; Abweichungen sind benannt.
- [ ] Das eigene Work Item und seine Änderung sind nachvollziehbar belegt.
- [ ] Die Deny-Ausnahme ist auf den Übungsbereich begrenzt und begründet.
- [ ] Fallanalyse, Konfigurationsprüfung und tatsächlicher Verhaltenstest sind klar getrennt.
- [ ] Zusätzliche Konten, Anmeldungen oder ein Trainer-Rollentest sind für diese Abnahme nicht erforderlich.

Lasst den dokumentierten Übungsbereich für die Abnahme bestehen. Bei späterer Wiederverwendung prüft ihr seine Deny-Regel ausdrücklich; kopiert sie nicht ungeprüft auf fachliche Areas.

## Portalhilfe

- [Stakeholder-Funktionsumfang](https://learn.microsoft.com/en-us/azure/devops/organizations/security/stakeholder-access?view=azure-devops)
- [Permissions für Work Items und Area Paths](https://learn.microsoft.com/en-us/azure/devops/organizations/security/set-permissions-access-work-tracking?view=azure-devops)
- [Git-Berechtigungen](https://learn.microsoft.com/en-us/azure/devops/organizations/security/default-git-permissions?view=azure-devops)
