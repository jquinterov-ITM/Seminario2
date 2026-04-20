#!/usr/bin/env python3
import json, sys
from collections import defaultdict

def load(p): 
    return json.load(open(p,'r',encoding='utf-8'))

def summarize(plan):
    counts=defaultdict(int)
    for rc in plan.get("resource_changes",[]):
        k=",".join(rc.get("change",{}).get("actions",[]))
        counts[k]+=1
    return counts

def diff_attrs(b,a):
    diffs={}
    keys=set((b or {}).keys())|set((a or {}).keys())
    for k in sorted(keys):
        vb=(b or {}).get(k,"<MISSING>")
        va=(a or {}).get(k,"<MISSING>")
        if vb!=va: diffs[k]={"before":vb,"after":va}
    return diffs

def detailed(plan):
    out=[]
    for rc in plan.get("resource_changes",[]):
        ch=rc.get("change",{})
        out.append({"address":rc.get("address"),"actions":ch.get("actions"),"attr_changes": diff_attrs(ch.get("before"), ch.get("after"))})
    return out

if len(sys.argv)!=3:
    print("Uso: compare_tfplans.py planA.json planB.json"); sys.exit(2)

pA=load(sys.argv[1]); pB=load(sys.argv[2])
sA=summarize(pA); sB=summarize(pB)
print("SUMMARY\nA:",dict(sA))
print("B:",dict(sB))
print("\nCOMPARE COUNTS")
for k in sorted(set(list(sA.keys())+list(sB.keys()))):
    print(f"{k}: A={sA.get(k,0)} | B={sB.get(k,0)}")

print("\nDETAILED SAMPLE A")
import pprint; pprint.pprint(detailed(pA)[:20], width=140)
print("\nDETAILED SAMPLE B")
pprint.pprint(detailed(pB)[:20], width=140)