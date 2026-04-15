# Règles RGPD

> **Statut :** Framework initial — sera enrichi par le skill `/analyse-rgpd` (à venir).
> Ces règles constituent un socle de vérification à appliquer dès la conception.
> Elles ne remplacent pas une analyse juridique complète.

Applicable quand les REQ ou le code manipulent des **données à caractère personnel** (DCP) :
nom, prénom, email, téléphone, adresse IP, identifiant technique, données de santé, données financières, comportements utilisateur, géolocalisation.

---

## Principes fondamentaux

### Minimisation des données
**Règle :** Ne collecter que les données strictement nécessaires à la finalité déclarée.

- [ ] Chaque champ collecté est justifié par une finalité explicite dans les REQ
- [ ] Pas de collecte "au cas où" ou "pour usage futur"
- [ ] Les champs optionnels sont clairement séparés des champs obligatoires

**Red flags :** Collecte d'email pour une feature qui n'en a pas besoin, stockage de l'IP pour des logs non-audit.

---

### Limitation des finalités
**Règle :** Les données collectées pour une finalité ne peuvent pas être réutilisées pour une autre sans consentement.

- [ ] La finalité de chaque donnée collectée est documentée dans les REQ
- [ ] Pas de réutilisation de données d'une feature A dans une feature B sans analyse
- [ ] Les traitements secondaires (analytics, ML, marketing) sont explicitement listés

---

### Durée de conservation
**Règle :** Les données personnelles ne doivent pas être conservées au-delà de leur durée de vie nécessaire.

- [ ] Une durée de rétention est définie pour chaque catégorie de DCP stockée
- [ ] Un mécanisme de suppression automatique (purge, archivage, anonymisation) est prévu
- [ ] La durée est proportionnée à la finalité (ex : logs = 90 jours, données client = durée de la relation + obligation légale)

---

### Droits des personnes
**Règle :** Les personnes ont le droit d'accéder, rectifier, supprimer et exporter leurs données.

- [ ] Le design prévoit un mécanisme d'accès aux données par l'utilisateur
- [ ] Un flux de suppression de compte (droit à l'effacement) est conçu
- [ ] Les données sont exportables dans un format structuré (droit à la portabilité)

---

### Sécurité des données
**Règle :** Les DCP doivent être protégées contre l'accès non autorisé.

- [ ] Les données sensibles sont chiffrées au repos (mots de passe = hash bcrypt/argon2, pas MD5/SHA1)
- [ ] Les données sensibles sont chiffrées en transit (HTTPS/TLS obligatoire)
- [ ] L'accès aux DCP est contrôlé par des règles d'autorisation explicites
- [ ] Les DCP n'apparaissent pas dans les logs applicatifs en clair

**Red flags :** Hash MD5 ou SHA1 pour les mots de passe, logs contenant des emails ou tokens, accès aux données sans vérification de rôle.

---

### Privacy by Design
**Règle :** La conformité RGPD est intégrée dès la conception, pas ajoutée après.

- [ ] Les flux de données personnelles sont identifiés dans le design (DES-xxx)
- [ ] Les composants qui traitent des DCP sont explicitement nommés
- [ ] Le consentement (si requis) est modélisé dans les REQ avant l'implémentation

---

## Checklist design (phase DES)

Pour chaque DES-xxx qui manipule des DCP :
- [ ] Finalité documentée
- [ ] Durée de conservation définie
- [ ] Droits d'accès/suppression prévus
- [ ] Chiffrement déclaré si données sensibles
- [ ] Pas de DCP dans les logs

## Checklist revue de code

- [ ] Pas de DCP en clair dans les logs (`log.info("User email: {}", email)` → interdit)
- [ ] Hash des mots de passe avec algorithme adapté (bcrypt, argon2)
- [ ] Requêtes paramétrées (pas de concaténation SQL avec des DCP)
- [ ] Endpoints exposant des DCP protégés par authentification + autorisation
