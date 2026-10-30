#!/usr/bin/env node
// Lê os iCals de exportação do Airbnb e do Booking (só leitura) e devolve os períodos ocupados em JSON.
// Os links vêm do ambiente (MARELAGO_ICAL_AIRBNB, MARELAGO_ICAL_BOOKING) e nunca são impressos.
const canais = { airbnb: process.env.MARELAGO_ICAL_AIRBNB, booking: process.env.MARELAGO_ICAL_BOOKING };

function desdobrar(texto) {            // RFC 5545: linha que começa com espaço continua a anterior
  return texto.replace(/\r?\n[ \t]/g, '');
}
function data(valor) {                 // 20261105 ou 20261105T140000Z -> AAAA-MM-DD
  const m = /^(\d{4})(\d{2})(\d{2})/.exec(valor || '');
  return m ? `${m[1]}-${m[2]}-${m[3]}` : null;
}
function eventos(texto) {
  const out = [];
  for (const bloco of desdobrar(texto).split('BEGIN:VEVENT').slice(1)) {
    const corpo = bloco.split('END:VEVENT')[0];
    const campo = (nome) => {
      const m = new RegExp(`^${nome}(;[^:]*)?:(.*)$`, 'm').exec(corpo);
      return m ? m[2].trim() : '';
    };
    const ini = data(campo('DTSTART')), fim = data(campo('DTEND'));
    if (ini && fim) out.push({ inicio: ini, fim, resumo: campo('SUMMARY').slice(0, 60) });
  }
  return out;
}

const hoje = new Date().toISOString().slice(0, 10);
const limite = new Date(Date.now() + 365 * 864e5).toISOString().slice(0, 10);
const resultado = { conferido: new Date().toISOString(), canais: {} };
for (const [canal, url] of Object.entries(canais)) {
  if (!url) { resultado.canais[canal] = { erro: 'link não configurado' }; continue; }
  try {
    const r = await fetch(url, { signal: AbortSignal.timeout(20000) });
    if (!r.ok) { resultado.canais[canal] = { erro: `HTTP ${r.status}` }; continue; }
    const ev = eventos(await r.text()).filter(e => e.fim >= hoje && e.inicio <= limite)
      .sort((a, b) => a.inicio.localeCompare(b.inicio));
    resultado.canais[canal] = { ocupados: ev };
  } catch (e) {
    resultado.canais[canal] = { erro: String(e.name === 'TimeoutError' ? 'tempo esgotado' : e.message).slice(0, 120) };
  }
}
console.log(JSON.stringify(resultado, null, 2));
