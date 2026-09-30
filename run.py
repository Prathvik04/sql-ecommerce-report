import sqlite3, re, sys
db=sqlite3.connect(':memory:')
for f in ['01_schema.sql','02_data.sql']: db.executescript(open(f).read())
db.execute("PRAGMA foreign_keys=ON")
md=["# Query results (auto-generated)\n"]
blocks=re.split(r'\n(?=-- Q\d+:)',open('03_queries.sql').read())
n=0
for b in blocks:
    m=re.match(r'-- (Q\d+): (.*)',b)
    if not m: continue
    sql="\n".join(l for l in b.split("\n") if not l.startswith('--')).strip()
    if not sql: continue
    n+=1
    cur=db.execute(sql); cols=[d[0] for d in cur.description]; rows=cur.fetchall()
    print(f"{m.group(1)} OK rows={len(rows)}")
    md.append(f"## {m.group(1)}: {m.group(2)}\n```sql\n{sql}\n```\n")
    md.append("| "+" | ".join(cols)+" |\n|"+"---|"*len(cols))
    for r in rows[:15]: md.append("| "+" | ".join('NULL' if v is None else str(v) for v in r)+" |")
    md.append(f"\n*{len(rows)} row(s)*\n")
print("queries:",n)
open('results.md','w').write("\n".join(md))
fails=0
for t in open('04_constraint_tests.sql').read().split('-- T: ')[1:]:
    name,_,sql=t.partition("\n")
    try: db.execute(sql.strip()); print("NOT BLOCKED:",name); fails+=1
    except sqlite3.Error as e: print("blocked:",name,"->",e)
print("constraint tests unblocked:",fails)
