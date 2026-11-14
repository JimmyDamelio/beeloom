# BEELOOM

Jeu Roblox d'élevage de lignées : l'abeille pollinise, les graines héritent des gènes des deux parents.
Conception : `docs/BEELOOM - Game Design Document.docx`.

## Installation sur ton PC (une seule fois)

1. Installe **Rokit** (gestionnaire d'outils Roblox) : https://github.com/rojo-rbx/rokit#installation
2. Dans ce dossier : `rokit install` (installe Rojo et Lune aux versions de `rokit.toml`).
3. Dans Roblox Studio, installe le plugin **Rojo** (Creator Store, auteur « Rojo »).

## Travailler

- `rojo serve` dans ce dossier, puis dans Studio : onglet Plugins → Rojo → **Connect**.
  Le code du dossier `src/` apparaît dans Studio et se met à jour à chaque sauvegarde.
- Modifie le code dans les fichiers, pas dans Studio : les fichiers sont la source de vérité.

## Tests (sans Studio)

```
lune run tests/genetics.test.luau
```

## Structure

| Dossier | Contenu |
|---|---|
| `src/ReplicatedStorage/Shared/Content.luau` | Le contenu en tableaux : espèces, gènes, variantes, raretés. Ajouter une Aura = ajouter une ligne. |
| `src/ReplicatedStorage/Shared/Genetics.luau` | L'hérédité : pollen, croisement, expression des gènes, rareté calculée, identifiant du Registre. |
| `tests/` | Tests automatiques de la génétique. |
