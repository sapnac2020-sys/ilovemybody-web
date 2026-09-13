# ILoveMyBody Body Need Master

This document defines the canonical parameter/formula/terminology layer for computing body needs from measured person data without inventing clinical targets.

## Core rule

A body-need computation is permitted only when all required measured inputs, targets, units, and coefficients have governed provenance. Missing or unverified inputs block computation; they are never silently replaced by population averages.

## Canonical chain

`subject observation -> LOINC observation identity -> canonical ILMB parameter -> UCUM unit -> ChEBI chemical/nutrient identity where applicable -> governed formula -> body-need result -> food/nutrient/body-system links`

LOINC is used to identify laboratory/clinical observations. ChEBI is used to identify molecular/chemical entities and nutrients. UBERON, CL, GO, HPO and Reactome remain available for anatomy, cell, process, phenotype and pathway context.

## Required masters

1. Parameter Master: one canonical record per quantity or state.
2. Identifier Crosswalk: one-to-many links to LOINC, ChEBI, UBERON, CL, GO, HPO, Reactome and other approved systems.
3. Formula Master: expression, purpose, evidence class, units, source and verification status.
4. Formula Inputs: each symbol mapped to a canonical parameter with explicit role.
5. Duplicate Candidate Register: possible duplicates are reviewed, not auto-deleted.
6. Body Need Runs: reproducible input snapshot, output, status and provenance.

## Formula governance

Allowed evidence classes are FIRST_PRINCIPLES, MEASURED_PERSON, AUTHORITATIVE_REFERENCE, PUBLISHED_MODEL and EXPLORATORY. Only VERIFIED/APPROVED formulas may be used for production calculations. Dimensional analysis and UCUM compatibility are mandatory for numeric formulas.

A generic target-gap relationship such as `need = target - measured` is a calculation pattern, not a target source. The target itself must be present as a governed parameter value with source provenance before a result is produced.

## Duplicate policy

Exact approved shared identifiers are high-confidence duplicate signals. Normalized name + unit, same source key, and formula equivalence are candidate signals only. No canonical record is deleted automatically.
