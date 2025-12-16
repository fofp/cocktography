/**
 * Popup script for Cocktography settings
 */

// Load current settings
document.addEventListener('DOMContentLoaded', () => {
    chrome.storage.sync.get({
        enabled: true,
        autoDecode: true,
        strokes: 2,
        mode: 1,
        cockblockSize: 340
    }, (settings) => {
        document.getElementById('enabled').checked = settings.enabled;
        document.getElementById('autoDecode').checked = settings.autoDecode;
        document.getElementById('strokes').value = settings.strokes;
        document.getElementById('mode').value = settings.mode;
        document.getElementById('cockblockSize').value = settings.cockblockSize;
    });
});

// Save settings
document.getElementById('save').addEventListener('click', () => {
    const settings = {
        enabled: document.getElementById('enabled').checked,
        autoDecode: document.getElementById('autoDecode').checked,
        strokes: parseInt(document.getElementById('strokes').value),
        mode: parseInt(document.getElementById('mode').value),
        cockblockSize: parseInt(document.getElementById('cockblockSize').value)
    };

    chrome.storage.sync.set(settings, () => {
        // Show success message
        const status = document.getElementById('status');
        status.textContent = 'Settings saved successfully! 🍆';
        status.className = 'status success';

        setTimeout(() => {
            status.style.display = 'none';
        }, 2000);
    });
});
