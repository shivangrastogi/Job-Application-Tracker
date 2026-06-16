import { useMemo, useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { ApplicationStatus, STATUS_KEYS, PIPELINE_STAGES, statusColor, statusLabel, WorkType, JobSource } from '../lib/enums';
import { relDate, appTitle, guessCompanyFromUrl, normalizeUrl, looksLikeUrl } from '../lib/format';
import { isStale, daysSince } from '../lib/staleness';
import { PREP_ITEMS, getPrep, setPrep } from '../lib/prep';

export default function Applications() {
  const data = useData();
  const apps = data.applications;
  const [filter, setFilter] = useState('all');
  const [kanban, setKanban] = useState(false);
  const [query, setQuery] = useState('');
  const [resumeFilter, setResumeFilter] = useState('all');
  const [tagFilter, setTagFilter] = useState('all');
  const [editing, setEditing] = useState(null); // app object or 'new'
  const [bulk, setBulk] = useState(false);

  const resumeDocs = (data.documents || []).filter((d) => (d.type || 'resume') === 'resume');
  const allTags = useMemo(
    () => [...new Set(apps.flatMap((a) => a.tags || []))].sort((a, b) => a.localeCompare(b)),
    [apps],
  );

  const filtered = useMemo(() => {
    let list = apps;
    if (filter !== 'all') list = list.filter((a) => a.status === filter);
    if (resumeFilter !== 'all') {
      list = list.filter((a) => (resumeFilter === 'none' ? !a.resumeVersionId : a.resumeVersionId === resumeFilter));
    }
    if (tagFilter !== 'all') list = list.filter((a) => (a.tags || []).includes(tagFilter));
    if (query) {
      const q = query.toLowerCase();
      list = list.filter((a) => a.company?.toLowerCase().includes(q) || a.role?.toLowerCase().includes(q));
    }
    return [...list].sort((a, b) => (b.updatedAt || '').localeCompare(a.updatedAt || ''));
  }, [apps, filter, query, resumeFilter, tagFilter]);

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Applications</h1><p className="muted">{apps.length} tracked</p></div>
        <div className="head-actions">
          <button className="btn btn-line btn-sm" onClick={() => setKanban((k) => !k)}>{kanban ? 'List view' : 'Board view'}</button>
          <button className="btn btn-line btn-sm" onClick={() => setBulk(true)}>Bulk add</button>
          <button className="btn btn-accent" onClick={() => setEditing('new')}>+ Add job</button>
        </div>
      </div>

      <div className="toolbar">
        <input className="search" placeholder="Search company or role" value={query} onChange={(e) => setQuery(e.target.value)} />
        {resumeDocs.length > 0 && (
          <select className="search toolbar-select" value={resumeFilter} onChange={(e) => setResumeFilter(e.target.value)}>
            <option value="all">All resumes</option>
            <option value="none">No resume</option>
            {resumeDocs.map((d) => (
              <option key={d.id} value={d.id}>{d.name}{d.version ? ` · v${d.version}` : ''}</option>
            ))}
          </select>
        )}
        {allTags.length > 0 && (
          <select className="search toolbar-select" value={tagFilter} onChange={(e) => setTagFilter(e.target.value)}>
            <option value="all">All tags</option>
            {allTags.map((t) => <option key={t} value={t}>{t}</option>)}
          </select>
        )}
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
              <span className="avatar">{(a.company || a.role || '?')[0].toUpperCase()}</span>
              <div className="row-main">
                <b>{appTitle(a)}</b>
                <span className="muted">{a.company || 'Tap to add details'}{a.location ? ` · ${a.location}` : ''}</span>
                {a.tags?.length > 0 && (
                  <span className="tag-row">{a.tags.map((t) => <span className="tag" key={t}>{t}</span>)}</span>
                )}
              </div>
              <span className="badge" style={{ color: statusColor(a.status), background: statusColor(a.status) + '22' }}>{statusLabel(a.status)}</span>
              {isStale(a) && <span className="badge stale-badge" title={`No update in ${daysSince(a.updatedAt)} days — follow up`}>⏰ {daysSince(a.updatedAt)}d</span>}
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

      {bulk && <BulkModal data={data} onClose={() => setBulk(false)} />}
    </div>
  );
}

