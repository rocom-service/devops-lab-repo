# Lab 03 – Ressourcen-Governance-Challenge

**Dauer:** 55 Minuten · **Arbeitsform:** Einzelarbeit  
**Organisation:** [ppedv-courses](https://dev.azure.com/ppedv-courses)  
**Voraussetzung:** Eigenes privates Projekt und die Gruppen aus [Lab 02](Lab02.md).

## Ziel und Ablauf

Schützt Repository, Branch, Pipeline und Environments jeweils an ihrer eigenen Grenze. Erstellt nachvollziehbare Regeln und prüft sie mit erlaubten und unerlaubten Aktionen. Arbeitet ausschließlich im eigenen Trainingsprojekt in **ppedv-courses**.

| Abschnitt | Zeit | Ergebnis |
|---|---|---|
| Branch und PR | 20 Min | Verbindliche Review- und Kommentarregeln |
| Ressourcenrollen und Autorisierung | 20 Min | Geschützte Trainings-Environments |
| Angriffstests und Protokoll | 15 Min | Nachweise und klar markierte Restpunkte |

`orderflow-ci` entsteht erst in Lab04 und erhält in Lab05 den vollständigen Build. Deshalb wird Build Validation hier gegebenenfalls **vorbereitet**. Deploymenttests folgen mit `orderflow-release` in Lab06. Ein noch nicht ausgeführter Test zählt nicht als erfolgreich.

## 1. `main` durch Branch Policies schützen

1. Öffnet **Repos → Branches**, wählt `orderflow-app` und bei `main` **… → Branch policies**.
2. Aktiviert **Require a minimum number of reviewers** und konfiguriert:

   | Einstellung | Sollwert |
   |---|---|
   | Minimum number of reviewers | `1` |
   | Allow requestors to approve their own changes | Aus |
   | Prohibit the most recent pusher from approving their own changes | Ein, sofern angeboten |
   | Allow completion even if some reviewers vote to wait or reject | Aus |
   | When new changes are pushed | **Reset all approval votes** oder Trainer-Vorgabe mit erneuter unabhängiger Freigabe |

3. Aktiviert **Check for comment resolution** als **Required**.
4. Verlasst die Seite erst, wenn die Speicherung bestätigt ist. Öffnet sie erneut und prüft die Werte.
5. Unter **Repos → Branches → main → … → Branch security** kontrolliert ihr für `OrderFlow Developers`: **Bypass policies when pushing** und **Bypass policies when completing pull requests** besitzen kein effektives Allow. Prüft auch geerbte Gruppenrechte.
6. Lasst Entwickler weiterhin auf Feature-Branches beitragen. Ein pauschales `Contribute: Deny` auf `main` ist für dieses Modell nicht nötig und kann die gewünschte PR-Abnahme behindern.

**Nachweis:** Reviewer-Policy, Kommentar-Policy und effektive Bypass-Rechte. Verbindliche Policies ohne Bypass erzwingen den PR-Weg.

## 2. Build Validation vorbereiten

1. Prüft auf derselben Policy-Seite den Abschnitt **Build Validation**.
2. Falls `orderflow-ci` noch nicht existiert, dokumentiert `Offen bis Lab04/05: orderflow-ci als Required/Automatic hinzufügen`. Legt keinen Platzhalter auf eine fremde Pipeline an.
3. Sobald die Pipeline vorhanden ist: **+ → Build pipeline: orderflow-ci → Trigger: Automatic → Policy requirement: Required**. Lasst den **Path filter** für diese Übung leer, damit jeder PR geprüft wird. Wählt bei Build expiration **Immediately when main is updated**, soweit angeboten, und speichert.
4. Für Azure Repos Git kommt die PR-Validierung aus der Branch Policy. Ein YAML-`pr:`-Eintrag ist dafür nicht die Lösung.

## 3. Pipeline-Verantwortung festlegen

1. Dokumentiert `orderflow-ci` als Build-/PR-Pipeline und `orderflow-release` als spätere Deployment-Pipeline.
2. Sobald `orderflow-ci` existiert, öffnet **Pipelines → Pipelines → orderflow-ci → … → Manage security** und übernehmt die Pipeline-Rechte aus Lab02.
3. Entwickler dürfen Builds starten und lesen. Nur die benannten Pipeline-Verantwortlichen dürfen Definition und Berechtigungen administrieren.
4. Haltet getrennt fest: Wer startet den Run? Welche Build-Service-Identität führt ihn aus? Welche konkrete Pipeline ist für eine Ressource autorisiert? Diese drei Angaben sind nicht austauschbar.

## 4. Zwei leere Trainings-Environments anlegen

1. Öffnet **Pipelines → Environments → New environment** beziehungsweise **Create environment**.
2. Erstellt `orderflow-staging` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Staging-Deployment`.
3. Erstellt analog `orderflow-prod` mit **Resource: None** und Beschreibung `Trainingsumgebung – simuliertes Produktionsdeployment`.
4. Existieren die Environments bereits im eigenen Trainingsprojekt, prüft und ergänzt sie. Fügt weder virtuelle Maschinen noch Kubernetes-Ressourcen hinzu; die folgenden Labs simulieren die Deployments.
5. Öffnet jedes Environment → **… → Security**.
6. Prüft **User permissions** und die Vererbung. Die benannten Ressourcenverantwortlichen verwalten die Ressource. Setzt `OrderFlow Release Managers` für die reine Freigaberolle auf **Reader**; die Gruppe wird in Lab06 zusätzlich als Approver eingetragen.
7. Prüft insbesondere breit vererbte **User**- oder **Administrator**-Rollen. Falls ihr für dieses Trainings-Environment die Vererbung einschränkt, erhaltet zuerst den Zugriff der vorgesehenen Ressourcenverantwortlichen und entfernt danach unnötige Rollen. Dokumentiert vorher/nachher. Die Rollen **Creator**, **User** und **Administrator** können nach der aktuellen Dokumentation Checks verwalten; Reader kann dies nicht.
8. Unter **Pipeline permissions** wählt ihr bei vorhandenem Open access **Restrict permission**. Fügt ausschließlich eine bereits vorhandene, dafür vorgesehene Kurspipeline hinzu. Solange `orderflow-release` noch nicht existiert, bleibt dessen gezielte Autorisierung als Restpunkt für Lab06 vermerkt; öffnet den Zugriff nicht für alle Pipelines.

**Nachweis:** Namen, Resource None, Benutzerrollen/Vererbung und eingeschränkte Pipeline permissions beider Environments. Approval-Konfiguration folgt in Lab06.

## 5. Service Connection prüfen oder Modell dokumentieren

1. Öffnet **Project settings → Service connections**.
2. Verwendet nur die vom Trainer ausdrücklich benannte Trainingsverbindung. Falls keine vorhanden ist, erstellt das Rollenmodell aus der Tabelle unten; legt keine produktive Verbindung oder Azure-Ressource an.
3. Öffnet die Trainingsverbindung → **… → Security**. Dokumentiert Reader-/User-/Administrator-Zuordnungen, soweit vorhanden.
4. Prüft **Pipeline permissions** und gegebenenfalls unter **Edit** die Option **Grant access permission to all pipelines**. Produktionsnahe Verbindungen werden nicht pauschal für alle Pipelines geöffnet.
5. Autorisiert nur die konkrete Pipeline mit einer tatsächlichen Nutzungsaufgabe. Die simulierten Deployments dieses Kurses brauchen keine Service Connection.
6. Bei einer echten Azure-Verbindung sind die Rechte der Verbindungsidentität in Azure zusätzlich zu prüfen. Eine Pipeline Permission ersetzt keine Azure-RBAC-Zuweisung.

| Schutzobjekt | Verantwortliche | Erlaubt | Nicht erlaubt | Nachweis |
|---|---|---|---|---|
| Trainings-Service-Connection oder geplante Verbindung | Benannte Ressourcenverantwortliche | Verwaltung; Nutzung nur durch benannte Pipeline | Open access / globale Administration für Fachrollen | Einstellungsseite oder ausdrücklich als geplant markiertes Modell |

## 6. Angriffstests durchführen

Verwendet das eingeschränkte Entwicklerkonto aus Lab02, nicht euer Administrationskonto mit möglichen Bypass-Rechten.

1. **Direkter Commit:** Öffnet `main` unter **Repos → Files**, versucht eine harmlose Trainingsänderung direkt auf `main` zu committen. Erwartet eine Verweigerung bzw. die Aufforderung, einen Branch/PR zu verwenden. Ein echter Git-Push mit dem vorbereiteten Konto ist ebenfalls geeignet. Notiert die genaue Meldung. Bei unerwartetem Erfolg stoppt und untersucht Bypass-Vererbung, bevor ihr fortfahrt.
2. **PR ohne Review:** Erstellt `feature/lab03-<kuerzel>` aus `main`, committet eine harmlose Dokumentationsdatei und öffnet über **Repos → Pull requests → New pull request** einen PR nach `main`.
3. Kontrolliert im PR, dass die Reviewer-Policy sichtbar ist und der Abschluss ohne unabhängige Zustimmung blockiert wird.
4. Lasst das vorgesehene zweite Testkonto einen offenen Kommentar anlegen und zustimmen. Prüft, dass der ungelöste Kommentar die Abnahme weiterhin blockiert. Löst ihn nach Bearbeitung auf. Falls Build Validation schon aktiv ist, muss zusätzlich ihr Build erfolgreich sein.
5. Führt die beiden Ressourcenautorisierungstests aus, sobald ein Deployment Job vorliegt: Die nicht autorisierte Testpipeline muss am Environment scheitern oder auf Autorisierung warten; die autorisierte Release-Pipeline darf die Ressource nach erfüllten Checks verwenden. Erteilt der negativen Testpipeline nicht versehentlich Zugriff über **Permit**.
6. Fehlen heute Deployment Jobs, dokumentiert Schritt 5 als offen und führt ihn in Lab06/07 aus. Mindestens drei Prüfungen sollen schließlich belegt sein; die PR-Tests können schon jetzt abgeschlossen werden.

## 7. Screenshots und Entscheidungsprotokoll

Speichert unter `Lab03-Screenshots`, jeweils mit Projekt-, Branch- oder Ressourcenkontext.

| Präfix | Inhalt |
|---|---|
| `01-Reviewer-Policy` | Alle Optionen und Reviewerzahl |
| `02-Kommentare-Build-Validation` | Required-Regeln bzw. offener Build-Validation-Punkt |
| `03-Branch-Security` | Effektive Bypass-Rechte des Entwicklerkontos |
| `04-Pipeline-Security` | Konkrete Pipeline und Rollen, sobald vorhanden |
| `05-Environments` | Namen und leere Trainingsressourcen |
| `06-Environment-Security` | Benutzerrollen, Vererbung und Pipeline permissions je Environment |
| `07-Service-Connection` | Trainingsverbindung oder dokumentiertes Rollenmodell |
| `08-Angriffstests` | Abgelehnter Direktcommit, blockierter PR, später Autorisierungsfehler und Erfolg |

Ergänzt für jede Ressource einen Satz: **Schutzobjekt – Identität/Gruppe – erlaubte Aktion – ausgeschlossene Aktion – Prüfnachweis**.

- [ ] Unabhängiges Review und Kommentarauflösung sind verpflichtend.
- [ ] Entwickler haben keine effektiven Bypass-Rechte.
- [ ] YAML-Änderungen laufen ebenfalls über den PR-Weg.
- [ ] Environments haben gezielte Rollen und eingeschränkte Pipeline permissions.
- [ ] Restpunkte nennen Lab04/05 bzw. Lab06/07 und wurden nicht als erfolgreiche Tests ausgegeben.

**Bonus:** Entfernt später ausschließlich an eurer Trainingsressource die Autorisierung der vorgesehenen Pipeline, belegt die Fehlermeldung und stellt genau diese Zuordnung wieder her. Kein Open access als Reparatur.

## Portalhilfe

- [Branch Policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
- [Environments, Rollen und Pipeline permissions](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Approvals und Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
