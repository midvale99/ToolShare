/* Neighbour Tool Share Board (PWA, local-only).
   Works on iPhone Safari (HTTPS required for geolocation). */

const STORAGE_KEY = "nts_v1";

function nowISO() {
  return new Date().toISOString();
}

function uid(prefix = "id") {
  return `${prefix}_${Math.random().toString(16).slice(2)}_${Date.now().toString(16)}`;
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function defaultState() {
  return {
    profile: {
      id: uid("user"),
      name: "Neighbour",
      street: ""
    },
    listings: [],
    requests: [],
    messages: [] // { id, requestId, senderId, text, createdAt }
  };
}

let state = loadState() || defaultState();
saveState(state);

// --- Geo ---
function toRad(x) {
  return (x * Math.PI) / 180;
}

function distanceMeters(a, b) {
  // Haversine
  const R = 6371000;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const s =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.sin(dLng / 2) * Math.sin(dLng / 2) * Math.cos(lat1) * Math.cos(lat2);
  const c = 2 * Math.atan2(Math.sqrt(s), Math.sqrt(1 - s));
  return R * c;
}

// --- DOM helpers ---
const $ = (id) => document.getElementById(id);
const statusText = $("statusText");

const tabBoard = $("tabBoard");
const tabMessages = $("tabMessages");
const tabProfile = $("tabProfile");

const viewBoard = $("viewBoard");
const viewMessages = $("viewMessages");
const viewProfile = $("viewProfile");

const listingList = $("listingList");
const listingEmpty = $("listingEmpty");
const requestList = $("requestList");
const requestEmpty = $("requestEmpty");

const installHint = $("installHint");

const newListingBtn = $("newListingBtn");
const refreshBtn = $("refreshBtn");
const searchInput = $("searchInput");
const searchBtn = $("searchBtn");

const modalNewListing = $("modalNewListing");
const newListingForm = $("newListingForm");
const cancelNewListingBtn = $("cancelNewListingBtn");

const listingTitle = $("listingTitle");
const listingCategory = $("listingCategory");
const listingDescription = $("listingDescription");
const listingPhoto = $("listingPhoto");

const modalListingDetail = $("modalListingDetail");
const detailTitle = $("detailTitle");
const detailCategory = $("detailCategory");
const detailDistance = $("detailDistance");
const detailDescription = $("detailDescription");
const detailPhotoWrap = $("detailPhotoWrap");
const detailPhoto = $("detailPhoto");
const requestNote = $("requestNote");
const sendRequestBtn = $("sendRequestBtn");
const closeDetailBtn = $("closeDetailBtn");

const modalChat = $("modalChat");
const chatTitle = $("chatTitle");
const chatMessages = $("chatMessages");
const chatInput = $("chatInput");
const chatSendBtn = $("chatSendBtn");

const profileName = $("profileName");
const profileStreet = $("profileStreet");
const saveProfileBtn = $("saveProfileBtn");

let currentPosition = null; // { lat, lng, accuracy, updatedAt }
let currentDetailListingId = null;
let currentChatRequestId = null;
let searchQuery = "";

function isStandalone() {
  return window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true;
}

function showInstallHintIfNeeded() {
  // iOS Safari doesn’t provide a great install prompt event; show a friendly hint.
  const isiPhone = /iPhone|iPad|iPod/i.test(navigator.userAgent);
  installHint.hidden = !(isiPhone && !isStandalone());
}

// --- UI: Tabs ---
function setTab(name) {
  const onBoard = name === "board";
  const onMessages = name === "messages";
  const onProfile = name === "profile";

  tabBoard.classList.toggle("tab--active", onBoard);
  tabMessages.classList.toggle("tab--active", onMessages);
  tabProfile.classList.toggle("tab--active", onProfile);

  viewBoard.hidden = !onBoard;
  viewMessages.hidden = !onMessages;
  viewProfile.hidden = !onProfile;
}

tabBoard.addEventListener("click", () => setTab("board"));
tabMessages.addEventListener("click", () => { setTab("messages"); renderRequests(); });
tabProfile.addEventListener("click", () => setTab("profile"));

// --- Location ---
function updateStatus(text) {
  statusText.textContent = text;
}

async function requestLocation() {
  if (!("geolocation" in navigator)) {
    updateStatus("This browser doesn’t support GPS.");
    return;
  }

  updateStatus("Requesting location permission…");

  navigator.geolocation.getCurrentPosition(
    (pos) => {
      currentPosition = {
        lat: pos.coords.latitude,
        lng: pos.coords.longitude,
        accuracy: pos.coords.accuracy,
        updatedAt: Date.now()
      };
      updateStatus(`Location ready (±${Math.round(currentPosition.accuracy)}m)`);
      renderListings();
    },
    (err) => {
      if (err.code === err.PERMISSION_DENIED) {
        updateStatus("Location blocked. Enable it in Safari settings.");
      } else {
        updateStatus("Couldn’t get location. Try Refresh.");
      }
    },
    { enableHighAccuracy: true, timeout: 12000, maximumAge: 15000 }
  );
}

refreshBtn.addEventListener("click", () => requestLocation());

// --- Listings ---
function within200m(listing) {
  if (!currentPosition) return true; // if no location yet, show all (friendly fallback)
  const d = distanceMeters(
    { lat: currentPosition.lat, lng: currentPosition.lng },
    { lat: listing.lat, lng: listing.lng }
  );
  return d <= 200;
}

function listingDistanceText(listing) {
  if (!currentPosition) return "distance unknown";
  const d = distanceMeters(
    { lat: currentPosition.lat, lng: currentPosition.lng },
    { lat: listing.lat, lng: listing.lng }
  );
  return d < 1000 ? `${Math.round(d)}m away` : `${(d / 1000).toFixed(1)}km away`;
}

function matchesSearch(listing, q) {
  if (!q || !q.trim()) return true;
  const lower = q.trim().toLowerCase();
  const title = (listing.title || "").toLowerCase();
  const category = (listing.category || "").toLowerCase();
  const desc = (listing.description || "").toLowerCase();
  return title.includes(lower) || category.includes(lower) || desc.includes(lower);
}

function renderListings() {
  const nearby = state.listings
    .filter((l) => l.status === "available")
    .filter(within200m)
    .filter((l) => matchesSearch(l, searchQuery))
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

  listingList.innerHTML = "";
  listingEmpty.hidden = nearby.length !== 0;
  listingEmpty.textContent = searchQuery.trim()
    ? "No matching tools found."
    : "No tools nearby yet. Post the first one.";

  nearby.forEach((l) => {
    const item = document.createElement("div");
    item.className = "item";
    item.innerHTML = `
      <div class="row row--space">
        <div>
          <div class="item__title">${escapeHtml(l.title)}</div>
          <div class="item__desc">${escapeHtml(l.description || "")}</div>
          <div class="item__meta">
            <span class="pill">${escapeHtml(l.category)}</span>
            <span class="pill pill--muted">${escapeHtml(listingDistanceText(l))}</span>
          </div>
        </div>
        <button class="btn btn--primary" type="button">View</button>
      </div>
    `;
    item.querySelector("button").addEventListener("click", () => openListingDetail(l.id));
    listingList.appendChild(item);
  });
}

searchBtn.addEventListener("click", () => {
  searchQuery = searchInput.value || "";
  renderListings();
});
searchInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter") {
    e.preventDefault();
    searchQuery = searchInput.value || "";
    renderListings();
  }
});

