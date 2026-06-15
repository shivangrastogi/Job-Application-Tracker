import { startOfPeriod } from './format';

export function goalProgress(goal, apps, interviews) {
  const start = startOfPeriod(goal.period).getTime();
  const after = (iso) => iso && new Date(iso).getTime() >= start;
  let current = 0;
  if (goal.metric === 'applicationsAdded') {
    current = apps.filter((a) => after(a.createdAt)).length;
  } else if (goal.metric === 'applicationsApplied') {
    current = apps.filter((a) => after(a.appliedDate)).length;
  } else if (goal.metric === 'interviews') {
    current = interviews.filter((i) => after(i.createdAt)).length;
  }
  const target = goal.target || 0;
  const fraction = target <= 0 ? 0 : Math.min(1, current / target);
  return { current, target, fraction, achieved: current >= target, remaining: Math.max(0, target - current) };
}
