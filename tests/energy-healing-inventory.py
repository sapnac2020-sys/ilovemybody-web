"""Check retrieval completeness and prevent metadata being presented as appraisal."""
import csv
from pathlib import Path
root=Path(__file__).resolve().parents[1]
with (root/'docs/research/energy-healing-primary-record-inventory.csv').open() as f:
 rows=list(csv.DictReader(f))
assert len(rows)==1976 and len({r['pmid'] for r in rows})==1976
searched=[r for r in rows if r['search_practices']]
assert len(searched)==1897
assert sum(len(r['search_practices'].split(';')) for r in searched)==2061
assert sum(r['earlier_cohort']=='True' for r in rows)==283
assert sum(r['review_status']=='ELIGIBILITY_SCREENING_PENDING' for r in rows)==1693
assert all(r['source_url']==f"https://pubmed.ncbi.nlm.nih.gov/{r['pmid']}/" for r in rows)
assert any(r['pmid']=='30860755' and r['publication_types']=='Study Guide' for r in rows)
with (root/'docs/research/energy-healing-abstract-extractions.csv').open() as f:
 extracted=list(csv.DictReader(f))
assert len(extracted)==100 and len({(r['practice_code'],r['pmid']) for r in extracted})==100
assert len({r['pmid'] for r in extracted})==98
assert sum(r['material_reviewed']=='ABSTRACT' for r in extracted)==99
assert sum(r['screening_status']=='CONTEXT_ONLY' for r in extracted)==2
assert sum(r['screening_status']=='ABSTRACT_EXTRACTED_FULL_REVIEW_PENDING' for r in extracted)==97
assert next(r for r in extracted if r['pmid']=='12233795')['material_reviewed']=='NO_ABSTRACT'
assert all(r['remaining_work'] and r['interpretation'] for r in extracted)
print('Primary record retrieval reconciliation and extraction scope checks passed')