function openListingDetail(listingId) {
  const l = state.listings.find((x) => x.id === listingId);
  if (!l) return;
  currentDetailListingId = listingId;

  detailTitle.textContent = l.title;
  detailCategory.textContent = l.category;
  detailDistance.textContent = listingDistanceText(l);
  detailDescription.textContent = l.description || "";
  requestNote.value = "";

  if (l.photoDataUrl) {
    detailPhoto.src = l.photoDataUrl;
    detailPhotoWrap.hidden = false;
  } else {
    detailPhotoWrap.hidden = true;
  }

  modalListingDetail.showModal();
}

closeDetailBtn.addEventListener("click", () => modalListingDetail.close());

newListingBtn.addEventListener("click", () => {
  if (!currentPosition) requestLocation();
  listingTitle.value = "";
  listingCategory.value = "";
  listingDescription.value = "";
  listingPhoto.value = "";
  modalNewListing.showModal();
});

cancelNewListingBtn.addEventListener("click", () => modalNewListing.close());

function readFileAsDataURL(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result || ""));
    reader.onerror = () => resolve("");
    reader.readAsDataURL(file);
  });
}

newListingForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  if (!currentPosition) {
    updateStatus("Need location before posting.");
    await requestLocation();
    if (!currentPosition) return;
  }

  const title = listingTitle.value.trim();
  const category = listingCategory.value.trim() || "tool";
  const desc = listingDescription.value.trim();

  let photoDataUrl = "";
  const file = listingPhoto.files && listingPhoto.files[0];
  if (file) {
    // Keep simple: store as base64; suitable for quick demo.
    photoDataUrl = await readFileAsDataURL(file);
  }

  const listing = {
    id: uid("listing"),
    ownerId: state.profile.id,
    ownerName: state.profile.name,
    title,
    category,
    description: desc,
    photoDataUrl,
    lat: currentPosition.lat,
    lng: currentPosition.lng,
    status: "available",
    createdAt: nowISO()
  };

  state.listings.push(listing);
  saveState(state);
  modalNewListing.close();
  renderListings();
});

