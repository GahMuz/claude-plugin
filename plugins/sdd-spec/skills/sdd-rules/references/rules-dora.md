# Règles DORA

> **Statut :** Framework initial — sera enrichi par le skill `/analyse-dora` (à venir).
> Ce fichier couvre deux dimensions DORA : les **métriques de livraison** (DevOps Research and Assessment)
> et le **règlement européen** DORA (Digital Operational Resilience Act, applicable aux entités financières).

---

## Partie 1 — Métriques DORA (DevOps)

Les 4 métriques clés pour mesurer la performance d'une équipe de livraison logicielle.
Ces règles guident les décisions de design et de planification pour maximiser la vélocité et la résilience.

### Fréquence de déploiement
**Objectif elite :** Plusieurs déploiements par jour.

- [ ] Le design favorise des changements petits et indépendants (feature flags, découplage)
- [ ] Pas de dépendances entre specs qui forcent un déploiement groupé
- [ ] Les specs sont dimensionnées pour être livrées en moins d'une semaine

**Red flags :** Spec qui touche > 10 modules sans isolation, couplage fort entre features livrées ensemble.

---

### Lead time (délai idée → production)
**Objectif elite :** < 1 heure.

- [ ] Le workflow spec est itératif — phases courtes, approbation rapide
- [ ] Les tâches atomiques (TASK-xxx.y) sont indépendamment testables et déployables
- [ ] Les tests automatisés permettent un feedback rapide (< 10 min pour la suite unitaire)

**Red flags :** Plan sans parallélisation, tâches de > 1 jour, suite de tests > 30 min.

---

### Taux d'échec des changements (Change Failure Rate)
**Objectif elite :** < 5%.

- [ ] Chaque déploiement est couvert par des tests automatisés (baseline-tests.json)
- [ ] Les breaking changes sont détectés avant le merge (phase finishing)
- [ ] Le design anticipe les rollback : migrations réversibles, feature flags désactivables

**Red flags :** Pas de tests de non-régression, migrations Liquibase/Flyway non réversibles, déploiement sans possibilité de rollback.

---

### Temps de rétablissement (MTTR — Mean Time To Restore)
**Objectif elite :** < 1 heure.

- [ ] Les composants critiques ont des mécanismes d'observabilité (logs structurés, métriques, alertes)
- [ ] Le design inclut une stratégie de dégradation gracieuse (circuit breaker, fallback)
- [ ] Les runbooks de restauration sont documentés dans les prochaines étapes des ADR concernés

**Red flags :** Pas de logs structurés sur les chemins critiques, absence de health checks, aucun mécanisme de circuit breaker sur les dépendances externes.

---

## Partie 2 — Règlement DORA (EU 2022/2554)

Applicable aux **entités financières** (banques, assurances, PSP, fonds d'investissement...) et leurs prestataires ICT critiques. En vigueur depuis janvier 2025.

> Si le projet ne s'inscrit pas dans un contexte financier réglementé, cette section peut être ignorée.

### Gestion des risques ICT (Art. 5-16)
- [ ] Les composants critiques sont identifiés et documentés (mapping DES ↔ criticité)
- [ ] Les dépendances sur des tiers ICT (cloud, SaaS, API externes) sont listées dans le design
- [ ] Un plan de continuité est prévu pour chaque dépendance critique (fallback, SLA, contrat)

---

### Tests de résilience opérationnelle (Art. 24-27)
- [ ] Les tests de résilience (chaos engineering, tests de bascule) sont planifiés dans le plan
- [ ] Les scénarios de panne des dépendances critiques sont couverts par des tests
- [ ] Les résultats des tests de résilience sont documentés et traçables

---

### Gestion des incidents ICT (Art. 17-23)
- [ ] Le design inclut une classification des incidents selon leur impact (P1/P2/P3)
- [ ] Les alertes sont configurées pour les incidents potentiellement déclarables
- [ ] Un processus de notification (régulateur, clients) est prévu si applicable

---

### Gestion du risque tiers (Art. 28-44)
- [ ] Chaque dépendance sur un prestataire ICT tiers est évaluée (criticité, concentration)
- [ ] Les contrats avec les prestataires critiques mentionnent les exigences DORA
- [ ] Pas de dépendance unique sur un tiers pour un service critique (concentration risk)

---

## Checklist design (phase DES)

Pour chaque DES-xxx dans un contexte DORA :
- [ ] Observabilité : logs structurés, métriques, alertes définis
- [ ] Résilience : stratégie de dégradation ou fallback documentée
- [ ] Déploiement : changement réversible, migration réversible
- [ ] Dépendances tierces : listées avec niveau de criticité
