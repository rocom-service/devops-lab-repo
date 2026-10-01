# Lab 02 – Benutzer, Gruppen und Berechtigungen

**Dauer:** 60 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Euer privates Projekt mit `orderflow-app` und `orderflow-infra` aus [Lab 01 Teil B](Lab01-Teil-B.md) ist vorhanden.

## Ziel und Vorbereitung

Für **alle Übungskonten in Lab02 wird ausschließlich Stakeholder verwendet**. Es wird kein Upgrade auf Basic verlangt. Konfiguriert vier Rollen nach dem Least-Privilege-Prinzip und prüft erlaubte und verweigerte Aktionen an Work Items. Alle Änderungen erfolgen im eigenen Trainingsprojekt in **ppedv-courses**.

Für die Einrichtung benötigt ihr passende administrative Permissions. Fehlen sie, übernimmt der Trainer die betreffenden Einstellungen; auch administrative Aufgaben sind mit Stakeholder und passenden Berechtigungen möglich. Die eingeschränkten Testkonten erhalten keine Administratorrolle. Ladet keine fremden Personen ein und verändert keine bestehenden Lizenzzuweisungen außerhalb der für Lab02 vorgesehenen Konten.

Stakeholder kann in privaten Projekten Work Items lesen und bearbeiten, soweit die Area-Permissions dies erlauben, hat aber keinen Zugriff auf Azure Repos. Deshalb entfallen praktische Git-Push- und PR-Tests in diesem Lab. Die Repository-Sollmatrix bleibt als Modell erhalten; ein fehlender Repo-Zugriff ist hier kein Nachweis eines bestimmten Git-Rechts. [Microsoft: Stakeholder-Zugriff](https://learn.microsoft.com/en-us/azure/devops/organizations/security/stakeholder-access?view=azure-devops).

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Gruppen und Access Levels | 15 Min | Vier Gruppen, dokumentierte Mitgliedschaften |
| Projekt-/Area-Rechte und Ressourcenmodelle | 25 Min | Praktische Boards-Rechte, Repo-Sollmatrix |
| Wirkung prüfen und dokumentieren | 20 Min | Positive und negative Tests |

Fehlen Testkonten, richtet die Gruppen ein und lasst den Trainer mit vorbereiteten Stakeholder-Konten testen. Kennzeichnet noch nicht ausgeführte Tests als offen. Bleibt in **ppedv-courses**.

## 1. Vier Projektgruppen anlegen

Die folgenden Rollen beschreiben das fachliche Zielmodell. Git-Aufgaben werden mit den Stakeholder-Konten nicht praktisch ausgeführt. Für den Berechtigungstest bekommt die Entwickler-Persona Schreibzugriff auf einen isolierten Work-Item-Bereich, QA dort nur Lesezugriff.

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

## 2. Stakeholder und Mitgliedschaften prüfen

1. Öffnet **Organization settings → Users** und sucht die vorbereiteten Lab02-Konten. Falls ihr diese Seite nicht verwalten dürft, übernimmt der Trainer die Prüfung.
2. Verwendet für diese Konten **Access level: Stakeholder**. Bei einem eigens bereitgestellten Konto mit abweichender Zuweisung setzt der zuständige Kursadministrator über **Change access level** den vereinbarten Stakeholder-Zugang. Bestehende Arbeitskonten werden nicht pauschal herabgestuft.
3. Prüft zusätzlich Projektmitgliedschaft und alle direkten/verschachtelten Gruppen. Der Access Level ersetzt diese Permissions nicht.
4. Dokumentiert folgende Werte:

   | Persona/Testkonto | Access Level | Direkte Gruppen | Geerbte Gruppen | Praktischer Test in Lab02 |
   |---|---|---|---|---|
   | Entwickler | Stakeholder | | | Work Item lesen und ändern |
   | QA | Stakeholder | | | Work Item lesen, Änderung verweigert |
   | Release Manager | Stakeholder | | | Projektzugang; optionale Pipelineprüfung |
   | Externer Reviewer | Stakeholder | | | Repo-Zugriff durch Access Level ausgeschlossen |

Die Einschränkung von Azure Repos bleibt auch bei einem Git-`Allow` bestehen. Es werden weder ein öffentliches Projekt noch zusätzliche Administratorrechte als Umgehung eingerichtet.

## 3. Minimale Projektrechte setzen

1. Öffnet **Project settings → Permissions** und wählt die erste neue Gruppe.
2. Setzt **View project-level information** auf **Allow**.
3. Lasst Projektadministration, Berechtigungsverwaltung und Löschen von Ressourcen ohne zusätzliches Allow. Wiederholt das für alle vier Gruppen.
4. Kontrolliert, ob die Oberfläche ein geerbtes Allow anzeigt. **Not set** entfernt kein Allow aus einer anderen Mitgliedschaft. Unnötige breite Mitgliedschaften sind zuerst zu bereinigen.

**Nachweis:** Projektberechtigungen jeder Gruppe mit sichtbarem Gruppennamen.

## 4. Isolierten Bereich für praktische Berechtigungstests einrichten

1. Öffnet **Project settings → Project configuration → Areas**. Legt unter dem Projektknoten über **… → New child** `Lab02-Permissions` an, sofern dieser Übungsbereich noch nicht existiert.
2. Öffnet ausschließlich bei diesem Area Path **… → Security**. Verändert nicht die Rechte des Projektwurzel-Pfads oder der produktbezogenen Areas aus Lab01.
3. Setzt für die Testgruppen:

   | Recht am Area Path `Lab02-Permissions` | OrderFlow Developers | OrderFlow QA |
   |---|---|---|
   | View work items in this node | Allow | Allow |
   | Edit work items in this node | Allow | Deny |

4. Das **Deny** ist hier eine bewusst begrenzte Übung: Work-Item-Bearbeitung kann bereits aus anderen Gruppen geerbt werden. Ein bloßes `Not set` würde dieses Allow nicht aufheben. Notiert die geerbten Rechte und den Grund für die Ausnahme.
5. Prüft, dass die beiden verwendeten Stakeholder-Testkonten keine Administratoren sind und nicht gleichzeitig beiden Testgruppen angehören. Sonst ist der Vergleich nicht aussagekräftig.
6. Öffnet die Rechte des jeweiligen Kontos an genau diesem Area Path und prüft Vererbung bzw. **Why?**, soweit angeboten. Erwartet für beide Lesen, für Entwickler Bearbeiten und für QA keine Bearbeitung.

Die Sperre gilt ausschließlich im Übungsbereich. Andere fachliche QA-Aufgaben werden dadurch nicht pauschal eingeschränkt. Die Prüfung erfolgt direkt am Work Item; der neue Area Path muss keinem Team-Board zugewiesen werden. [Microsoft: Work-Tracking-Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/set-permissions-access-work-tracking?view=azure-devops).

## 5. Repositoryrechte als Sollmodell auswerten

1. Übertragt die folgende Matrix in euer Rollenmodell. Sie beschreibt Git-Rechte bei grundsätzlich verfügbarem Repos-Zugriff; Stakeholder erhält dadurch keinen Repo-Zugang.
2. Falls der Trainer die Repository-Security im vorhandenen Projekt öffnen kann, gleicht das Modell dort ab. Eine Einstellung an dieser Oberfläche oder ein Basic-Konto ist keine Voraussetzung für die Lab02-Abnahme.

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

3. Ergänzt `orderflow-infra` im Modell: Reviewer und QA erhalten kein vorgesehenes Read-Allow. Für Entwickler und Release Manager ist der konkrete Bedarf zu begründen.
4. Falls eine Persona weiterhin ein geerbtes Allow besitzt, ermittelt seine Herkunft. Vermeidet pauschale Deny-Regeln. Ein gezieltes Deny kommt erst infrage, wenn eine notwendige Ausnahme von einem nicht entfernbaren Allow begründet ist.
5. Unterscheidet beim Reviewer **Contribute to pull requests** von **Contribute**. Diese Rechte sind fachlich verschieden; mit Stakeholder wird keines davon durch einen echten PR- oder Pushversuch nachgewiesen.

**Ergebnis:** Erläuterte Sollmatrix und die Unterscheidung zwischen Access-Level-Grenze und Ressourcen-Permission.

## 6. Pipelinerechte vorbereiten oder optional prüfen

Existiert bereits eine vorbereitete `orderflow-ci`, könnt ihr ihre Portalrechte zusätzlich prüfen. Andernfalls genügt in Lab02 das folgende Modell; ein Pipeline-Run ist für die Pflichtabnahme nicht nötig. Pipelinezugriff und Repo-Zugriff sind getrennt: Stakeholder kann Azure Pipelines bei passenden Permissions nutzen. YAML-Bearbeitung im privaten Azure Repo bleibt ausgeschlossen.

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

## 7. Verhalten mit zwei Stakeholder-Konten testen

1. Meldet euch mit dem Entwickler-Testkonto in einem separaten Browserprofil oder privaten Fenster an. Kontrolliert Konto und Access Level. Die Auswahl einer Gruppe im Adminportal wechselt nicht die angemeldete Identität.
2. Öffnet **Boards → Work Items → New Work Item** und wählt **Task** oder den vom Trainer vorgegebenen Typ. Tragt den Titel `Lab02 – Berechtigungstest <kuerzel>` ein und setzt **Area Path** ausdrücklich auf `<projekt>\Lab02-Permissions`. Speichert. Falls dieser Erstellungsschritt im vorbereiteten Projekt nicht möglich ist, legt der Trainer das Testelement an; der anschließende Änderungstest bleibt erforderlich.
3. **Positivtest Entwickler:** Ändert die Beschreibung des Testelements auf `Änderung durch Entwickler-Testkonto` und speichert. Prüft die gespeicherte Änderung bzw. den History-Eintrag und notiert ID/Link des Work Items.
4. Öffnet denselben Work-Item-Link mit dem QA-Testkonto in einem getrennten Browserprofil. **Positivtest QA:** Das Element und die Beschreibung sind lesbar.
5. **Negativtest QA:** Versucht, die Beschreibung zu ändern und zu speichern. Erwartet eine fehlende Bearbeitungsmöglichkeit oder eine Berechtigungsfehlermeldung. Notiert die tatsächliche Reaktion. Das Work Item muss unverändert bleiben.
6. Vergleicht den Befund mit **Edit work items in this node** am Testbereich. Die Verweigerung folgt hier aus der Area-Permission, nicht aus Stakeholder, denn beide Konten haben denselben Access Level.
7. **Access-Level-Abgrenzung:** Prüft mit dem Entwickler-Stakeholder den bekannten Link zu `orderflow-app`. Erwartet keinen Repo-Zugriff, unabhängig vom Git-Sollmodell. Bezeichnet dies nicht als erfolgreichen Negativtest für QA-Contribute oder Infra-Read.
8. **Optional bei vorhandener Pipeline:** QA liest einen vorbereiteten Run und Logs, darf die Pipeline nach der Rollenmatrix aber nicht bearbeiten. Notiert den tatsächlichen Befund; fordert dafür kein Upgrade auf Basic an.
9. Lasst den isolierten Testbereich bis zur Abnahme bestehen. Soll er später anderweitig genutzt werden, stellt der zuständige Administrator die zuvor notierten Rechte gezielt wieder her. Keine unvermerkten Deny-Regeln auf gemeinsam genutzten Areas hinterlassen.

## 8. Abnahme

| Test | Identität / Access Level | Erwartung | Tatsächliches Ergebnis | Work-Item-/Run-Link oder Meldung |
|---|---|---|---|---|
| Work Item ändern | Entwickler / Stakeholder | erlaubt | | |
| Dasselbe Work Item lesen | QA / Stakeholder | erlaubt | | |
| Dasselbe Work Item ändern | QA / Stakeholder | verweigert durch Area-Permission | | |
| Privates App-Repo öffnen | Entwickler / Stakeholder | kein Zugriff durch Access Level | | |
| Vorbereiteten Build lesen | QA / Stakeholder | optional, mit passenden Permissions | | |
| Pipeline bearbeiten | QA / Stakeholder | optional, laut Rollenmatrix verweigert | | |

- [ ] Alle für Lab02 verwendeten Übungskonten haben Stakeholder; kein Basic-Upgrade ist erforderlich.
- [ ] Gruppen und Mitgliedschaftsketten sind dokumentiert.
- [ ] Lesen/Bearbeiten am isolierten Area Path sind für zwei Konten effektiv geprüft.
- [ ] Ein erfolgreicher Änderungstest und ein verweigerter Änderungstest sind am selben Work Item belegt.
- [ ] Die gezielte Deny-Ausnahme und ihr begrenzter Scope können erklärt werden.
- [ ] Git-Rechte sind als Sollmodell ausgewertet; ausgefallene Repos-/PR-Aktionen werden nicht als Permission-Nachweis ausgegeben.

**Reflexion:** Warum darf ein Stakeholder das Work Item bearbeiten, der andere nicht? Warum bringt ein Git-Allow dennoch keinen Repos-Zugang? Wie würdet ihr ein Einzelrecht durch eine Gruppe ersetzen?

## Portalhilfe

- [Berechtigungsreferenz](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)
- [Git-Standardberechtigungen](https://learn.microsoft.com/en-us/azure/devops/organizations/security/default-git-permissions?view=azure-devops)
- [Zugriff auf Pull Requests](https://learn.microsoft.com/en-us/azure/devops/repos/git/about-pull-requests?view=azure-devops)

- [Stakeholder-Funktionsumfang](https://learn.microsoft.com/en-us/azure/devops/organizations/security/stakeholder-access?view=azure-devops)
- [Permissions für Work Items und Area Paths](https://learn.microsoft.com/en-us/azure/devops/organizations/security/set-permissions-access-work-tracking?view=azure-devops)
