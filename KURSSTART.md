# Kursstart und Voraussetzungen

Die Labs verwenden Azure DevOps Services in der Organisation [ppedv-courses](https://dev.azure.com/ppedv-courses). Sie bauen aufeinander auf und starten jeweils nach Aufforderung des Trainers.

## Konto und Anmeldung

Verwende dein persönlich zugeteiltes Kurskonto mit Access Level **Basic**. Zugangsdaten erhältst du separat vom Trainer. Der Trainer stellt das Recht zur Projektanlage und den Agentzugang bereit. Im selbst angelegten Projekt behältst du die Administratorrechte für die Konfigurationsaufgaben.

## Teilnehmerprojekte und Kürzel

Der Trainer teilt dir deinen Projektnamen und dein Kürzel mit. Diese persönliche Zuordnung gehört zu den separat bereitgestellten Kursinformationen.

- `<projekt>` steht für deinen zugeteilten Projektnamen, im Kurs nach dem Muster `orderflow-<kuerzel>`.
- `<kuerzel>` steht für dein zugeteiltes Kürzel, beispielsweise in `feature/lab04-<kuerzel>`.
- Verwende durchgehend dieses Projekt. Das Referenzprojekt `orderflow-solutions` wird nicht bearbeitet.

## Technische Voraussetzungen

- Browser mit Zugriff auf Azure DevOps und dieses Repository.
- Texteditor zum Lesen von JSON und ein Werkzeug zum Entpacken von ZIP-Dateien.
- Ein gemeinsamer Microsoft-hosted Paralleljob im Pool **Azure Pipelines**, Image **ubuntu-latest**. Wartende Runs weiterverwenden, keine Duplikate starten.
- Keine Azure Subscription und keine Service Connection: Die Deployments sind Simulationen in leeren Environments.

Bei einem Anmelde-, Import-, Berechtigungs- oder Kapazitätsproblem unterstützt dich der Trainer.

## Arbeitsweise

Teil A von Lab01 ist ein Partnergespräch. Die technischen Labs bearbeitest du im eigenen Projekt. Verständnisfragen werden mündlich besprochen; Ergebnisse prüfst du direkt im Portal. Schriftliche Erklärungen, Protokolle, Dokumentationen und Screenshots sind nicht erforderlich.

Ab Lab03 gehen Änderungen nach `main` über einen Feature-Branch und PR. Die eigene PR-Zustimmung und später die Freigabe des eigenen simulierten Releases sind Trainingsausnahmen. Pflichtprüfungen bleiben aktiv, ein Policy-Bypass wird nicht verwendet.

Die Anleitungen, Wertstrom-Vorlage und verlinkten YAML-Dateien sind in diesem Repository enthalten. Einstieg: [Lab01 Teil A](labs/Lab01-Teil-A.md) und anschließend [Lab01 Teil B](labs/Lab01-Teil-B.md).
