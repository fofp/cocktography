/**
 * Background service worker for Cocktography extension
 */

// Log installation
chrome.runtime.onInstalled.addListener((details) => {
    console.log('🍆 Cocktography extension installed!', details);

    // Set default settings
    chrome.storage.sync.set({
        enabled: true,
        autoDecode: true,
        strokes: 2,
        mode: 1, // THIN_CHODE
        cockblockSize: 340
    });
});

// Handle messages from content script if needed
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'ping') {
        sendResponse({ status: 'ok' });
    }
    return true;
});
