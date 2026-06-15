import { useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { ReferralSourceType, ReferralStatus } from '../lib/enums';

export default function Referrals() {
  const data = useData();
  const [tab, setTab] = useState('requests');
  const [modal, setModal] = useState(null); // {type:'req'|'src'|'profile', item}

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Referrals</h1><p className="muted">Forms, groups & requests</p></div>
        <div className="head-actions">
          <button className="btn btn-line btn-sm" onClick={() => setModal({ type: 'profile' })}>My details</button>
          <button className="btn btn-accent" onClick={() => setModal({ type: tab === 'requests' ? 'req' : 'src' })}>
            + {tab === 'requests' ? 'New request' : 'New group'}
          </button>
        </div>
      </div>

      <div className="tabs">
        <button className={'tab' + (tab === 'requests' ? ' active' : '')} onClick={() => setTab('requests')}>Requests</button>
        <button className={'tab' + (tab === 'sources' ? ' active' : '')} onClick={() => setTab('sources')}>Groups & Forms</button>
      </div>

      {tab === 'requests' ? <RequestsTab data={data} onEdit={(r) => setModal({ type: 'req', item: r })} />
        : <SourcesTab data={data} onEdit={(s) => setModal({ type: 'src', item: s })} />}

      {modal?.type === 'req' && <RequestModal data={data} item={modal.item} onClose={() => setModal(null)} />}
      {modal?.type === 'src' && <SourceModal data={data} item={modal.item} onClose={() => setModal(null)} />}
      {modal?.type === 'profile' && <ProfileModal onClose={() => setModal(null)} />}
    </div>
  );
}

