import { useMemo, useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { ApplicationStatus, STATUS_KEYS, PIPELINE_STAGES, statusColor, statusLabel, WorkType, JobSource } from '../lib/enums';
import { relDate } from '../lib/format';

export default function Applications() {
  const data = useData();
  const apps = data.applications;
  const [filter, setFilter] = useState('all');
  const [kanban, setKanban] = useState(false);
  const [query, setQuery] = useState('');
  const [editing, setEditing] = useState(null); // app object or 'new'

  const filtered = useMemo(() => {
    let list = apps;
    if (filter !== 'all') list = list.filter((a) => a.status === filter);
    if (query) {
      const q = query.toLowerCase();
      list = list.filter((a) => a.company?.toLowerCase().includes(q) || a.role?.toLowerCase().includes(q));
    }
    return [...list].sort((a, b) => (b.updatedAt || '').localeCompare(a.updatedAt || ''));
  }, [apps, filter, query]);

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Applications</h1><p className="muted">{apps.length} tracked</p></div>
        <div className="head-actions">
          <button className="btn btn-line btn-sm" onClick={() => setKanban((k) => !k)}>{kanban ? 'List view' : 'Board view'}</button>
          <button className="btn btn-accent" onClick={() => setEditing('new')}>+ Add job</button>
        </div>
      </div>

      <div className="toolbar">
        <input className="search" placeholder="Search company or role" value={query} onChange={(e) => setQuery(e.target.value)} />
      </div>

      {!kanban && (
        <div className="chips">
          <Chip active={filter === 'all'} onClick={() => setFilter('all')}>All</Chip>
          {STATUS_KEYS.map((s) => (
            <Chip key={s} active={filter === s} color={statusColor(s)} onClick={() => setFilter(s)}>{statusLabel(s)}</Chip>
          ))}
        </div>
      )}

      {kanban ? (
        <div className="kanban">
          {PIPELINE_STAGES.map((s) => {
            const items = filtered.filter((a) => a.status === s);
            return (
              <div className="kcol" key={s}>
                <div className="kcol-head"><span className="dot" style={{ background: statusColor(s) }} />{statusLabel(s)}<b>{items.length}</b></div>
                {items.map((a) => <KCard key={a.id} app={a} onClick={() => setEditing(a)} />)}
              </div>
            );
          })}
        </div>
      ) : filtered.length === 0 ? (
        <div className="empty"><p>No applications{filter !== 'all' ? ' in this stage' : ' yet'}.</p>
          <button className="btn btn-accent" onClick={() => setEditing('new')}>Add your first job</button></div>
      ) : (
        <div className="list">
          {filtered.map((a) => (
            <div className="row-card" key={a.id} onClick={() => setEditing(a)}>
              <span className="avatar">{(a.company || '?')[0].toUpperCase()}</span>
              <div className="row-main">
                <b>{a.role}</b>
                <span className="muted">{a.company}{a.location ? ` · ${a.location}` : ''}</span>
              </div>
              <span className="badge" style={{ color: statusColor(a.status), background: statusColor(a.status) + '22' }}>{statusLabel(a.status)}</span>
              <span className="muted small">{relDate(a.updatedAt)}</span>
            </div>
          ))}
        </div>
      )}

      {editing && (
        <JobModal
          app={editing === 'new' ? null : editing}
          onClose={() => setEditing(null)}
          data={data}
        />
      )}
    </div>
  );
}

function KCard({ app, onClick }) {
  return (
    <div className="kcard" onClick={onClick}>
      <b>{app.role}</b>
      <span className="muted">{app.company}</span>
    </div>
  );
}

function Chip({ active, color, children, onClick }) {
  return (
    <button className={'chip' + (active ? ' active' : '')} onClick={onClick}
      style={active && color ? { background: color + '22', color, borderColor: color + '55' } : undefined}>
      {children}
    </button>
  );
}

function JobModal({ app, onClose, data }) {
  const [f, setF] = useState(() => ({
    company: app?.company || '', role: app?.role || '', status: app?.status || 'wishlist',
    location: app?.location || '', workType: app?.workType || 'onsite',
    source: app?.source || 'other', jobUrl: app?.jobUrl || '',
    appliedDate: app?.appliedDate ? app.appliedDate.slice(0, 10) : '',
    salaryMin: app?.salaryMin ?? '', salaryMax: app?.salaryMax ?? '',
    priority: app?.priority ?? 3, notes: app?.notes || '',
  }));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const [busy, setBusy] = useState(false);

  const save = async () => {
    if (!f.company.trim() || !f.role.trim()) return;
    setBusy(true);
    const patch = {
      company: f.company.trim(), role: f.role.trim(), status: f.status,
      location: f.location.trim() || null, workType: f.workType, source: f.source,
      jobUrl: f.jobUrl.trim() || null,
      appliedDate: f.appliedDate ? new Date(f.appliedDate).toISOString() : null,
      salaryMin: f.salaryMin === '' ? null : Number(f.salaryMin),
      salaryMax: f.salaryMax === '' ? null : Number(f.salaryMax),
      priority: Number(f.priority), notes: f.notes.trim() || null,
    };
    if (app) await data.updateApplication(app, patch);
    else await data.addApplication(patch);
    onClose();
  };

  const del = async () => { if (confirm('Delete this application?')) { await data.deleteApplication(app.id); onClose(); } };

  return (
    <Modal title={app ? 'Edit application' : 'Add application'} onClose={onClose} wide>
      <div className="form-grid">
        <Field label="Company *"><input value={f.company} onChange={set('company')} /></Field>
        <Field label="Role *"><input value={f.role} onChange={set('role')} /></Field>
        <Field label="Status">
          <select value={f.status} onChange={set('status')}>
            {STATUS_KEYS.map((s) => <option key={s} value={s}>{ApplicationStatus[s].label}</option>)}
          </select>
        </Field>
        <Field label="Applied date"><input type="date" value={f.appliedDate} onChange={set('appliedDate')} /></Field>
        <Field label="Location"><input value={f.location} onChange={set('location')} /></Field>
        <Field label="Work type">
          <select value={f.workType} onChange={set('workType')}>
            {Object.entries(WorkType).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
          </select>
        </Field>
        <Field label="Source">
          <select value={f.source} onChange={set('source')}>
            {Object.entries(JobSource).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
          </select>
        </Field>
        <Field label="Priority (1-5)"><input type="number" min="1" max="5" value={f.priority} onChange={set('priority')} /></Field>
        <Field label="Salary min"><input type="number" value={f.salaryMin} onChange={set('salaryMin')} /></Field>
        <Field label="Salary max"><input type="number" value={f.salaryMax} onChange={set('salaryMax')} /></Field>
        <Field label="Job URL" full><input value={f.jobUrl} onChange={set('jobUrl')} placeholder="https://" /></Field>
        <Field label="Notes" full><textarea rows="3" value={f.notes} onChange={set('notes')} /></Field>
      </div>
      <div className="modal-actions">
        {app && <button className="btn btn-danger btn-sm" onClick={del}>Delete</button>}
        <div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" disabled={busy} onClick={save}>{app ? 'Save' : 'Add job'}</button>
      </div>
    </Modal>
  );
}

function Field({ label, children, full }) {
  return <label className={'field' + (full ? ' full' : '')}><span>{label}</span>{children}</label>;
}