// --- Requests + Messages ---
sendRequestBtn.addEventListener("click", () => {
  const listingId = currentDetailListingId;
  if (!listingId) return;
  const l = state.listings.find((x) => x.id === listingId);
  if (!l) return;

  const note = (requestNote.value || "").trim();
  if (!note) {
    alert("Write a short note first.");
    return;
  }

  const req = {
    id: uid("req"),
    listingId: l.id,
    listingTitle: l.title,
    ownerId: l.ownerId,
    ownerName: l.ownerName || "Owner",
    borrowerId: state.profile.id,
    borrowerName: state.profile.name,
    status: "pending",
    createdAt: nowISO()
  };
  state.requests.push(req);
  state.messages.push({
    id: uid("msg"),
    requestId: req.id,
    senderId: state.profile.id,
    senderName: state.profile.name,
    text: note,
    createdAt: nowISO()
  });

  saveState(state);
  modalListingDetail.close();
  setTab("messages");
  renderRequests();
  openChat(req.id);
});

function renderRequests() {
  requestList.innerHTML = "";

  const mine = state.requests
    .filter((r) => r.borrowerId === state.profile.id || r.ownerId === state.profile.id)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

  requestEmpty.hidden = mine.length !== 0;

  mine.forEach((r) => {
    const item = document.createElement("div");
    item.className = "item";
    const role = r.borrowerId === state.profile.id ? "You requested" : "Someone requested";
    item.innerHTML = `
      <div class="row row--space">
        <div>
          <div class="item__title">${escapeHtml(r.listingTitle)}</div>
          <div class="muted">${escapeHtml(role)} • ${escapeHtml(r.status)}</div>
        </div>
        <button class="btn btn--primary" type="button">Open</button>
      </div>
    `;
    item.querySelector("button").addEventListener("click", () => openChat(r.id));
    requestList.appendChild(item);
  });
}

function openChat(requestId) {
  const r = state.requests.find((x) => x.id === requestId);
  if (!r) return;
  currentChatRequestId = requestId;

  chatTitle.textContent = `Chat: ${r.listingTitle}`;
  chatInput.value = "";
  renderChat();
  modalChat.showModal();
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function renderChat() {
  const msgs = state.messages
    .filter((m) => m.requestId === currentChatRequestId)
    .sort((a, b) => a.createdAt.localeCompare(b.createdAt));

  chatMessages.innerHTML = "";
  msgs.forEach((m) => {
    const bubble = document.createElement("div");
    const isMe = m.senderId === state.profile.id;
    bubble.className = `bubble ${isMe ? "bubble--me" : ""}`;
    bubble.innerHTML = `
      <div>${escapeHtml(m.text)}</div>
      <div class="bubble__meta">${escapeHtml(isMe ? "You" : (m.senderName || "Neighbour"))}</div>
    `;
    chatMessages.appendChild(bubble);
  });
}

function sendChatMessage() {
  const text = (chatInput.value || "").trim();
  if (!text || !currentChatRequestId) return;

  state.messages.push({
    id: uid("msg"),
    requestId: currentChatRequestId,
    senderId: state.profile.id,
    senderName: state.profile.name,
    text,
    createdAt: nowISO()
  });
  saveState(state);
  chatInput.value = "";
  renderChat();
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

chatSendBtn.addEventListener("click", sendChatMessage);
chatInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter") {
    e.preventDefault();
    sendChatMessage();
  }
});

// --- Profile ---
function loadProfileIntoForm() {
  profileName.value = state.profile.name || "Neighbour";
  profileStreet.value = state.profile.street || "";
}

saveProfileBtn.addEventListener("click", () => {
  const name = profileName.value.trim() || "Neighbour";
  const street = profileStreet.value.trim();
  state.profile.name = name;
  state.profile.street = street;
  saveState(state);
  alert("Saved.");
});

// --- Service worker registration ---
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./sw.js").catch(() => {});
  });
}

// --- Safety: escape for UI ---
function escapeHtml(str) {
  return String(str)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

// --- Boot ---
showInstallHintIfNeeded();
loadProfileIntoForm();
setTab("board");
renderListings();
renderRequests();
requestLocation();