function RequestsTab({ data, onEdit }) {
  const { referrals, referral_sources: sources } = data;
  if (!referrals.length) return <div className="empty"><p>Log a referral you asked for via a form or group, track its status, and convert it to an application.</p></div>;
  const srcName = (id) => sources.find((s) => s.id === id)?.name;
  const srcOf = (id) => sources.find((s) => s.id === id);
  return (
    <div className="list">
      {referrals.map((r) => {
        const src = srcOf(r.sourceId);
        return (
          <div className="row-card" key={r.id}>
            <div className="row-main">
              <b>{r.role ? `${r.company} · ${r.role}` : r.company}</b>
              {src && <span className="muted">via {src.name}</span>}
            </div>
            <select className="status-select" value={r.status}
              onChange={(e) => data.updateReferral(r, { status: e.target.value })}
              style={{ color: ReferralStatus[r.status].color }}>
              {Object.entries(ReferralStatus).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
            </select>
            {src?.url && <button className="icon-btn" title="Open" onClick={() => window.open(buildUrl(src), '_blank', 'noopener')}>↗</button>}
            {!r.linkedApplicationId && <button className="icon-btn" title="Convert to application"
              onClick={async () => { const a = await data.addApplication({ company: r.company, role: r.role || 'Role via referral', jobUrl: r.jobUrl, source: 'referral', sourceName: srcName(r.sourceId) }); data.updateReferral(r, { linkedApplicationId: a.id, status: 'applied' }); }}>➜</button>}
            <button className="icon-btn" onClick={() => onEdit(r)}>✎</button>
            <button className="icon-btn" onClick={() => confirm('Delete?') && data.deleteReferral(r.id)}>✕</button>
          </div>
        );
      })}
    </div>
  );
}

function SourcesTab({ data, onEdit }) {
  const { referral_sources: sources } = data;
  if (!sources.length) return <div className="empty"><p>Save the Google Forms, WhatsApp/Telegram groups and contacts you get referrals through, for one-tap access.</p></div>;
  return (
    <div className="list">
      {sources.map((s) => (
        <div className="row-card" key={s.id}>
          <span className="avatar" style={{ background: '#14b8a622', color: '#2dd4bf' }}>{(s.name || '?')[0].toUpperCase()}</span>
          <div className="row-main"><b>{s.name}</b><span className="muted">{ReferralSourceType[s.type]?.label}{s.formTemplate ? ' · prefill on' : ''}</span></div>
          {(s.url || s.formTemplate) && <button className="icon-btn" onClick={() => window.open(buildUrl(s), '_blank', 'noopener')}>↗</button>}
          <button className="icon-btn" onClick={() => onEdit(s)}>✎</button>
          <button className="icon-btn" onClick={() => confirm('Delete?') && data.deleteSource(s.id)}>✕</button>
        </div>
      ))}
    </div>
  );
}

// substitute prefill tokens using saved profile
function buildUrl(src, referral) {
  if (!src.formTemplate) return src.url;
  let p = {};
  try { p = JSON.parse(localStorage.getItem('referralProfile') || '{}'); } catch { /* ignore */ }
  const tok = { name: p.name || '', email: p.email || '', phone: p.phone || '', linkedin: p.linkedin || '', resume: p.resume || '', company: referral?.company || '', role: referral?.role || '' };
  let url = src.formTemplate;
  for (const [k, v] of Object.entries(tok)) url = url.replaceAll(`{${k}}`, encodeURIComponent(v));
  return url;
}

function RequestModal({ data, item, onClose }) {
  const sources = data.referral_sources;
  const [f, setF] = useState(() => ({ company: item?.company || '', role: item?.role || '', sourceId: item?.sourceId || '', referrerName: item?.referrerName || '', jobUrl: item?.jobUrl || '', status: item?.status || 'requested' }));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const save = () => {
    if (!f.company.trim()) return;
    const payload = { company: f.company.trim(), role: f.role.trim() || null, sourceId: f.sourceId || null, referrerName: f.referrerName.trim() || null, jobUrl: f.jobUrl.trim() || null, status: f.status };
    if (item) data.updateReferral(item, payload); else data.addReferral(payload);
    onClose();
  };
  return (
    <Modal title={item ? 'Edit request' : 'New referral request'} onClose={onClose}>
      <label className="field full"><span>Company *</span><input value={f.company} onChange={set('company')} /></label>
      <label className="field full"><span>Role</span><input value={f.role} onChange={set('role')} /></label>
      <label className="field full"><span>Via group / form</span>
        <select value={f.sourceId} onChange={set('sourceId')}><option value="">None</option>{sources.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}</select>
      </label>
      <label className="field full"><span>Referrer name</span><input value={f.referrerName} onChange={set('referrerName')} /></label>
      <label className="field full"><span>Job URL</span><input value={f.jobUrl} onChange={set('jobUrl')} placeholder="https://" /></label>
      <label className="field full"><span>Status</span>
        <select value={f.status} onChange={set('status')}>{Object.entries(ReferralStatus).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}</select>
      </label>
      <div className="modal-actions"><div className="spacer" /><button className="btn btn-line" onClick={onClose}>Cancel</button><button className="btn btn-accent" onClick={save}>Save</button></div>
    </Modal>
  );
}

function SourceModal({ data, item, onClose }) {
  const [f, setF] = useState(() => ({ name: item?.name || '', type: item?.type || 'group', url: item?.url || '', formTemplate: item?.formTemplate || '', notes: item?.notes || '' }));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const isForm = ReferralSourceType[f.type]?.isForm;
  const save = () => {
    if (!f.name.trim()) return;
    const payload = { name: f.name.trim(), type: f.type, url: f.url.trim() || null, formTemplate: isForm && f.formTemplate.trim() ? f.formTemplate.trim() : null, notes: f.notes.trim() || null };
    if (item) data.updateSource({ ...item, ...payload }); else data.addSource(payload);
    onClose();
  };
  return (
    <Modal title={item ? 'Edit source' : 'New group / form'} onClose={onClose}>
      <label className="field full"><span>Name *</span><input value={f.name} onChange={set('name')} placeholder="Tech Referrals (Telegram)" /></label>
      <label className="field full"><span>Type</span>
        <select value={f.type} onChange={set('type')}>{Object.entries(ReferralSourceType).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}</select>
      </label>
      <label className="field full"><span>{isForm ? 'Form URL' : 'Group / profile link'}</span><input value={f.url} onChange={set('url')} placeholder="https://" /></label>
      {isForm && <label className="field full"><span>Prefilled link template</span>
        <textarea rows="2" value={f.formTemplate} onChange={set('formTemplate')} placeholder="Google Forms pre-filled link with {name} {email} {phone} {linkedin} {resume} {company} {role}" /></label>}
      <label className="field full"><span>Notes</span><input value={f.notes} onChange={set('notes')} /></label>
      <div className="modal-actions"><div className="spacer" /><button className="btn btn-line" onClick={onClose}>Cancel</button><button className="btn btn-accent" onClick={save}>Save</button></div>
    </Modal>
  );
}

function ProfileModal({ onClose }) {
  const [p, setP] = useState(() => { try { return JSON.parse(localStorage.getItem('referralProfile') || '{}'); } catch { return {}; } });
  const set = (k) => (e) => setP((s) => ({ ...s, [k]: e.target.value }));
  const save = () => { localStorage.setItem('referralProfile', JSON.stringify(p)); onClose(); };
  return (
    <Modal title="My referral details" onClose={onClose}>
      <p className="hint" style={{ marginBottom: 12 }}>Used to auto-fill Google Form links via {'{name}'}, {'{email}'}… tokens.</p>
      {[['name', 'Full name'], ['email', 'Email'], ['phone', 'Phone'], ['linkedin', 'LinkedIn URL'], ['resume', 'Resume link']].map(([k, label]) => (
        <label className="field full" key={k}><span>{label}</span><input value={p[k] || ''} onChange={set(k)} /></label>
      ))}
      <div className="modal-actions"><div className="spacer" /><button className="btn btn-accent" onClick={save}>Save</button></div>
    </Modal>
  );
}
