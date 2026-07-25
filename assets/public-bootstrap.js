(() => {
  'use strict';

  const endpoint = document.documentElement.dataset.bootstrapEndpoint || '/v1/public/bootstrap';
  const state = {
    status: 'idle',
    records: [],
    grouped: Object.freeze({}),
    error: null
  };

  function safeJson(value) {
    if (value && typeof value === 'object') return value;
    if (typeof value !== 'string' || value.trim() === '') return {};
    try {
      return JSON.parse(value);
    } catch {
      return {};
    }
  }

  function normalizeRecord(record) {
    return {
      type: String(record.record_type || '').trim(),
      key: String(record.record_key || '').trim(),
      order: Number.isFinite(Number(record.display_order)) ? Number(record.display_order) : 0,
      payload: safeJson(record.payload_json)
    };
  }

  function groupRecords(records) {
    return records.reduce((groups, record) => {
      if (!record.type) return groups;
      if (!groups[record.type]) groups[record.type] = [];
      groups[record.type].push(record);
      groups[record.type].sort((a, b) => a.order - b.order || a.key.localeCompare(b.key));
      return groups;
    }, {});
  }

  function setText(selector, value) {
    if (typeof value !== 'string' || value.trim() === '') return;
    const node = document.querySelector(selector);
    if (node) node.textContent = value.trim();
  }

  function applySettings(grouped) {
    const settings = Object.fromEntries((grouped.setting || []).map(item => [item.key, item.payload]));
    const identity = settings.product_identity || settings.identity || {};
    const medical = settings.medical_boundary || {};

    setText('.entrance-brand, .hospital-brand b', identity.product_name);
    setText('.entrance-tagline', identity.tagline);
    setText('.reception-boundary', medical.copy || medical.text || medical.value);

    if (identity.page_title) document.title = identity.page_title;
  }

  function applyContent(grouped) {
    const content = Object.fromEntries((grouped.content || []).map(item => [item.key, item.payload]));
    const reception = content.reception_intro || {};
    setText('[data-room-panel="reception"] h2', reception.heading);
    setText('[data-room-panel="reception"] .reception-intro > p:last-child', reception.body);
  }

  function publish(status, detail = {}) {
    state.status = status;
    Object.assign(state, detail);
    window.ILB_PUBLIC_BOOTSTRAP = state;
    document.dispatchEvent(new CustomEvent('ilb:public-bootstrap', {
      detail: { status, ...detail }
    }));
  }

  async function load() {
    publish('loading');

    try {
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: { Accept: 'application/json' },
        credentials: 'same-origin'
      });

      if (!response.ok) throw new Error(`Bootstrap request failed with HTTP ${response.status}`);

      const body = await response.json();
      const rawRecords = Array.isArray(body) ? body : Array.isArray(body.records) ? body.records : [];
      const records = rawRecords.map(normalizeRecord).filter(record => record.type && record.key);
      const grouped = groupRecords(records);

      applySettings(grouped);
      applyContent(grouped);
      publish('ready', { records, grouped, error: null });
    } catch (error) {
      console.warn('[ILB] Public bootstrap unavailable; using static hospital shell.', error);
      publish('fallback', { records: [], grouped: Object.freeze({}), error });
    }
  }

  load();
})();
