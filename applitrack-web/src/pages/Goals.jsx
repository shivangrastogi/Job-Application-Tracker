import { useState } from 'react';
import { useData } from '../data/store.jsx';
import Modal from '../components/Modal.jsx';
import { GoalMetric, GoalPeriod } from '../lib/enums';
import { goalProgress } from '../lib/goals';

export default function Goals() {
  const data = useData();
  const { goals, applications: apps, interviews } = data;
  const [editing, setEditing] = useState(null);

  return (
    <div className="page">
      <div className="page-head">
        <div><h1>Goals</h1><p className="muted">Stay on the grind.</p></div>
        <button className="btn btn-accent" onClick={() => setEditing({})}>+ New goal</button>
      </div>

      {goals.length === 0 ? (
        <div className="empty"><p>Set a target like “100 applications a day” and track your progress.</p>
          <button className="btn btn-accent" onClick={() => setEditing({})}>Create your first goal</button></div>
      ) : (
        <div className="goal-list">
          {goals.map((g) => {
            const p = goalProgress(g, apps, interviews);
            const color = p.achieved ? '#22c55e' : 'var(--lime)';
            return (
              <div className={'goal-card' + (g.active ? '' : ' off')} key={g.id}>
                <div className="goal-card-head">
                  <div>
                    <b>{g.target} {GoalMetric[g.metric]?.short} {GoalPeriod[g.period]?.unit}</b>
                    <span className="muted small">{GoalPeriod[g.period]?.label} · {GoalMetric[g.metric]?.label}</span>
                  </div>
                  <div className="head-actions">
                    <button className="icon-btn" onClick={() => setEditing(g)}>✎</button>
                    <button className="icon-btn" onClick={() => data.updateGoal({ ...g, active: !g.active })}>{g.active ? '⏸' : '▶'}</button>
                    <button className="icon-btn" onClick={() => confirm('Delete goal?') && data.deleteGoal(g.id)}>✕</button>
                  </div>
                </div>
                <div className="goal-progress">
                  <span className="goal-big" style={{ color }}>{p.current}</span>
                  <span className="muted">/ {g.target}</span>
                  <span className="spacer" />
                  <span className="muted small">{p.achieved ? 'Done 🎉' : `${p.remaining} to go`}</span>
                </div>
                <div className="bar lg"><i style={{ width: `${p.fraction * 100}%`, background: color }} /></div>
              </div>
            );
          })}
        </div>
      )}

      {editing && <GoalModal data={data} goal={editing.id ? editing : null} onClose={() => setEditing(null)} />}
    </div>
  );
}

function GoalModal({ data, goal, onClose }) {
  const [metric, setMetric] = useState(goal?.metric || 'applicationsApplied');
  const [period, setPeriod] = useState(goal?.period || 'daily');
  const [target, setTarget] = useState(goal?.target || '');
  const save = () => {
    const t = parseInt(target, 10);
    if (!t || t <= 0) return;
    if (goal) data.updateGoal({ ...goal, metric, period, target: t });
    else data.addGoal({ metric, period, target: t });
    onClose();
  };
  return (
    <Modal title={goal ? 'Edit goal' : 'New goal'} onClose={onClose}>
      <label className="field full"><span>I want to track</span>
        <select value={metric} onChange={(e) => setMetric(e.target.value)}>
          {Object.entries(GoalMetric).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
        </select>
      </label>
      <label className="field full"><span>Per</span>
        <select value={period} onChange={(e) => setPeriod(e.target.value)}>
          {Object.entries(GoalPeriod).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
        </select>
      </label>
      <label className="field full"><span>Target</span>
        <input type="number" min="1" value={target} onChange={(e) => setTarget(e.target.value)} placeholder="e.g. 100" />
      </label>
      <div className="modal-actions"><div className="spacer" />
        <button className="btn btn-line" onClick={onClose}>Cancel</button>
        <button className="btn btn-accent" onClick={save}>{goal ? 'Save' : 'Create goal'}</button>
      </div>
    </Modal>
  );
}
