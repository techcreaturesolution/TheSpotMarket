function parseDate(raw) {
  if (!raw) return null;
  const d = new Date(raw);
  return isNaN(d.getTime()) ? null : d.toISOString();
}

function parseIpoItem(j) {
  const companyName = (j.name || j.symbol || '').trim();
  const symbol = (j.symbol || '').trim();
  if (!companyName && !symbol) return null;

  const lotSize = parseInt(j.lot_size, 10) || null;
  const priceMin = parseFloat(j.min_price) || parseFloat(j.issue_price) || 0.0;
  const priceMax = parseFloat(j.max_price) || parseFloat(j.issue_price) || 0.0;

  // Indian retail Mainboard limit is ₹15,000 per lot; SME lots require > ₹1,00,000 minimum
  const isSme = Boolean(j.is_sme) || (lotSize && priceMax && (lotSize * priceMax > 50000));
  const exchange = isSme ? 'NSE SME' : 'NSE, BSE';

  const openDate = parseDate(j.bidding_start_date);
  const closeDate = parseDate(j.bidding_end_date);
  const allotmentDate = parseDate(j.allotment_date);
  const listingDate = parseDate(j.listing_date);

  let issueSizeCr = null;
  if (j.issue_size) {
    issueSizeCr = parseFloat(j.issue_size);
  }

  const sub = parseFloat(j.total_subscription_rate);

  let state = 'UNKNOWN';
  if (j.status === 'active') {
    if (!openDate || !closeDate) {
      // An IPO cannot logically be "Open" without definitive opening/closing calendar dates.
      state = 'UPCOMING';
    } else {
      const now = new Date();
      const openD = new Date(openDate);
      const closeD = new Date(closeDate);
      closeD.setHours(23, 59, 59, 999);
      if (now < openD) {
        state = 'UPCOMING';
      } else if (now > closeD) {
        state = 'CLOSED';
      } else {
        state = 'OPEN';
      }
    }
  } else if (j.status === 'upcoming' || j.status === 'pre_apply') {
    state = 'UPCOMING';
  } else if (j.status === 'closed') {
    state = 'CLOSED';
  } else if (j.status === 'listed') {
    state = 'LISTED';
  }

  return {
    id: symbol ? symbol.toLowerCase() : companyName.toLowerCase().replace(/\s+/g, '-'),
    name: companyName,
    symbol: symbol || 'IPO',
    exchange,
    sector: isSme ? 'SME Enterprise' : 'Equity / Mainboard',
    openDate,
    closeDate,
    allotmentDate,
    listingDate,
    priceMin,
    priceMax,
    lotSize,
    issueSizeCr,
    issuePrice: j.issue_price ? parseFloat(j.issue_price) : null,
    registrar: 'Link Intime / KFintech',
    registrarUrl: j.document_url || 'https://linkintime.co.in/Initial_Offer/public-issues.html',
    about: `${companyName} is an ${isSme ? "SME" : "Mainboard"} initial public offer on ${exchange}.`,
    subscriptionQib: !isNaN(sub) ? parseFloat(sub.toFixed(2)) : null,
    subscriptionNii: !isNaN(sub) ? parseFloat(sub.toFixed(2)) : null,
    subscriptionRetail: !isNaN(sub) ? parseFloat(sub.toFixed(2)) : null,
    gmp: parseFloat(j.listing_gains) || null,
    isSme,
    state,
    status: j.status // preserve original status for debugging
  };
}

module.exports = {
  parseDate,
  parseIpoItem
};
