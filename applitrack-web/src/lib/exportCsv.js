import { ApplicationStatus, WorkType, JobSource } from './enums';

// Escape a value for CSV (RFC 4180): wrap in quotes and double any quotes when
// the value contains a comma, quote or newline.
function cell(v) {
  if (v === null || v === undefined) return '';
  const s = String(v);
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

const COLUMNS = [
  ['Company', (a) => a.company],
  ['Role', (a) => a.role],
  ['Status', (a) => ApplicationStatus[a.status]?.label || a.status],
  ['Source', (a) => JobSource[a.source] || a.source],
  ['Work type', (a) => WorkType[a.workType] || a.workType],
  ['Location', (a) => a.location],
  ['Salary min', (a) => a.salaryMin],
  ['Salary max', (a) => a.salaryMax],
  ['Currency', (a) => a.salaryCurrency],
  ['Priority', (a) => a.priority],
  ['Resume', (a, ctx) => ctx.resumeName(a.resumeVersionId)],
  ['Cover letter', (a) => (a.coverLetterUsed ? 'Yes' : 'No')],
  ['Job URL', (a) => a.jobUrl],
  ['Applied date', (a) => (a.appliedDate ? a.appliedDate.slice(0, 10) : '')],
  ['Created', (a) => (a.createdAt ? a.createdAt.slice(0, 10) : '')],
  ['Updated', (a) => (a.updatedAt ? a.updatedAt.slice(0, 10) : '')],
  ['Notes', (a) => a.notes],
];

export function applicationsToCsv(apps, documents = []) {
  const byId = new Map(documents.map((d) => [d.id, d]));
  const ctx = {
    resumeName: (id) => {
      if (!id) return '';
      const d = byId.get(id);
      if (!d) return '';
      return d.version ? `${d.name} v${d.version}` : d.name;
    },
  };
  const header = COLUMNS.map(([h]) => cell(h)).join(',');
  const rows = apps.map((a) => COLUMNS.map(([, fn]) => cell(fn(a, ctx))).join(','));
  return [header, ...rows].join('\r\n');
}

// Trigger a client-side download of a CSV string.
export function downloadCsv(filename, csv) {
  const blob = new Blob(['﻿', csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
