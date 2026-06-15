import { useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { InterviewType } from '../lib/enums';
import { fmtDate } from '../lib/format';

export default function Interviews() {
  const data = useData();
  const { interviews, applications: apps } = data;
  const [adding, setAdding] = useState(false);

  const sorted = [...interviews].sort((a, b) => (a.scheduledAt || '').localeCompare(b.scheduledAt || ''));
  const appName = (id) => {
    const a = apps.find((x) => x.id === id);
    return a ? `${a.company} · ${a.role}` : 'Interview';
  };

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Interviews</h1><p className="muted">{interviews.length} scheduled</p></div>
        <button className="btn btn-accent" disabled={!apps.length} onClick={() => setAdding(true)}>+ Schedule</button>
      </div>

      {!apps.length ? (
        <div className="empty"><p>Add an application first, then schedule interviews against it.</p></div>
      ) : sorted.length === 0 ? (
        <div className="empty"><p>No interviews scheduled.</p><button className="btn btn-accent" onClick={() => setAdding(true)}>Schedule one</button></div>
      ) : (
        <div className="list">
          {sorted.map((iv) => (
            <div className="row-card" key={iv.id}>
              <span className="avatar" style={{ background: '#8b5cf622', color: '#a78bfa' }}>◆</span>
              <div className="row-main">
                <b>{InterviewType[iv.type] || iv.type}</b>
                <span className="muted">{appName(iv.applicationId)}</span>
              </div>
              <span className="muted small">{fmtDate(iv.scheduledAt)}</span>
              <button className="icon-btn" onClick={() => confirm('Delete interview?') && data.deleteInterview(iv.id)}>✕</button>
            </div>
          ))}
        </div>
      )}

      {adding && <AddInterview data={data} apps={apps} onClose={() => setAdding(false)} />}
    </div>
  );
}

function AddInterview({ data, apps, onClose }) {
  const [f, setF] = useState({ applicationId: apps[0]?.id || '', type: 'phone', scheduledAt: '', platform: '', interviewerName: '', notes: '' });
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const save = async () => {
    if (!f.applicationId || !f.scheduledAt) return;
    await data.addInterview({ ...f, scheduledAt: new Date(f.scheduledAt).toISOString() });
    onClose();
  };
  return (
    <Modal title="Schedule interview" onClose={onClose}>
      <div className="form-grid">
        <label className="field full"><span>Application</span>
          <select value={f.applicationId} onChange={set('applicationId')}>
            {apps.map((a) => <option key={a.id} value={a.id}>{a.company} · {a.role}</option>)}
          </select>
        </label>
        <label className="field"><span>Type</span>
          <select value={f.type} onChange={set('type')}>
            {Object.entries(InterviewType).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
          </select>
        </label>
        <label className="field"><span>When</span><input type="datetime-local" value={f.scheduledAt} onChange={set('scheduledAt')} /></label>
        <label className="field"><span>Platform</span><input value={f.platform} onChange={set('platform')} placeholder="Zoom, Meet…" /></label>
        <label className="field"><span>Interviewer</span><input value={f.interviewerName} onChange={set('interviewerName')} /></label>
        <label className="field full"><span>Notes</span><textarea rows="2" value={f.notes} onChange={set('notes')} /></label>
      </div>
      <div className="modal-actions">
        <div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" onClick={save}>Schedule</button>
      </div>
    </Modal>
  );
}
