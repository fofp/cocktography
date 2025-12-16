/**
 * Background service worker for Cocktography extension
 */

// Firefox compatibility
const browserAPI = typeof browser !== 'undefined' ? browser : chrome;

// Log installation
browserAPI.runtime.onInstalled.addListener((details) => {
    console.log('🍆 Cocktography extension installed!', details);

    // Set default settings
    browserAPI.storage.sync.set({
        enabled: true,
        autoDecode: true,
        strokes: 2,
        mode: 1, // THIN_CHODE
        cockblockSize: 340
    });
});

// Handle messages from content script if needed
browserAPI.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'ping') {
        sendResponse({ status: 'ok' });
    }
    return true;
});