function BulkModal({ data, onClose }) {
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState(null);

  const run = async () => {
    const lines = text.split('\n').map((s) => s.trim()).filter(Boolean);
    if (!lines.length) return;
    setBusy(true);
    const existing = new Set(
      (data.applications || []).map((a) => (a.jobUrl ? normalizeUrl(a.jobUrl) : '')).filter(Boolean),
    );
    const seen = new Set();
    const defaultResume = data.defaultResumeId || null;
    let added = 0, skipped = 0, invalid = 0;
    for (const line of lines) {
      const norm = normalizeUrl(line);
      if (!norm) { invalid++; continue; }
      if (existing.has(norm) || seen.has(norm)) { skipped++; continue; }
      seen.add(norm);
      // eslint-disable-next-line no-await-in-loop
      await data.addApplication({
        jobUrl: line,
        company: guessCompanyFromUrl(line) || null,
        status: 'wishlist',
        resumeVersionId: defaultResume,
      });
      added++;
    }
    setResult({ added, skipped, invalid });
    setBusy(false);
  };

  return (
    <Modal title="Bulk add jobs" onClose={onClose}>
      {result ? (
        <>
          <p>✅ Added <b>{result.added}</b> job{result.added === 1 ? '' : 's'}
            {result.skipped ? `, skipped ${result.skipped} already tracked` : ''}
            {result.invalid ? `, ${result.invalid} weren't valid links` : ''}.</p>
          <p className="muted small">They're saved as <b>Wishlist</b> — open each to set the status, role and details when ready.</p>
          <div className="modal-actions"><div className="spacer" /><button className="btn btn-accent" onClick={onClose}>Done</button></div>
        </>
      ) : (
        <>
          <p className="muted" style={{ marginBottom: 10 }}>Paste one job link per line. We create an application for each, guess the company, attach your default resume, and skip links you already track.</p>
          <label className="field full"><span>Job links (one per line)</span>
            <textarea rows="8" value={text} onChange={(e) => setText(e.target.value)}
              placeholder={'https://boards.greenhouse.io/stripe/jobs/123\nhttps://jobs.lever.co/cred/abc\nhttps://www.linkedin.com/jobs/view/456'} />
          </label>
          <div className="modal-actions">
            <div className="spacer" />
            <button className="btn btn-line" onClick={onClose}>Cancel</button>
            <button className="btn btn-accent" disabled={busy || !text.trim()} onClick={run}>{busy ? 'Adding…' : 'Add all'}</button>
          </div>
        </>
      )}
    </Modal>
  );
}

