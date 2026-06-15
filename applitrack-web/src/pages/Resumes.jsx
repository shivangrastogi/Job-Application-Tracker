import { useMemo, useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { DocumentType } from '../lib/enums';
import { relDate } from '../lib/format';
import { getDefaultResumeId, setDefaultResumeId } from '../lib/resumePref';

const DOC_KEYS = Object.keys(DocumentType);

export default function Resumes() {
  const data = useData();
  const docs = data.documents || [];
  const apps = data.applications || [];
  const [editing, setEditing] = useState(null); // doc object or 'new'
  const [defaultId, setDefault] = useState(() => getDefaultResumeId());

  const sorted = useMemo(
    () => [...docs].sort((a, b) => (b.updatedAt || '').localeCompare(a.updatedAt || '')),
    [docs],
  );

  // How many applications reference each document — so deletes are informed.
  const usage = useMemo(() => {
    const m = {};
    for (const a of apps) if (a.resumeVersionId) m[a.resumeVersionId] = (m[a.resumeVersionId] || 0) + 1;
    return m;
  }, [apps]);

  const makeDefault = (id) => {
    const next = defaultId === id ? null : id;
    setDefaultResumeId(next);
    setDefault(next);
  };

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Resumes</h1><p className="muted">{docs.length} document{docs.length === 1 ? '' : 's'} · syncs with your phone</p></div>
        <div className="head-actions">
          <button className="btn btn-accent" onClick={() => setEditing('new')}>+ Add resume</button>
        </div>
      </div>

      {sorted.length === 0 ? (
        <div className="empty">
          <p>No resumes yet. Add the versions you send out, then pick one on each application to see which performs best in Analytics.</p>
          <button className="btn btn-accent" onClick={() => setEditing('new')}>Add your first resume</button>
        </div>
      ) : (
        <div className="list">
          {sorted.map((d) => (
            <div className="row-card" key={d.id} onClick={() => setEditing(d)}>
              <span className="avatar">{(d.name || '?')[0].toUpperCase()}</span>
              <div className="row-main">
                <b>{d.name}{d.version ? ` · v${d.version}` : ''}</b>
                <span className="muted">
                  {DocumentType[d.type] || d.type}
                  {usage[d.id] ? ` · used on ${usage[d.id]} application${usage[d.id] === 1 ? '' : 's'}` : ' · not used yet'}
                </span>
              </div>
              {defaultId === d.id && <span className="badge" style={{ color: '#10B981', background: '#10B98122' }}>Default</span>}
              <button
                className="btn btn-line btn-sm"
                onClick={(e) => { e.stopPropagation(); makeDefault(d.id); }}
              >
                {defaultId === d.id ? 'Unset default' : 'Set default'}
              </button>
              <span className="muted small">{relDate(d.updatedAt)}</span>
            </div>
          ))}
        </div>
      )}

      {editing && (
        <DocModal
          doc={editing === 'new' ? null : editing}
          usageCount={editing !== 'new' ? (usage[editing.id] || 0) : 0}
          onClose={() => setEditing(null)}
          data={data}
        />
      )}
    </div>
  );
}

function DocModal({ doc, usageCount, onClose, data }) {
  const [f, setF] = useState(() => ({
    name: doc?.name || '', type: doc?.type || 'resume',
    version: doc?.version || '', tags: (doc?.tags || []).join(', '),
    content: doc?.content || '',
  }));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const [busy, setBusy] = useState(false);

  const save = async () => {
    if (!f.name.trim()) return;
    setBusy(true);
    const patch = {
      name: f.name.trim(), type: f.type,
      version: f.version.trim() || null,
      tags: f.tags.split(',').map((t) => t.trim()).filter(Boolean),
      content: f.content.trim() || null,
    };
    if (doc) await data.updateDocument(doc, patch);
    else await data.addDocument(patch);
    onClose();
  };

  const del = async () => {
    const warn = usageCount
      ? `This resume is linked to ${usageCount} application(s). Deleting it won't remove those applications, but they'll show as "No resume". Delete anyway?`
      : 'Delete this resume?';
    if (confirm(warn)) { await data.deleteDocument(doc.id); onClose(); }
  };

  return (
    <Modal title={doc ? 'Edit resume' : 'Add resume'} onClose={onClose} wide>
      <div className="form-grid">
        <Field label="Name *"><input value={f.name} onChange={set('name')} placeholder="e.g. Backend Engineer" /></Field>
        <Field label="Type">
          <select value={f.type} onChange={set('type')}>
            {DOC_KEYS.map((k) => <option key={k} value={k}>{DocumentType[k]}</option>)}
          </select>
        </Field>
        <Field label="Version"><input value={f.version} onChange={set('version')} placeholder="e.g. 2 or 2024-fall" /></Field>
        <Field label="Tags (comma separated)"><input value={f.tags} onChange={set('tags')} placeholder="java, remote" /></Field>
        <Field label="Notes / link" full>
          <textarea rows="3" value={f.content} onChange={set('content')} placeholder="Paste a link to the file or notes about this version" />
        </Field>
      </div>
      <div className="modal-actions">
        {doc && <button className="btn btn-danger btn-sm" onClick={del}>Delete</button>}
        <div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" disabled={busy} onClick={save}>{doc ? 'Save' : 'Add resume'}</button>
      </div>
    </Modal>
  );
}

function Field({ label, children, full }) {
  return <label className={'field' + (full ? ' full' : '')}><span>{label}</span>{children}</label>;
}
