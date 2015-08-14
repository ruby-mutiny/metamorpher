# Release History

## v0.2.3 (14 August 2015)
* Prefer `Site#transformed_code` to `Site#refactored_code` as the latter is odd when a Site is produced during a mutation rather than a refactoring.

## v0.2.2 (4 June 2015)
* Provide whole match special variable (&) for derivations
* Provide sensible default logic (derive the value of their first argument) for derivations

## v0.2.1 (12 May 2015)
* Provide support for term sets, which make it possible to match (or rewrite to) multiple expressions at once

## v0.2.0 (9 May 2015)
* Provide support for mutators, which are similar to refactorers but produce multiple transformed programs

## v0.1.1 (8 May 2015)
* Update dependencies

## v0.1.0 (6 May 2014)
Provide support for:
* A generic mechanism for specifying terms
* Language-independent term matching and rewriting
* Language-specific refactoring
* A Ruby builder that enables program matching, rewriting and refactoring of Ruby programs.