function KCard({ app, onClick }) {
  return (
    <div className="kcard" onClick={onClick}>
      <b>{appTitle(app)}</b>
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
  const resumes = (data.documents || []).filter((d) => (d.type || 'resume') === 'resume');
  const [f, setF] = useState(() => ({
    company: app?.company || '', role: app?.role || '', status: app?.status || 'wishlist',
    location: app?.location || '', workType: app?.workType || 'onsite',
    source: app?.source || 'other', jobUrl: app?.jobUrl || '',
    appliedDate: app?.appliedDate ? app.appliedDate.slice(0, 10) : '',
    salaryMin: app?.salaryMin ?? '', salaryMax: app?.salaryMax ?? '',
    priority: app?.priority ?? 3, notes: app?.notes || '',
    resumeVersionId: app ? (app.resumeVersionId || '') : (data.defaultResumeId || ''),
    coverLetterUsed: app?.coverLetterUsed ?? false,
    tags: (app?.tags || []).join(', '),
  }));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const setBool = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.checked }));
  const [busy, setBusy] = useState(false);

  // When adding a new job, flag if its URL is already tracked (don't block).
  const dupe = (!app && f.jobUrl.trim())
    ? (data.applications || []).find((a) => a.jobUrl && normalizeUrl(a.jobUrl) === normalizeUrl(f.jobUrl))
    : null;

  const save = async () => {
    if (!f.jobUrl.trim()) return;
    setBusy(true);
    const patch = {
      company: f.company.trim(), role: f.role.trim(), status: f.status,
      location: f.location.trim() || null, workType: f.workType, source: f.source,
      jobUrl: f.jobUrl.trim() || null,
      appliedDate: f.appliedDate ? new Date(f.appliedDate).toISOString() : null,
      salaryMin: f.salaryMin === '' ? null : Number(f.salaryMin),
      salaryMax: f.salaryMax === '' ? null : Number(f.salaryMax),
      priority: Number(f.priority), notes: f.notes.trim() || null,
      resumeVersionId: f.resumeVersionId || null,
      coverLetterUsed: f.coverLetterUsed,
      tags: f.tags.split(',').map((t) => t.trim()).filter(Boolean),
    };
    if (app) await data.updateApplication(app, patch);
    else await data.addApplication(patch);
    onClose();
  };

  const del = async () => { if (confirm('Delete this application?')) { await data.deleteApplication(app.id); onClose(); } };

  return (
    <Modal title={app ? 'Edit application' : 'Add application'} onClose={onClose} wide>
      <div className="form-grid">
        {dupe && (
          <div className="field full dupe-warn">
            ⚠️ You already tracked <b>{appTitle(dupe)}</b>{dupe.company ? ` at ${dupe.company}` : ''} ({statusLabel(dupe.status)}). You can still add it again.
          </div>
        )}
        <Field label="Job URL *" full>
          <input
            value={f.jobUrl}
            onChange={set('jobUrl')}
            onBlur={() => setF((s) => {
              if (s.company.trim()) return s;
              const guess = guessCompanyFromUrl(s.jobUrl);
              return guess ? { ...s, company: guess } : s;
            })}
            placeholder="https://… (paste the link, fill the rest later)"
            autoFocus
          />
          {f.jobUrl.trim() && !looksLikeUrl(f.jobUrl) && (
            <span className="field-hint">⚠ That doesn't look like a web link — you can still save it.</span>
          )}
        </Field>
        <Field label="Company"><input value={f.company} onChange={set('company')} /></Field>
        <Field label="Role"><input value={f.role} onChange={set('role')} /></Field>
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
        <Field label="Resume used">
          <select value={f.resumeVersionId} onChange={set('resumeVersionId')}>
            <option value="">No resume</option>
            {resumes.map((d) => (
              <option key={d.id} value={d.id}>{d.name}{d.version ? ` · v${d.version}` : ''}</option>
            ))}
          </select>
        </Field>
        <label className="field field-check">
          <input type="checkbox" checked={f.coverLetterUsed} onChange={setBool('coverLetterUsed')} />
          <span>Cover letter sent</span>
        </label>
        <Field label="Priority (1-5)"><input type="number" min="1" max="5" value={f.priority} onChange={set('priority')} /></Field>
        <Field label="Salary min"><input type="number" value={f.salaryMin} onChange={set('salaryMin')} /></Field>
        <Field label="Salary max"><input type="number" value={f.salaryMax} onChange={set('salaryMax')} /></Field>
        <Field label="Tags (comma separated)" full><input value={f.tags} onChange={set('tags')} placeholder="remote, dream company, urgent" /></Field>
        <Field label="Notes" full><textarea rows="3" value={f.notes} onChange={set('notes')} /></Field>
      </div>
      {app && <PrepChecklist appId={app.id} />}
      <div className="modal-actions">
        {app && <button className="btn btn-danger btn-sm" onClick={del}>Delete</button>}
        <div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" disabled={busy || !f.jobUrl.trim()} onClick={save}>{app ? 'Save' : 'Add job'}</button>
      </div>
    </Modal>
  );
}

function Field({ label, children, full }) {
  return <label className={'field' + (full ? ' full' : '')}><span>{label}</span>{children}</label>;
}

function PrepChecklist({ appId }) {
  const [done, setDone] = useState(() => getPrep(appId));
  const toggle = (item) => {
    const next = done.includes(item) ? done.filter((x) => x !== item) : [...done, item];
    setDone(next);
    setPrep(appId, next);
  };
  return (
    <div className="prep">
      <div className="prep-head">
        <b>Interview prep</b>
        <span className="muted small">{done.length}/{PREP_ITEMS.length} done</span>
      </div>
      {PREP_ITEMS.map((item) => (
        <label className="prep-item" key={item}>
          <input type="checkbox" checked={done.includes(item)} onChange={() => toggle(item)} />
          <span className={done.includes(item) ? 'prep-done' : ''}>{item}</span>
        </label>
      ))}
    </div>
  );
}
