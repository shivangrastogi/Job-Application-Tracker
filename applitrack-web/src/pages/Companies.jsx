import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { AtsProvider, CompanyCategory, CATEGORY_KEYS, isFetchable } from '../lib/enums';
import { detectFromUrl } from '../lib/jobBoard';
import { initials } from '../lib/format';

export default function Companies() {
  const data = useData();
  const companies = data.companies;
  const [query, setQuery] = useState('');
  const [adding, setAdding] = useState(null);
  const nav = useNavigate();

  const filtered = query
    ? companies.filter((c) => c.name.toLowerCase().includes(query.toLowerCase()) || (c.tags || []).some((t) => t.toLowerCase().includes(query.toLowerCase())))
    : companies;
  const byCat = {};
  for (const c of filtered) (byCat[c.category] ||= []).push(c);
  const cats = CATEGORY_KEYS.filter((k) => byCat[k]?.length);

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Companies</h1><p className="muted">{companies.length} tracked · live job sync</p></div>
        <div className="head-actions">
          <Link to="/companies/catalog" className="btn btn-line btn-sm">✨ Catalog</Link>
          <button className="btn btn-accent" onClick={() => setAdding({})}>+ Add MNC</button>
        </div>
      </div>

      {companies.length === 0 ? (
        <div className="empty">
          <p>Add companies and pull their latest openings — or start from the catalog of 40+ top employers.</p>
          <div className="head-actions"><Link to="/companies/catalog" className="btn btn-accent">Browse catalog</Link>
            <button className="btn btn-line" onClick={() => setAdding({})}>Add manually</button></div>
        </div>
      ) : (
        <>
          <div className="toolbar"><input className="search" placeholder="Search companies or tags" value={query} onChange={(e) => setQuery(e.target.value)} /></div>
          {cats.map((cat) => (
            <div key={cat} className="cat-block">
              <h3 className="cat-title">{CompanyCategory[cat]} · {byCat[cat].length}</h3>
              <div className="card-grid">
                {byCat[cat].map((c) => (
                  <div className="company-card" key={c.id} onClick={() => nav(`/companies/${c.id}`)}>
                    <span className="avatar">{initials(c.name)}</span>
                    <div className="row-main">
                      <b>{c.name}</b>
                      <span className={'pill ' + (isFetchable(c.provider) ? 'ok' : 'mute')}>
                        {isFetchable(c.provider) ? AtsProvider[c.provider]?.label : 'Link'}
                        {c.lastJobCount ? ` · ${c.lastJobCount} jobs` : ''}
                      </span>
                    </div>
                    <span className="chev">›</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </>
      )}

      {adding !== null && <CompanyModal data={data} company={adding.id ? adding : null} onClose={() => setAdding(null)} />}
    </div>
  );
}

export function CompanyModal({ data, company, onClose }) {
  const [f, setF] = useState(() => ({
    name: company?.name || '', provider: company?.provider || 'greenhouse',
    slug: company?.slug || '', careerUrl: company?.careerUrl || '',
    category: company?.category || 'other', tags: (company?.tags || []).join(', '),
    cfg: company?.config || {},
  }));
  const [paste, setPaste] = useState('');
  const [msg, setMsg] = useState('');
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const setCfg = (k) => (e) => setF((s) => ({ ...s, cfg: { ...s.cfg, [k]: e.target.value } }));

  const detect = () => {
    const r = detectFromUrl(paste);
    if (!r) { setF((s) => ({ ...s, provider: 'custom', careerUrl: paste })); setMsg("Couldn't recognise it — saved as open-in-browser link."); return; }
    setF((s) => ({ ...s, provider: r.provider, slug: r.slug || s.slug, careerUrl: paste, cfg: { ...s.cfg, ...(r.config || {}) } }));
    setMsg(`Detected ${AtsProvider[r.provider].label} — live sync enabled.`);
  };

  const needsSlug = isFetchable(f.provider) && f.provider !== 'amazon' && f.provider !== 'workday';
  const save = async () => {
    if (!f.name.trim()) return;
    const payload = {
      name: f.name.trim(), provider: f.provider, slug: needsSlug ? f.slug.trim() : null,
      careerUrl: f.careerUrl.trim() || null, category: f.category,
      tags: f.tags.split(',').map((t) => t.trim()).filter(Boolean),
      config: buildCfg(f),
    };
    if (company) await data.updateCompany(company, payload);
    else await data.addCompany(payload);
    onClose();
  };

  return (
    <Modal title={company ? 'Edit company' : 'Add MNC'} onClose={onClose} wide>
      <div className="paste-box">
        <div className="paste-row">
          <input placeholder="Paste careers URL (e.g. boards.greenhouse.io/stripe)" value={paste} onChange={(e) => setPaste(e.target.value)} />
          <button className="btn btn-line btn-sm" onClick={detect}>Detect</button>
        </div>
        {msg && <p className="hint">{msg}</p>}
      </div>
      <div className="form-grid">
        <label className="field"><span>Company name *</span><input value={f.name} onChange={set('name')} /></label>
        <label className="field"><span>Category</span>
          <select value={f.category} onChange={set('category')}>
            {CATEGORY_KEYS.map((k) => <option key={k} value={k}>{CompanyCategory[k]}</option>)}
          </select>
        </label>
        <label className="field full"><span>Careers source</span>
          <select value={f.provider} onChange={set('provider')}>
            {Object.entries(AtsProvider).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
          </select>
        </label>
        {needsSlug && <label className="field full"><span>{AtsProvider[f.provider].label} slug *</span><input value={f.slug} onChange={set('slug')} placeholder={AtsProvider[f.provider].hint} /></label>}
        {f.provider === 'amazon' && <>
          <label className="field"><span>Location</span><input value={f.cfg.loc_query || 'India'} onChange={setCfg('loc_query')} /></label>
          <label className="field"><span>Country code</span><input value={f.cfg.country || 'IND'} onChange={setCfg('country')} /></label>
          <label className="field full"><span>Keyword</span><input value={f.cfg.query || ''} onChange={setCfg('query')} placeholder="software development engineer" /></label>
        </>}
        {f.provider === 'workday' && <>
          <label className="field"><span>Tenant *</span><input value={f.cfg.tenant || ''} onChange={setCfg('tenant')} placeholder="nvidia" /></label>
          <label className="field"><span>DC *</span><input value={f.cfg.dc || ''} onChange={setCfg('dc')} placeholder="wd5" /></label>
          <label className="field full"><span>Site *</span><input value={f.cfg.site || ''} onChange={setCfg('site')} placeholder="NVIDIAExternalCareerSite" /></label>
          <label className="field full"><span>Keyword</span><input value={f.cfg.query || ''} onChange={setCfg('query')} placeholder="engineer" /></label>
        </>}
        <label className="field full"><span>Careers URL{isFetchable(f.provider) ? ' (optional)' : ''}</span><input value={f.careerUrl} onChange={set('careerUrl')} placeholder="https://" /></label>
        <label className="field full"><span>Tags (comma separated)</span><input value={f.tags} onChange={set('tags')} placeholder="India, Remote, Dream" /></label>
      </div>
      <div className="modal-actions">
        <div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" onClick={save}>{company ? 'Save' : 'Add company'}</button>
      </div>
    </Modal>
  );
}

function buildCfg(f) {
  if (f.provider === 'amazon') return { loc_query: f.cfg.loc_query || 'India', country: f.cfg.country || 'IND', ...(f.cfg.query ? { query: f.cfg.query } : {}), ...(f.cfg.category ? { category: f.cfg.category } : {}) };
  if (f.provider === 'workday') return { tenant: f.cfg.tenant || '', dc: f.cfg.dc || '', site: f.cfg.site || '', ...(f.cfg.query ? { query: f.cfg.query } : {}) };
  return {};
}
