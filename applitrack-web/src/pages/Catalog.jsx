import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useData } from '../data/store.jsx';
import { CATALOG } from '../lib/catalog';
import { CompanyCategory, CATEGORY_KEYS, isFetchable } from '../lib/enums';
import { initials } from '../lib/format';

export default function Catalog() {
  const data = useData();
  const nav = useNavigate();
  const [query, setQuery] = useState('');
  const addedNames = new Set(data.companies.map((c) => c.name.trim().toLowerCase()));

  const list = query
    ? CATALOG.filter((s) => s.name.toLowerCase().includes(query.toLowerCase()) || (s.tags || []).some((t) => t.toLowerCase().includes(query.toLowerCase())))
    : CATALOG;
  const byCat = {};
  for (const s of list) (byCat[s.category] ||= []).push(s);
  const cats = CATEGORY_KEYS.filter((k) => byCat[k]?.length);

  const add = (seed) => { if (!addedNames.has(seed.name.trim().toLowerCase())) data.addCompany(seed); };
  const addAll = () => list.forEach(add);

  return (
    <div className="page">
      <div className="page-head">
        <div>
          <button className="link" onClick={() => nav('/companies')}>‹ Companies</button>
          <h1>Company catalog</h1><p className="muted">{CATALOG.length} verified employers</p>
        </div>
        <button className="btn btn-line btn-sm" onClick={addAll}>Add all</button>
      </div>

      <div className="toolbar"><input className="search" placeholder="Search 40+ companies" value={query} onChange={(e) => setQuery(e.target.value)} /></div>

      {cats.map((cat) => (
        <div key={cat} className="cat-block">
          <h3 className="cat-title">{CompanyCategory[cat]}</h3>
          <div className="card-grid">
            {byCat[cat].map((s) => {
              const isAdded = addedNames.has(s.name.trim().toLowerCase());
              return (
                <div className="company-card" key={s.name}>
                  <span className="avatar">{initials(s.name)}</span>
                  <div className="row-main">
                    <b>{s.name}</b>
                    <span className={'pill ' + (isFetchable(s.provider) ? 'ok' : 'mute')}>{isFetchable(s.provider) ? 'Live sync' : 'Opens in browser'}</span>
                  </div>
                  {isAdded ? <span className="added">✓</span>
                    : <button className="btn btn-accent btn-sm" onClick={() => add(s)}>Add</button>}
                </div>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
